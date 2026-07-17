// lib/infra/firebase/firebase_game_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/player_profile.dart';
import '../local/progress_rewards_data.dart';

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

  /// Cambia el héroe activo del jugador.
  Future<void> updateActiveHero({
    required String uid,
    required String heroId,
  }) async {
    await _users.doc(uid).update({'activeHeroId': heroId});
  }

  // ── ECONOMÍA ───────────────────────────────────────────────────────────

  Future<void> addSoftCoins(String uid, int amount) async {
    await _users.doc(uid).update({'softCoins': FieldValue.increment(amount)});
  }

  Future<void> addMedals(String uid, int amount) async {
    await _users.doc(uid).update({'medals': FieldValue.increment(amount)});
  }

  Future<void> addTokens(String uid, int amount) async {
    await _users.doc(uid).update({'tokens': FieldValue.increment(amount)});
  }

  Future<void> spendTokensAndUnlockHero({
    required String uid,
    required String heroId,
    required int cost,
  }) async {
    await _db.runTransaction((tx) async {
      final ref = _users.doc(uid);
      final snap = await tx.get(ref);
      final data = snap.data() as Map<String, dynamic>;
      final current = data['tokens'] as int? ?? 0;
      if (current < cost) throw Exception('Tokens insuficientes');
      tx.update(ref, {
        'tokens': current - cost,
        'unlockedHeroIds': FieldValue.arrayUnion([heroId]),
      });
    });
  }

  Future<void> spendCoinsAndUnlockHero({
    required String uid,
    required String heroId,
    required int cost,
  }) async {
    await _db.runTransaction((tx) async {
      final ref = _users.doc(uid);
      final snap = await tx.get(ref);
      final data = snap.data() as Map<String, dynamic>;
      final current = data['softCoins'] as int? ?? 0;
      if (current < cost) throw Exception('Monedas insuficientes');
      tx.update(ref, {
        'softCoins': current - cost,
        'unlockedHeroIds': FieldValue.arrayUnion([heroId]),
      });
    });
  }

  Future<void> grantBundle({
    required String uid,
    required String heroId,
    required int tokenAmount,
    List<String> cardIds = const [],
  }) async {
    await _db.runTransaction((tx) async {
      final ref = _users.doc(uid);
      final snap = await tx.get(ref);
      final data = snap.data() as Map<String, dynamic>;

      // Sumar las cartas del bundle a ownedCards (incrementa cantidades)
      final ownedRaw = data['ownedCards'] as List<dynamic>? ?? [];
      final owned = List<Map<String, dynamic>>.from(
        ownedRaw.map((e) => Map<String, dynamic>.from(e as Map)),
      );
      for (final cardId in cardIds) {
        final idx = owned.indexWhere((c) => c['cardId'] == cardId);
        if (idx >= 0) {
          owned[idx]['quantity'] = (owned[idx]['quantity'] as int) + 1;
        } else {
          owned.add({'cardId': cardId, 'quantity': 1});
        }
      }

      tx.update(ref, {
        'tokens': FieldValue.increment(tokenAmount),
        'unlockedHeroIds': FieldValue.arrayUnion([heroId]),
        'ownedCards': owned,
      });
    });
  }

  /// Ascensión de héroe: descuenta medallas y sube la estrella, atómico.
  Future<void> ascendHero({
    required String uid,
    required String heroId,
    required int newStars,
    required int medalCost,
  }) async {
    await _db.runTransaction((tx) async {
      final ref = _users.doc(uid);
      final snap = await tx.get(ref);
      final data = snap.data() as Map<String, dynamic>;
      final medals = data['medals'] as int? ?? 0;
      if (medals < medalCost) throw Exception('Medallas insuficientes');
      tx.update(ref, {
        'medals': medals - medalCost,
        'heroStars.$heroId': newStars,
      });
    });
  }

  // ── LEADERBOARD SEMANAL ──────────────────────────────────────────────────

  /// Clave de la semana actual en formato ISO ('2026-W28').
  static String currentWeekKey() {
    final now = DateTime.now().toUtc();
    // Algoritmo ISO 8601: la semana pertenece al año de su jueves.
    final thursday = now.add(Duration(days: 4 - (now.weekday)));
    final firstDayOfYear = DateTime.utc(thursday.year, 1, 1);
    final week = ((thursday.difference(firstDayOfYear).inDays) / 7).floor() + 1;
    return '${thursday.year}-W${week.toString().padLeft(2, '0')}';
  }

  /// Suma puntos al score semanal del jugador (crea la entrada si no existe).
  Future<void> submitWeeklyPoints({
    required String uid,
    required String displayName,
    required int points,
  }) async {
    final ref = _db
        .collection('leaderboard')
        .doc(currentWeekKey())
        .collection('entries')
        .doc(uid);
    await ref.set({
      'name': displayName,
      'points': FieldValue.increment(points),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Top N de la semana actual, ordenado por puntos.
  Future<List<Map<String, dynamic>>> fetchWeeklyTop({int limit = 50}) async {
    final snap = await _db
        .collection('leaderboard')
        .doc(currentWeekKey())
        .collection('entries')
        .orderBy('points', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => {'uid': d.id, ...d.data()})
        .toList();
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
      // isEnabled: true por defecto, no sobreescribir si ya existe
      batch.set(
        cardsCol.doc(card['id'] as String),
        {...card, 'isEnabled': true},
        SetOptions(merge: true),
      );
    }

    // Configuración global de recompensas (si no existe)
    final settingsRef = _db.collection('gameConfig').doc('settings');
    batch.set(settingsRef, {
      'progressRewards': [
        {'requiredPoints': 10, 'type': 'coins',  'amount': 150},
        {'requiredPoints': 12, 'type': 'tokens', 'amount': 2},
        {'requiredPoints': 15, 'type': 'coins',  'amount': 300},
        {'requiredPoints': 10, 'type': 'tokens', 'amount': 5},
      ],
      'pointsPerWin': {'easy': 3, 'normal': 5, 'hard': 8},
      'pointsPerWinSimple': {'easy': 2, 'normal': 3, 'hard': 5},
      'features': {'simpleModeEnabled': false},
    }, SetOptions(merge: true));

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

  // ── ADMIN — CARTAS ─────────────────────────────────────────────────────────

  Future<void> addCard(Map<String, dynamic> cardData) async {
    final id = cardData['id'] as String;
    await _db
        .collection('gameData')
        .doc('cards')
        .collection('items')
        .doc(id)
        .set({...cardData, 'isEnabled': true});
  }

  Future<void> updateCard(String cardId, Map<String, dynamic> data) async {
    await _db
        .collection('gameData')
        .doc('cards')
        .collection('items')
        .doc(cardId)
        .update(data);
  }

  Future<void> toggleCardEnabled(String cardId, bool enabled) async {
    await _db
        .collection('gameData')
        .doc('cards')
        .collection('items')
        .doc(cardId)
        .update({'isEnabled': enabled});
  }

  // ── ADMIN — HÉROES ─────────────────────────────────────────────────────────

  Future<void> updateHero(String heroId, Map<String, dynamic> data) async {
    await _db
        .collection('gameData')
        .doc('heroes')
        .collection('items')
        .doc(heroId)
        .update(data);
  }

  // ── ADMIN — CONFIGURACIÓN GLOBAL ───────────────────────────────────────────

  Future<void> saveGameSettings(Map<String, dynamic> settings) async {
    await _db
        .collection('gameConfig')
        .doc('settings')
        .set(settings, SetOptions(merge: true));
  }

  // ── STORY ARCS ─────────────────────────────────────────────────────────────

  /// Carga todos los arcos de historia desde Firestore.
  /// Cada documento en la colección 'storyArcs' es un arco con id "{heroId}_{rarity}".
  Future<List<Map<String, dynamic>>> loadStoryArcs() async {
    final snap = await _db.collection('storyArcs').get();
    return snap.docs.map((d) => {'arcId': d.id, ...d.data()}).toList();
  }

  /// Guarda (o sobreescribe) un arco de historia desde el admin web.
  Future<void> saveStoryArc(String arcId, Map<String, dynamic> data) async {
    await _db.collection('storyArcs').doc(arcId).set(data);
  }

  // ── PROGRESO DE HISTORIA ────────────────────────────────────────────────────

  Future<void> saveStoryProgress({
    required String uid,
    required String arcKey, // "{heroId}_{rarity}"
    required int stageIndex,
  }) async {
    await _users.doc(uid).update({'storyProgress.$arcKey': stageIndex});
  }

  Future<void> completeStoryArc({
    required String uid,
    required String arcKey,
    String? rewardHeroId, // null si es legendary
  }) async {
    final updates = <String, dynamic>{
      'completedStoryArcs': FieldValue.arrayUnion([arcKey]),
    };
    if (rewardHeroId != null) {
      updates['unlockedHeroIds'] = FieldValue.arrayUnion([rewardHeroId]);
    }
    await _users.doc(uid).update(updates);
  }

  Future<void> grantAchievement({
    required String uid,
    required String achievementId,
  }) async {
    await _users.doc(uid).update({
      'achievements': FieldValue.arrayUnion([achievementId]),
    });
  }

  // ── CICLO DE PROGRESO ──────────────────────────────────────────────────────

  Future<void> addBattlePoints(String uid, int amount) async {
    await _users.doc(uid).update({'battlePoints': FieldValue.increment(amount)});
  }

  Future<void> claimProgressReward(
    String uid, {
    required int newCycleIndex,
    required ProgressRewardType rewardType,
    required int rewardAmount,
    String? rewardCardId,
  }) async {
    final batch = _db.batch();
    final doc = _users.doc(uid);

    batch.update(doc, {
      'battlePoints': 0,
      'lastClaimedCycleIndex': newCycleIndex,
    });

    if (rewardType == ProgressRewardType.coins) {
      batch.update(doc, {'softCoins': FieldValue.increment(rewardAmount)});
    } else if (rewardType == ProgressRewardType.tokens) {
      batch.update(doc, {'tokens': FieldValue.increment(rewardAmount)});
    }

    await batch.commit();

    // Cartas se manejan en PlayerNotifier donde ya existe la lógica de ownedCards
  }
}
