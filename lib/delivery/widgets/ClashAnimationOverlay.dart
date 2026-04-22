import 'package:flutter/material.dart';

class ClashAnimationOverlay extends StatefulWidget {
  final double damage;
  final bool playerWon;  // true = daño va al oponente (arriba), false = al jugador (abajo)
  final VoidCallback onComplete;

  const ClashAnimationOverlay({
    super.key,
    required this.damage,
    required this.playerWon,
    required this.onComplete,
  });

  @override
  State<ClashAnimationOverlay> createState() => _ClashAnimationOverlayState();
}

class _ClashAnimationOverlayState extends State<ClashAnimationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _flashController;
  late AnimationController _numberController;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _numberController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _play();
  }

  Future<void> _play() async {
    await _flashController.forward();
    _flashController.reverse();
    await _numberController.forward();
    widget.onComplete();
  }

  @override
  void dispose() {
    _flashController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Flash blanco
          AnimatedBuilder(
            animation: _flashController,
            builder: (_, __) => Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(_flashController.value * 0.6),
              ),
            ),
          ),
          // Número de daño volando
          if (widget.damage > 0)
            AnimatedBuilder(
              animation: _numberController,
              builder: (context, _) {
                final t = _numberController.value;
                final screenH = MediaQuery.of(context).size.height;
                // Si ganó el jugador, el daño vuela hacia arriba (al oponente)
                // Si perdió, vuela hacia abajo (hacia el jugador)
                final startY = screenH / 2;
                final endY = widget.playerWon ? screenH * 0.15 : screenH * 0.7;
                final currentY = startY + (endY - startY) * Curves.easeOut.transform(t);

                return Positioned(
                  left: 0,
                  right: 0,
                  top: currentY,
                  child: Opacity(
                    opacity: (1 - t * 0.3).clamp(0.0, 1.0),
                    child: Center(
                      child: Transform.scale(
                        scale: 1 + t * 0.5,
                        child: Text(
                          '-${widget.damage.round()}',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 8),
                              Shadow(color: Colors.red.shade800, blurRadius: 15),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}