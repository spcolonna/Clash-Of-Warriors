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
                _ShopHeader(softCoins: player.softCoins, tokens: player.tokens),
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

class _ShopHeader extends ConsumerWidget {
  final int softCoins;
  final int tokens;
  const _ShopHeader({required this.softCoins, required this.tokens});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tienda',
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              _CurrencyChip(icon: '🪙', value: softCoins, color: const Color(0xFFF5B800)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _CurrencyChip(icon: '💎', value: tokens, color: const Color(0xFFB39DDB)),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _showTokenConvertSheet(context, ref, tokens),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB39DDB).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFB39DDB).withValues(alpha: 0.4)),
                  ),
                  child: const Text(
                    'Convertir →',
                    style: TextStyle(color: Color(0xFFB39DDB), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTokenConvertSheet(BuildContext context, WidgetRef ref, int currentTokens) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _TokenConvertSheet(currentTokens: currentTokens, ref: ref),
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  final String icon;
  final int value;
  final Color color;
  const _CurrencyChip({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(icon, style: GoogleFonts.notoColorEmoji(textStyle: const TextStyle(fontSize: 16))),
          const SizedBox(width: 6),
          Text('$value', style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _TokenConvertSheet extends StatelessWidget {
  final int currentTokens;
  final WidgetRef ref;

  const _TokenConvertSheet({required this.currentTokens, required this.ref});

  static const _options = [
    (tokenCost: 100, coins: 500),
    (tokenCost: 250, coins: 1500),
    (tokenCost: 500, coins: 3500),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💎 → 🪙  Convertir Tokens',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Saldo actual: $currentTokens tokens',
            style: const TextStyle(color: Color(0xFF8A8A9A), fontSize: 13),
          ),
          const SizedBox(height: 20),
          ..._options.map((opt) => _ConvertOption(
            tokenCost: opt.tokenCost,
            coins: opt.coins,
            canAfford: currentTokens >= opt.tokenCost,
            onTap: () async {
              Navigator.of(context).pop();
              final success = await ref.read(playerProvider.notifier).convertTokensToSoftCoins(
                tokenCost: opt.tokenCost,
                softCoinAmount: opt.coins,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  success
                    ? SnackBar(
                        content: Text('+${opt.coins} monedas añadidas'),
                        backgroundColor: const Color(0xFF27AE60),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      )
                    : const SnackBar(content: Text('Tokens insuficientes')),
                );
              }
            },
          )),
        ],
      ),
    );
  }
}

class _ConvertOption extends StatelessWidget {
  final int tokenCost;
  final int coins;
  final bool canAfford;
  final VoidCallback onTap;

  const _ConvertOption({
    required this.tokenCost,
    required this.coins,
    required this.canAfford,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: canAfford ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: canAfford
                ? const Color(0xFFB39DDB).withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: canAfford
                  ? const Color(0xFFB39DDB).withValues(alpha: 0.4)
                  : Colors.white12,
            ),
          ),
          child: Row(
            children: [
              Text(
                '$tokenCost 💎',
                style: TextStyle(
                  color: canAfford ? const Color(0xFFB39DDB) : Colors.white30,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: Color(0xFF8A8A9A), size: 16),
              const SizedBox(width: 8),
              Text(
                '$coins 🪙',
                style: TextStyle(
                  color: canAfford ? const Color(0xFFF5B800) : Colors.white30,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (!canAfford)
                const Text(
                  'Sin saldo',
                  style: TextStyle(color: Colors.white30, fontSize: 11),
                ),
            ],
          ),
        ),
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
