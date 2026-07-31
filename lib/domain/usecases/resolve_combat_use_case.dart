import 'dart:math';

import '../config/game_config.dart';
import '../config/ring_events.dart';
import '../entities/battle_state.dart';
import '../entities/game_card.dart';
import '../entities/hero_entity.dart';


/// Tabla RPSLS de choques:
/// Punch    > Kick, Dodge
/// Kick     > Grapple, Defense
/// Grapple  > Punch, Dodge
/// Defense  > Punch, Grapple
/// Dodge    > Kick, Defense
class CombatEngine {
  static const _winTable = <CardCategory, List<CardCategory>>{
    CardCategory.punch:   [CardCategory.kick, CardCategory.dodge],
    CardCategory.kick:    [CardCategory.grapple, CardCategory.defense],
    CardCategory.grapple: [CardCategory.punch, CardCategory.dodge],
    CardCategory.defense: [CardCategory.punch, CardCategory.grapple],
    CardCategory.dodge:   [CardCategory.kick, CardCategory.defense],
  };

  // Modo Normal: Puño > Patada > Defensa > Puño (RPS)
  static const _simpleModeWinTable = <CardCategory, List<CardCategory>>{
    CardCategory.punch:   [CardCategory.kick],
    CardCategory.kick:    [CardCategory.defense],
    CardCategory.defense: [CardCategory.punch],
  };

  /// Determina si A vence a B según la tabla de choques.
  static bool beats(CardCategory a, CardCategory b, {GameMode mode = GameMode.expert}) {
    final table = mode == GameMode.normal ? _simpleModeWinTable : _winTable;
    return table[a]?.contains(b) ?? false;
  }

  /// True si la categoría participa del ruleset del modo. En Normal, Agarre y
  /// Esquive quedan fuera de la tabla: no son parte del RPS de 3, pero igual
  /// pueden llegar a la mano vía la carta pasiva (que no se filtra por modo).
  /// Una categoría fuera de tabla no tiene counter → conecta sin resistencia,
  /// que es justo lo que promete el lore de las pasivas.
  static bool categoryPlaysIn(CardCategory c, GameMode mode) =>
      mode == GameMode.normal ? _simpleModeWinTable.containsKey(c) : true;

  // ── Cadenas de combo ──────────────────────────────────────────────────
  // Puño → Patada → Agarre → Puño. Si ganaste el slot anterior con la
  // categoría que encadena en la actual, la carta actual pega +50%.
  static const chainMap = <CardCategory, CardCategory>{
    CardCategory.punch:   CardCategory.kick,
    CardCategory.kick:    CardCategory.grapple,
    CardCategory.grapple: CardCategory.punch,
  };

  /// True si [card] continúa una cadena para [side] ('player'/'opponent').
  static bool _chainMet(
    String side,
    GameCard card,
    List<SlotResult> previousSlotResults,
  ) {
    if (previousSlotResults.isEmpty) return false;
    final last = previousSlotResults.last;
    if (last.winner != side) return false;
    final lastCard = side == 'player' ? last.playerCard : last.opponentCard;
    if (lastCard == null) return false;
    return chainMap[lastCard.category] == card.category;
  }

  /// "Lectura": el perdedor de este slot ([loserSide]) repitió la misma
  /// categoría que en el slot inmediatamente anterior, y el ganador la
  /// counteró → el ganador cobra daño ×readMultiplier. Castiga repetir.
  static bool _readMet(
    String loserSide,
    CardCategory loserCategory,
    List<SlotResult> previousSlotResults,
  ) {
    if (previousSlotResults.isEmpty) return false;
    final last = previousSlotResults.last;
    final lastLoserCard =
        loserSide == 'player' ? last.playerCard : last.opponentCard;
    if (lastLoserCard == null) return false;
    return lastLoserCard.category == loserCategory;
  }

  /// Evalúa si el bonus condicional de una carta se cumple en este slot.
  static bool _isConditionalMet({
    required ConditionalBonus? bonus,
    required List<SlotResult> previousSlotResults,
    required bool opponentRested,
    required int playerCurrentHp,
    required int opponentCurrentHp,
    required int playerMaxHp,
  }) {
    if (bonus == null) return false;
    return switch (bonus) {
      ConditionalBonus.wonPreviousSlot =>
        previousSlotResults.isNotEmpty &&
        previousSlotResults.last.winner == 'player',
      ConditionalBonus.opponentRested => opponentRested,
      ConditionalBonus.playerAhead   => playerCurrentHp > opponentCurrentHp,
      ConditionalBonus.lowHp         =>
        playerCurrentHp <= (playerMaxHp * 0.4).round(),
    };
  }

