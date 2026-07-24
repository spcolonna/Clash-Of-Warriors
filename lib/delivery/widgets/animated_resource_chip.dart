// lib/delivery/widgets/animated_resource_chip.dart
//
// Chip de recurso (monedas/tokens/medallas) que anima el cambio de valor:
// el número cuenta de viejo→nuevo, hace un flash de color, y lanza un "+X"/
// "−X" flotante que sube y se desvanece. En aumento suena `coin` + haptic.
// El flotante va por Overlay para NO ocupar layout (el header del home es
// angosto y usa FittedBox).

import 'package:flutter/material.dart';
import '../../infra/services/haptics_service.dart';
import '../../infra/sound/sound_service.dart';

class AnimatedResourceChip extends StatefulWidget {
  final IconData icon;
  final int value;
  final Color color;

  const AnimatedResourceChip({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  State<AnimatedResourceChip> createState() => _AnimatedResourceChipState();
}

class _AnimatedResourceChipState extends State<AnimatedResourceChip>
    with SingleTickerProviderStateMixin {
  late int _displayFrom; // valor de arranque de la animación de conteo
  late int _current;     // valor objetivo actual
  late final AnimationController _flash;

  @override
  void initState() {
    super.initState();
    _current = widget.value;
    _displayFrom = widget.value;
    _flash = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedResourceChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _current) {
      final delta = widget.value - _current;
      _displayFrom = _current;
      _current = widget.value;
      _flash.forward(from: 0);
      // Insertar en el Overlay debe esperar a que termine este build: hacerlo
      // en didUpdateWidget dispara un setState del Overlay a mitad de build.
      WidgetsBinding.instance.addPostFrameCallback((_) => _spawnFloater(delta));
      if (delta > 0) {
        SoundService().play('coin');
        HapticsService().light();
      }
      setState(() {});
    }
  }

  void _spawnFloater(int delta) {
    if (!mounted) return;
    final overlay = Overlay.maybeOf(context);
    final box = context.findRenderObject() as RenderBox?;
    if (overlay == null || box == null || !box.hasSize) return;
    final topCenter = box.localToGlobal(Offset(box.size.width / 2, 0));
    final entry = OverlayEntry(
      builder: (_) => _FloatingDelta(
        origin: topCenter,
        delta: delta,
        color: delta > 0 ? widget.color : const Color(0xFFE74C3C),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 1000), entry.remove);
  }

  @override
  void dispose() {
    _flash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flash,
      builder: (context, _) {
        // Flash: el borde/fondo se intensifica y vuelve.
        final t = Curves.easeOut.transform(1 - _flash.value);
        final glow = widget.color.withValues(alpha: 0.3 + 0.5 * t * (_flash.isAnimating ? 1 : 0));
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: glow),
            boxShadow: _flash.isAnimating
                ? [BoxShadow(color: widget.color.withValues(alpha: 0.4 * t), blurRadius: 10)]
                : null,
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 16, color: widget.color),
              const SizedBox(width: 6),
              TweenAnimationBuilder<double>(
                tween: Tween(
                    begin: _displayFrom.toDouble(), end: _current.toDouble()),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, v, _) => Text(
                  '${v.round()}',
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// "+X"/"−X" que aparece sobre el chip, sube y se desvanece.
class _FloatingDelta extends StatefulWidget {
  final Offset origin;
  final int delta;
  final Color color;

  const _FloatingDelta({
    required this.origin,
    required this.delta,
    required this.color,
  });

  @override
  State<_FloatingDelta> createState() => _FloatingDeltaState();
}

class _FloatingDeltaState extends State<_FloatingDelta>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        final rise = 26 * Curves.easeOut.transform(t);
        final opacity = t < 0.2 ? t / 0.2 : (1 - (t - 0.2) / 0.8).clamp(0.0, 1.0);
        final sign = widget.delta > 0 ? '+' : '−';
        return Positioned(
          left: widget.origin.dx - 20,
          top: widget.origin.dy - 8 - rise,
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  '$sign${widget.delta.abs()}',
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
