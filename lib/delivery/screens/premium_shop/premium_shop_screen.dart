// lib/delivery/screens/premium_shop/premium_shop_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../infra/config/premium_shop_config.dart';
import '../../state/providers.dart';

class PremiumShopScreen extends ConsumerWidget {
  const PremiumShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = ref.watch(playerProvider)?.tokens ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: CustomScrollView(
        slivers: [
          _PremiumShopAppBar(tokens: tokens),
          SliverToBoxAdapter(
            child: _SectionHeader(
              icon: Icons.emoji_events,
              title: 'Packs Legendarios',
              subtitle: 'Héroe + cartas + tokens al mejor precio',
            ),
          ),
          const SliverToBoxAdapter(child: _BundlesSection()),
          SliverToBoxAdapter(
            child: _SectionHeader(
              icon: Icons.diamond,
              title: 'Tokens',
              subtitle: 'Recarga tu economía de juego',
            ),
          ),
          const SliverToBoxAdapter(child: _TokenPacksSection()),
          SliverToBoxAdapter(
            child: _SectionHeader(
              icon: Icons.sports_mma,
              title: 'Héroes',
              subtitle: 'Desbloquea guerreros únicos con tokens',
            ),
          ),
          const SliverToBoxAdapter(child: _HeroesSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// ─── APP BAR ────────────────────────────────────────────────────────────────

class _PremiumShopAppBar extends StatelessWidget {
  final int tokens;
  const _PremiumShopAppBar({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: const Color(0xFF0D0D0D),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF2D0050),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFB39DDB).withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.diamond, size: 14, color: Color(0xFFB39DDB)),
              const SizedBox(width: 6),
              Text(
                '$tokens',
                style: const TextStyle(
                  color: Color(0xFFB39DDB),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2D0050), Color(0xFF0D0D0D)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, size: 26, color: Colors.amber),
                      const SizedBox(width: 10),
                      const Text(
                        'Tienda Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── SECCIÓN HEADER ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(icon, size: 22, color: Colors.white70),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Color(0xFF8A8A9A), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── SECCIÓN BUNDLES ────────────────────────────────────────────────────────

class _BundlesSection extends ConsumerWidget {
  const _BundlesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bundles = PremiumShopConfig.bundles;
    return SizedBox(
      height: 300,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: bundles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) => _BundleCard(
          bundle: bundles[i],
          onPurchase: () => _onBundlePurchase(context, ref, bundles[i]),
        ),
      ),
    );
  }

  Future<void> _onBundlePurchase(BuildContext context, WidgetRef ref, PremiumBundle bundle) async {
    final confirmed = await _showPurchaseDialog(
      context: context,
      title: bundle.name,
      body: 'Simulando compra de \$${_formatPrice(bundle.priceUsd)} USD\n\nRecibirás:\n• ${bundle.tokenAmount} tokens\n• Héroe: ${bundle.heroName}\n• ${bundle.cardCount} cartas de mazo',
      confirmLabel: 'Confirmar',
    );
    if (!confirmed || !context.mounted) return;
    await ref.read(playerProvider.notifier).grantBundle(
      heroId: bundle.heroId,
      tokenAmount: bundle.tokenAmount,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(_successSnackBar(
        '+${bundle.tokenAmount} tokens y ${bundle.heroName} desbloqueado',
      ));
    }
  }
}

class _BundleCard extends StatelessWidget {
  final PremiumBundle bundle;
  final VoidCallback onPurchase;

  const _BundleCard({required this.bundle, required this.onPurchase});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(bundle.heroGradientStart), Color(bundle.heroGradientEnd)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: bundle.isHighlighted
            ? Border.all(color: const Color(0xFFFFD700), width: 2)
            : Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: bundle.isHighlighted
                ? const Color(0xFFFFD700).withValues(alpha: 0.2)
                : Colors.black38,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.sports_mma, size: 44, color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 12),
                Text(bundle.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, height: 1.2)),
                const SizedBox(height: 4),
                Text(
                  bundle.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10),
                ),
                const SizedBox(height: 10),
                _BundleContentsRow(bundle: bundle),
                const Spacer(),
                _PriceButton(priceUsd: bundle.priceUsd, onTap: onPurchase),
              ],
            ),
          ),
          if (bundle.badgeText != null)
            Positioned(top: 10, right: 10, child: _Badge(text: bundle.badgeText!)),
        ],
      ),
    );
  }
}