  /// Multiplicador de daño cuando el bonus condicional se cumple.
  static double _conditionalMultiplier(ConditionalBonus bonus) => switch (bonus) {
    ConditionalBonus.wonPreviousSlot => 1.5,
    ConditionalBonus.opponentRested  => 1.3,
    ConditionalBonus.playerAhead     => 1.5,
    ConditionalBonus.lowHp           => 1.4,
  };

  /// Resuelve un slot individual y retorna el resultado.
  /// [playerWeakenPct]/[opponentWeakenPct] (0..100): reducen el daño de ese
  /// lado (efecto `weaken`). El efecto `pierce` en la carta ganadora ignora
  /// la mitigación de Defensa del rival.
  static SlotResult resolveSlot({
    required int slotIndex,
    required GameCard? playerCard,
    required GameCard? opponentCard,
    required HeroEntity playerHero,
    required HeroEntity opponentHero,
    GameMode mode = GameMode.expert,
    List<SlotResult> previousSlotResults = const [],
    int playerCurrentHp = 0,
    int opponentCurrentHp = 0,
    int playerMaxHp = 1,
    int playerWeakenPct = 0,
    int opponentWeakenPct = 0,
    RingEventRule? ringRule,
  }) {
    // Ambos vacíos — nada ocurre
    if (playerCard == null && opponentCard == null) {
      return SlotResult(
        // Antes iba 0 fijo: los slots 1 y 2 vacíos se buscaban por slotIndex
        // en la UI y devolvían el resultado del slot 0 (o ninguno).
        slotIndex: slotIndex,
        playerCard: null,
        opponentCard: null,
        playerDamageDealt: 0,
        opponentDamageDealt: 0,
        winner: 'tie',
        narrative: 'Ambos descansan.',
      );
    }

    // Slot vacío del jugador — el oponente conecta (con cadena si aplica)
    if (playerCard == null) {
      final chainMet = _chainMet('opponent', opponentCard!, previousSlotResults);
      final dmg = _calcDamage(opponentCard, opponentHero,
          chainMet: chainMet, weakenPct: opponentWeakenPct, ringRule: ringRule);
      final (affinityBy, rivalBy) =
          _affinityFlags('opponent', opponentCard, opponentHero);
      return SlotResult(
        slotIndex: slotIndex,
        playerCard: null,
        opponentCard: opponentCard,
        playerDamageDealt: 0,
        opponentDamageDealt: dmg,
        winner: 'opponent',
        chainBonusBy: chainMet ? 'opponent' : null,
        affinityBy: affinityBy,
        rivalBy: rivalBy,
        narrative: '${opponentCard.name} conecta sin resistencia.',
      );
    }

    // Slot vacío del oponente — evaluar bonus opponentRested + cadena
    if (opponentCard == null) {
      final conditionalMet = _isConditionalMet(
        bonus: playerCard.conditionalBonus,
        previousSlotResults: previousSlotResults,
        opponentRested: true,
        playerCurrentHp: playerCurrentHp,
        opponentCurrentHp: opponentCurrentHp,
        playerMaxHp: playerMaxHp,
      );
      final chainMet = _chainMet('player', playerCard, previousSlotResults);
      final dmg = _calcDamage(playerCard, playerHero,
          conditionalMet: conditionalMet, chainMet: chainMet,
          weakenPct: playerWeakenPct, ringRule: ringRule);
      final (affinityBy, rivalBy) =
          _affinityFlags('player', playerCard, playerHero);
      return SlotResult(
        slotIndex: slotIndex,
        playerCard: playerCard,
        opponentCard: null,
        playerDamageDealt: dmg,
        opponentDamageDealt: 0,
        winner: 'player',
        conditionalBonusApplied: conditionalMet,
        chainBonusBy: chainMet ? 'player' : null,
        affinityBy: affinityBy,
        rivalBy: rivalBy,
        narrative: '${playerCard.name} conecta sin resistencia.',
      );
    }

    // Ambos tienen carta — resolver choque
    var playerWins = beats(playerCard.category, opponentCard.category, mode: mode);
    var opponentWins = beats(opponentCard.category, playerCard.category, mode: mode);

    // Categoría fuera del ruleset del modo (Agarre/Esquive en Normal, que solo
    // llegan por la pasiva): no tiene counter, así que gana el slot en vez de
    // caer en el empate — antes ambos lados se hacían daño sin motivo claro.
    if (!playerWins && !opponentWins) {
      final playerInMode = categoryPlaysIn(playerCard.category, mode);
      final opponentInMode = categoryPlaysIn(opponentCard.category, mode);
      if (playerInMode != opponentInMode) {
        playerWins = !playerInMode;
        opponentWins = !opponentInMode;
      }
    }

    if (playerWins) {
      final conditionalMet = _isConditionalMet(
        bonus: playerCard.conditionalBonus,
        previousSlotResults: previousSlotResults,
        opponentRested: false,
        playerCurrentHp: playerCurrentHp,
        opponentCurrentHp: opponentCurrentHp,
        playerMaxHp: playerMaxHp,
      );
      final chainMet = _chainMet('player', playerCard, previousSlotResults);
      var dmg = _calcDamage(playerCard, playerHero,
          conditionalMet: conditionalMet, chainMet: chainMet,
          weakenPct: playerWeakenPct, ringRule: ringRule);
      // Defensa que pierde igual bloquea parte del golpe, salvo que la carta
      // ganadora tenga el efecto `pierce` (ignora la mitigación).
      final mitigated = opponentCard.category == CardCategory.defense &&
          playerCard.effect != CardEffect.pierce;
      if (mitigated) dmg *= _mitigationFactor(ringRule);
      // Lectura: el rival repitió categoría y lo counteraste → ×readMultiplier
      final read =
          _readMet('opponent', opponentCard.category, previousSlotResults);
      if (read) dmg *= GameConfig.readMultiplier;
      final (affinityBy, rivalBy) =
          _affinityFlags('player', playerCard, playerHero);
      return SlotResult(
        slotIndex: slotIndex,
        playerCard: playerCard,
        opponentCard: opponentCard,
        playerDamageDealt: dmg,
        opponentDamageDealt: 0,
        winner: 'player',
        conditionalBonusApplied: conditionalMet,
        chainBonusBy: chainMet ? 'player' : null,
        mitigatedBy: mitigated ? 'opponent' : null,
        affinityBy: affinityBy,
        rivalBy: rivalBy,
        readBy: read ? 'player' : null,
        narrative: mitigated
            ? '${opponentCard.name} amortigua el golpe de ${playerCard.name}.'
            : '${playerCard.name} supera a ${opponentCard.name}.',
      );
    } else if (opponentWins) {
      final chainMet = _chainMet('opponent', opponentCard, previousSlotResults);
      var dmg = _calcDamage(opponentCard, opponentHero,
          chainMet: chainMet, weakenPct: opponentWeakenPct, ringRule: ringRule);
      final mitigated = playerCard.category == CardCategory.defense &&
          opponentCard.effect != CardEffect.pierce;
      if (mitigated) dmg *= _mitigationFactor(ringRule);
      final read =
          _readMet('player', playerCard.category, previousSlotResults);
      if (read) dmg *= GameConfig.readMultiplier;
      final (affinityBy, rivalBy) =
          _affinityFlags('opponent', opponentCard, opponentHero);
      return SlotResult(
        slotIndex: slotIndex,
        playerCard: playerCard,
        opponentCard: opponentCard,
        playerDamageDealt: 0,
        opponentDamageDealt: dmg,
        winner: 'opponent',
        chainBonusBy: chainMet ? 'opponent' : null,
        mitigatedBy: mitigated ? 'player' : null,
        affinityBy: affinityBy,
        rivalBy: rivalBy,
        readBy: read ? 'opponent' : null,
        narrative: mitigated
            ? '${playerCard.name} amortigua el golpe de ${opponentCard.name}.'
            : '${opponentCard.name} supera a ${playerCard.name}.',
      );
    } else {
      // Empate — mismo tipo
      final playerDmg = _calcDamage(playerCard, playerHero,
          tieFactor: 0.5, weakenPct: playerWeakenPct, ringRule: ringRule);
      final opponentDmg = _calcDamage(opponentCard, opponentHero,
          tieFactor: 0.5, weakenPct: opponentWeakenPct, ringRule: ringRule);
      return SlotResult(
        slotIndex: slotIndex,
        playerCard: playerCard,
        opponentCard: opponentCard,
        playerDamageDealt: playerDmg,
        opponentDamageDealt: opponentDmg,
        winner: 'tie',
        narrative: '${playerCard.name} empata con ${opponentCard.name}.',
      );
    }
  }

