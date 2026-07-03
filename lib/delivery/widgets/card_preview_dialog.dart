import 'package:flutter/material.dart';
import '../../domain/entities/game_card.dart';
import 'game_card_widget.dart';

class CardPreviewDialog extends StatelessWidget {
  final GameCard card;
  final bool isPassive;
  final VoidCallback? onPlay;
  final bool canPlay;
  final String playLabel;

  const CardPreviewDialog({
    super.key,
    required this.card,
    this.isPassive = false,
    this.onPlay,
    this.canPlay = true,
    this.playLabel = 'Jugar',
  });

  /// [onPlay] agrega un botón "Jugar" debajo de la carta (cierra el dialog
  /// antes de invocar el callback). [canPlay] en false lo muestra
  /// deshabilitado con la razón "Sin stamina". [playLabel] permite avisar
  /// destinos especiales (p. ej. "Jugar como apertura").
  static Future<void> show(
      BuildContext context,
      GameCard card, {
        bool isPassive = false,
        VoidCallback? onPlay,
        bool canPlay = true,
        String playLabel = 'Jugar',
      }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => CardPreviewDialog(
        card: card,
        isPassive: isPassive,
        onPlay: onPlay,
        canPlay: canPlay,
        playLabel: playLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: Center(
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'card_${card.id}',
                  child: GameCardWidget(
                    card: card,
                    width: 260,
                    isPassive: isPassive,
                  ),
                ),
                if (onPlay != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 260,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canPlay
                            ? const Color(0xFFE74C3C)
                            : const Color(0xFF2A2A3E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: canPlay
                          ? () {
                              Navigator.of(context).pop();
                              onPlay!();
                            }
                          : null,
                      icon: Icon(
                        canPlay ? Icons.sports_mma : Icons.bolt,
                        size: 18,
                        color: canPlay ? Colors.white : Colors.white38,
                      ),
                      label: Text(
                        canPlay ? playLabel : 'Sin stamina',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: canPlay ? Colors.white : Colors.white38,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
