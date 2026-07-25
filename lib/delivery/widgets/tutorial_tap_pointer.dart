// lib/delivery/widgets/tutorial_tap_pointer.dart
//
// Una ÚNICA indicación de "tocá acá" para el tutorial guionado: anillos
// concéntricos que se expanden y se desvanecen en loop (lenguaje universal de
// tap), más un punto central estable. Sin flecha, sin dedo, sin movimiento
// direccional — no sugiere swipe. Se renderiza SOBRE el target (carta o botón)
// dentro del mismo árbol, así que no necesita medición.

import 'package:flutter/material.dart';

class TutorialTapPointer extends StatefulWidget {
  final double size;
  final Color color;

  const TutorialTapPointer({
    super.key,
    this.size = 64,
    this.color = const Color(0xFFF5B800),
  });

  @override
  State<TutorialTapPointer> createState() => _TutorialTapPointerState();
}

class _TutorialTapPointerState extends State<TutorialTapPointer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Dos anillos desfasados que se expanden y se apagan.
                _ring(_c.value),
                _ring((_c.value + 0.5) % 1.0),
                // Punto central estable (el "dónde tocar").
                Container(
                  width: widget.size * 0.28,
                  height: widget.size * 0.28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.7),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _ring(double t) {
    final scale = 0.35 + t * 0.65; // crece de 35% a 100%
    final opacity = (1 - t).clamp(0.0, 1.0) * 0.9;
    return Transform.scale(
      scale: scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.color.withValues(alpha: opacity),
            width: 3,
          ),
        ),
      ),
    );
  }
}
