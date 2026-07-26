// lib/delivery/state/providers.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/hero.dart';
import '../../domain/entities/hero_entity.dart';
import '../../domain/entities/player_profile.dart';
import '../../infra/local/card_catalog.dart';
import '../../infra/firebase/firebase_auth_service.dart';
import '../../infra/firebase/firebase_game_service.dart';
import '../../infra/firebase/firestore_player_repository.dart';
import '../../infra/firebase/firebase_analytics_service.dart';
import '../../infra/local/neutral_cards_data.dart';
import '../../infra/services/admob_service.dart';
import '../../infra/services/game_seed_service.dart';
import '../../infra/sound/sound_service.dart';
import '../../domain/entities/battle_state.dart' show BotDifficulty, GameMode;
import '../../domain/config/game_config.dart' as cfg;
import '../../domain/entities/game_config.dart';
import '../../infra/firebase/game_config_service.dart';
import '../../infra/local/heroes_data.dart';
import '../../infra/local/progress_rewards_data.dart';
import '../../infra/local/daily_rewards_data.dart';
import '../../infra/local/daily_missions_data.dart';
import '../../domain/entities/daily_mission.dart';
import '../../infra/config/premium_shop_config.dart';
import '../../infra/local/new_player_journey_data.dart';
import '../../infra/local/story_arcs_data.dart';
import '../../domain/entities/story_arc.dart';

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

/// Resultado de contabilizar el login del día (para el dialog de bienvenida).
class DailyLoginResult {
  final int streak;
  final DailyReward reward;
  const DailyLoginResult({required this.streak, required this.reward});
}

final playerProvider =
StateNotifierProvider<PlayerNotifier, PlayerProfile?>((ref) {
  return PlayerNotifier(ref);
});

