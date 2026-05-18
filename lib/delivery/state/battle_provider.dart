// lib/delivery/state/battle_provider.dart

import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/battle_state.dart';
import '../../domain/entities/game_card.dart';
import '../../domain/entities/hero_entity.dart';
import '../../domain/usecases/resolve_combat_use_case.dart';
import '../../infra/local/neutral_cards_data.dart';

export '../../domain/entities/battle_state.dart' show BotDifficulty;

final battleProvider = NotifierProvider<BattleNotifier, BattleState>(
  BattleNotifier.new,
);

class BattleNotifier extends Notifier<BattleState> {
  BotDifficulty? _botDifficulty; // null = tutorial

  @override
  BattleState build() => _emptyState();

  BattleState _emptyState() => const BattleState(
    phase: BattlePhase.planning,
    player: CombatantState(
      hero: HeroEntity(
        id: '',
        name: '',
        title: '',
        faction: Faction.shaolin,
        rarity: 'common',
        stats: HeroStats(
            punch: 0, kick: 0, grapple: 0, defense: 0, dodge: 0),
        maxHp: 0,
        maxStamina: 0,
        passive: GameCard(
          id: '',
          name: '',
          lore: '',
          category: CardCategory.punch,
          rarity: CardRarity.neutral,
          staminaCost: 0,
        ),
        lore: '',
        imagePath: '',
      ),
      currentHp: 0,
      currentStamina: 0,
      hand: [],
      deck: [],
      discardPile: [],
    ),
    opponent: CombatantState(
      hero: HeroEntity(
        id: '',
        name: '',
        title: '',
        faction: Faction.shaolin,
        rarity: 'common',
        stats: HeroStats(
            punch: 0, kick: 0, grapple: 0, defense: 0, dodge: 0),
        maxHp: 0,
        maxStamina: 0,
        passive: GameCard(
          id: '',
          name: '',
          lore: '',
          category: CardCategory.punch,
          rarity: CardRarity.neutral,
          staminaCost: 0,
        ),
        lore: '',
        imagePath: '',
      ),
      currentHp: 0,
      currentStamina: 0,
      hand: [],
      deck: [],
      discardPile: [],
    ),
  );

  /// Batalla de arena contra bot con IA escalable (no tutorial).
  void initArenaBattle({
    required HeroEntity playerHero,
    required HeroEntity botHero,
    required BotDifficulty difficulty,
  }) {
    _botDifficulty = difficulty;

    final deck = NeutralCardsData.buildStarterDeck()..shuffle(Random());
    final hand = deck.take(5).toList();
    final remainingDeck = deck.skip(5).toList();

    final botDeck = NeutralCardsData.buildStarterDeck()..shuffle(Random());
    final botHand = botDeck.take(5).toList();
    final botRemainingDeck = botDeck.skip(5).toList();

    state = BattleState(
      phase: BattlePhase.planning,
      isTutorial: false,
      botDifficulty: difficulty,
      player: CombatantState(
        hero: playerHero,
        currentHp: playerHero.maxHp,
        currentStamina: playerHero.maxStamina,
        hand: hand,
        deck: remainingDeck,
        discardPile: [],
        plannedSequence: List.filled(3, null),
      ),
      opponent: CombatantState(
        hero: botHero,
        currentHp: botHero.maxHp,
        currentStamina: botHero.maxStamina,
        hand: botHand,
        deck: botRemainingDeck,
        discardPile: [],
        plannedSequence: List.filled(3, null),
      ),
      currentRound: 1,
      roundHistory: [],
    );
  }

  void initTutorialBattle({
    required HeroEntity playerHero,
    required HeroEntity botHero,
  }) {
    _botDifficulty = null;
    final deck = NeutralCardsData.buildStarterDeck()..shuffle(Random());
    final hand = deck.take(5).toList();
    final remainingDeck = deck.skip(5).toList();

    final botDeck = NeutralCardsData.buildStarterDeck()..shuffle(Random());
    final botHand = botDeck.take(5).toList();
    final botRemainingDeck = botDeck.skip(5).toList();

    final weakenedBot = botHero.copyWith(maxHp: 5); // seba

    state = BattleState(
      phase: BattlePhase.planning,
      player: CombatantState(
        hero: playerHero,
        currentHp: playerHero.maxHp,
        currentStamina: playerHero.maxStamina,
        hand: hand,
        deck: remainingDeck,
        discardPile: [],
        plannedSequence: List.filled(3, null),
      ),
      opponent: CombatantState(
        hero: weakenedBot,
        currentHp: weakenedBot.maxHp,
        currentStamina: weakenedBot.maxStamina,
        hand: botHand,
        deck: botRemainingDeck,
        discardPile: [],
        plannedSequence: List.filled(3, null),
      ),
      currentRound: 1,
      roundHistory: [],
    );
  }

