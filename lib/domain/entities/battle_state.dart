// lib/domain/entities/battle_state.dart

import 'game_card.dart';
import 'hero_entity.dart';

enum BattlePhase { planning, resolving, roundEnd, battleEnd }

enum BotDifficulty { easy, normal, hard }

enum GameMode { normal, expert }

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
  // Carta conservada entre rondas (elegida por el jugador al final del round).
  final GameCard? heldCard;

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
    this.heldCard,
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
    GameCard? heldCard,
    bool clearHeld = false,
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
        heldCard: clearHeld ? null : (heldCard ?? this.heldCard),
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
  final bool conditionalBonusApplied;
  // 'player' | 'opponent' | null — quién ganó con bonus de cadena de combo
  final String? chainBonusBy;
  // 'player' | 'opponent' | null — quién mitigó daño perdiendo con Defensa
  final String? mitigatedBy;
  final String narrative;

  const SlotResult({
    required this.slotIndex,
    required this.playerCard,
    required this.opponentCard,
    required this.playerDamageDealt,
    required this.opponentDamageDealt,
    required this.winner,
    this.conditionalBonusApplied = false,
    this.chainBonusBy,
    this.mitigatedBy,
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
  // Ronda perfecta: ganó los 3 slots → daño extra aplicado al final del round.
  final int playerPerfectBonus;
  final int opponentPerfectBonus;

  const RoundResult({
    required this.roundNumber,
    required this.slotResults,
    required this.totalPlayerDamage,
    required this.totalOpponentDamage,
    required this.playerHpAfter,
    required this.opponentHpAfter,
    this.playerPerfectBonus = 0,
    this.opponentPerfectBonus = 0,
  });
}

class BattleState {
  final BattlePhase phase;
  final CombatantState player;
  final CombatantState opponent;
  final int currentRound;
  final List<RoundResult> roundHistory;
  final bool? playerWon; // null = en curso
  final bool isTutorial; // false = batalla de arena con bot IA escalable
  final bool isStoryBattle; // true = batalla del modo historia
  final BotDifficulty? botDifficulty; // null = tutorial
  final GameMode gameMode;
  final bool passiveJustUnlocked; // true solo el round en que se inyecta la pasiva

  // ── Scout mechanic ────────────────────────────────────────────────────────
  // 3 tokens por batalla (no se recargan entre rondas).
  final int scoutTokensRemaining;
  // Slots del oponente revelados esta ronda (se limpia al iniciar cada ronda).
  final Map<int, GameCard> revealedOpponentSlots;

  const BattleState({
    required this.phase,
    required this.player,
    required this.opponent,
    this.currentRound = 1,
    this.roundHistory = const [],
    this.playerWon,
    this.isTutorial = true,
    this.isStoryBattle = false,
    this.botDifficulty,
    this.gameMode = GameMode.expert,
    this.passiveJustUnlocked = false,
    this.scoutTokensRemaining = 3,
    this.revealedOpponentSlots = const {},
  });

  bool get isBattleOver => playerWon != null;

  BattleState copyWith({
    BattlePhase? phase,
    CombatantState? player,
    CombatantState? opponent,
    int? currentRound,
    List<RoundResult>? roundHistory,
    bool? playerWon,
    bool? isTutorial,
    bool? isStoryBattle,
    BotDifficulty? botDifficulty,
    GameMode? gameMode,
    bool? passiveJustUnlocked,
    int? scoutTokensRemaining,
    Map<int, GameCard>? revealedOpponentSlots,
  }) =>
      BattleState(
        phase: phase ?? this.phase,
        player: player ?? this.player,
        opponent: opponent ?? this.opponent,
        currentRound: currentRound ?? this.currentRound,
        roundHistory: roundHistory ?? this.roundHistory,
        playerWon: playerWon ?? this.playerWon,
        isTutorial: isTutorial ?? this.isTutorial,
        isStoryBattle: isStoryBattle ?? this.isStoryBattle,
        botDifficulty: botDifficulty ?? this.botDifficulty,
        gameMode: gameMode ?? this.gameMode,
        passiveJustUnlocked: passiveJustUnlocked ?? this.passiveJustUnlocked,
        scoutTokensRemaining: scoutTokensRemaining ?? this.scoutTokensRemaining,
        revealedOpponentSlots: revealedOpponentSlots ?? this.revealedOpponentSlots,
      );
}
