import 'dart:math';
import 'package:flutter/material.dart';

class StaminaGlobe extends StatefulWidget {
  final int currentStamina;
  final int remainingStamina;
  final double size;

  const StaminaGlobe({
    super.key,
    required this.currentStamina,
    required this.remainingStamina,
    this.size = 76.0,
  });

  @override
  State<StaminaGlobe> createState() => _StaminaGlobeState();
}

class _StaminaGlobeState extends State<StaminaGlobe>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _sloshController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _sloshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void didUpdateWidget(StaminaGlobe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.remainingStamina != widget.remainingStamina) {
      _sloshController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _sloshController.dispose();
    super.dispose();
  }

  Color _liquidColor(double ratio) {
    if (ratio > 0.6) return const Color(0xFF42A5F5);
    if (ratio > 0.3) return const Color(0xFFFFC107);
    return const Color(0xFFEF5350);
  }

  @override
  Widget build(BuildContext context) {
    final ratio = widget.currentStamina > 0
        ? widget.remainingStamina / widget.currentStamina
        : 0.0;
    final color = _liquidColor(ratio.clamp(0.0, 1.0));

    return AnimatedBuilder(
      animation: Listenable.merge([_waveController, _sloshController]),
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _StaminaLiquidPainter(
              fillRatio: ratio.clamp(0.0, 1.0),
              wavePhase: _waveController.value * 2 * pi,
              sloshValue: _sloshController.value,
              liquidColor: color,
              size: widget.size,
            ),
            child: child,
          ),
        );
      },
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.remainingStamina}',
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.size * 0.26,
                fontWeight: FontWeight.bold,
                shadows: const [
                  Shadow(color: Colors.black54, blurRadius: 4),
                ],
              ),
            ),
            Text(
              '/${widget.currentStamina}',
              style: TextStyle(
                color: Colors.white70,
                fontSize: widget.size * 0.14,
                shadows: const [
                  Shadow(color: Colors.black54, blurRadius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaminaLiquidPainter extends CustomPainter {
  final double fillRatio;
  final double wavePhase;
  final double sloshValue;
  final Color liquidColor;
  final double size;

  const _StaminaLiquidPainter({
    required this.fillRatio,
    required this.wavePhase,
    required this.sloshValue,
    required this.liquidColor,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(size / 2, size / 2);
    final radius = size / 2;

    // 1. Fondo oscuro
    final bgPaint = Paint()..color = const Color(0xFF0D0D1A);
    canvas.drawCircle(center, radius, bgPaint);

    // 2. Líquido con ola
    final amplitude = 1.5 + 4.0 * sloshValue; // base suave, pico al slosh
    final liquidTop = size - size * fillRatio;

    final liquidPath = Path();
    liquidPath.moveTo(0, liquidTop + sin(wavePhase) * amplitude);

    for (double x = 0; x <= size; x += 1.0) {
      final y = liquidTop + sin(x / size * 2 * pi * 1.5 + wavePhase) * amplitude;
      liquidPath.lineTo(x, y);
    }

    liquidPath.lineTo(size, size);
    liquidPath.lineTo(0, size);
    liquidPath.close();

    // Recortar al círculo
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius - 1)));

    final liquidPaint = Paint()..color = liquidColor.withValues(alpha: 0.85);
    canvas.drawPath(liquidPath, liquidPaint);

    // Highlight de ola secundaria (más tenue)
    final secondaryPath = Path();
    secondaryPath.moveTo(0, liquidTop + sin(wavePhase + pi) * amplitude * 0.4);
    for (double x = 0; x <= size; x += 1.0) {
      final y = liquidTop + sin(x / size * 2 * pi * 1.5 + wavePhase + pi) * amplitude * 0.4;
      secondaryPath.lineTo(x, y);
    }
    secondaryPath.lineTo(size, size);
    secondaryPath.lineTo(0, size);
    secondaryPath.close();

    final secondaryPaint = Paint()
      ..color = liquidColor.withValues(alpha: 0.3);
    canvas.drawPath(secondaryPath, secondaryPaint);

    canvas.restore();

    // 3. Glass overlay (highlight)
    final glassRect = Rect.fromCircle(center: center, radius: radius);
    final glassPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        radius: 0.7,
        colors: [
          Colors.white.withValues(alpha: 0.18),
          Colors.transparent,
        ],
      ).createShader(glassRect);
    canvas.drawCircle(center, radius - 1, glassPaint);

    // 4. Borde circular
    final borderColor = fillRatio > 0.6
        ? const Color(0xFF42A5F5)
        : fillRatio > 0.3
            ? const Color(0xFFFFC107)
            : const Color(0xFFEF5350);

    final borderPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 0.75, borderPaint);
  }

  @override
  bool shouldRepaint(_StaminaLiquidPainter old) =>
      old.fillRatio != fillRatio ||
      old.wavePhase != wavePhase ||
      old.sloshValue != sloshValue ||
      old.liquidColor != liquidColor;
}
