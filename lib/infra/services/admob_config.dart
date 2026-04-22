/// ═══════════════════════════════════════════════════════════
/// ADMOB CONFIG — IDs de producción
/// ═══════════════════════════════════════════════════════════

class AdMobConfig {
  // ── iOS ──
  static const String appIdIOS = 'ca-app-pub-9552343552775183~1356877916';
  static const String bannerIdIOS = 'ca-app-pub-9552343552775183/8528790922';
  static const String interstitialIdIOS = 'ca-app-pub-9552343552775183/6647242359';
  static const String rewardedIdIOS = 'ca-app-pub-9552343552775183/5390908184';

  // ── Android (cuando lo necesites) ──
  static const String appIdAndroid = '';
  static const String bannerIdAndroid = '';
  static const String interstitialIdAndroid = '';
  static const String rewardedIdAndroid = '';

  // ── Test IDs (para desarrollo sin cobrar) ──
  static const String testBannerIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const String testInterstitialIOS = 'ca-app-pub-3940256099942544/4411468910';
  static const String testRewardedIOS = 'ca-app-pub-3940256099942544/1712485313';

  /// true = usa IDs de test, false = usa IDs reales
  /// IMPORTANTE: Dejá en true hasta que la app esté aprobada en AdMob
  static const bool useTestAds = true;

  // Helpers
  static String get bannerId =>
      useTestAds ? testBannerIOS : bannerIdIOS;
  static String get interstitialId =>
      useTestAds ? testInterstitialIOS : interstitialIdIOS;
  static String get rewardedId =>
      useTestAds ? testRewardedIOS : rewardedIdIOS;
}