/// Aplica al héroe del catálogo las estrellas de ascensión que tiene el
/// jugador. Fuente de verdad única: la batalla y TODA pantalla que muestre
/// stats deben pasar por acá, o un héroe 2★ se ve con stats de 1★.
HeroEntity heroWithAscension(HeroEntity hero, PlayerProfile? player) {
  final stars = player?.heroStarsFor(hero.id) ?? 1;
  return stars > 1 ? hero.copyWith(stars: stars) : hero;
}

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
    List<String> cardIds = const [],
  }) async {
    if (state == null) return;
    final alreadyOwned = state!.unlockedHeroIds.contains(heroId);

    // Sumar cartas del bundle al estado local (incrementando cantidades)
    final owned = List<OwnedCard>.from(state!.ownedCards);
    for (final cardId in cardIds) {
      final idx = owned.indexWhere((c) => c.cardId == cardId);
      if (idx >= 0) {
        owned[idx] =
            OwnedCard(cardId: cardId, quantity: owned[idx].quantity + 1);
      } else {
        owned.add(OwnedCard(cardId: cardId, quantity: 1));
      }
    }

    state = state!.copyWith(
      tokens: state!.tokens + tokenAmount,
      unlockedHeroIds: alreadyOwned
          ? state!.unlockedHeroIds
          : [...state!.unlockedHeroIds, heroId],
      ownedCards: owned,
    );
    await _svc.grantBundle(
      uid: state!.uid,
      heroId: heroId,
      tokenAmount: tokenAmount,
      cardIds: cardIds,
    );
  }

  /// Ascensión de héroe: gasta medallas y sube una estrella (★2..★5).
  /// Retorna false si no alcanzan las medallas o ya está al máximo.
  Future<bool> ascendHero(String heroId) async {
    if (state == null) return false;
    final current = state!.heroStarsFor(heroId);
    final cost = cfg.GameConfig.ascensionCostFrom(current);
    if (cost == null || state!.medals < cost) return false;

    final newStars = current + 1;
    state = state!.copyWith(
      medals: state!.medals - cost,
      heroStars: {...state!.heroStars, heroId: newStars},
    );
    try {
      await _svc.ascendHero(
        uid: state!.uid,
        heroId: heroId,
        newStars: newStars,
        medalCost: cost,
      );
      return true;
    } catch (e) {
      print('[PlayerNotifier] ascendHero: $e');
      return false;
    }
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
    // Leaderboard semanal: cada victoria de arena suma al ranking.
    final name = FirebaseAuth.instance.currentUser?.displayName ?? 'Guerrero';
    _svc
        .submitWeeklyPoints(
          uid: state!.uid,
          displayName: name,
          points: amount,
        )
        .catchError((_) {}); // el ranking nunca bloquea el flujo
  }

  // ── Retención: login diario + XP de cuenta ──────────────────────────────────

  String _todayStr() => DateTime.now().toIso8601String().substring(0, 10);

  /// Contabiliza el login del día. Actualiza la racha, otorga la recompensa
  /// correspondiente y persiste. Retorna el resultado para el dialog, o null
  /// si el login de hoy ya fue contabilizado.
  DailyLoginResult? processDailyLogin() {
    if (state == null) return null;
    final today = _todayStr();
    final last = state!.lastLoginDate;
    if (last == today) return null; // ya contado hoy

    int newStreak;
    if (last == null) {
      newStreak = 1;
    } else {
      final lastDate = DateTime.tryParse(last);
      final todayDate = DateTime.tryParse(today);
      if (lastDate != null && todayDate != null) {
        final diff = todayDate.difference(lastDate).inDays;
        newStreak = diff == 1 ? state!.loginStreak + 1 : 1;
      } else {
        newStreak = 1;
      }
    }

    final reward = DailyRewardsData.rewardForStreak(newStreak);
    var next = state!.copyWith(lastLoginDate: today, loginStreak: newStreak);
    next = _applyDailyReward(next, reward);
    state = next;
    _svc.savePlayer(state!).catchError(
        (e) => print('[PlayerNotifier] processDailyLogin: $e'));
    return DailyLoginResult(streak: newStreak, reward: reward);
  }

  PlayerProfile _applyDailyReward(PlayerProfile p, DailyReward r) {
    switch (r.type) {
      case DailyRewardType.coins:
        return p.copyWith(softCoins: p.softCoins + r.amount);
      case DailyRewardType.tokens:
        return p.copyWith(tokens: p.tokens + r.amount);
      case DailyRewardType.card:
        if (r.cardId == null) return p;
        final existing =
            p.ownedCards.where((c) => c.cardId == r.cardId).firstOrNull;
        final updated = existing == null
            ? [...p.ownedCards, OwnedCard(cardId: r.cardId!, quantity: 1)]
            : p.ownedCards
                .map((c) => c.cardId == r.cardId
                    ? OwnedCard(cardId: c.cardId, quantity: c.quantity + 1)
                    : c)
                .toList();
        return p.copyWith(ownedCards: updated);
    }
  }

  /// Marca y reporta si es la primera victoria del día (para duplicar premio).
  /// Retorna true solo la primera vez que se llama en el día.
  bool consumeFirstWinOfDay() {
    if (state == null) return false;
    final today = _todayStr();
    if (state!.lastDailyWinDate == today) return false;
    state = state!.copyWith(lastDailyWinDate: today);
    _svc.savePlayer(state!).catchError(
        (e) => print('[PlayerNotifier] consumeFirstWinOfDay: $e'));
    return true;
  }

  /// Suma XP de cuenta, otorga monedas por cada nivel ganado y persiste.
  /// Retorna la cantidad de niveles subidos (0 si ninguno).
  int addAccountXp(int amount) {
    if (state == null || amount <= 0) return 0;
    final before = state!.accountLevel;
    var next = state!.copyWith(accountXp: state!.accountXp + amount);
    final levelsGained = next.accountLevel - before;
    if (levelsGained > 0) {
      next = next.copyWith(
        softCoins: next.softCoins + levelsGained * DailyRewardsData.coinsPerLevelUp,
      );
    }
    state = next;
    _svc.savePlayer(state!).catchError(
        (e) => print('[PlayerNotifier] addAccountXp: $e'));
    return levelsGained;
  }

  // ── Misiones diarias ────────────────────────────────────────────────────────

  /// Genera 3 misiones nuevas si las actuales son de otro día. Se llama al
  /// abrir la app. Idempotente dentro del mismo día.
  void ensureDailyMissions() {
    if (state == null) return;
    final today = _todayStr();
    if (state!.missionsDate == today && state!.dailyMissions.isNotEmpty) return;
    state = state!.copyWith(
      dailyMissions: DailyMissionsData.generateDaily(),
      missionsDate: today,
    );
    _svc.savePlayer(state!).catchError(
        (e) => print('[PlayerNotifier] ensureDailyMissions: $e'));
  }

  /// Reporta el resultado de una batalla y avanza el progreso de las misiones.
  void reportBattleResult({
    required bool won,
    required int slotsWon,
    required bool wasHard,
    required int scoutsUsed,
  }) {
    if (state == null || state!.dailyMissions.isEmpty) return;

    final updated = state!.dailyMissions.map((m) {
      if (m.claimed || m.isComplete) return m;
      final inc = switch (m.type) {
        DailyMissionType.winBattles  => won ? 1 : 0,
        DailyMissionType.playBattles => 1,
        DailyMissionType.winSlots    => slotsWon,
        DailyMissionType.useScout    => scoutsUsed,
        DailyMissionType.playHard    => wasHard ? 1 : 0,
      };
      if (inc == 0) return m;
      return m.copyWith(progress: (m.progress + inc).clamp(0, m.target));
    }).toList();

    state = state!.copyWith(dailyMissions: updated);
    _svc.savePlayer(state!).catchError(
        (e) => print('[PlayerNotifier] reportBattleResult: $e'));
  }

  /// Cobra la recompensa de una misión completa. No-op si no está lista.
  void claimMission(String missionId) {
    if (state == null) return;
    final mission =
        state!.dailyMissions.where((m) => m.id == missionId).firstOrNull;
    if (mission == null || !mission.isComplete || mission.claimed) return;

    final updated = state!.dailyMissions
        .map((m) => m.id == missionId ? m.copyWith(claimed: true) : m)
        .toList();

    var next = state!.copyWith(dailyMissions: updated);
    if (mission.rewardType == 'tokens') {
      next = next.copyWith(tokens: next.tokens + mission.rewardAmount);
    } else {
      next = next.copyWith(softCoins: next.softCoins + mission.rewardAmount);
    }
    state = next;
    _svc.savePlayer(state!).catchError(
        (e) => print('[PlayerNotifier] claimMission: $e'));
  }

  // ── Camino del nuevo jugador ────────────────────────────────────────────────

  /// Cobra un hito del camino del nuevo jugador. No-op si no está completo o
  /// ya fue cobrado.
  void claimMilestone(String milestoneId) {
    if (state == null) return;
    if (state!.claimedMilestones.contains(milestoneId)) return;
    final milestone = NewPlayerJourneyData.milestones
        .where((m) => m.id == milestoneId)
        .firstOrNull;
    if (milestone == null || !milestone.isComplete(state!)) return;

    var next = state!.copyWith(
      claimedMilestones: [...state!.claimedMilestones, milestoneId],
    );
    if (milestone.rewardType == 'tokens') {
      next = next.copyWith(tokens: next.tokens + milestone.rewardAmount);
    } else {
      next = next.copyWith(softCoins: next.softCoins + milestone.rewardAmount);
    }
    state = next;
    _svc.savePlayer(state!).catchError(
        (e) => print('[PlayerNotifier] claimMilestone: $e'));
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

  // ── Modo Historia ─────────────────────────────────────────────────────────

  Future<void> updateStoryProgress(String heroId, String rarity, int stageIndex) async {
    if (state == null) return;
    final key = '${heroId}_$rarity';
    final newMap = Map<String, int>.from(state!.storyProgress)..[key] = stageIndex;
    state = state!.copyWith(storyProgress: newMap);
    _svc
        .saveStoryProgress(uid: state!.uid, arcKey: key, stageIndex: stageIndex)
        .catchError((e) => print('[PlayerNotifier] updateStoryProgress: $e'));
  }

  Future<void> completeStoryArc(String heroId, String rarity) async {
    if (state == null) return;
    final key = '${heroId}_$rarity';
    final rewardId = PlayerProfile.rewardHeroId(heroId, rarity);

    final newCompleted = {...state!.completedStoryArcs, key};
    final newUnlocked = rewardId != null && !state!.unlockedHeroIds.contains(rewardId)
        ? [...state!.unlockedHeroIds, rewardId]
        : state!.unlockedHeroIds;
    final newAchievements = rarity == 'legendary' && !state!.achievements.contains('dragon_path_$heroId')
        ? [...state!.achievements, 'dragon_path_$heroId']
        : state!.achievements;

    state = state!.copyWith(
      completedStoryArcs: newCompleted,
      unlockedHeroIds: newUnlocked,
      achievements: newAchievements,
    );

    _svc
        .completeStoryArc(uid: state!.uid, arcKey: key, rewardHeroId: rewardId)
        .catchError((e) => print('[PlayerNotifier] completeStoryArc: $e'));

    if (rarity == 'legendary') {
      _svc
          .grantAchievement(uid: state!.uid, achievementId: 'dragon_path_$heroId')
          .catchError((e) => print('[PlayerNotifier] grantAchievement: $e'));
    }
  }
}