  /// Factor de mitigación de Defensa, más débil bajo "Lluvia de Botellas".
  static double _mitigationFactor(RingEventRule? ringRule) =>
      ringRule == RingEventRule.weakDefenses
          ? GameConfig.weakDefenseMitigation
          : GameConfig.defenseMitigation;

  static double _calcDamage(
    GameCard card,
    HeroEntity hero, {
    double tieFactor = 1.0,
    bool conditionalMet = false,
    bool chainMet = false,
    int weakenPct = 0,
    RingEventRule? ringRule,
  }) {
    if (card.baseDamage == null) return 0;

    final stat = hero.stats.statFor(card.category);
    double dmg =
        card.baseDamage! * (stat / 10.0) * tieFactor * GameConfig.damageScale;

    // Debilitado (efecto weaken del rival): −weakenPct% de daño.
    if (weakenPct > 0) dmg *= (1 - weakenPct / 100).clamp(0.0, 1.0);

    // "Público Enfervorizado": los Puños pegan más fuerte.
    if (ringRule == RingEventRule.punchPriority &&
        card.category == CardCategory.punch) {
      dmg *= GameConfig.ringPunchBonus;
    }

    // Sinergia héroe-carta (+10%)
    if (card.heroId == hero.id) dmg *= 1.1;

    // Afinidad de facción: +20% si la carta es de tu facción, −20% si es de
    // una facción rival. Neutral → sin cambio. (Stackea con la sinergia de la
    // pasiva propia, que es coherente: la pasiva también es de tu facción.)
    switch (factionAffinityFor(hero.faction, card.factionId)) {
      case FactionAffinity.affinity:
        dmg *= GameConfig.factionAffinityMultiplier;
      case FactionAffinity.rival:
        dmg *= GameConfig.factionRivalMultiplier;
      case FactionAffinity.none:
        break;
    }

    // Bonus condicional (reemplaza el dado: predecible y habilidad-dependiente)
    if (conditionalMet && card.conditionalBonus != null) {
      dmg *= _conditionalMultiplier(card.conditionalBonus!);
    }

    // Cadena de combo (Puño→Patada→Agarre→Puño ganando el slot anterior)
    if (chainMet) dmg *= GameConfig.chainBonusMultiplier;

    return dmg;
  }

