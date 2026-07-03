import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Trama de medios tonos clásica de cómic: grilla de puntos cuyo radio
/// crece hacia un foco (gradiente radial).
class HalftonePainter extends CustomPainter {
  final Color dotColor;
  final double spacing;
  final double minRadius;
  final double maxRadius;
  /// Foco del gradiente en coordenadas relativas (0..1, 0..1).
  final Alignment focus;
  final double opacity;

  const HalftonePainter({
    required this.dotColor,
    this.spacing = 9,
    this.minRadius = 0.4,
    this.maxRadius = 2.6,
    this.focus = Alignment.bottomRight,
    this.opacity = 0.25,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor.withValues(alpha: opacity);
    final fx = (focus.x + 1) / 2 * size.width;
    final fy = (focus.y + 1) / 2 * size.height;
    final maxDist = math.sqrt(size.width * size.width + size.height * size.height);

    for (double y = spacing / 2; y < size.height; y += spacing) {
      // desplazamiento alternado de columnas (grilla de imprenta)
      final rowOffset = ((y / spacing).floor() % 2) * spacing / 2;
      for (double x = spacing / 2 + rowOffset; x < size.width; x += spacing) {
        final dist = math.sqrt((x - fx) * (x - fx) + (y - fy) * (y - fy));
        final t = (1 - dist / maxDist).clamp(0.0, 1.0);
        final r = minRadius + (maxRadius - minRadius) * t * t;
        canvas.drawCircle(Offset(x, y), r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant HalftonePainter old) =>
      old.dotColor != dotColor ||
      old.spacing != spacing ||
      old.focus != focus ||
      old.opacity != opacity;
}

/// Burst radial de rayos (fondo de portadas y onomatopeyas).
class SunburstPainter extends CustomPainter {
  final Color color;
  final int rays;
  final double opacity;

  const SunburstPainter({
    required this.color,
    this.rays = 24,
    this.opacity = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.max(size.width, size.height);

    for (int i = 0; i < rays; i++) {
      final a0 = (i * 2 * math.pi / rays);
      final a1 = a0 + math.pi / rays * 0.55;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(center.dx + math.cos(a0) * radius,
            center.dy + math.sin(a0) * radius)
        ..lineTo(center.dx + math.cos(a1) * radius,
            center.dy + math.sin(a1) * radius)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SunburstPainter old) =>
      old.color != color || old.rays != rays || old.opacity != opacity;
}

/// Líneas de velocidad/acción que convergen hacia un foco.
class SpeedLinesPainter extends CustomPainter {
  final Color color;
  final Alignment focus;
  final int lines;
  final double opacity;

  const SpeedLinesPainter({
    required this.color,
    this.focus = Alignment.center,
    this.lines = 36,
    this.opacity = 0.35,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeCap = StrokeCap.round;
    final fx = (focus.x + 1) / 2 * size.width;
    final fy = (focus.y + 1) / 2 * size.height;
    final maxR = math.sqrt(size.width * size.width + size.height * size.height);

    for (int i = 0; i < lines; i++) {
      // Jitter determinístico por índice
      final seed = (i * 2654435761) & 0xFFFF;
      final jA = (seed % 1000) / 1000.0;
      final jL = ((seed >> 6) % 1000) / 1000.0;

      final angle = i * 2 * math.pi / lines + jA * 0.15;
      final inner = maxR * (0.32 + jL * 0.22);
      paint.strokeWidth = 1.0 + jL * 2.2;
      canvas.drawLine(
        Offset(fx + math.cos(angle) * inner, fy + math.sin(angle) * inner),
        Offset(fx + math.cos(angle) * maxR, fy + math.sin(angle) * maxR),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SpeedLinesPainter old) =>
      old.color != color || old.focus != focus || old.opacity != opacity;
}
