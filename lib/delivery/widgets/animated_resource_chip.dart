// lib/delivery/widgets/animated_resource_chip.dart
//
// Chip de recurso (monedas/tokens/medallas) que anima el cambio de valor:
// el número cuenta de viejo→nuevo como un odómetro (sin números flotantes
// superpuestos) y el borde hace un flash de color mientras cuenta. En
// aumento suena `coin` + haptic.

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
  static const _duration = Duration(milliseconds: 1200);

  late final AnimationController _controller;
  late Animation<double> _count;
  int _displayFrom = 0;
  int _target = 0;
  bool _rising = false;

  @override
  void initState() {
    super.initState();
    _target = widget.value;
    _displayFrom = widget.value;
    _controller = AnimationController(vsync: this, duration: _duration);
    _count = AlwaysStoppedAnimation(widget.value.toDouble());
  }

  @override
  void didUpdateWidget(covariant AnimatedResourceChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _target) {
      // Si ya estaba contando, arrancar desde el valor actualmente mostrado
      // (no desde el target viejo) para que no "salte".
      _displayFrom = _count.value.round();
      _rising = widget.value > _target;
      _target = widget.value;
      _count = Tween<double>(
        begin: _displayFrom.toDouble(),
        end: _target.toDouble(),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller.forward(from: 0);
      if (_rising) {
        SoundService().play('coin');
        HapticsService().light();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final counting = _controller.isAnimating;
        final t = counting ? Curves.easeOut.transform(1 - _controller.value) : 0.0;
        final glow = widget.color.withValues(alpha: 0.3 + 0.5 * t);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: counting ? glow : widget.color.withValues(alpha: 0.3)),
            boxShadow: counting
                ? [BoxShadow(color: widget.color.withValues(alpha: 0.4 * t), blurRadius: 10)]
                : null,
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 16, color: widget.color),
              const SizedBox(width: 6),
              Text(
                '${_count.value.round()}',
                style: TextStyle(
                  color: widget.color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
