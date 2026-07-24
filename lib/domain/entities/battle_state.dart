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
  staminaBoost,
  slotBlocked,
  defenseDenied,  // el combatante no puede jugar Defensa esta ronda
  weakened,       // el combatante hace −[value]% daño esta ronda
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
  // 'player' | 'opponent' | null — quién pegó con bonus de afinidad de facción
  final String? affinityBy;
  // 'player' | 'opponent' | null — quién pegó nerfeado por facción rival
  final String? rivalBy;
  // 'player' | 'opponent' | null — quién "leyó" al rival (counteró una carta
  // repetida) y pegó con daño ×readMultiplier.
  final String? readBy;
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
    this.affinityBy,
    this.rivalBy,
    this.readBy,
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
  // Combos posicionales detectados sobre la secuencia de 3 (null si ninguno).
  final String? playerComboName;
  final String? opponentComboName;
  // Daño extra de combo (One-Two / Agarrar y Golpear), aplicado al cerrar el
  // round igual que el bonus de ronda perfecta.
  final int playerComboDamage;
  final int opponentComboDamage;
  // Cura de combo (Tortuga) aplicada al cerrar el round.
  final int playerComboHeal;
  final int opponentComboHeal;

  const RoundResult({
    required this.roundNumber,
    required this.slotResults,
    required this.totalPlayerDamage,
    required this.totalOpponentDamage,
    required this.playerHpAfter,
    required this.opponentHpAfter,
    this.playerPerfectBonus = 0,
    this.opponentPerfectBonus = 0,
    this.playerComboName,
    this.opponentComboName,
    this.playerComboDamage = 0,
    this.opponentComboDamage = 0,
    this.playerComboHeal = 0,
    this.opponentComboHeal = 0,
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

  // Evento de ring activo esta ronda (id de RingEvents), null si ninguno.
  final String? activeRingEvent;

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
    this.activeRingEvent,
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
    // Sentinela: permite poner activeRingEvent en null explícitamente (rondas
    // sin evento) sin que el `?? this` lo preserve por error.
    Object? activeRingEvent = _noChange,
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
        activeRingEvent: identical(activeRingEvent, _noChange)
            ? this.activeRingEvent
            : activeRingEvent as String?,
      );

  static const Object _noChange = Object();
}