class _BundleContentsRow extends StatelessWidget {
  final PremiumBundle bundle;
  const _BundleContentsRow({required this.bundle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ContentLine(icon: Icons.person, text: '1 Héroe: ${bundle.heroName}'),
        const SizedBox(height: 2),
        _ContentLine(icon: Icons.style, text: '${bundle.cardCount} Cartas de mazo'),
        const SizedBox(height: 2),
        _ContentLine(icon: Icons.diamond, text: '${bundle.tokenAmount} Tokens'),
      ],
    );
  }
}

class _ContentLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContentLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 11, color: const Color(0xFFB0B0B0)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 10)),
      ],
    );
  }
}

// ─── SECCIÓN TOKEN PACKS ────────────────────────────────────────────────────

class _TokenPacksSection extends ConsumerWidget {
  const _TokenPacksSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packs = PremiumShopConfig.tokenPacks;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: packs.length,
        itemBuilder: (context, i) => _TokenPackCard(
          pack: packs[i],
          onPurchase: () => _onPackPurchase(context, ref, packs[i]),
        ),
      ),
    );
  }

  Future<void> _onPackPurchase(BuildContext context, WidgetRef ref, TokenPack pack) async {
    final confirmed = await _showPurchaseDialog(
      context: context,
      title: pack.name,
      body: 'Simulando compra de \$${_formatPrice(pack.priceUsd)} USD\n\nRecibirás ${pack.totalTokens} tokens'
          '${pack.bonusTokens > 0 ? ' (+${pack.bonusTokens} de regalo)' : ''}.',
      confirmLabel: 'Confirmar',
    );
    if (!confirmed || !context.mounted) return;
    await ref.read(playerProvider.notifier).addTokens(pack.totalTokens);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(_successSnackBar('+${pack.totalTokens} tokens añadidos'));
    }
  }
}

class _TokenPackCard extends StatelessWidget {
  final TokenPack pack;
  final VoidCallback onPurchase;

  const _TokenPackCard({required this.pack, required this.onPurchase});

  @override
  Widget build(BuildContext context) {
    final isPopular = pack.badgeText != null;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A1A00), Color(0xFF1A0D00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: isPopular
            ? Border.all(color: const Color(0xFFF5B800).withValues(alpha: 0.6))
            : Border.all(color: Colors.white10),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monetization_on, size: 28, color: Color(0xFFF5B800)),
                    const Spacer(),
                    Text(
                      '\$${_formatPrice(pack.priceUsd)}',
                      style: const TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_formatTokens(pack.totalTokens)} 💎',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (pack.bonusTokens > 0)
                      Text(
                        '+${pack.bonusTokens} de regalo',
                        style: const TextStyle(color: Color(0xFFF5B800), fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: onPurchase,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5B800),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Comprar',
                            style: TextStyle(color: Color(0xFF0D0D0D), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (pack.badgeText != null)
            Positioned(top: 8, left: 8, child: _Badge(text: pack.badgeText!)),
        ],
      ),
    );
  }
}

// ─── SECCIÓN HÉROES ─────────────────────────────────────────────────────────

class _HeroesSection extends ConsumerWidget {
  const _HeroesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heroes = PremiumShopConfig.heroOffers;
    final unlockedIds = ref.watch(playerProvider)?.unlockedHeroIds ?? [];
    final currentTokens = ref.watch(playerProvider)?.tokens ?? 0;

    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: heroes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final hero = heroes[i];
          final isOwned = unlockedIds.contains(hero.heroId);
          final cost = _tokenCostForRarity(hero.rarity);
          return _HeroCard(
            hero: hero,
            isOwned: isOwned,
            tokenCost: cost,
            canAfford: currentTokens >= cost,
            onPurchase: isOwned ? null : () => _onHeroPurchase(context, ref, hero, cost, currentTokens),
            onInfo: () => _showHeroPreviewDialog(context, hero, cost, isOwned),
          );
        },
      ),
    );
  }

  Future<void> _onHeroPurchase(
    BuildContext context,
    WidgetRef ref,
    HeroOffer hero,
    int cost,
    int currentTokens,
  ) async {
    if (currentTokens < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        _errorSnackBar('No tenés suficientes tokens (necesitás $cost 💎)'),
      );
      return;
    }
    final confirmed = await _showPurchaseDialog(
      context: context,
      title: hero.name,
      body: 'Gastarás $cost tokens.\n\nSaldo actual: $currentTokens 💎\nSaldo final: ${currentTokens - cost} 💎',
      confirmLabel: 'Desbloquear',
    );
    if (!confirmed || !context.mounted) return;
    final success = await ref.read(playerProvider.notifier).purchaseHeroWithTokens(
      heroId: hero.heroId,
      tokenCost: cost,
    );
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(_successSnackBar('${hero.name} desbloqueado'));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(_errorSnackBar('No se pudo completar la compra'));
    }
  }
}

