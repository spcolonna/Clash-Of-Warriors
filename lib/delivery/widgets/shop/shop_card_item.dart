// lib/delivery/widgets/shop/shop_card_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/game_card.dart';
import '../../state/providers.dart';
import '../../state/shop_provider.dart';
import '../card_preview_dialog.dart';
import '../game_card_widget.dart';

class ShopCardItem extends ConsumerWidget {
  final ShopCard card;
  final String? factionId;
  final bool isFactionUnlocked;
  final bool isOwned;
  final bool canAfford;
  final VoidCallback? onTap;

  const ShopCardItem({
    super.key,
    required this.card,
    this.factionId,
    required this.isFactionUnlocked,
    required this.isOwned,
    required this.canAfford,
    this.onTap,
  });

  static const double _cardWidth = 130.0;

  GameCard _toGameCard() => GameCard(
    id: card.id,
    name: card.name,
    lore: card.lore.isEmpty ? 'Sin descripción disponible.' : card.lore,
    category: _parseCategory(card.category),
    rarity: _parseRarity(card.rarity),
    staminaCost: card.staminaCost,
    baseDamage: card.baseDamage ?? 0,
    factionId: factionId,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usar el GameCard real del catálogo (trae imageUrl, efectos, etc.);
    // caer a la reconstrucción local solo si aún no está en el catálogo.
    final gameCard =
        ref.watch(cardCatalogProvider).findById(card.id) ?? _toGameCard();

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => CardPreviewDialog.show(context, gameCard),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GameCardWidget(card: gameCard, width: _cardWidth),

          // ── Estado: precio / comprada / bloqueada ──────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.72),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(10)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: _StateBadge(
                isOwned: isOwned,
                isFactionUnlocked: isFactionUnlocked,
                canAfford: canAfford,
                cost: card.cost,
              ),
            ),
          ),

          // ── Overlay de bloqueo ─────────────────────────────────────────
          if (!isFactionUnlocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(Icons.lock, color: Colors.white70, size: 28),
                ),
              ),
            ),

          // ── Botón de preview (arriba izquierda, siempre tappable) ──────
          Positioned(
            top: 4,
            left: 4,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => CardPreviewDialog.show(context, gameCard),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.visibility_outlined,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  CardCategory _parseCategory(String s) => switch (s) {
    'kick'    => CardCategory.kick,
    'grapple' => CardCategory.grapple,
    'defense' => CardCategory.defense,
    'dodge'   => CardCategory.dodge,
    _         => CardCategory.punch,
  };

  CardRarity _parseRarity(String s) => switch (s) {
    'rare'      => CardRarity.rare,
    'epic'      => CardRarity.epic,
    'legendary' => CardRarity.legendary,
    'neutral'   => CardRarity.neutral,
    _           => CardRarity.common,
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
      return _badge(icon: Icons.check_circle, text: 'EN MAZO', color: const Color(0xFF27AE60));
    }
    if (!isFactionUnlocked) {
      return _badge(icon: Icons.lock, text: 'BLOQUEADA', color: Colors.grey);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.monetization_on,
          size: 12,
          color: canAfford ? const Color(0xFFF5B800) : Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          '$cost',
          style: TextStyle(
            color: canAfford ? const Color(0xFFF5B800) : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _badge({required IconData icon, required String text, required Color color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
