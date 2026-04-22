// lib/infra/firebase/game_data_repository.dart
//
// Lee los datos del seed desde Firebase (gameData/heroes, gameData/cards).
// Cachea en memoria para no hacer lecturas repetidas.

import 'package:cloud_firestore/cloud_firestore.dart';

class GameDataRepository {
  final FirebaseFirestore _db;

  GameDataRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // Cache en memoria — se llena en la primera lectura
  List<Map<String, dynamic>>? _heroesCache;
  List<Map<String, dynamic>>? _cardsCache;

  Future<List<Map<String, dynamic>>> getAllHeroes() async {
    if (_heroesCache != null) return _heroesCache!;

    final snap = await _db
        .collection('gameData')
        .doc('heroes')
        .collection('items')
        .get();

    _heroesCache = snap.docs.map((d) => d.data()).toList();
    return _heroesCache!;
  }

  Future<List<Map<String, dynamic>>> getAllCards() async {
    if (_cardsCache != null) return _cardsCache!;

    final snap = await _db
        .collection('gameData')
        .doc('cards')
        .collection('items')
        .get();

    _cardsCache = snap.docs.map((d) => d.data()).toList();
    return _cardsCache!;
  }

  /// Cartas filtradas por facción (para el shop).
  Future<List<Map<String, dynamic>>> getCardsByFaction(String factionId) async {
    final all = await getAllCards();
    return all.where((c) => c['factionId'] == factionId).toList();
  }

  /// Cartas neutrales (para el mazo inicial de todos).
  Future<List<Map<String, dynamic>>> getNeutralCards() async {
    final all = await getAllCards();
    return all.where((c) => c['rarity'] == 'neutral').toList();
  }

  /// Héroe por id.
  Future<Map<String, dynamic>?> getHeroById(String heroId) async {
    final all = await getAllHeroes();
    try {
      return all.firstWhere((h) => h['id'] == heroId);
    } catch (_) {
      return null;
    }
  }

  /// Carta por id.
  Future<Map<String, dynamic>?> getCardById(String cardId) async {
    final all = await getAllCards();
    try {
      return all.firstWhere((c) => c['id'] == cardId);
    } catch (_) {
      return null;
    }
  }

  /// Fuerza la recarga desde Firebase (para después de un seed update).
  void clearCache() {
    _heroesCache = null;
    _cardsCache = null;
  }
}