  /// Flags de afinidad para el SlotResult: el combatante [side] jugó [card].
  /// Retorna (affinityBy, rivalBy) con [side] o null según corresponda.
  static (String?, String?) _affinityFlags(
      String side, GameCard card, HeroEntity hero) {
    return switch (factionAffinityFor(hero.faction, card.factionId)) {
      FactionAffinity.affinity => (side, null),
      FactionAffinity.rival => (null, side),
      FactionAffinity.none => (null, null),
    };
  }

  /// Resuelve un round completo: retorna todos los SlotResults y los HP finales.
  /// [playerBlockedSlots] / [opponentBlockedSlots]: índices de slots bloqueados
  /// por StatusEffect — ese combatante actúa como si no tuviera carta en ese slot.
  static RoundResult resolveRound({
    required int roundNumber,
    required CombatantState player,
    required CombatantState opponent,
    List<int> playerBlockedSlots = const [],
    List<int> opponentBlockedSlots = const [],
    GameMode mode = GameMode.expert,
    RingEventRule? ringRule,
    Random? rng,
  }) {
    final random = rng ?? Random();
    final slotResults = <SlotResult>[];
    double totalPlayerDamage = 0;
    double totalOpponentDamage = 0;

    // Efecto weaken activo (−% daño) de cada lado, sumando StatusEffects.
    int weaken(CombatantState c) => c.statusEffects
        .where((e) => e.type == StatusEffectType.weakened)
        .fold(0, (sum, e) => sum + e.value);
    final playerWeakenPct = weaken(player);
    final opponentWeakenPct = weaken(opponent);

    // Efecto denyDefense: si el combatante lo tiene, sus cartas de Defensa
    // de este round se anulan (actúa como slot vacío en esos slots).
    final playerDefenseDenied = player.statusEffects
        .any((e) => e.type == StatusEffectType.defenseDenied);
    final opponentDefenseDenied = opponent.statusEffects
        .any((e) => e.type == StatusEffectType.defenseDenied);

    // Evento de ring que anula cartas por chance (afecta a ambos lados).
    bool ringFails(GameCard? c) {
      if (c == null) return false;
      if (ringRule == RingEventRule.kicksMayFail &&
          c.category == CardCategory.kick) {
        return random.nextDouble() < GameConfig.ringKickFailChance;
      }
      if (ringRule == RingEventRule.dodgesMayFail &&
          c.category == CardCategory.dodge) {
        return random.nextDouble() < GameConfig.ringDodgeFailChance;
      }
      return false;
    }

    for (int i = 0; i < 3; i++) {
      var playerCard = playerBlockedSlots.contains(i) ? null : player.plannedSequence[i];
      var opponentCard = opponentBlockedSlots.contains(i) ? null : opponent.plannedSequence[i];
      if (playerDefenseDenied && playerCard?.category == CardCategory.defense) {
        playerCard = null;
      }
      if (opponentDefenseDenied && opponentCard?.category == CardCategory.defense) {
        opponentCard = null;
      }
      if (ringFails(playerCard)) playerCard = null;
      if (ringFails(opponentCard)) opponentCard = null;
      final result = resolveSlot(
        slotIndex: i,
        playerCard: playerCard,
        opponentCard: opponentCard,
        playerHero: player.hero,
        opponentHero: opponent.hero,
        mode: mode,
        previousSlotResults: slotResults,
        playerCurrentHp: player.currentHp,
        opponentCurrentHp: opponent.currentHp,
        playerMaxHp: player.hero.maxHp,
        playerWeakenPct: playerWeakenPct,
        opponentWeakenPct: opponentWeakenPct,
        ringRule: ringRule,
      );
      slotResults.add(result);
      totalPlayerDamage += result.playerDamageDealt;
      totalOpponentDamage += result.opponentDamageDealt;
    }

    // Ronda perfecta: ganar los 3 slots otorga daño extra (se aplica al
    // cerrar el round, con su propio banner en la UI).
    final playerPerfect =
        slotResults.every((s) => s.winner == 'player') && totalPlayerDamage > 0;
    final opponentPerfect =
        slotResults.every((s) => s.winner == 'opponent') &&
            totalOpponentDamage > 0;
    final playerPerfectBonus = playerPerfect
        ? (totalPlayerDamage * GameConfig.perfectRoundBonus).ceil()
        : 0;
    final opponentPerfectBonus = opponentPerfect
        ? (totalOpponentDamage * GameConfig.perfectRoundBonus).ceil()
        : 0;

    // Combos posicionales sobre la secuencia de 3 (se aplican al cerrar el
    // round, igual que el bonus de ronda perfecta).
    final playerCombo = _detectCombo('player', slotResults, player.hero.maxHp);
    final opponentCombo =
        _detectCombo('opponent', slotResults, opponent.hero.maxHp);

    final playerHpAfter = (player.currentHp -
            totalOpponentDamage -
            opponentPerfectBonus -
            opponentCombo.damage +
            playerCombo.heal)
        .ceil()
        .clamp(0, player.hero.maxHp);
    final opponentHpAfter = (opponent.currentHp -
            totalPlayerDamage -
            playerPerfectBonus -
            playerCombo.damage +
            opponentCombo.heal)
        .ceil()
        .clamp(0, opponent.hero.maxHp);

    return RoundResult(
      roundNumber: roundNumber,
      slotResults: slotResults,
      totalPlayerDamage: totalPlayerDamage,
      totalOpponentDamage: totalOpponentDamage,
      playerHpAfter: playerHpAfter,
      opponentHpAfter: opponentHpAfter,
      playerPerfectBonus: playerPerfectBonus,
      opponentPerfectBonus: opponentPerfectBonus,
      playerComboName: playerCombo.name,
      opponentComboName: opponentCombo.name,
      playerComboDamage: playerCombo.damage,
      opponentComboDamage: opponentCombo.damage,
      playerComboHeal: playerCombo.heal,
      opponentComboHeal: opponentCombo.heal,
    );
  }

