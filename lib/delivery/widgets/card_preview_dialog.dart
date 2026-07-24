import 'package:flutter/material.dart';
import '../../domain/entities/game_card.dart';
import 'game_card_widget.dart';

class CardPreviewDialog extends StatelessWidget {
  final GameCard card;
  final bool isPassive;
  final VoidCallback? onPlay;
  final bool canPlay;
  final String playLabel;
  final String disabledLabel;
  final IconData playIcon;
  final Color playColor;

  const CardPreviewDialog({
    super.key,
    required this.card,
    this.isPassive = false,
    this.onPlay,
    this.canPlay = true,
    this.playLabel = 'Jugar',
    this.disabledLabel = 'Sin stamina',
    this.playIcon = Icons.sports_mma,
    this.playColor = const Color(0xFFE74C3C),
  });

  /// [onPlay] agrega un botón de acción debajo de la carta (cierra el dialog
  /// antes de invocar el callback) — así una sola pantalla sirve tanto para
  /// ver la carta como para actuar sobre ella (jugarla, comprarla, etc.).
  /// [canPlay] en false lo muestra deshabilitado con el texto [disabledLabel].
  static Future<void> show(
      BuildContext context,
      GameCard card, {
        bool isPassive = false,
        VoidCallback? onPlay,
        bool canPlay = true,
        String playLabel = 'Jugar',
        String disabledLabel = 'Sin stamina',
        IconData playIcon = Icons.sports_mma,
        Color playColor = const Color(0xFFE74C3C),
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
        disabledLabel: disabledLabel,
        playIcon: playIcon,
        playColor: playColor,
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
                            ? playColor
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
                        canPlay ? playIcon : Icons.lock,
                        size: 18,
                        color: canPlay ? Colors.white : Colors.white38,
                      ),
                      label: Text(
                        canPlay ? playLabel : disabledLabel,
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
