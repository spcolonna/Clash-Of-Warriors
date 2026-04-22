import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'admob_config.dart';
import '../../domain/config/game_config.dart';

/// AdMob Service — Implementación completa
/// Banner, Interstitial (cada N batallas), Rewarded (+tokens)
class AdMobService {
  static final AdMobService _instance = AdMobService._();
  factory AdMobService() => _instance;
  AdMobService._();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInitialized = false;

  /// Inicializar SDK — llamar en main()
  Future<void> initialize() async {
    if (_isInitialized) return;
    await MobileAds.instance.initialize();
    _isInitialized = true;
    _loadInterstitial();
    _loadRewarded();
  }

  // ═══ BANNER ══════════════════════════════════════════

  BannerAd? get bannerAd => _bannerAd;

  void loadBanner({
    required Function(Ad) onLoaded,
    required Function(Ad, LoadAdError) onFailed,
  }) {
    _bannerAd = BannerAd(
      adUnitId: AdMobConfig.bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          onFailed(ad, error);
        },
      ),
    )..load();
  }

  void disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  // ═══ INTERSTITIAL ════════════════════════════════════

  /// ¿Debería mostrar interstitial después de esta batalla?
  bool shouldShowInterstitial(int battleCount) {
    return battleCount > 0 &&
        battleCount % GameConfig.adInterstitialEveryNBattles == 0;
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: AdMobConfig.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitial(); // Pre-cargar el siguiente
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          // Reintentar después de 30 segundos
          Future.delayed(const Duration(seconds: 30), _loadInterstitial);
        },
      ),
    );
  }

  Future<void> showInterstitial() async {
    if (_interstitialAd != null) {
      await _interstitialAd!.show();
    } else {
      _loadInterstitial();
    }
  }

  // ═══ REWARDED ════════════════════════════════════════

  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: AdMobConfig.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          Future.delayed(const Duration(seconds: 30), _loadRewarded);
        },
      ),
    );
  }

  /// Muestra rewarded video. Retorna true si el usuario lo completó.
  /// El callback onRewarded se llama con la cantidad de tokens.
  Future<bool> showRewarded({
    required Function(int tokens) onRewarded,
  }) async {
    if (_rewardedAd == null) {
      _loadRewarded();
      return false;
    }

    bool completed = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewarded(); // Pre-cargar el siguiente
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewarded();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        completed = true;
        onRewarded(GameConfig.rewardedAdTokens);
      },
    );

    return completed;
  }

  bool get isRewardedReady => _rewardedAd != null;

  // ═══ CLEANUP ═════════════════════════════════════════

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
