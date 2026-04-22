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

  /// Determina si A vence a B según la tabla de choques.
  static bool beats(CardCategory a, CardCategory b) =>
      _winTable[a]?.contains(b) ?? false;

  /// Resuelve un slot individual y retorna el resultado.
  static SlotResult resolveSlot({
    required int slotIndex,
    required GameCard? playerCard,
    required GameCard? opponentCard,
    required HeroEntity playerHero,
    required HeroEntity opponentHero,
  }) {
    // Ambos vacíos — nada ocurre
    if (playerCard == null && opponentCard == null) {
      return SlotResult(
        slotIndex: slotIndex,
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

    // Slot vacío del oponente
    if (opponentCard == null) {
      final dmg = _calcDamage(playerCard, playerHero);
      return SlotResult(
        slotIndex: slotIndex,
        playerCard: playerCard,
        opponentCard: null,
        playerDamageDealt: dmg,
        opponentDamageDealt: 0,
        winner: 'player',
        narrative: '${playerCard.name} conecta sin resistencia.',
      );
    }

    // Ambos tienen carta — resolver choque
    int? diceRoll;
    if (playerCard.requiresDice) {
      diceRoll = Random().nextInt(6) + 1;
    }

    final playerWins = beats(playerCard.category, opponentCard.category);
    final opponentWins = beats(opponentCard.category, playerCard.category);

    if (playerWins) {
      final dmg = _calcDamage(playerCard, playerHero, diceRoll: diceRoll);
      return SlotResult(
        slotIndex: slotIndex,
        playerCard: playerCard,
        opponentCard: opponentCard,
        playerDamageDealt: dmg,
        opponentDamageDealt: 0,
        winner: 'player',
        diceRoll: diceRoll,
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
    int? diceRoll,
    double tieFactor = 1.0,
  }) {
    if (card.category == CardCategory.defense) return 0;
    if (card.category == CardCategory.dodge) return 0;
    if (card.baseDamage == null) return 0;

    final stat = hero.stats.statFor(card.category);
    double dmg = card.baseDamage! * (stat / 10.0) * tieFactor;

    // Sinergia héroe-carta (+10%)
    if (card.heroId == hero.id) dmg *= 1.1;

    // Modificador de dado
    if (diceRoll != null) {
      final factor = switch (diceRoll) {
        1     => 0.0,
        2 || 3 => 0.5,
        4 || 5 => 1.0,
        6     => 1.5,
        _     => 1.0,
      };
      dmg *= factor;
    }

    return dmg;
  }

  /// Resuelve un round completo: retorna todos los SlotResults y los HP finales.
  static RoundResult resolveRound({
    required int roundNumber,
    required CombatantState player,
    required CombatantState opponent,
  }) {
    final slotResults = <SlotResult>[];
    double totalPlayerDamage = 0;
    double totalOpponentDamage = 0;

    for (int i = 0; i < 5; i++) {
      final result = resolveSlot(
        slotIndex: i,
        playerCard: player.plannedSequence[i],
        opponentCard: opponent.plannedSequence[i],
        playerHero: player.hero,
        opponentHero: opponent.hero,
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
    final sequence = List<GameCard?>.filled(5, null);

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

    // Patrón: 3 ataques + 1 defensa + 1 vacío
    // Mezcla entre tipos de ataque para no ser predecible
    int availableStamina = 10;
    int slotIndex = 0;

    // Slot 1 y 2: atacar con cartas baratas
    for (final atk in attacks) {
      if (slotIndex >= 4) break;
      if (atk.staminaCost > availableStamina) continue;
      sequence[slotIndex] = atk;
      availableStamina -= atk.staminaCost;
      slotIndex++;
    }

    // Slot 3 o 4: meter una defensa si hay stamina
    if (slotIndex < 4 && defenses.isNotEmpty) {
      final def = defenses.firstWhere(
            (d) => d.staminaCost <= availableStamina,
        orElse: () => defenses.first,
      );
      if (def.staminaCost <= availableStamina) {
        sequence[slotIndex] = def;
        availableStamina -= def.staminaCost;
      }
    }

    // Slot 5 siempre vacío (el bot "descansa")
    return sequence;
  }

  /// HP reducido para que pierda en 2-3 rounds
  static int get tutorialBotHp => 50;
  static int get tutorialBotStamina => 10;
}
