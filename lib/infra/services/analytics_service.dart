/// Analytics Service — Firebase Analytics wrapper
/// Eventos que rastreamos para métricas de negocio.
///
/// TODO: Implementar con firebase_analytics: ^11.x

abstract class AnalyticsService {
  // ── Combate ──
  Future<void> logBattleStart({
    required String mode,      // '1v1' | '3v3' | 'story'
    required String difficulty,
    required String heroId,
    String? opponentHeroId,
  });

  Future<void> logBattleEnd({
    required String mode,
    required String result,    // 'win' | 'loss' | 'draw'
    required int rounds,
    required String heroId,
    int? tokensEarned,
  });

  Future<void> logTechniquePicked({
    required String technique,
    required String heroId,
    required String mode,
  });

  // ── Monetización ──
  Future<void> logPurchaseStarted({
    required String itemId,
    required double price,
    required String type,      // 'tokens' | 'pack' | 'pro'
  });

  Future<void> logPurchaseCompleted({
    required String itemId,
    required double price,
    required int tokensReceived,
  });

  Future<void> logAdWatched({
    required String adType,    // 'banner' | 'interstitial' | 'rewarded'
    int? tokensEarned,
  });

  // ── Progresión ──
  Future<void> logHeroUnlocked(String heroId);
  Future<void> logHeroLeveledUp(String heroId, int newLevel);
  Future<void> logStoryChapterCompleted(String heroId, int chapter);
  Future<void> logDailyRewardClaimed(int day, int tokens);

  // ── User Properties ──
  Future<void> setUserProperties({
    int? totalBattles,
    double? winRate,
    String? favoriteHero,
    bool? isPro,
    double? totalSpent,
  });
}
