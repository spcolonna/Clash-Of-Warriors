/// AdMob Service — Maneja banner, interstitial y rewarded ads
/// 
/// TODO: Implementar con google_mobile_ads: ^5.x
/// 
/// IDs de test (reemplazar en producción):
///   Banner iOS:        ca-app-pub-3940256099942544/2934735716
///   Banner Android:    ca-app-pub-3940256099942544/6300978111
///   Interstitial iOS:  ca-app-pub-3940256099942544/4411468910
///   Interstitial And:  ca-app-pub-3940256099942544/1033173712
///   Rewarded iOS:      ca-app-pub-3940256099942544/1712485313
///   Rewarded And:      ca-app-pub-3940256099942544/5224354917

import '../../domain/config/game_config.dart';

abstract class AdService {
  /// Inicializar AdMob SDK
  Future<void> initialize();

  /// Cargar y mostrar banner en pantallas configuradas
  Future<void> showBanner(String screenName);
  void hideBanner();

  /// Mostrar interstitial (cada N batallas, ver GameConfig)
  Future<void> showInterstitial();
  bool shouldShowInterstitial(int battleCount) =>
      battleCount % GameConfig.adInterstitialEveryNBattles == 0;

  /// Mostrar rewarded video y retornar true si completado
  Future<bool> showRewardedAd();

  void dispose();
}
