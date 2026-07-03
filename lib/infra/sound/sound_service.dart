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

  // Pool de players para permitir SFX superpuestos (clash + hit + whoosh)
  // sin que uno corte al otro.
  static const _poolSize = 4;
  final List<AudioPlayer> _sfxPool =
      List.generate(_poolSize, (_) => AudioPlayer());
  int _poolIndex = 0;
  final AudioPlayer _musicPlayer = AudioPlayer();
  bool _initialized = false;

  /// Configura el pool en modo low-latency (AVAudioPlayer/SoundPool en vez
  /// de AVPlayer — evita el leak de continuation en iOS) y pre-carga los
  /// SFX para que el primer disparo no trabe el juego.
  /// Llamar una vez al inicio de la app; los errores no son fatales.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      for (final p in _sfxPool) {
        await p.setPlayerMode(PlayerMode.lowLatency);
        await p.setReleaseMode(ReleaseMode.stop);
        await p.setVolume(_sfxVolume);
      }
      await AudioCache.instance.loadAll(
        GameConfig.sfxFiles.values.map((f) => 'sounds/$f').toList(),
      );
    } catch (_) {
      // Sin audio no se rompe el juego
    }
  }
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

  void setSfxVolume(double v) {
    _sfxVolume = v.clamp(0.0, 1.0);
    for (final p in _sfxPool) {
      p.setVolume(_sfxVolume).ignore();
    }
  }
  void setMusicVolume(double v) {
    _musicVolume = v.clamp(0.0, 1.0);
    _musicPlayer.setVolume(_musicVolume);
  }

  /// Reproducir un SFX por su key (ver GameConfig.sfxFiles).
  /// Fire-and-forget: nunca bloquea al caller aunque el player nativo
  /// se cuelgue (bug conocido de AVPlayer en iOS).
  void play(String key) {
    if (!_sfxEnabled) return;
    final file = GameConfig.sfxFiles[key];
    if (file == null) return;
    if (!_initialized) init().ignore();
    try {
      final player = _sfxPool[_poolIndex];
      _poolIndex = (_poolIndex + 1) % _poolSize;
      player.play(AssetSource('sounds/$file')).catchError((_) {
        // Silently fail — no crashear por un sonido faltante
      });
    } catch (_) {}
  }

  /// Reproducir SFX de técnica según resultado
  void playTechniqueResult({
    required Technique technique,
    required bool hit,
  }) {
    if (!hit) {
      play('block');
      return;
    }
    switch (technique) {
      case Technique.fist:
        play('punch');
      case Technique.kick:
        play('kick');
      case Technique.grapple:
        play('grapple');
      case Technique.block:
        play('block');
      case Technique.palm:
        play('palm');
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
    for (final p in _sfxPool) {
      p.dispose();
    }
    _musicPlayer.dispose();
  }
}