class _HeroCard extends StatelessWidget {
  final HeroOffer hero;
  final bool isOwned;
  final int tokenCost;
  final bool canAfford;
  final VoidCallback? onPurchase;
  final VoidCallback onInfo;

  const _HeroCard({
    required this.hero,
    required this.isOwned,
    required this.tokenCost,
    required this.canAfford,
    required this.onPurchase,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = Color(hero.rarity.colorHex);

    return Container(
      width: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(hero.gradientStart), Color(hero.gradientEnd)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: rarityColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(color: rarityColor.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.sports_mma, size: 36, color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: rarityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: rarityColor.withValues(alpha: 0.5), width: 0.5),
                  ),
                  child: Text(
                    hero.rarity.label,
                    style: TextStyle(color: rarityColor, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(height: 6),
                Text(hero.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (isOwned)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                    ),
                    child: const Center(
                      child: Text('COMPRADO', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: onPurchase,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: canAfford
                            ? const Color(0xFFB39DDB).withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: canAfford
                              ? const Color(0xFFB39DDB).withValues(alpha: 0.6)
                              : Colors.white24,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$tokenCost 💎',
                          style: TextStyle(
                            color: canAfford ? const Color(0xFFB39DDB) : Colors.white38,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (hero.isNew)
            Positioned(top: 8, right: 8, child: _Badge(text: 'NUEVO', color: const Color(0xFF00C853))),
          if (hero.isFeatured && !hero.isNew)
            Positioned(top: 8, right: 8, child: _Badge(text: 'DESTACADO', color: const Color(0xFFFFD700))),
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: onInfo,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.info_outline, size: 13, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── WIDGETS COMPARTIDOS ────────────────────────────────────────────────────

class _PriceButton extends StatelessWidget {
  final double priceUsd;
  final VoidCallback onTap;

  const _PriceButton({required this.priceUsd, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFE65100)]),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            '\$${_formatPrice(priceUsd)} USD',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1))],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, this.color = const Color(0xFFFFD700)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }
}

// ─── DIALOG PREVIEW DE HÉROE ────────────────────────────────────────────────

void _showHeroPreviewDialog(
  BuildContext context,
  HeroOffer hero,
  int tokenCost,
  bool isOwned,
) {
  final rarityColor = Color(hero.rarity.colorHex);
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (ctx) => Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(hero.gradientStart), Color(hero.gradientEnd)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: rarityColor.withValues(alpha: 0.5), width: 2),
              ),
              child: const Icon(Icons.sports_mma, size: 36, color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Text(
              hero.name,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: rarityColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: rarityColor.withValues(alpha: 0.5)),
              ),
              child: Text(
                hero.rarity.label.toUpperCase(),
                style: TextStyle(color: rarityColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              hero.description,
              style: const TextStyle(color: Color(0xFFB0B0C8), fontSize: 13, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (isOwned)
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green),
                  SizedBox(width: 6),
                  Text('Ya desbloqueado', style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.diamond, size: 16, color: Color(0xFFB39DDB)),
                  const SizedBox(width: 6),
                  Text('$tokenCost tokens', style: const TextStyle(color: Color(0xFFB39DDB), fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.of(ctx).pop(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: rarityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: rarityColor.withValues(alpha: 0.3)),
                ),
                child: const Text('Cerrar', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ─── DIALOG DE CONFIRMACIÓN ─────────────────────────────────────────────────

Future<bool> _showPurchaseDialog({
  required BuildContext context,
  required String title,
  required String body,
  required String confirmLabel,
}) async {
  return await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Text(body, style: const TextStyle(color: Color(0xFFB0B0C8), height: 1.5)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8A8A9A))),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB39DDB),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  ) ?? false;
}

SnackBar _successSnackBar(String message) => SnackBar(
  content: Text(message),
  backgroundColor: const Color(0xFF27AE60),
  behavior: SnackBarBehavior.floating,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
);

SnackBar _errorSnackBar(String message) => SnackBar(
  content: Text(message),
  backgroundColor: const Color(0xFFE74C3C),
  behavior: SnackBarBehavior.floating,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
);

// ─── HELPERS ────────────────────────────────────────────────────────────────

int _tokenCostForRarity(HeroRarity rarity) => switch (rarity) {
  HeroRarity.rare       => 500,
  HeroRarity.epic       => 1000,
  HeroRarity.legendary  => 1500,
};


String _formatPrice(double price) =>
    price == price.floorToDouble() ? price.toInt().toString() : price.toStringAsFixed(2);

String _formatTokens(int tokens) =>
    tokens >= 1000 ? '${(tokens / 1000).toStringAsFixed(tokens % 1000 == 0 ? 0 : 1)}K' : '$tokens';
