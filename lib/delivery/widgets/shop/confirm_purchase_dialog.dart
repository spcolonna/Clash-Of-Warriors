// lib/delivery/widgets/shop/confirm_purchase_dialog.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state/shop_provider.dart';

class ConfirmPurchaseDialog extends StatelessWidget {
  final ShopCard card;
  final int playerCoins;

  const ConfirmPurchaseDialog({
    super.key,
    required this.card,
    required this.playerCoins,
  });

  static Future<bool?> show({
    required BuildContext context,
    required ShopCard card,
    required int playerCoins,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => ConfirmPurchaseDialog(
        card: card,
        playerCoins: playerCoins,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = playerCoins - card.cost;

    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🛒',
                style: GoogleFonts.notoColorEmoji(
                  textStyle: const TextStyle(fontSize: 40),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '¿Confirmar compra?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      card.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.rarity.toUpperCase(),
                      style: TextStyle(
                        color: _rarityColor(card.rarity),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '🪙',
                          style: GoogleFonts.notoColorEmoji(
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${card.cost}',
                          style: const TextStyle(
                            color: Color(0xFFF5B800),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ResourcePreview(
                current: playerCoins,
                after: remaining,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Comprar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _rarityColor(String rarity) => switch (rarity) {
        'common' => const Color(0xFFAAAAAA),
        'rare' => const Color(0xFF3498DB),
        'epic' => const Color(0xFF9B59B6),
        'legendary' => const Color(0xFFF39C12),
        _ => Colors.white,
      };
}

class _ResourcePreview extends StatelessWidget {
  final int current;
  final int after;

  const _ResourcePreview({required this.current, required this.after});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$current',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward, color: Colors.white38, size: 14),
        const SizedBox(width: 8),
        Text(
          '$after',
          style: const TextStyle(
            color: Color(0xFFF5B800),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '🪙',
          style: GoogleFonts.notoColorEmoji(
            textStyle: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
