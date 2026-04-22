// lib/delivery/state/battle_provider.dart

import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/battle_state.dart';
import '../../domain/entities/game_card.dart';
import '../../domain/entities/hero_entity.dart';
import '../../domain/usecases/resolve_combat_use_case.dart';
import '../../infra/local/neutral_cards_data.dart';

final battleProvider = NotifierProvider<BattleNotifier, BattleState>(
  BattleNotifier.new,
);

class BattleNotifier extends Notifier<BattleState> {
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

  void initTutorialBattle({
    required HeroEntity playerHero,
    required HeroEntity botHero,
  }) {
    final deck = NeutralCardsData.buildStarterDeck()..shuffle(Random());
    final hand = deck.take(7).toList();
    final remainingDeck = deck.skip(7).toList();

    final botDeck = NeutralCardsData.buildStarterDeck()..shuffle(Random());
    final botHand = botDeck.take(7).toList();
    final botRemainingDeck = botDeck.skip(7).toList();

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
        plannedSequence: List.filled(5, null),
      ),
      opponent: CombatantState(
        hero: weakenedBot,
        currentHp: weakenedBot.maxHp,
        currentStamina: weakenedBot.maxStamina,
        hand: botHand,
        deck: botRemainingDeck,
        discardPile: [],
        plannedSequence: List.filled(5, null),
      ),
      currentRound: 1,
      roundHistory: [],
    );
  }

  void placeCardInSlot(GameCard card, int slotIndex) {
    final player = state.player;
    if (slotIndex < 0 || slotIndex >= 5) return;
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
    final botSequence = TutorialBotAI.decideSequence(state.opponent.hand);
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

  /// Cierra el round: detecta fin de batalla, incrementa round.
  void finalizeRound() {
    final player = state.player;
    final opponent = state.opponent;

    bool? playerWon;
    if (!opponent.isAlive) playerWon = true;
    if (!player.isAlive) playerWon = false;

    state = state.copyWith(
      phase: playerWon != null ? BattlePhase.battleEnd : BattlePhase.roundEnd,
      currentRound: state.currentRound + 1,
      playerWon: playerWon,
    );
  }

  void startNextRound() {
    final player = _drawCards(state.player);
    final opponent = _drawCards(state.opponent);

    state = state.copyWith(
      phase: BattlePhase.planning,
      player: player.copyWith(
        plannedSequence: List.filled(5, null),
        currentStamina: player.hero.maxStamina,
      ),
      opponent: opponent.copyWith(
        plannedSequence: List.filled(5, null),
        currentStamina: opponent.hero.maxStamina,
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

    while (hand.length < 7) {
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
      plannedSequence: List.filled(5, null),
    );
  }
}
