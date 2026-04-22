/// Local Storage — SharedPreferences wrapper para modo offline
/// Guarda perfil local como fallback cuando no hay conexión.
///
/// Dependencia: shared_preferences: ^2.x

import '../../domain/entities/player.dart';

abstract class LocalStorage {
  Future<void> saveProfile(PlayerProfile profile);
  Future<PlayerProfile?> loadProfile();
  Future<void> clearProfile();

  // Settings
  Future<void> setSfxEnabled(bool enabled);
  Future<bool> getSfxEnabled();
  Future<void> setMusicEnabled(bool enabled);
  Future<bool> getMusicEnabled();
  Future<void> setLanguage(String langCode);
  Future<String?> getLanguage();

  // Battle count (para interstitial ads)
  Future<int> incrementBattleCount();
  Future<int> getBattleCount();
}