  void placeCardInSlot(GameCard card, int slotIndex) {
    final player = state.player;
    if (slotIndex < 0 || slotIndex >= 3) return;
    if (!player.hand.contains(card)) return;

    final currentSequence = List<GameCard?>.from(player.plannedSequence);
    final currentHand = List<GameCard>.from(player.hand);
    final previousCard = currentSequence[slotIndex];

    if (previousCard != null) {
      currentHand.add(previousCard);
      currentSequence[slotIndex] = null;
    }

    final usedWithoutSlot = currentSequence
        .whereType<GameCard>()
        .fold(0, (s, c) => s + c.staminaCost);

    if (usedWithoutSlot + card.staminaCost > player.currentStamina) {
      if (previousCard != null) {
        currentSequence[slotIndex] = previousCard;
        currentHand.remove(previousCard);
      }
      return;
    }

    currentHand.remove(card);
    currentSequence[slotIndex] = card;

    state = state.copyWith(
      player: player.copyWith(
        plannedSequence: currentSequence,
        hand: currentHand,
      ),
    );
  }

  void removeCardFromSlot(int slotIndex) {
    final player = state.player;
    final sequence = List<GameCard?>.from(player.plannedSequence);
    final hand = List<GameCard>.from(player.hand);

    final card = sequence[slotIndex];
    if (card != null) {
      hand.add(card);
      sequence[slotIndex] = null;
    }

    state = state.copyWith(
      player: player.copyWith(
        plannedSequence: sequence,
        hand: hand,
      ),
    );
  }

  /// Resuelve el round SIN aplicar HP final.
  /// El battle_screen llama applySlotDamage por cada slot durante la animación.
  Future<void> confirmSequenceAndResolve() async {
    // Extraer slots bloqueados por StatusEffect para cada combatiente
    final playerBlockedSlots = state.player.statusEffects
        .where((e) => e.type == StatusEffectType.slotBlocked)
        .map((e) => e.value)
        .toList();
    final opponentBlockedSlots = state.opponent.statusEffects
        .where((e) => e.type == StatusEffectType.slotBlocked)
        .map((e) => e.value)
        .toList();

    final List<GameCard?> playerLastSequence = state.roundHistory.isNotEmpty
        ? state.roundHistory.last.slotResults.map((r) => r.playerCard).toList()
        : [];

    final botSequence = _botDifficulty != null
        ? BotAI.decideSequence(
            state.opponent.hand,
            state.opponent.hero,
            _botDifficulty!,
            playerLastSequence: playerLastSequence,
          )
        : TutorialBotAI.decideSequence(state.opponent.hand);

    final opponentWithSequence =
        state.opponent.copyWith(plannedSequence: botSequence);

    state = state.copyWith(
      phase: BattlePhase.resolving,
      opponent: opponentWithSequence,
    );

    await Future.delayed(const Duration(milliseconds: 300));

    final result = CombatEngine.resolveRound(
      roundNumber: state.currentRound,
      player: state.player,
      opponent: opponentWithSequence,
      playerBlockedSlots: playerBlockedSlots,
      opponentBlockedSlots: opponentBlockedSlots,
    );

    // Solo guardamos el resultado en el history; NO aplicamos el HP final.
    final newHistory = [...state.roundHistory, result];
    state = state.copyWith(roundHistory: newHistory);
  }

  /// Aplica el daño de UN slot específico al HP actual.
  /// Se llama slot por slot durante la animación de resolución.
  void applySlotDamage(int slotIndex) {
    if (state.roundHistory.isEmpty) return;
    final lastRound = state.roundHistory.last;
    if (slotIndex < 0 || slotIndex >= lastRound.slotResults.length) return;

    final slotResult = lastRound.slotResults[slotIndex];

    final newPlayerHp =
    (state.player.currentHp - slotResult.opponentDamageDealt)
        .ceil()
        .clamp(0, state.player.hero.maxHp);
    final newOpponentHp =
    (state.opponent.currentHp - slotResult.playerDamageDealt)
        .ceil()
        .clamp(0, state.opponent.hero.maxHp);

    state = state.copyWith(
      player: state.player.copyWith(currentHp: newPlayerHp),
      opponent: state.opponent.copyWith(currentHp: newOpponentHp),
    );
  }

