// lib/delivery/widgets/tutorial_spotlight_overlay.dart
//
// Overlay de tutorial que oscurece toda la pantalla excepto un círculo
// alrededor del widget target. Muestra una flecha animada y texto guía.
//
// Uso:
//   TutorialSpotlightOverlay(
//     targetKey: someGlobalKey,
//     message: 'Tocá aquí para continuar',
//     onDismiss: () => ...,
//   )

import 'dart:math' as math;
import 'package:flutter/material.dart';

class TutorialSpotlightOverlay extends StatefulWidget {
  final GlobalKey targetKey;
  final String message;
  final VoidCallback? onDismiss;
  final double spotlightPadding;

  const TutorialSpotlightOverlay({
    super.key,
    required this.targetKey,
    required this.message,
    this.onDismiss,
    this.spotlightPadding = 12,
  });

  @override
  State<TutorialSpotlightOverlay> createState() =>
      _TutorialSpotlightOverlayState();
}

class _TutorialSpotlightOverlayState extends State<TutorialSpotlightOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _arrowController;
  late AnimationController _fadeController;

  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();

    // Medir el target después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureTarget());
  }

  void _measureTarget() {
    final context = widget.targetKey.currentContext;
    if (context == null) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final offset = box.localToGlobal(Offset.zero);
    setState(() {
      _targetRect = Rect.fromLTWH(
        offset.dx,
        offset.dy,
        box.size.width,
        box.size.height,
      );
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _arrowController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_targetRect == null) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final spotlightCenter = _targetRect!.center;
    final radius = math.max(_targetRect!.width, _targetRect!.height) / 2 +
        widget.spotlightPadding;

    // Decidir posición del texto: arriba o abajo del spotlight
    final showTextAbove = spotlightCenter.dy > screenSize.height * 0.5;
    final textTop = showTextAbove
        ? spotlightCenter.dy - radius - 180
        : spotlightCenter.dy + radius + 60;

    return FadeTransition(
      opacity: _fadeController,
      child: GestureDetector(
        onTap: widget.onDismiss,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Capa oscura con hueco circular
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                final pulse = 1 + _pulseController.value * 0.08;
                return CustomPaint(
                  size: screenSize,
                  painter: _SpotlightPainter(
                    center: spotlightCenter,
                    radius: radius * pulse,
                  ),
                );
              },
            ),

            // Ring pulsante alrededor del target
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                final pulse = _pulseController.value;
                return Positioned(
                  left: spotlightCenter.dx - radius - 10,
                  top: spotlightCenter.dy - radius - 10,
                  child: IgnorePointer(
                    child: Container(
                      width: (radius + 10) * 2,
                      height: (radius + 10) * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.amber
                              .withOpacity((1 - pulse).clamp(0.3, 0.8)),
                          width: 3 + pulse * 2,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Flecha animada
            if (!showTextAbove)
              AnimatedBuilder(
                animation: _arrowController,
                builder: (context, _) {
                  final bounce = _arrowController.value * 20;
                  return Positioned(
                    left: spotlightCenter.dx - 20,
                    top: spotlightCenter.dy - radius - 60 - bounce,
                    child: Transform.rotate(
                      angle: math.pi, // apunta hacia abajo
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.amber,
                        size: 40,
                      ),
                    ),
                  );
                },
              )
            else
              AnimatedBuilder(
                animation: _arrowController,
                builder: (context, _) {
                  final bounce = _arrowController.value * 20;
                  return Positioned(
                    left: spotlightCenter.dx - 20,
                    top: spotlightCenter.dy + radius + 20 + bounce,
                    child: const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.amber,
                      size: 40,
                    ),
                  );
                },
              ),

            // Texto guía
            Positioned(
              left: 24,
              right: 24,
              top: textTop,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Offset center;
  final double radius;

  _SpotlightPainter({required this.center, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.80);

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) =>
      old.center != center || old.radius != radius;
}
