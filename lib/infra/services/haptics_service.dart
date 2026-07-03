import 'package:flutter/services.dart';

/// Servicio centralizado de vibración háptica.
/// Todos los llamados son fire-and-forget y seguros en plataformas
/// sin soporte (desktop/web: no-op silencioso).
class HapticsService {
  static final HapticsService _instance = HapticsService._();
  factory HapticsService() => _instance;
  HapticsService._();

  bool enabled = true;
  void toggle() => enabled = !enabled;

  /// Tap liviano: selección de carta, botones de menú.
  void light() {
    if (!enabled) return;
    HapticFeedback.lightImpact();
  }

  /// Impacto medio: colocar carta en slot, scout.
  void medium() {
    if (!enabled) return;
    HapticFeedback.mediumImpact();
  }

  /// Impacto fuerte: clash de cartas, daño recibido.
  void heavy() {
    if (!enabled) return;
    HapticFeedback.heavyImpact();
  }

  /// Feedback de selección (picker-style).
  void selection() {
    if (!enabled) return;
    HapticFeedback.selectionClick();
  }

  /// Vibración larga: KO, victoria/derrota.
  void success() {
    if (!enabled) return;
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (enabled) HapticFeedback.mediumImpact();
    });
  }

  /// Error: acción inválida (sin stamina, slot bloqueado).
  void error() {
    if (!enabled) return;
    HapticFeedback.vibrate();
  }
}
