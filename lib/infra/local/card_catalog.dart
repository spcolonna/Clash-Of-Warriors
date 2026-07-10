// lib/infra/local/card_catalog.dart
//
// Registro global de cartas: único punto de verdad para resolver cardId →
// GameCard, combinando cartas remotas (Firestore, editables desde el admin)
// con las locales (neutrales + cartas de facción). El doc remoto gana sobre
// la carta local con el mismo id, de modo que el admin puede tunear stats
// sin tocar código.
//
// Reutilizado por: battle_provider (armar el mazo del jugador y del bot),
// deck_builder_provider (mostrar/editar el mazo) y la tienda.

import '../../domain/entities/game_card.dart';
import '../../domain/entities/hero_entity.dart';
import 'heroes_data.dart';
import 'neutral_cards_data.dart';

class CardCatalog {
  final Map<String, GameCard> _byId;

  CardCatalog._(this._byId);

  /// Construye el catálogo. [remoteCards] son los docs de Firestore
  /// (gameConfigProvider.cards); si viene vacío, solo quedan las locales.
  factory CardCatalog.build(List<Map<String, dynamic>> remoteCards) {
    final byId = <String, GameCard>{};

    // 1. Base local: neutrales + cartas de facción.
    for (final c in NeutralCardsData.allUniqueCards) {
      byId[c.id] = c;
    }
    for (final c in FactionStarterCards.all) {
      byId[c.id] = c;
    }

    // 2. Remotas: pisan a las locales con el mismo id.
    for (final data in remoteCards) {
      final id = data['id'] as String?;
      if (id == null || id.isEmpty) continue;
      byId[id] = NeutralCardsData.mapToGameCard(data);
    }

    return CardCatalog._(byId);
  }

  GameCard? findById(String id) => _byId[id];

  /// Todas las cartas de una facción (locales + remotas).
  List<GameCard> byFaction(String factionId) =>
      _byId.values.where((c) => c.factionId == factionId).toList();

  /// Resuelve una lista de ids (el deckCardIds del jugador) a GameCards,
  /// descartando los que no existan en el catálogo.
  List<GameCard> resolveDeck(List<String> cardIds) {
    final result = <GameCard>[];
    for (final id in cardIds) {
      final card = _byId[id];
      if (card != null) result.add(card);
    }
    return result;
  }

  /// Mazo temático de 20 cartas para un bot de la facción [faction]:
  /// base neutral + cartas de la facción (hasta 8 slots, máx 2 copias c/u).
  /// Escala solo: cuantas más cartas de esa facción existan, más ricas.
  List<GameCard> buildFactionDeck(Faction faction) {
    final factionCards = byFaction(faction.name);
    if (factionCards.isEmpty) {
      return NeutralCardsData.buildStarterDeck();
    }

    // Hasta 8 slots de facción, ciclando y con tope de 2 copias por carta.
    const factionSlots = 8;
    final maxCopies = factionCards.length * 2;
    final picks = <GameCard>[];
    for (int i = 0; picks.length < factionSlots && i < maxCopies; i++) {
      picks.add(factionCards[i % factionCards.length]);
    }

    final neutralCount = 20 - picks.length;
    final neutral = NeutralCardsData.buildStarterDeck().take(neutralCount);
    return [...neutral, ...picks];
  }
}
