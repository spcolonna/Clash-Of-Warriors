// lib/domain/entities/battle_state.dart

import 'game_card.dart';
import 'hero_entity.dart';

enum BattlePhase { planning, resolving, roundEnd, battleEnd }

class CombatantState {
  final HeroEntity hero;
  final int currentHp;
  final int currentStamina;
  final List<GameCard> hand;
  final List<GameCard> deck;
  final List<GameCard> discardPile;
  final bool passiveUsed;
  final List<StatusEffect> statusEffects;
  // null = slot vacío
  final List<GameCard?> plannedSequence; // 3 slots

  const CombatantState({
    required this.hero,
    required this.currentHp,
    required this.currentStamina,
    required this.hand,
    required this.deck,
    required this.discardPile,
    this.passiveUsed = false,
    this.statusEffects = const [],
    this.plannedSequence = const [null, null, null],
  });

  bool get isAlive => currentHp > 0;
  int get usedStamina =>
      plannedSequence.whereType<GameCard>().fold(0, (s, c) => s + c.staminaCost);
  int get remainingStamina => currentStamina - usedStamina;

  CombatantState copyWith({
    int? currentHp,
    int? currentStamina,
    List<GameCard>? hand,
    List<GameCard>? deck,
    List<GameCard>? discardPile,
    bool? passiveUsed,
    List<StatusEffect>? statusEffects,
    List<GameCard?>? plannedSequence,
  }) =>
      CombatantState(
        hero: hero,
        currentHp: currentHp ?? this.currentHp,
        currentStamina: currentStamina ?? this.currentStamina,
        hand: hand ?? this.hand,
        deck: deck ?? this.deck,
        discardPile: discardPile ?? this.discardPile,
        passiveUsed: passiveUsed ?? this.passiveUsed,
        statusEffects: statusEffects ?? this.statusEffects,
        plannedSequence: plannedSequence ?? this.plannedSequence,
      );
}

class StatusEffect {
  final StatusEffectType type;
  final int value;
  final int roundsRemaining;

  const StatusEffect({
    required this.type,
    required this.value,
    required this.roundsRemaining,
  });

  StatusEffect tickDown() =>
      StatusEffect(type: type, value: value, roundsRemaining: roundsRemaining - 1);
}

enum StatusEffectType {
  continuousDamage,
  staminaReduction,
  slotBlocked,
}

class SlotResult {
  final int slotIndex;
  final GameCard? playerCard;
  final GameCard? opponentCard;
  final double playerDamageDealt;
  final double opponentDamageDealt;
  final String? winner; // 'player' | 'opponent' | 'tie' | 'empty'
  final int? diceRoll;
  final String narrative;

  const SlotResult({
    required this.slotIndex,
    required this.playerCard,
    required this.opponentCard,
    required this.playerDamageDealt,
    required this.opponentDamageDealt,
    required this.winner,
    this.diceRoll,
    required this.narrative,
  });
}

class RoundResult {
  final int roundNumber;
  final List<SlotResult> slotResults;
  final double totalPlayerDamage;
  final double totalOpponentDamage;
  final int playerHpAfter;
  final int opponentHpAfter;

  const RoundResult({
    required this.roundNumber,
    required this.slotResults,
    required this.totalPlayerDamage,
    required this.totalOpponentDamage,
    required this.playerHpAfter,
    required this.opponentHpAfter,
  });
}

class BattleState {
  final BattlePhase phase;
  final CombatantState player;
  final CombatantState opponent;
  final int currentRound;
  final List<RoundResult> roundHistory;
  final bool? playerWon; // null = en curso

  const BattleState({
    required this.phase,
    required this.player,
    required this.opponent,
    this.currentRound = 1,
    this.roundHistory = const [],
    this.playerWon,
  });

  bool get isBattleOver => playerWon != null;

  BattleState copyWith({
    BattlePhase? phase,
    CombatantState? player,
    CombatantState? opponent,
    int? currentRound,
    List<RoundResult>? roundHistory,
    bool? playerWon,
  }) =>
      BattleState(
        phase: phase ?? this.phase,
        player: player ?? this.player,
        opponent: opponent ?? this.opponent,
        currentRound: currentRound ?? this.currentRound,
        roundHistory: roundHistory ?? this.roundHistory,
        playerWon: playerWon ?? this.playerWon,
      );
}