  /// Cierra el round: detecta fin de batalla, genera StatusEffects desde
  /// passives ganadores y hace tick-down de efectos existentes.
  void finalizeRound() {
    final player = state.player;
    final opponent = state.opponent;

    bool? playerWon;
    if (!opponent.isAlive) playerWon = true;
    if (!player.isAlive) playerWon = false;

    // 1. Tick-down de efectos existentes y filtrar expirados
    final tickedPlayerEffects = player.statusEffects
        .map((e) => e.tickDown())
        .where((e) => e.roundsRemaining > 0)
        .toList();
    final tickedOpponentEffects = opponent.statusEffects
        .map((e) => e.tickDown())
        .where((e) => e.roundsRemaining > 0)
        .toList();

    // 2. Generar nuevos StatusEffects desde passives que ganaron slots
    final newPlayerEffects = List<StatusEffect>.from(tickedPlayerEffects);
    final newOpponentEffects = List<StatusEffect>.from(tickedOpponentEffects);

    if (state.roundHistory.isNotEmpty) {
      for (final slot in state.roundHistory.last.slotResults) {
        if (slot.winner == 'player') {
          // Kage passive: daño continuo al oponente durante 2 rounds
          if (slot.playerCard?.id == 'passive_kage') {
            newOpponentEffects.add(const StatusEffect(
              type: StatusEffectType.continuousDamage,
              value: 8,
              roundsRemaining: 2,
            ));
          }
          // Mila passive: bloquea slot 0 del oponente el próximo round
          if (slot.playerCard?.id == 'passive_mila') {
            newOpponentEffects.add(const StatusEffect(
              type: StatusEffectType.slotBlocked,
              value: 0,
              roundsRemaining: 1,
            ));
          }
        }
      }
    }

    state = state.copyWith(
      phase: playerWon != null ? BattlePhase.battleEnd : BattlePhase.roundEnd,
      currentRound: state.currentRound + 1,
      playerWon: playerWon,
      player: player.copyWith(statusEffects: newPlayerEffects),
      opponent: opponent.copyWith(statusEffects: newOpponentEffects),
    );
  }

  void surrender() {
    state = state.copyWith(
      phase: BattlePhase.battleEnd,
      playerWon: false,
    );
  }

  void startNextRound() {
    // Resetear passiveJustUnlocked del round anterior
    state = state.copyWith(passiveJustUnlocked: false);

    // Capturar si el jugador agotó toda su stamina este round (antes de drawCards)
    final playerUsedAllStamina = state.player.remainingStamina == 0;

    var player = _drawCards(state.player);
    var opponent = _drawCards(state.opponent);

    // Aplicar daño continuo (DoT) desde efectos activos
    final playerDoT = player.statusEffects
        .where((e) => e.type == StatusEffectType.continuousDamage)
        .fold(0, (sum, e) => sum + e.value);
    final opponentDoT = opponent.statusEffects
        .where((e) => e.type == StatusEffectType.continuousDamage)
        .fold(0, (sum, e) => sum + e.value);

    // Aplicar reducción de stamina + carry-over bonus
    final playerStaminaReduction = player.statusEffects
        .where((e) => e.type == StatusEffectType.staminaReduction)
        .fold(0, (sum, e) => sum + e.value);
    final carryBonus = playerUsedAllStamina ? 0 : 1;
    final effectivePlayerStamina = (player.hero.maxStamina - playerStaminaReduction + carryBonus)
        .clamp(1, player.hero.maxStamina + 1);

    final newPlayerHp = (player.currentHp - playerDoT).clamp(0, player.hero.maxHp);
    final newOpponentHp = (opponent.currentHp - opponentDoT).clamp(0, opponent.hero.maxHp);

    // Inyectar passive en mano si HP ≤ 40% y aún no fue usado
    var playerHand = List<GameCard>.from(player.hand);
    var passiveUsed = player.passiveUsed;
    var passiveJustUnlocked = false;
    final hpThreshold = (player.hero.maxHp * 0.4).round();
    if (!passiveUsed && newPlayerHp > 0 && newPlayerHp <= hpThreshold) {
      playerHand.add(player.hero.passive);
      passiveUsed = true;
      passiveJustUnlocked = true;
    }

    // Si el DoT mata a alguien, terminar la batalla
    bool? playerWon;
    if (newOpponentHp <= 0 && newPlayerHp <= 0) {
      playerWon = true;
    } else if (newOpponentHp <= 0) {
      playerWon = true;
    } else if (newPlayerHp <= 0) {
      playerWon = false;
    }

    state = state.copyWith(
      phase: playerWon != null ? BattlePhase.battleEnd : BattlePhase.planning,
      playerWon: playerWon,
      passiveJustUnlocked: passiveJustUnlocked,
      player: player.copyWith(
        currentHp: newPlayerHp,
        currentStamina: effectivePlayerStamina,
        plannedSequence: List.filled(3, null),
        hand: playerHand,
        passiveUsed: passiveUsed,
      ),
      opponent: opponent.copyWith(
        currentHp: newOpponentHp,
        currentStamina: opponent.hero.maxStamina,
        plannedSequence: List.filled(3, null),
      ),
    );
  }

  CombatantState _drawCards(CombatantState combatant) {
    var deck = List<GameCard>.from(combatant.deck);
    var discard = List<GameCard>.from(combatant.discardPile);
    var hand = List<GameCard>.from(combatant.hand);

    for (final card in combatant.plannedSequence.whereType<GameCard>()) {
      discard.add(card);
    }

    while (hand.length < 5) {
      if (deck.isEmpty) {
        if (discard.isEmpty) break;
        deck = List<GameCard>.from(discard)..shuffle(Random());
        discard.clear();
      }
      if (deck.isNotEmpty) {
        hand.add(deck.removeAt(0));
      } else {
        break;
      }
    }

    return combatant.copyWith(
      hand: hand,
      deck: deck,
      discardPile: discard,
      plannedSequence: List.filled(3, null),
    );
  }
}
