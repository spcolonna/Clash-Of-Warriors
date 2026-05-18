// lib/delivery/state/providers.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/hero.dart';
import '../../domain/entities/hero_entity.dart';
import '../../domain/entities/player_profile.dart';
import '../../infra/firebase/firebase_auth_service.dart';
import '../../infra/firebase/firebase_game_service.dart';
import '../../infra/firebase/firestore_player_repository.dart';
import '../../infra/firebase/firebase_analytics_service.dart';
import '../../infra/local/neutral_cards_data.dart';
import '../../infra/services/admob_service.dart';
import '../../infra/services/game_seed_service.dart';
import '../../infra/sound/sound_service.dart';
import '../../domain/entities/battle_state.dart' show BotDifficulty, GameMode;
import '../../domain/entities/game_config.dart';
import '../../infra/firebase/game_config_service.dart';
import '../../infra/local/heroes_data.dart';
import '../../infra/local/progress_rewards_data.dart';

// ── Servicios singleton ────────────────────────────────────────────────────

final authProvider = Provider((_) => FirebaseAuthService());
final analyticsProvider = Provider((_) => FirebaseAnalyticsService());
final adMobProvider = Provider((_) => AdMobService());
final soundProvider = Provider((_) => SoundService());

final firebaseGameServiceProvider = Provider((_) => FirebaseGameService());

final firestoreProvider = Provider((ref) {
  final service = ref.read(firebaseGameServiceProvider);
  return FirestorePlayerRepository(service: service);
});

final gameSeedServiceProvider = Provider((ref) {
  final service = ref.read(firebaseGameServiceProvider);
  return GameSeedService(firebase: service);
});

// ── Firebase Auth State (listener global) ──────────────────────────────────

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// ── Locale ─────────────────────────────────────────────────────────────────

final localeProvider = StateProvider<Locale?>((ref) => null);

// ── Selected Hero (provider liviano para onboarding) ───────────────────────

final selectedHeroForBattleProvider =
StateProvider<HeroEntity?>((ref) => null);

// ── Player Profile ─────────────────────────────────────────────────────────

final playerProvider =
StateNotifierProvider<PlayerNotifier, PlayerProfile?>((ref) {
  return PlayerNotifier(ref);
});

class PlayerNotifier extends StateNotifier<PlayerProfile?> {
  final Ref _ref;
  PlayerNotifier(this._ref) : super(null);

  FirebaseGameService get _svc => _ref.read(firebaseGameServiceProvider);

  void setState(PlayerProfile profile) {
    state = profile;
  }

  Future<void> loadPlayer(String uid) async {
    debugPrint('[Player] loadPlayer START uid=$uid');
    try {
      final repo = _ref.read(firestoreProvider);
      var player = await repo.getPlayer(uid);
      if (player == null) {
        player = await _svc.createNewPlayer(uid);
      }
      state = player;
      debugPrint('[Player] loadPlayer DONE uid=$uid');
    } catch (e) {
      debugPrint('[Player] loadPlayer ERROR: $e');
    }
  }

  /// Paso 1 — elegir facción + asignar mazo de 20 cartas neutrales.
  Future<void> selectFaction(String factionId, String heroId) async {
    if (state == null) return;

    final starterIds = NeutralCardsData.starterDeckCardIds();

    state = state!.copyWith(
      selectedFactionId: factionId,
      activeHeroId: heroId,
      unlockedHeroIds: [...state!.unlockedHeroIds, heroId],
      deckCardIds: starterIds,
    );

    try {
      await _svc.saveFactionSelection(
        uid: state!.uid,
        factionId: factionId,
        heroId: heroId,
        starterDeckIds: starterIds,
      );
    } catch (e) {
      print('[PlayerNotifier] selectFaction error: $e');
    }
  }

  /// Paso 2 — ganar primera batalla
  Future<void> completeTutorialBattle({
    required int medals,
    required int coins,
    required String rivalHeroId,
  }) async {
    if (state == null) return;
    state = state!.copyWith(
      tutorialBattleComplete: true,
      medals: state!.medals + medals,
      softCoins: state!.softCoins + coins,
      unlockedHeroIds: [...state!.unlockedHeroIds, rivalHeroId],
    );
    _svc
        .completeTutorialBattle(
      uid: state!.uid,
      medalsEarned: medals,
      coinsEarned: coins,
      rivalHeroId: rivalHeroId,
    )
        .catchError((e) =>
        print('[PlayerNotifier] completeTutorialBattle: $e'));
  }