  /// Detecta el combo posicional del lado [side] sobre los 3 slots resueltos.
  /// Devuelve (name, damage extra, heal). Solo un combo por lado (prioridad:
  /// Tortuga defensiva > One-Two > Agarrar y Golpear).
  static ({String? name, int damage, int heal}) _detectCombo(
    String side,
    List<SlotResult> slots,
    int maxHp,
  ) {
    GameCard? card(int i) =>
        side == 'player' ? slots[i].playerCard : slots[i].opponentCard;
    double dmgAt(int i) =>
        side == 'player' ? slots[i].playerDamageDealt : slots[i].opponentDamageDealt;
    bool wonAt(int i) => slots[i].winner == side;

    final c0 = card(0), c1 = card(1), c2 = card(2);

    // Tortuga: las 3 cartas son Defensa → cura % del HP máx.
    if (c0?.category == CardCategory.defense &&
        c1?.category == CardCategory.defense &&
        c2?.category == CardCategory.defense) {
      final heal = (maxHp * GameConfig.comboTortugaHealPct).ceil();
      return (name: 'Tortuga', damage: 0, heal: heal);
    }

    // One-Two: Puño en slot 0 y slot 1, GANANDO el segundo → +% a su daño.
    // Exigir la victoria (y no solo que haya hecho daño) lo alinea con
    // "Agarrar y Golpear": antes un empate en el slot 1 alcanzaba para
    // disparar el combo, lo que sumaba daño difícil de explicar.
    if (c0?.category == CardCategory.punch &&
        c1?.category == CardCategory.punch &&
        wonAt(1)) {
      final bonus = (dmgAt(1) * GameConfig.comboOneTwoBonus).ceil();
      if (bonus > 0) return (name: 'One-Two', damage: bonus, heal: 0);
    }

    // Agarrar y Golpear: Agarre ganado seguido de Puño → el Puño castiga más
    // fuerte (aprox. de "ignora la mitigación": +% a su daño).
    for (int i = 0; i < 2; i++) {
      if (card(i)?.category == CardCategory.grapple &&
          wonAt(i) &&
          card(i + 1)?.category == CardCategory.punch) {
        final bonus = (dmgAt(i + 1) * GameConfig.comboOneTwoBonus).ceil();
        if (bonus > 0) {
          return (name: 'Agarrar y Golpear', damage: bonus, heal: 0);
        }
      }
    }

    return (name: null, damage: 0, heal: 0);
  }
}

