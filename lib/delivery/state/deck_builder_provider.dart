// lib/delivery/state/deck_builder_provider.dart
//
// Divide las cartas del jugador en:
//   - deck: cartas en el mazo activo (deckCardIds)
//   - collection: cartas que posee (ownedCards) que NO están en el mazo
//
// Cada cambio persiste en Firebase via playerProvider.updateDeck.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';

class DeckEntry {
  final String cardId;
  final int quantity;

  const DeckEntry({required this.cardId, required this.quantity});

  DeckEntry withQuantity(int q) => DeckEntry(cardId: cardId, quantity: q);
}

class DeckBuilderState {
  final List<DeckEntry> deck;
  final List<DeckEntry> collection;

  const DeckBuilderState({
    required this.deck,
    required this.collection,
  });

  DeckBuilderState copyWith({
    List<DeckEntry>? deck,
    List<DeckEntry>? collection,
  }) =>
      DeckBuilderState(
        deck: deck ?? this.deck,
        collection: collection ?? this.collection,
      );
}

final deckBuilderProvider =
StateNotifierProvider<DeckBuilderNotifier, AsyncValue<DeckBuilderState>>(
      (ref) => DeckBuilderNotifier(ref),
);

class DeckBuilderNotifier
    extends StateNotifier<AsyncValue<DeckBuilderState>> {
  final Ref _ref;
  static const int maxDeckSize = 20;

  DeckBuilderNotifier(this._ref) : super(const AsyncValue.loading());

  Future<void> loadFromPlayer() async {
    final player = _ref.read(playerProvider);
    if (player == null) {
      state = const AsyncValue.loading();
      return;
    }

    try {
      // Contar cuántas veces aparece cada cardId en deckCardIds
      final deckByCardId = <String, int>{};
      for (final id in player.deckCardIds) {
        deckByCardId[id] = (deckByCardId[id] ?? 0) + 1;
      }

      final deck = deckByCardId.entries
          .map((e) => DeckEntry(cardId: e.key, quantity: e.value))
          .toList();

      // Collection: cartas de ownedCards cuyas quantity superan lo que está en deck
      final collection = <DeckEntry>[];
      for (final owned in player.ownedCards) {
        final inDeck = deckByCardId[owned.cardId] ?? 0;
        final remaining = owned.quantity - inDeck;
        if (remaining > 0) {
          collection.add(
            DeckEntry(cardId: owned.cardId, quantity: remaining),
          );
        }
      }

      state = AsyncValue.data(
        DeckBuilderState(deck: deck, collection: collection),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addToDeck(String cardId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final totalInDeck =
    current.deck.fold<int>(0, (s, e) => s + e.quantity);
    if (totalInDeck >= maxDeckSize) return;

    final fromCollection = current.collection.firstWhere(
          (c) => c.cardId == cardId,
      orElse: () => const DeckEntry(cardId: '', quantity: 0),
    );
    if (fromCollection.cardId.isEmpty) return;

    final newCollection = current.collection
        .map((c) => c.cardId == cardId ? c.withQuantity(c.quantity - 1) : c)
        .where((c) => c.quantity > 0)
        .toList();

    final inDeckIdx = current.deck.indexWhere((c) => c.cardId == cardId);
    final newDeck = inDeckIdx >= 0
        ? current.deck
        .map((c) => c.cardId == cardId
        ? c.withQuantity(c.quantity + 1)
        : c)
        .toList()
        : [...current.deck, DeckEntry(cardId: cardId, quantity: 1)];

    state = AsyncValue.data(
      current.copyWith(deck: newDeck, collection: newCollection),
    );

    await _persistDeck(newDeck);
  }

  Future<void> removeFromDeck(String cardId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final fromDeck = current.deck.firstWhere(
          (c) => c.cardId == cardId,
      orElse: () => const DeckEntry(cardId: '', quantity: 0),
    );
    if (fromDeck.cardId.isEmpty) return;

    final newDeck = current.deck
        .map((c) =>
    c.cardId == cardId ? c.withQuantity(c.quantity - 1) : c)
        .where((c) => c.quantity > 0)
        .toList();

    final inCollectionIdx =
    current.collection.indexWhere((c) => c.cardId == cardId);
    final newCollection = inCollectionIdx >= 0
        ? current.collection
        .map((c) => c.cardId == cardId
        ? c.withQuantity(c.quantity + 1)
        : c)
        .toList()
        : [...current.collection, DeckEntry(cardId: cardId, quantity: 1)];

    state = AsyncValue.data(
      current.copyWith(deck: newDeck, collection: newCollection),
    );

    await _persistDeck(newDeck);
  }

  /// Convierte las DeckEntries en List<String> con repeticiones y persiste.
  Future<void> _persistDeck(List<DeckEntry> newDeck) async {
    final deckCardIds = <String>[];
    for (final entry in newDeck) {
      for (int i = 0; i < entry.quantity; i++) {
        deckCardIds.add(entry.cardId);
      }
    }
    await _ref.read(playerProvider.notifier).updateDeck(deckCardIds);
  }
}