  /// Paso 3 — comprar primera carta
  Future<bool> purchaseStarterCard({
    required String cardId,
    required int cost,
  }) async {
    if (state == null) return false;
    if (state!.softCoins < cost) return false;

    final existing =
        state!.ownedCards.where((c) => c.cardId == cardId).firstOrNull;

    final updatedCards = existing != null
        ? state!.ownedCards
        .map((c) => c.cardId == cardId
        ? OwnedCard(cardId: c.cardId, quantity: c.quantity + 1)
        : c)
        .toList()
        : [...state!.ownedCards, OwnedCard(cardId: cardId, quantity: 1)];

    state = state!.copyWith(
      softCoins: state!.softCoins - cost,
      ownedCards: updatedCards,
      starterCardPurchased: true,
    );

    try {
      await _svc.purchaseStarterCard(
        uid: state!.uid,
        cardId: cardId,
        cost: cost,
      );
      return true;
    } catch (e) {
      print('[PlayerNotifier] purchaseStarterCard: $e');
      return false;
    }
  }

  /// Paso 4 — agregar carta al mazo y completar tutorial
  Future<void> addStarterCardToDeckAndComplete() async {
    if (state == null) return;
    state = state!.copyWith(
      starterCardAddedToDeck: true,
      isOnboardingComplete: true,
    );
    _svc.addStarterCardToDeckAndComplete(state!.uid).catchError(
            (e) => print('[PlayerNotifier] addStarterCardToDeck: $e'));
  }

  /// Actualiza el deck del jugador (desde el deck builder).
  Future<void> updateDeck(List<String> deckCardIds) async {
    if (state == null) return;
    state = state!.copyWith(deckCardIds: deckCardIds);
    _svc
        .updateDeck(uid: state!.uid, deckCardIds: deckCardIds)
        .catchError((e) => print('[PlayerNotifier] updateDeck: $e'));
  }

  /// Cambia el héroe activo del jugador (usado desde el deck builder).
  Future<void> updateActiveHero(String heroId) async {
    if (state == null) return;
    state = state!.copyWith(activeHeroId: heroId);
    _svc
        .updateActiveHero(uid: state!.uid, heroId: heroId)
        .catchError((e) => print('[PlayerNotifier] updateActiveHero: $e'));
  }

  Future<void> addSoftCoins(int amount) async {
    if (state == null) return;
    state = state!.copyWith(softCoins: state!.softCoins + amount);
    _svc.addSoftCoins(state!.uid, amount);
  }

  Future<void> addMedals(int amount) async {
    if (state == null) return;
    state = state!.copyWith(medals: state!.medals + amount);
    _svc.addMedals(state!.uid, amount);
  }

  Future<void> addTokens(int amount) async {
    if (state == null) return;
    state = state!.copyWith(tokens: state!.tokens + amount);
    _svc.addTokens(state!.uid, amount);
  }

  Future<bool> purchaseHeroWithCoins({
    required String heroId,
    required int coinCost,
  }) async {
    if (state == null || state!.softCoins < coinCost) return false;
    try {
      await _svc.spendCoinsAndUnlockHero(
        uid: state!.uid,
        heroId: heroId,
        cost: coinCost,
      );
      state = state!.copyWith(
        softCoins: state!.softCoins - coinCost,
        unlockedHeroIds: [...state!.unlockedHeroIds, heroId],
      );
      return true;
    } catch (e) {
      print('[PlayerNotifier] purchaseHeroWithCoins: $e');
      return false;
    }
  }

  Future<bool> purchaseHeroWithTokens({
    required String heroId,
    required int tokenCost,
  }) async {
    if (state == null || state!.tokens < tokenCost) return false;
    try {
      await _svc.spendTokensAndUnlockHero(
        uid: state!.uid,
        heroId: heroId,
        cost: tokenCost,
      );
      state = state!.copyWith(
        tokens: state!.tokens - tokenCost,
        unlockedHeroIds: [...state!.unlockedHeroIds, heroId],
      );
      return true;
    } catch (e) {
      print('[PlayerNotifier] purchaseHeroWithTokens: $e');
      return false;
    }
  }

  Future<void> grantBundle({
    required String heroId,
    required int tokenAmount,
  }) async {
    if (state == null) return;
    final alreadyOwned = state!.unlockedHeroIds.contains(heroId);
    state = state!.copyWith(
      tokens: state!.tokens + tokenAmount,
      unlockedHeroIds: alreadyOwned
          ? state!.unlockedHeroIds
          : [...state!.unlockedHeroIds, heroId],
    );
    await _svc.grantBundle(
      uid: state!.uid,
      heroId: heroId,
      tokenAmount: tokenAmount,
    );
  }

  Future<bool> convertTokensToSoftCoins({
    required int tokenCost,
    required int softCoinAmount,
  }) async {
    if (state == null || state!.tokens < tokenCost) return false;
    state = state!.copyWith(
      tokens: state!.tokens - tokenCost,
      softCoins: state!.softCoins + softCoinAmount,
    );
    _svc.addTokens(state!.uid, -tokenCost);
    _svc.addSoftCoins(state!.uid, softCoinAmount);
    return true;
  }

