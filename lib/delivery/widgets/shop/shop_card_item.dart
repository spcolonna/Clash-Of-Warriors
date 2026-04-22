// lib/delivery/widgets/shop/shop_card_item.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state/shop_provider.dart';

class ShopCardItem extends StatelessWidget {
  final ShopCard card;
  final bool isFactionUnlocked;
  final bool isOwned;
  final bool canAfford;
  final VoidCallback? onTap;

  const ShopCardItem({
    super.key,
    required this.card,
    required this.isFactionUnlocked,
    required this.isOwned,
    required this.canAfford,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = _rarityColor(card.rarity);
    final blocked = !isFactionUnlocked || (!canAfford && !isOwned);

    return Opacity(
      opacity: blocked && !isOwned ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 130,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: rarityColor, width: 2),
            boxShadow: [
              if (onTap != null)
                BoxShadow(
                  color: rarityColor.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      card.name,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAEAEA),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            _categoryEmoji(card.category),
                            style: GoogleFonts.notoColorEmoji(
                              textStyle: const TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Precio o estado
                    _StateBadge(
                      isOwned: isOwned,
                      isFactionUnlocked: isFactionUnlocked,
                      canAfford: canAfford,
                      cost: card.cost,
                    ),
                  ],
                ),
              ),

              // Badge de rareza
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: rarityColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    card.rarity.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // Overlay de bloqueo
              if (!isFactionUnlocked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.lock, color: Colors.white, size: 36),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _rarityColor(String rarity) => switch (rarity) {
        'common' => const Color(0xFF888888),
        'rare' => const Color(0xFF2980B9),
        'epic' => const Color(0xFF8E44AD),
        'legendary' => const Color(0xFFF39C12),
        _ => const Color(0xFFB0B0B0),
      };

  String _categoryEmoji(String category) => switch (category) {
        'punch' => '👊',
        'kick' => '🦵',
        'grapple' => '🤼',
        'defense' => '🛡️',
        'dodge' => '💨',
        _ => '❓',
      };
}

class _StateBadge extends StatelessWidget {
  final bool isOwned;
  final bool isFactionUnlocked;
  final bool canAfford;
  final int cost;

  const _StateBadge({
    required this.isOwned,
    required this.isFactionUnlocked,
    required this.canAfford,
    required this.cost,
  });

  @override
  Widget build(BuildContext context) {
    if (isOwned) {
      return _badge(
        icon: Icons.check_circle,
        text: 'EN MAZO',
        color: const Color(0xFF27AE60),
      );
    }
    if (!isFactionUnlocked) {
      return _badge(
        icon: Icons.lock,
        text: 'BLOQUEADA',
        color: Colors.grey,
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: canAfford
            ? const Color(0xFFF5B800).withOpacity(0.15)
            : Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '🪙',
            style: GoogleFonts.notoColorEmoji(
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$cost',
            style: TextStyle(
              color: canAfford
                  ? const Color(0xFFF5B800)
                  : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
