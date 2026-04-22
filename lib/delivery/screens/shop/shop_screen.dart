// lib/delivery/screens/shop/shop_screen.dart
//
// Shop con filas por facción. Cada fila muestra las cartas de esa facción
// ordenadas por rareza. Si la facción no está desbloqueada, toda la fila
// se ve bloqueada. Si está desbloqueada, las cartas individuales se marcan
// como "comprables" según los softCoins del jugador.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../state/providers.dart';
import '../../state/shop_provider.dart';
import '../../widgets/shop/shop_card_item.dart';
import '../../widgets/shop/confirm_purchase_dialog.dart';
import '../../widgets/shop/faction_row_header.dart';
import '../../widgets/tutorial_spotlight_overlay.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final GlobalKey _starterCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Carga inicial del shop
    Future.microtask(() => ref.read(shopProvider.notifier).loadShop());
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final shopState = ref.watch(shopProvider);

    if (player == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final showStarterTutorial = player.tutorialBattleComplete &&
        !player.starterCardPurchased &&
        player.selectedFactionId != null;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                _ShopHeader(softCoins: player.softCoins),
                Expanded(
                  child: shopState.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(
                      child: Text(
                        'Error: $e',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    data: (factions) => ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: factions.length,
                      itemBuilder: (context, index) {
                        final faction = factions[index];
                        final isUnlocked =
                            player.selectedFactionId == faction.id;

                        return _FactionRow(
                          faction: faction,
                          isUnlocked: isUnlocked,
                          playerCoins: player.softCoins,
                          ownedCardIds: player.ownedCards
                              .map((c) => c.cardId)
                              .toSet(),
                          starterCardKey:
                              (showStarterTutorial && isUnlocked)
                                  ? _starterCardKey
                                  : null,
                          onCardTap: (card) => _onCardTap(card, player.softCoins),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Tutorial overlay dentro del shop
        if (showStarterTutorial)
          TutorialSpotlightOverlay(
            targetKey: _starterCardKey,
            message:
                'Esta es la primera carta de tu facción.\nTocala para comprarla con tus monedas.',
            spotlightPadding: 8,
          ),
      ],
    );
  }

  void _onCardTap(ShopCard card, int playerCoins) async {
    final confirmed = await ConfirmPurchaseDialog.show(
      context: context,
      card: card,
      playerCoins: playerCoins,
    );

    if (confirmed != true) return;

    final success = await ref.read(playerProvider.notifier).purchaseStarterCard(
          cardId: card.id,
          cost: card.cost,
        );

    if (!mounted) return;

    if (success) {
      // Si era la starter card del tutorial, completar el onboarding
      final player = ref.read(playerProvider);
      if (player != null &&
          !player.starterCardAddedToDeck &&
          player.tutorialBattleComplete) {
        await ref
            .read(playerProvider.notifier)
            .addStarterCardToDeckAndComplete();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tenés suficientes monedas')),
      );
    }
  }
}

class _ShopHeader extends StatelessWidget {
  final int softCoins;
  const _ShopHeader({required this.softCoins});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Tienda',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF5B800).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Text(
                  '🪙',
                  style: GoogleFonts.notoColorEmoji(
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$softCoins',
                  style: const TextStyle(
                    color: Color(0xFFF5B800),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FactionRow extends StatelessWidget {
  final FactionShop faction;
  final bool isUnlocked;
  final int playerCoins;
  final Set<String> ownedCardIds;
  final GlobalKey? starterCardKey;
  final void Function(ShopCard) onCardTap;

  const _FactionRow({
    required this.faction,
    required this.isUnlocked,
    required this.playerCoins,
    required this.ownedCardIds,
    required this.starterCardKey,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FactionRowHeader(
            factionId: faction.id,
            factionName: faction.name,
            isUnlocked: isUnlocked,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: faction.cards.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final card = faction.cards[i];
                final isOwned = ownedCardIds.contains(card.id);
                final canAfford = playerCoins >= card.cost;

                // Si hay tutorial activo, la primera carta starter lleva la key
                final key = (starterCardKey != null &&
                        card.isTutorialCard &&
                        i == 0)
                    ? starterCardKey
                    : null;

                return ShopCardItem(
                  key: key,
                  card: card,
                  isFactionUnlocked: isUnlocked,
                  isOwned: isOwned,
                  canAfford: canAfford,
                  onTap: isUnlocked && !isOwned && canAfford
                      ? () => onCardTap(card)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
