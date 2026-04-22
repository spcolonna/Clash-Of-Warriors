// lib/delivery/widgets/player_hand_widget.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/game_card.dart';
import 'card_preview_dialog.dart';
import 'game_card_widget.dart';

class PlayerHandWidget extends StatefulWidget {
  final List<GameCard> cards;
  final GameCard? passive;
  final bool isDraggable;
  final VoidCallback? onDealAnimationComplete;

  const PlayerHandWidget({
    super.key,
    required this.cards,
    this.passive,
    this.isDraggable = true,
    this.onDealAnimationComplete,
  });

  @override
  State<PlayerHandWidget> createState() => _PlayerHandWidgetState();
}

class _PlayerHandWidgetState extends State<PlayerHandWidget>
    with TickerProviderStateMixin {
  final List<AnimationController> _dealControllers = [];
  bool _dealt = false;

  @override
  void initState() {
    super.initState();
    _setupDealAnimations();
  }

  void _setupDealAnimations() {
    final total = widget.cards.length + (widget.passive != null ? 1 : 0);
    for (int i = 0; i < total; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 450),
      );
      _dealControllers.add(controller);
    }
    _startDealAnimation();
  }

  Future<void> _startDealAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (int i = 0; i < _dealControllers.length; i++) {
      if (!mounted) return;
      _dealControllers[i].forward();
      await Future.delayed(const Duration(milliseconds: 120));
    }
    if (mounted) {
      setState(() => _dealt = true);
      widget.onDealAnimationComplete?.call();
    }
  }

  @override
  void dispose() {
    for (final c in _dealControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allCards = <_HandCardData>[];
    if (widget.passive != null) {
      // allCards.add(_HandCardData(widget.passive!, isPassive: true));
    }
    for (final c in widget.cards) {
      allCards.add(_HandCardData(c));
    }

    final screenWidth = MaxWidth.of(context);
    final cardWidth = 90.0;
    final totalCards = allCards.length;

    // La "mano" se extiende en abanico, con rotación y offset en Y
    final fanSpread = _calculateFanSpread(totalCards, cardWidth, screenWidth);
    final anglePerCard = totalCards > 1
        ? (0.08 + (totalCards * 0.008)).clamp(0.08, 0.15)
        : 0.0;
    final startAngle = -(totalCards - 1) * anglePerCard / 2;

    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: List.generate(totalCards, (i) {
          final cardData = allCards[i];
          final angle = startAngle + (i * anglePerCard);
          final xOffset = totalCards > 1
              ? (i / (totalCards - 1) - 0.5) * fanSpread
              : 0.0;
          // Curva en Y para simular el arco de la mano
          final normalized = totalCards > 1 ? (i / (totalCards - 1) - 0.5) * 2 : 0.0;
          final yOffset = (normalized * normalized) * 20.0; // más abajo los de los extremos

          final cardWidget = GameCardWidget(
            card: cardData.card,
            width: cardWidth,
            isPassive: cardData.isPassive,
          );

          // Envolvemos con GestureDetector para el tap de preview
          final tappable = GestureDetector(
            onTap: () => CardPreviewDialog.show(
              context,
              cardData.card,
              isPassive: cardData.isPassive,
            ),
            child: cardWidget,
          );

          final draggable = widget.isDraggable
              ? LongPressDraggable<GameCard>(
            data: cardData.card,
            delay: const Duration(milliseconds: 150),
            feedback: Material(
              color: Colors.transparent,
              child: Transform.scale(
                scale: 1.15,
                child: GameCardWidget(
                  card: cardData.card,
                  width: cardWidth,
                  isPassive: cardData.isPassive,
                ),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: cardWidget,
            ),
            dragAnchorStrategy: pointerDragAnchorStrategy,
            child: tappable,
          )
              : tappable;

          // Animación de aparición de cada carta
          final dealAnim = _dealControllers[i];

          return AnimatedBuilder(
            animation: dealAnim,
            builder: (context, child) {
              final t = Curves.easeOutCubic.transform(dealAnim.value);
              return Positioned(
                bottom: 10,
                child: Transform.translate(
                  // Empieza desde arriba (-250) y baja a su posición
                  offset: Offset(xOffset * t, -250 * (1 - t) + yOffset),
                  child: Transform.rotate(
                    angle: angle * t,
                    child: Opacity(
                      opacity: t,
                      child: child,
                    ),
                  ),
                ),
              );
            },
            child: draggable,
          );
        }),
      ),
    );
  }

  double _calculateFanSpread(int cards, double cardWidth, double screenWidth) {
    if (cards <= 1) return 0;

    // Solapamiento deseado entre cartas: ~60% de ancho de carta
    final desiredOverlap = cardWidth * 0.6;
    final naturalSpread = (cards - 1) * desiredOverlap;

    // Si el spread natural cabe en pantalla, úsalo
    final maxSpread = screenWidth - cardWidth - 32; // 32 = márgenes

    return naturalSpread.clamp(0.0, maxSpread);
  }
}

class _HandCardData {
  final GameCard card;
  final bool isPassive;
  _HandCardData(this.card, {this.isPassive = false});
}

class MaxWidth {
  static double of(BuildContext context) => MediaQuery.of(context).size.width;
}