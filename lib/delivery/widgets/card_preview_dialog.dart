import 'package:flutter/material.dart';
import '../../domain/entities/game_card.dart';
import 'game_card_widget.dart';

class CardPreviewDialog extends StatelessWidget {
  final GameCard card;
  final bool isPassive;

  const CardPreviewDialog({
    super.key,
    required this.card,
    this.isPassive = false,
  });

  static Future<void> show(
      BuildContext context,
      GameCard card, {
        bool isPassive = false,
      }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => CardPreviewDialog(card: card, isPassive: isPassive),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Hero(
            tag: 'card_${card.id}',
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.7, end: 1.0),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: GameCardWidget(
                card: card,
                width: 260,
                isPassive: isPassive,
              ),
            ),
          ),
        ),
      ),
    );
  }
}