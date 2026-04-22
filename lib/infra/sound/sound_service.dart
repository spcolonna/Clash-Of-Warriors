import 'package:audioplayers/audioplayers.dart';
import '../../domain/config/game_config.dart';
import '../../domain/entities/technique.dart';

/// Servicio de sonido centralizado.
/// Usa audioplayers para reproducir SFX.
/// Los archivos van en assets/sounds/ (ver GameConfig.sfxFiles).
class SoundService {
  static final SoundService _instance = SoundService._();
  factory SoundService() => _instance;
  SoundService._();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  bool _sfxEnabled = true;
  bool _musicEnabled = true;
  double _sfxVolume = 1.0;
  double _musicVolume = 0.5;

  bool get sfxEnabled => _sfxEnabled;
  bool get musicEnabled => _musicEnabled;

  void toggleSfx() => _sfxEnabled = !_sfxEnabled;
  void toggleMusic() {
    _musicEnabled = !_musicEnabled;
    if (!_musicEnabled) _musicPlayer.stop();
  }

  void setSfxVolume(double v) => _sfxVolume = v.clamp(0.0, 1.0);
  void setMusicVolume(double v) {
    _musicVolume = v.clamp(0.0, 1.0);
    _musicPlayer.setVolume(_musicVolume);
  }

  /// Reproducir un SFX por su key (ver GameConfig.sfxFiles)
  Future<void> play(String key) async {
    if (!_sfxEnabled) return;
    final file = GameConfig.sfxFiles[key];
    if (file == null) return;
    try {
      await _sfxPlayer.setVolume(_sfxVolume);
      await _sfxPlayer.play(AssetSource('sounds/$file'));
    } catch (e) {
      // Silently fail — no crashear por un sonido faltante
    }
  }

  /// Reproducir SFX de técnica según resultado
  Future<void> playTechniqueResult({
    required Technique technique,
    required bool hit,
  }) async {
    if (hit) {
      // Primero el sonido de la técnica, luego el hit
      switch (technique) {
        case Technique.fist:
          await play('punch');
          break;
        case Technique.kick:
          await play('kick');
          break;
        case Technique.grapple:
          await play('grapple');
          break;
        case Technique.block:
          await play('block');
          break;
        case Technique.palm:
          await play('palm');
          break;
      }
    } else {
      await play('block');
    }
  }

  /// Reproducir música de fondo (loop)
  Future<void> playMusic(String file) async {
    if (!_musicEnabled) return;
    try {
      await _musicPlayer.setVolume(_musicVolume);
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(AssetSource('sounds/$file'));
    } catch (_) {}
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  void dispose() {
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
  }
}
