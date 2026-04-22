import 'package:firebase_analytics/firebase_analytics.dart';

/// Firebase Analytics — Implementación con eventos reales
class FirebaseAnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ── Combate ──
  Future<void> logBattleStart({
    required String mode,
    required String difficulty,
    required String heroId,
    String? opponentHeroId,
  }) async {
    await _analytics.logEvent(name: 'battle_start', parameters: {
      'mode': mode,
      'difficulty': difficulty,
      'hero_id': heroId,
      if (opponentHeroId != null) 'opponent_hero_id': opponentHeroId,
    });
  }

  Future<void> logBattleEnd({
    required String mode,
    required String result,
    required int rounds,
    required String heroId,
    int? tokensEarned,
  }) async {
    await _analytics.logEvent(name: 'battle_end', parameters: {
      'mode': mode,
      'result': result,
      'rounds': rounds,
      'hero_id': heroId,
      if (tokensEarned != null) 'tokens_earned': tokensEarned,
    });
  }

  Future<void> logTechniquePicked({
    required String technique,
    required String heroId,
    required String mode,
  }) async {
    await _analytics.logEvent(name: 'technique_picked', parameters: {
      'technique': technique,
      'hero_id': heroId,
      'mode': mode,
    });
  }

  // ── Monetización ──
  Future<void> logPurchaseStarted({
    required String itemId,
    required double price,
    required String type,
  }) async {
    await _analytics.logEvent(name: 'purchase_started', parameters: {
      'item_id': itemId,
      'price': price,
      'type': type,
    });
  }

  Future<void> logPurchaseCompleted({
    required String itemId,
    required double price,
    required int tokensReceived,
  }) async {
    await _analytics.logPurchase(
      currency: 'USD',
      value: price,
      items: [AnalyticsEventItem(itemId: itemId, quantity: tokensReceived)],
    );
  }

  Future<void> logAdWatched({
    required String adType,
    int? tokensEarned,
  }) async {
    await _analytics.logEvent(name: 'ad_watched', parameters: {
      'ad_type': adType,
      if (tokensEarned != null) 'tokens_earned': tokensEarned,
    });
  }

  // ── Progresión ──
  Future<void> logHeroUnlocked(String heroId) async {
    await _analytics.logEvent(name: 'hero_unlocked', parameters: {'hero_id': heroId});
  }

  Future<void> logHeroLeveledUp(String heroId, int newLevel) async {
    await _analytics.logLevelUp(level: newLevel, character: heroId);
  }

  Future<void> logStoryChapterCompleted(String heroId, int chapter) async {
    await _analytics.logEvent(name: 'story_chapter_completed', parameters: {
       'hero_id': heroId,
       'chapter': chapter,
    });
  }

  Future<void> logDailyRewardClaimed(int day, int tokens) async {
    await _analytics.logEvent(name: 'daily_reward', parameters: {
      'day': day,
      'tokens': tokens,
    });
  }

  // ── User Properties ──
  Future<void> setUserProperties({
    int? totalBattles,
    double? winRate,
    String? favoriteHero,
    bool? isPro,
  }) async {
    if (totalBattles != null) {
      await _analytics.setUserProperty(
          name: 'total_battles', value: totalBattles.toString());
    }
    if (winRate != null) {
      await _analytics.setUserProperty(
          name: 'win_rate', value: winRate.toStringAsFixed(2));
    }
    if (favoriteHero != null) {
      await _analytics.setUserProperty(
          name: 'favorite_hero', value: favoriteHero);
    }
    if (isPro != null) {
      await _analytics.setUserProperty(
          name: 'is_pro', value: isPro.toString());
    }
  }

  // ── Screen tracking ──
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }
}