  Future<void> addBattlePoints(int amount) async {
    if (state == null) return;
    state = state!.copyWith(battlePoints: state!.battlePoints + amount);
    _svc.addBattlePoints(state!.uid, amount);
  }

  Future<void> claimProgressReward() async {
    if (state == null) return;
    final reward = ProgressRewardsData.currentReward(state!.lastClaimedCycleIndex);
    final newIndex = state!.lastClaimedCycleIndex + 1;

    var next = state!.copyWith(
      battlePoints: 0,
      lastClaimedCycleIndex: newIndex,
    );

    if (reward.type == ProgressRewardType.coins) {
      next = next.copyWith(softCoins: next.softCoins + reward.amount);
    } else if (reward.type == ProgressRewardType.tokens) {
      next = next.copyWith(tokens: next.tokens + reward.amount);
    } else if (reward.type == ProgressRewardType.card && reward.cardId != null) {
      final existing = next.ownedCards.where((c) => c.cardId == reward.cardId!).firstOrNull;
      final updatedCards = existing == null
          ? [...next.ownedCards, OwnedCard(cardId: reward.cardId!, quantity: 1)]
          : next.ownedCards
              .map((c) => c.cardId == reward.cardId!
                  ? OwnedCard(cardId: c.cardId, quantity: c.quantity + 1)
                  : c)
              .toList();
      next = next.copyWith(ownedCards: updatedCards);
    }

    state = next;

    _svc
        .claimProgressReward(
          state!.uid,
          newCycleIndex: newIndex,
          rewardType: reward.type,
          rewardAmount: reward.amount,
          rewardCardId: reward.cardId,
        )
        .catchError((e) => print('[PlayerNotifier] claimProgressReward: $e'));
  }
}

// ── Game Config (cargado desde Firestore al inicio) ───────────────────────

final gameConfigServiceProvider = Provider((_) => GameConfigService());

final gameConfigProvider =
    AsyncNotifierProvider<GameConfigNotifier, GameConfig>(
  GameConfigNotifier.new,
);

class GameConfigNotifier extends AsyncNotifier<GameConfig> {
  @override
  Future<GameConfig> build() async {
    try {
      final svc = ref.read(gameConfigServiceProvider);
      final results = await Future.wait([
        svc.fetchEnabledCards(),
        svc.fetchHeroes(),
        svc.fetchSettings(),
      ]);

      final cards    = results[0] as List<Map<String, dynamic>>;
      final heroes   = results[1] as List<Map<String, dynamic>>;
      final settings = results[2] as Map<String, dynamic>;

      final rawRewards = settings['progressRewards'] as List<dynamic>? ?? [];
      final rewards = rawRewards.isEmpty
          ? GameConfig.defaults.progressRewards
          : rawRewards
              .map((r) => ProgressRewardConfig.fromMap(r as Map<String, dynamic>))
              .toList();

      final rawPoints = settings['pointsPerWin'] as Map<String, dynamic>? ?? {};
      final pointsMap = {
        BotDifficulty.easy:   rawPoints['easy']   as int? ?? 3,
        BotDifficulty.normal: rawPoints['normal']  as int? ?? 5,
        BotDifficulty.hard:   rawPoints['hard']    as int? ?? 8,
      };

      final rawPointsSimple = settings['pointsPerWinSimple'] as Map<String, dynamic>? ?? {};
      final pointsSimpleMap = {
        BotDifficulty.easy:   rawPointsSimple['easy']   as int? ?? 2,
        BotDifficulty.normal: rawPointsSimple['normal']  as int? ?? 3,
        BotDifficulty.hard:   rawPointsSimple['hard']    as int? ?? 5,
      };

      final rawFeatures = settings['features'] as Map<String, dynamic>? ?? {};
      final features = GameFeatures.fromMap(rawFeatures);

      // Aplicar stats de Firestore a HeroesData (fuente primaria del juego)
      if (heroes.isNotEmpty) {
        HeroesData.applyOverrides(heroes);
      }

      return GameConfig(
        cards: cards,
        heroes: heroes,
        progressRewards: rewards,
        pointsPerWin: pointsMap,
        pointsPerWinSimple: pointsSimpleMap,
        features: features,
      );
    } catch (e) {
      debugPrint('[GameConfig] Error al cargar: $e — usando defaults');
      return GameConfig.defaults;
    }
  }
}

// ── Game State ─────────────────────────────────────────────────────────────

final selectedHeroProvider = StateProvider<GameHero?>((ref) => null);

// ── Dificultad de arena (se resetea a normal en cada pre-batalla) ──────────

final selectedDifficultyProvider =
    StateProvider<BotDifficulty>((ref) => BotDifficulty.normal);

// ── Modo de juego seleccionado (Normal / Experto) ──────────────────────────

final selectedGameModeProvider =
    StateProvider<GameMode>((ref) => GameMode.expert);