/// IA del bot tutorial — predecible y siempre vencible
class TutorialBotAI {
  /// El bot juega una secuencia variada: mezcla de ataques y defensas.
  /// La variedad genera algún daño al jugador (20-40%) pero sin optimizar.
  /// No usa cartas especiales ni estrategia profunda.
  static List<GameCard?> decideSequence(List<GameCard> hand, {int stamina = 10}) {
    final sequence = List<GameCard?>.filled(3, null);

    // Separar cartas por tipo para variar la secuencia
    final attacks = hand.where((c) =>
    c.category == CardCategory.punch ||
        c.category == CardCategory.kick ||
        c.category == CardCategory.grapple
    ).toList();

    final defenses = hand.where((c) =>
    c.category == CardCategory.defense ||
        c.category == CardCategory.dodge
    ).toList();

    // Patrón: 1-2 ataques + 1 defensa + 1 vacío
    // Mezcla entre tipos de ataque para no ser predecible
    int availableStamina = stamina;
    int slotIndex = 0;

    // Slot 1: atacar con cartas baratas
    for (final atk in attacks) {
      if (slotIndex >= 2) break;
      if (atk.staminaCost > availableStamina) continue;
      sequence[slotIndex] = atk;
      availableStamina -= atk.staminaCost;
      slotIndex++;
    }

    // Slot 2: meter una defensa si hay stamina
    if (slotIndex < 2 && defenses.isNotEmpty) {
      final def = defenses.firstWhere(
            (d) => d.staminaCost <= availableStamina,
        orElse: () => defenses.first,
      );
      if (def.staminaCost <= availableStamina) {
        sequence[slotIndex] = def;
        availableStamina -= def.staminaCost;
      }
    }

    // La apertura (slot 0) nunca debe quedar vacía: el coach del tutorial le
    // dice al jugador "ya ves la apertura del rival" apuntando a este slot, y
    // con poca stamina en la ronda 1 los bucles de arriba pueden no ubicar
    // ninguna carta ahí. Forzar la más barata que entre en la stamina total.
    if (sequence[0] == null) {
      final affordable = hand.where((c) => c.staminaCost <= stamina).toList()
        ..sort((a, b) => a.staminaCost.compareTo(b.staminaCost));
      if (affordable.isNotEmpty) sequence[0] = affordable.first;
    }

    // Slot 3 siempre vacío (el bot "descansa")
    return sequence;
  }

