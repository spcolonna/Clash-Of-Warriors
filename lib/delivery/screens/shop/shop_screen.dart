// lib/delivery/screens/shop/shop_screen.dart
//
// Shop con filas por facción. Cada fila muestra las cartas de esa facción
// ordenadas por rareza. Si la facción no está desbloqueada, toda la fila
// se ve bloqueada. Si está desbloqueada, las cartas individuales se marcan
// como "comprables" según los softCoins del jugador.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/hero_entity.dart';
import '../../../domain/entities/player_profile.dart';
import '../../../infra/local/heroes_data.dart';
import '../../state/providers.dart';
import '../../state/shop_provider.dart';
import '../../widgets/shop/shop_card_item.dart';
import '../../widgets/shop/confirm_purchase_dialog.dart';
import '../../widgets/shop/faction_row_header.dart';
import '../../widgets/tutorial_spotlight_overlay.dart';
import '../heroes/character_select_screen.dart'; // factionColor

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
                      itemCount: factions.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _HeroesSection(
                            player: player,
                            onHeroPurchase: (hero) => _onHeroPurchase(hero),
                          );
                        }
                        final faction = factions[index - 1];
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

  void _onHeroPurchase(HeroEntity hero) async {
    const heroPrice = _HeroShopCard.price;
    final player = ref.read(playerProvider);
    if (player == null) return;

    final canAfford = player.softCoins >= heroPrice;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Desbloquear ${hero.name}',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hero.title, style: const TextStyle(color: Color(0xFF8A8A9A), fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.monetization_on, size: 16, color: Color(0xFFF5B800)),
                const SizedBox(width: 4),
                Text(
                  '$heroPrice monedas',
                  style: const TextStyle(color: Color(0xFFF5B800), fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Text(
                  '(saldo: ${player.softCoins})',
                  style: TextStyle(
                    color: canAfford ? Colors.white54 : Colors.red.shade300,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: canAfford ? () => Navigator.of(context).pop(true) : null,
            child: Text(
              'Comprar',
              style: TextStyle(
                color: canAfford ? const Color(0xFFF5B800) : Colors.white24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await ref.read(playerProvider.notifier).purchaseHeroWithCoins(
      heroId: hero.id,
      coinCost: heroPrice,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      success
          ? SnackBar(
              content: Text('¡${hero.name} desbloqueado! Seleccionalo desde Mazo.'),
              backgroundColor: const Color(0xFF27AE60),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            )
          : const SnackBar(content: Text('No tenés suficientes monedas')),
    );
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
              _CurrencyChip(icon: Icons.monetization_on, value: softCoins, color: const Color(0xFFF5B800)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _CurrencyChip(icon: Icons.diamond, value: tokens, color: const Color(0xFFB39DDB)),
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
  final IconData icon;
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
          Icon(icon, size: 16, color: color),
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
          Row(
            children: [
              const Icon(Icons.diamond, size: 18, color: Color(0xFFB39DDB)),
              const Text(' → ', style: TextStyle(color: Colors.white54, fontSize: 18)),
              const Icon(Icons.monetization_on, size: 18, color: Color(0xFFF5B800)),
              const SizedBox(width: 8),
              const Text('Convertir Tokens', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
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
                '$tokenCost',
                style: TextStyle(
                  color: canAfford ? const Color(0xFFB39DDB) : Colors.white30,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.diamond, size: 14, color: canAfford ? const Color(0xFFB39DDB) : Colors.white30),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: Color(0xFF8A8A9A), size: 16),
              const SizedBox(width: 8),
              Text(
                '$coins',
                style: TextStyle(
                  color: canAfford ? const Color(0xFFF5B800) : Colors.white30,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.monetization_on, size: 14, color: canAfford ? const Color(0xFFF5B800) : Colors.white30),
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

// ─── HEROES SECTION ──────────────────────────────────────────────────────────

class _HeroesSection extends StatelessWidget {
  final PlayerProfile player;
  final void Function(HeroEntity) onHeroPurchase;

  const _HeroesSection({required this.player, required this.onHeroPurchase});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: Text(
            'Héroes',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 192,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: HeroesData.starterHeroes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final hero = HeroesData.starterHeroes[i];
              final isActive = hero.id == player.activeHeroId;
              final isUnlocked = player.unlockedHeroIds.contains(hero.id);
              return _HeroShopCard(
                hero: hero,
                isActive: isActive,
                isUnlocked: isUnlocked,
                playerCoins: player.softCoins,
                onPurchase: () => onHeroPurchase(hero),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        const Divider(color: Colors.white12, height: 1),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _HeroShopCard extends StatelessWidget {
  static const int price = 500;

  final HeroEntity hero;
  final bool isActive;
  final bool isUnlocked;
  final int playerCoins;
  final VoidCallback onPurchase;

  const _HeroShopCard({
    required this.hero,
    required this.isActive,
    required this.isUnlocked,
    required this.playerCoins,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final color = factionColor(hero.faction);
    final canAfford = playerCoins >= price;

    return GestureDetector(
      onTap: (!isUnlocked && canAfford) ? onPurchase : null,
      child: Container(
        width: 112,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? const Color(0xFFFFD700)
                : color.withValues(alpha: 0.3),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Portrait
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: SizedBox(
                        height: 96,
                        child: Image.asset(
                          hero.imagePath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => Container(
                            color: color.withValues(alpha: 0.2),
                            child: Center(child: Icon(Icons.sports_mma, color: color, size: 40)),
                          ),
                        ),
                      ),
                    ),
                    // Oscurecer si bloqueado
                    if (!isUnlocked)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        child: Container(
                          height: 96,
                          color: Colors.black.withValues(alpha: 0.45),
                          child: const Center(
                            child: Icon(Icons.lock, color: Colors.white54, size: 24),
                          ),
                        ),
                      ),
                  ],
                ),
                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              hero.name,
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              hero.title,
                              style: const TextStyle(color: Color(0xFF8A8A9A), fontSize: 9),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        if (isUnlocked && !isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF27AE60).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'DESBLOQUEADO',
                              style: TextStyle(color: Color(0xFF27AE60), fontSize: 7, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else if (!isUnlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: canAfford
                                  ? const Color(0xFFF5B800).withValues(alpha: 0.12)
                                  : Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: canAfford
                                    ? const Color(0xFFF5B800).withValues(alpha: 0.4)
                                    : Colors.white12,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.monetization_on, size: 9,
                                    color: canAfford ? const Color(0xFFF5B800) : Colors.white30),
                                const SizedBox(width: 2),
                                Text(
                                  '$price',
                                  style: TextStyle(
                                    color: canAfford ? const Color(0xFFF5B800) : Colors.white30,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Badge ACTIVO
            if (isActive)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'ACTIVO',
                    style: TextStyle(color: Colors.black, fontSize: 7, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

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
