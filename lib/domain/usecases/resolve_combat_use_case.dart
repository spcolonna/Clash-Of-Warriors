import 'dart:math';

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
  }) {
    // Ambos vacíos — nada ocurre
    if (playerCard == null && opponentCard == null) {
      return const SlotResult(
        slotIndex: 0,
        playerCard: null,
        opponentCard: null,
        playerDamageDealt: 0,
        opponentDamageDealt: 0,
        winner: 'tie',
        narrative: 'Ambos descansan.',
      );
    }

    // Slot vacío del jugador
    if (playerCard == null) {
      final dmg = _calcDamage(opponentCard!, opponentHero);
      return SlotResult(
        slotIndex: slotIndex,
        playerCard: null,
        opponentCard: opponentCard,
        playerDamageDealt: 0,
        opponentDamageDealt: dmg,
        winner: 'opponent',
        narrative: '${opponentCard.name} conecta sin resistencia.',
      );
    }

    // Slot vacío del oponente — evaluar bonus opponentRested
    if (opponentCard == null) {
      final conditionalMet = _isConditionalMet(
        bonus: playerCard.conditionalBonus,
        previousSlotResults: previousSlotResults,
        opponentRested: true,
        playerCurrentHp: playerCurrentHp,
        opponentCurrentHp: opponentCurrentHp,
        playerMaxHp: playerMaxHp,
      );
      final dmg = _calcDamage(playerCard, playerHero, conditionalMet: conditionalMet);
      return SlotResult(
        slotIndex: slotIndex,
        playerCard: playerCard,
        opponentCard: null,
        playerDamageDealt: dmg,
        opponentDamageDealt: 0,
        winner: 'player',
        conditionalBonusApplied: conditionalMet,
        narrative: '${playerCard.name} conecta sin resistencia.',
      );
    }

    // Ambos tienen carta — resolver choque
    final playerWins = beats(playerCard.category, opponentCard.category, mode: mode);
    final opponentWins = beats(opponentCard.category, playerCard.category, mode: mode);

    if (playerWins) {
      final conditionalMet = _isConditionalMet(
        bonus: playerCard.conditionalBonus,
        previousSlotResults: previousSlotResults,
        opponentRested: false,
        playerCurrentHp: playerCurrentHp,
        opponentCurrentHp: opponentCurrentHp,
        playerMaxHp: playerMaxHp,
      );
      final dmg = _calcDamage(playerCard, playerHero, conditionalMet: conditionalMet);
      return SlotResult(
        slotIndex: slotIndex,
        playerCard: playerCard,
        opponentCard: opponentCard,
        playerDamageDealt: dmg,
        opponentDamageDealt: 0,
        winner: 'player',
        conditionalBonusApplied: conditionalMet,
        narrative: '${playerCard.name} supera a ${opponentCard.name}.',
      );
    } else if (opponentWins) {
      final dmg = _calcDamage(opponentCard, opponentHero);
      return SlotResult(
        slotIndex: slotIndex,
        playerCard: playerCard,
        opponentCard: opponentCard,
        playerDamageDealt: 0,
        opponentDamageDealt: dmg,
        winner: 'opponent',
        narrative: '${opponentCard.name} supera a ${playerCard.name}.',
      );
    } else {
      // Empate — mismo tipo
      final playerDmg = _calcDamage(playerCard, playerHero, tieFactor: 0.5);
      final opponentDmg = _calcDamage(opponentCard, opponentHero, tieFactor: 0.5);
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

  static double _calcDamage(
    GameCard card,
    HeroEntity hero, {
    double tieFactor = 1.0,
    bool conditionalMet = false,
  }) {
    if (card.baseDamage == null) return 0;

    final stat = hero.stats.statFor(card.category);
    double dmg = card.baseDamage! * (stat / 10.0) * tieFactor;

    // Sinergia héroe-carta (+10%)
    if (card.heroId == hero.id) dmg *= 1.1;

    // Bonus condicional (reemplaza el dado: predecible y habilidad-dependiente)
    if (conditionalMet && card.conditionalBonus != null) {
      dmg *= _conditionalMultiplier(card.conditionalBonus!);
    }

    return dmg;
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
  }) {
    final slotResults = <SlotResult>[];
    double totalPlayerDamage = 0;
    double totalOpponentDamage = 0;

    for (int i = 0; i < 3; i++) {
      final playerCard = playerBlockedSlots.contains(i) ? null : player.plannedSequence[i];
      final opponentCard = opponentBlockedSlots.contains(i) ? null : opponent.plannedSequence[i];
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
      );
      slotResults.add(result);
      totalPlayerDamage += result.playerDamageDealt;
      totalOpponentDamage += result.opponentDamageDealt;
    }

    final playerHpAfter =
        (player.currentHp - totalOpponentDamage).ceil().clamp(0, player.hero.maxHp);
    final opponentHpAfter =
        (opponent.currentHp - totalPlayerDamage).ceil().clamp(0, opponent.hero.maxHp);

    return RoundResult(
      roundNumber: roundNumber,
      slotResults: slotResults,
      totalPlayerDamage: totalPlayerDamage,
      totalOpponentDamage: totalOpponentDamage,
      playerHpAfter: playerHpAfter,
      opponentHpAfter: opponentHpAfter,
    );
  }
}

/// IA del bot tutorial — predecible y siempre vencible
class TutorialBotAI {
  /// El bot juega una secuencia variada: mezcla de ataques y defensas.
  /// La variedad genera algún daño al jugador (20-40%) pero sin optimizar.
  /// No usa cartas especiales ni estrategia profunda.
  static List<GameCard?> decideSequence(List<GameCard> hand) {
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
    int availableStamina = 10;
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
  static const _counterChance = {
    BotDifficulty.easy:   0.0,   // puramente aleatorio
    BotDifficulty.normal: 0.35,  // 35% por slot
    BotDifficulty.hard:   0.70,  // 70% por slot
  };

  static List<GameCard?> decideSequence(
    List<GameCard> hand,
    HeroEntity botHero,
    BotDifficulty difficulty, {
    List<GameCard?> playerLastSequence = const [],
    GameMode mode = GameMode.expert,
  }) {
    final random = Random();

    // Copia mutable mezclada para no repetir cartas del mismo tipo referencia
    final workingHand = (mode == GameMode.normal
            ? hand.where((c) => _simpleCategories.contains(c.category)).toList()
            : List<GameCard>.from(hand))
        ..shuffle(random);

    final sequence = List<GameCard?>.filled(3, null);
    int stamina = botHero.maxStamina;
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
                c.staminaCost <= stamina &&
                CombatEngine.beats(c.category, playerCard.category, mode: mode))
            .firstOrNull;
      }

      // Fallback: cualquier carta aleatoria que entre en stamina
      if (picked == null) {
        final available = workingHand.where((c) => c.staminaCost <= stamina).toList();
        if (available.isNotEmpty) {
          picked = available[random.nextInt(available.length)];
        }
      }

      if (picked != null) {
        workingHand.remove(picked); // remove() elimina la primera ocurrencia
        sequence[i] = picked;
        stamina -= picked.staminaCost;
      }
    }

    return sequence;
  }
}
