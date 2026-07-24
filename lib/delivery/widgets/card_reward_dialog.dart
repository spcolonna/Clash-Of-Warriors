// lib/delivery/widgets/card_reward_dialog.dart
//
// Celebración al CONSEGUIR una carta fuera de la tienda (recompensa diaria,
// progreso, historia). Muestra la carta real grande con anillos de energía y
// un sello "¡NUEVA CARTA!", reusando el mismo lenguaje visual que la compra
// en la tienda (PurchaseCardDialog) sin el flujo de compra.

import 'package:flutter/material.dart';
import '../../domain/entities/game_card.dart';
import '../../infra/services/haptics_service.dart';
import '../../infra/sound/sound_service.dart';
import 'game_card_widget.dart';

class CardRewardDialog extends StatefulWidget {
  final GameCard card;

  const CardRewardDialog({super.key, required this.card});

  static Future<void> show(BuildContext context, GameCard card) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (_) => CardRewardDialog(card: card),
    );
  }

  @override
  State<CardRewardDialog> createState() => _CardRewardDialogState();
}

class _CardRewardDialogState extends State<CardRewardDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  Color get _rarityColor => switch (widget.card.rarity) {
        CardRarity.rare => const Color(0xFF4FC3F7),
        CardRarity.epic => const Color(0xFFCE93D8),
        CardRarity.legendary => const Color(0xFFFFD700),
        _ => const Color(0xFFF5B800),
      };

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..forward();
    SoundService().play('unlock');
    HapticsService().success();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final t = _c.value;
              final ring = Curves.easeOut.transform(t.clamp(0.0, 1.0));
              final stampT = Curves.elasticOut.transform(((t - 0.15) / 0.5).clamp(0.0, 1.0));
              final entry = Curves.easeOutBack.transform((t / 0.4).clamp(0.0, 1.0));
              return Transform.scale(
                scale: 0.7 + 0.3 * entry,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '¡NUEVA CARTA!',
                      style: TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 3, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 300,
                      height: 320,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _Ring(progress: ring, delay: 0.0, color: _rarityColor),
                          _Ring(progress: ring, delay: 0.15, color: _rarityColor),
                          GameCardWidget(card: widget.card, width: 210),
                          if (stampT > 0.01)
                            Positioned(
                              bottom: 12,
                              child: Transform.scale(
                                scale: stampT.clamp(0.0, 1.2),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF14100C).withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: _rarityColor, width: 1.5),
                                  ),
                                  child: Text(
                                    '¡TUYA!',
                                    style: TextStyle(color: _rarityColor, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Tocá para continuar',
                        style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final double progress;
  final double delay;
  final Color color;

  const _Ring({required this.progress, required this.delay, required this.color});

  @override
  Widget build(BuildContext context) {
    final t = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);
    if (t <= 0) return const SizedBox.shrink();
    final size = 150 + t * 200;
    return Opacity(
      opacity: (1 - t) * 0.5,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2.5),
        ),
      ),
    );
  }
}