  /// HP reducido para que pierda en 2-3 rounds
  static int get tutorialBotHp => 50;
  static int get tutorialBotStamina => 10;
}

// ─────────────────────────────────────────────────────────────────────────────
// IA escalable para batallas de arena
// ─────────────────────────────────────────────────────────────────────────────

class BotAI {
  static const _simpleCategories = {
    CardCategory.punch,
    CardCategory.kick,
    CardCategory.defense,
  };

  // Por dificultad: probabilidad (0.0–1.0) de que el bot intente jugar
  // la carta que gana contra lo que el jugador puso en ese slot la ronda anterior.
  // Ronda 1 siempre es aleatoria (no hay secuencia previa del jugador).
  // Valores subidos para compensar que la apertura del bot ahora es visible.
  static const _counterChance = {
    BotDifficulty.easy:   0.0,   // puramente aleatorio
    BotDifficulty.normal: 0.45,  // 45% por slot
    BotDifficulty.hard:   0.80,  // 80% por slot
  };

  static List<GameCard?> decideSequence(
    List<GameCard> hand,
    HeroEntity botHero,
    BotDifficulty difficulty, {
    List<GameCard?> playerLastSequence = const [],
    GameMode mode = GameMode.expert,
    int? stamina,
  }) {
    final random = Random();

    // Copia mutable mezclada para no repetir cartas del mismo tipo referencia
    final workingHand = (mode == GameMode.normal
            ? hand.where((c) => _simpleCategories.contains(c.category)).toList()
            : List<GameCard>.from(hand))
        ..shuffle(random);

    final sequence = List<GameCard?>.filled(3, null);
    final counterPick = List<bool>.filled(3, false);
    int remaining = stamina ?? botHero.maxStamina;
    final chance = _counterChance[difficulty] ?? 0.0;

    for (int i = 0; i < 3; i++) {
      GameCard? picked;

      // Intentar contra-lectura según dificultad
      if (chance > 0 &&
          i < playerLastSequence.length &&
          playerLastSequence[i] != null &&
          random.nextDouble() < chance) {
        final playerCard = playerLastSequence[i]!;
        picked = workingHand
            .where((c) =>
                c.staminaCost <= remaining &&
                CombatEngine.beats(c.category, playerCard.category, mode: mode))
            .firstOrNull;
        if (picked != null) counterPick[i] = true;
      }

      // Fallback: carta que entre en stamina.
      // Hard elige la de mayor daño efectivo; el resto, aleatoria.
      if (picked == null) {
        final available = workingHand.where((c) => c.staminaCost <= remaining).toList();
        if (available.isNotEmpty) {
          picked = difficulty == BotDifficulty.hard
              ? available.reduce((a, b) =>
                  botHero.effectiveDamage(a) >= botHero.effectiveDamage(b)
                      ? a
                      : b)
              : available[random.nextInt(available.length)];
        }
      }

      if (picked != null) {
        workingHand.remove(picked); // remove() elimina la primera ocurrencia
        sequence[i] = picked;
        remaining -= picked.staminaCost;
      }
    }

    // La apertura (slot 1) es visible para el jugador: normal/hard evitan
    // exponer su mejor carta y mueven la más débil de la secuencia al slot 0
    // (salvo que el slot 0 sea una contra-lectura deliberada).
    if (difficulty != BotDifficulty.easy && !counterPick[0] && sequence[0] != null) {
      int weakest = 0;
      for (int j = 1; j < 3; j++) {
        if (counterPick[j] || sequence[j] == null) continue;
        if (botHero.effectiveDamage(sequence[j]!) <
            botHero.effectiveDamage(sequence[weakest]!)) {
          weakest = j;
        }
      }
      if (weakest != 0) {
        final tmp = sequence[0];
        sequence[0] = sequence[weakest];
        sequence[weakest] = tmp;
      }
    }

    return sequence;
  }
}
