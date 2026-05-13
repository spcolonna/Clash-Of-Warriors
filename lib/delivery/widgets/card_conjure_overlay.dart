// lib/delivery/widgets/card_conjure_overlay.dart

import 'package:flutter/material.dart';
import '../../domain/entities/game_card.dart';
import 'game_card_widget.dart';

/// Overlay que aparece brevemente cuando el jugador coloca una carta en un slot.
/// Muestra la carta en primer plano con glow de categoría y un ripple de energía.
class CardConjureOverlay extends StatefulWidget {
  final GameCard card;
  final VoidCallback onComplete;

  const CardConjureOverlay({
    super.key,
    required this.card,
    required this.onComplete,
  });

  @override
  State<CardConjureOverlay> createState() => _CardConjureOverlayState();
}

class _CardConjureOverlayState extends State<CardConjureOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // ── Scale de la carta: aparece con overshoot, se estabiliza, sale flotando ──
  late final Animation<double> _scale;
  // ── Opacidad de la carta ─────────────────────────────────────────────────────
  late final Animation<double> _cardOpacity;
  // ── Opacidad del scrim negro ─────────────────────────────────────────────────
  late final Animation<double> _scrimOpacity;
  // ── Intensidad del glow de categoría ────────────────────────────────────────
  late final Animation<double> _glow;
  // ── Ripple: escala del anillo que se expande al aparecer ────────────────────
  late final Animation<double> _rippleScale;
  late final Animation<double> _rippleOpacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 880),
    );

    // Weights suman 100 → fácil de mapear a porcentajes de la duración.
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.1, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 32,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 13,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 22),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.07)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 33,
      ),
    ]).animate(_ctrl);

    _cardOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 52),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 33),
    ]).animate(_ctrl);

    _scrimOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.82), weight: 18),
      TweenSequenceItem(tween: ConstantTween(0.82), weight: 49),
      TweenSequenceItem(tween: Tween(begin: 0.82, end: 0.0), weight: 33),
    ]).animate(_ctrl);

    _glow = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 32),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.55), weight: 18),
      TweenSequenceItem(tween: Tween(begin: 0.55, end: 0.9), weight: 17),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 0.0), weight: 33),
    ]).animate(_ctrl);

    _rippleScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.55, end: 2.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem(tween: ConstantTween(2.4), weight: 55),
    ]).animate(_ctrl);

    _rippleOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 0.0), weight: 45),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 55),
    ]).animate(_ctrl);

    _ctrl.forward().then((_) {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color  = _conjureColor(widget.card.category);
    final label  = _conjureLabel(widget.card.category);
    final cardW  = MediaQuery.of(context).size.width * 0.52;
    final cardH  = cardW * 1.5;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => Stack(
        fit: StackFit.expand,
        children: [
          // ── Scrim ──────────────────────────────────────────────────────────
          ColoredBox(
            color: Colors.black.withValues(alpha: _scrimOpacity.value),
          ),

          // ── Ripple: anillo de energía que se expande ────────────────────────
          Center(
            child: Transform.scale(
              scale: _rippleScale.value,
              child: Opacity(
                opacity: _rippleOpacity.value,
                child: Container(
                  width: cardW,
                  height: cardH,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color, width: 2.5),
                  ),
                ),
              ),
            ),
          ),

          // ── Carta + badge + glow ────────────────────────────────────────────
          Center(
            child: Opacity(
              opacity: _cardOpacity.value,
              child: Transform.scale(
                scale: _scale.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge de categoría con glow
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 7),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: _glow.value * 0.85),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Carta con doble glow (cercano + lejano)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: _glow.value * 0.65),
                            blurRadius: 55,
                            spreadRadius: 10,
                          ),
                          BoxShadow(
                            color: color.withValues(alpha: _glow.value * 0.25),
                            blurRadius: 110,
                            spreadRadius: 28,
                          ),
                        ],
                      ),
                      child: GameCardWidget(card: widget.card, width: cardW),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _conjureColor(CardCategory c) => switch (c) {
  CardCategory.punch   => const Color(0xFFE74C3C),
  CardCategory.kick    => const Color(0xFFE67E22),
  CardCategory.grapple => const Color(0xFF8E44AD),
  CardCategory.defense => const Color(0xFF2980B9),
  CardCategory.dodge   => const Color(0xFF27AE60),
};

String _conjureLabel(CardCategory c) => switch (c) {
  CardCategory.punch   => '⚡ PUÑO',
  CardCategory.kick    => '⚡ PATADA',
  CardCategory.grapple => '⚡ AGARRE',
  CardCategory.defense => '⚡ DEFENSA',
  CardCategory.dodge   => '⚡ ESQUIVE',
};