// ── Game Config (cargado desde Firestore al inicio) ───────────────────────

final gameConfigServiceProvider = Provider((_) => GameConfigService());

final gameConfigProvider =
    AsyncNotifierProvider<GameConfigNotifier, GameConfig>(
  GameConfigNotifier.new,
);

/// Registro global de cartas, derivado de la config remota. Se reconstruye
/// cuando llegan/cambian las cartas de Firestore.
final cardCatalogProvider = Provider<CardCatalog>((ref) {
  final cards = ref.watch(gameConfigProvider).value?.cards ?? const [];
  return CardCatalog.build(cards);
});

/// Catálogo de la tienda premium: Firestore (premium_shop/*) con fallback al
/// hardcodeado local, filtrado por isEnabled. Depende de gameConfigProvider
/// para que "Recargar contenido del juego" también lo refresque.
final premiumShopProvider = FutureProvider<PremiumShopData>((ref) async {
  ref.watch(gameConfigProvider);
  try {
    final remote =
        await ref.read(gameConfigServiceProvider).fetchPremiumShop();
    return PremiumShopData.fromRemote(remote);
  } catch (e) {
    debugPrint('[PremiumShop] Error al cargar remoto: $e — usando local');
    return PremiumShopData.localOnly();
  }
});

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

      final rawBattleRewards =
          settings['battleRewards'] as Map<String, dynamic>? ?? {};
      final battleRewards = BattleRewardsConfig.fromMap(rawBattleRewards);

      // Aplicar stats de Firestore a HeroesData (fuente primaria del juego)
      if (heroes.isNotEmpty) {
        HeroesData.applyOverrides(heroes);
      }

      // Cargar arcos de historia desde Firestore y aplicar a StoryArcsData
      final gameSvc = ref.read(firebaseGameServiceProvider);
      final storyArcs = await gameSvc.loadStoryArcs().catchError((_) => <Map<String, dynamic>>[]);
      if (storyArcs.isNotEmpty) {
        StoryArcsData.applyRemoteArcs(storyArcs);
      }

      return GameConfig(
        cards: cards,
        heroes: heroes,
        storyArcs: storyArcs,
        progressRewards: rewards,
        pointsPerWin: pointsMap,
        pointsPerWinSimple: pointsSimpleMap,
        features: features,
        battleRewards: battleRewards,
      );
    } catch (e) {
      debugPrint('[GameConfig] Error al cargar: $e — usando defaults');
      return GameConfig.defaults;
    }
  }
}

