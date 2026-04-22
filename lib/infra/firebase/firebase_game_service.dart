// lib/infra/firebase/firebase_game_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/player_profile.dart';

class FirebaseGameService {
  final FirebaseFirestore _db;

  FirebaseGameService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  static const String _usersCollection = 'users';
  static const String _settingsCollection = 'gameSettings';
  static const String _seedDoc = 'seed';

  CollectionReference get _users => _db.collection(_usersCollection);
  DocumentReference get _seedRef =>
      _db.collection(_settingsCollection).doc(_seedDoc);

  // ── PLAYER PROFILE ─────────────────────────────────────────────────────

  Future<PlayerProfile?> getPlayer(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return PlayerProfile.fromFirestore(uid, doc.data() as Map<String, dynamic>);
  }

  Future<void> savePlayer(PlayerProfile player) async {
    await _users.doc(player.uid).set(
      player.toFirestore(),
      SetOptions(merge: true),
    );
  }

  Future<PlayerProfile> createNewPlayer(String uid) async {
    final profile = PlayerProfile(uid: uid);
    await savePlayer(profile);
    return profile;
  }

  // ── TUTORIAL STEPS ─────────────────────────────────────────────────────

  /// Paso 1: elige facción y recibe el mazo starter de 20 cartas neutrales.
  Future<void> saveFactionSelection({
    required String uid,
    required String factionId,
    required String heroId,
    required List<String> starterDeckIds,
  }) async {
    await _users.doc(uid).update({
      'selectedFactionId': factionId,
      'activeHeroId': heroId,
      'unlockedHeroIds': FieldValue.arrayUnion([heroId]),
      'deckCardIds': starterDeckIds,
    });
  }

  /// Paso 2: ganó la primera batalla.
  Future<void> completeTutorialBattle({
    required String uid,
    required int medalsEarned,
    required int coinsEarned,
    required String rivalHeroId,
  }) async {
    await _users.doc(uid).update({
      'tutorialBattleComplete': true,
      'medals': FieldValue.increment(medalsEarned),
      'softCoins': FieldValue.increment(coinsEarned),
      'unlockedHeroIds': FieldValue.arrayUnion([rivalHeroId]),
    });
  }

  /// Paso 3: compró la starter card.
  Future<void> purchaseStarterCard({
    required String uid,
    required String cardId,
    required int cost,
  }) async {
    await _db.runTransaction((tx) async {
      final ref = _users.doc(uid);
      final snap = await tx.get(ref);
      final data = snap.data() as Map<String, dynamic>;

      final currentCoins = data['softCoins'] as int? ?? 0;
      if (currentCoins < cost) {
        throw Exception('Soft coins insuficientes: $currentCoins < $cost');
      }

      final ownedRaw = data['ownedCards'] as List<dynamic>? ?? [];
      final owned = List<Map<String, dynamic>>.from(
        ownedRaw.map((e) => Map<String, dynamic>.from(e as Map)),
      );

      final idx = owned.indexWhere((c) => c['cardId'] == cardId);
      if (idx >= 0) {
        owned[idx]['quantity'] = (owned[idx]['quantity'] as int) + 1;
      } else {
        owned.add({'cardId': cardId, 'quantity': 1});
      }

      tx.update(ref, {
        'softCoins': currentCoins - cost,
        'ownedCards': owned,
        'starterCardPurchased': true,
      });
    });
  }

  /// Paso 4: agregó la carta al mazo y completó el onboarding.
  Future<void> addStarterCardToDeckAndComplete(String uid) async {
    await _users.doc(uid).update({
      'starterCardAddedToDeck': true,
      'isOnboardingComplete': true,
    });
  }

  // ── DECK MANAGEMENT ────────────────────────────────────────────────────

  /// Actualiza el deck completo del jugador.
  Future<void> updateDeck({
    required String uid,
    required List<String> deckCardIds,
  }) async {
    await _users.doc(uid).update({'deckCardIds': deckCardIds});
  }

  // ── ECONOMÍA ───────────────────────────────────────────────────────────

  Future<void> addSoftCoins(String uid, int amount) async {
    await _users.doc(uid).update({'softCoins': FieldValue.increment(amount)});
  }

  Future<void> addMedals(String uid, int amount) async {
    await _users.doc(uid).update({'medals': FieldValue.increment(amount)});
  }

  // ── SEED ───────────────────────────────────────────────────────────────

  Future<bool> isSeedLoaded() async {
    final doc = await _seedRef.get();
    if (!doc.exists) return false;
    final data = doc.data() as Map<String, dynamic>;
    return data['firstLoad'] == true;
  }

  Future<void> writeSeed({
    required List<Map<String, dynamic>> heroes,
    required List<Map<String, dynamic>> cards,
  }) async {
    final batch = _db.batch();

    final heroesCol =
    _db.collection('gameData').doc('heroes').collection('items');
    for (final hero in heroes) {
      batch.set(heroesCol.doc(hero['id'] as String), hero,
          SetOptions(merge: true));
    }

    final cardsCol =
    _db.collection('gameData').doc('cards').collection('items');
    for (final card in cards) {
      batch.set(cardsCol.doc(card['id'] as String), card,
          SetOptions(merge: true));
    }

    batch.set(_seedRef, {
      'firstLoad': true,
      'loadedAt': FieldValue.serverTimestamp(),
      'heroCount': heroes.length,
      'cardCount': cards.length,
    });

    await batch.commit();
  }

  Future<void> resetSeedFlag() async {
    await _seedRef.set({'firstLoad': false});
  }
}