// ── Game State ─────────────────────────────────────────────────────────────

final selectedHeroProvider = StateProvider<GameHero?>((ref) => null);

// ── Dificultad y modo de arena (persistidos entre sesiones) ────────────────

final selectedDifficultyProvider =
    NotifierProvider<SelectedDifficultyNotifier, BotDifficulty>(
  SelectedDifficultyNotifier.new,
);

class SelectedDifficultyNotifier extends Notifier<BotDifficulty> {
  static const _prefsKey = 'selectedDifficulty';

  @override
  BotDifficulty build() {
    SharedPreferences.getInstance().then((prefs) {
      final name = prefs.getString(_prefsKey);
      if (name != null) {
        state = BotDifficulty.values.firstWhere(
          (d) => d.name == name,
          orElse: () => BotDifficulty.normal,
        );
      }
    });
    return BotDifficulty.normal;
  }

  void select(BotDifficulty d) {
    state = d;
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setString(_prefsKey, d.name));
  }
}

final selectedGameModeProvider =
    NotifierProvider<SelectedGameModeNotifier, GameMode>(
  SelectedGameModeNotifier.new,
);

class SelectedGameModeNotifier extends Notifier<GameMode> {
  static const _prefsKey = 'selectedGameMode';

  @override
  GameMode build() {
    SharedPreferences.getInstance().then((prefs) {
      final name = prefs.getString(_prefsKey);
      if (name != null) {
        state = GameMode.values.firstWhere(
          (m) => m.name == name,
          orElse: () => GameMode.expert,
        );
      }
    });
    return GameMode.expert;
  }

  void select(GameMode m) {
    state = m;
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setString(_prefsKey, m.name));
  }
}

// ── Contexto de batalla de historia ───────────────────────────────────────
// null cuando no hay historia activa; se setea antes de ir a /battle en modo historia

final storyBattleContextProvider = StateProvider<StoryBattleContext?>((_) => null);
