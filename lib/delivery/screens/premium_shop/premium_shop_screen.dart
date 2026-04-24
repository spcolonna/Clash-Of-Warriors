// lib/delivery/screens/premium_shop/premium_shop_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../infra/config/premium_shop_config.dart';

class PremiumShopScreen extends StatelessWidget {
  const PremiumShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: CustomScrollView(
        slivers: [
          _PremiumShopAppBar(),
          SliverToBoxAdapter(
            child: _SectionHeader(
              icon: '🏆',
              title: 'Packs Legendarios',
              subtitle: 'Héroe + cartas + tokens al mejor precio',
            ),
          ),
          SliverToBoxAdapter(child: _BundlesSection()),
          SliverToBoxAdapter(
            child: _SectionHeader(
              icon: '🪙',
              title: 'Tokens',
              subtitle: 'Recarga tu economía de juego',
            ),
          ),
          SliverToBoxAdapter(child: _TokenPacksSection()),
          SliverToBoxAdapter(
            child: _SectionHeader(
              icon: '⚔️',
              title: 'Héroes',
              subtitle: 'Desbloquea guerreros únicos',
            ),
          ),
          SliverToBoxAdapter(child: _HeroesSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// ─── APP BAR ────────────────────────────────────────────────────────────────

class _PremiumShopAppBar extends StatelessWidget {
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
                      Text(
                        '🏆',
                        style: GoogleFonts.notoColorEmoji(
                          textStyle: const TextStyle(fontSize: 26),
                        ),
                      ),
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
  final String icon;
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
          Text(
            icon,
            style: GoogleFonts.notoColorEmoji(
              textStyle: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF8A8A9A),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── SECCIÓN BUNDLES ────────────────────────────────────────────────────────

class _BundlesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bundles = PremiumShopConfig.bundles;
    return SizedBox(
      height: 300,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: bundles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) => _BundleCard(bundle: bundles[i]),
      ),
    );
  }
}

class _BundleCard extends StatelessWidget {
  final PremiumBundle bundle;

  const _BundleCard({required this.bundle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(bundle.heroGradientStart),
            Color(bundle.heroGradientEnd),
          ],
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
                ? const Color(0xFFFFD700).withOpacity(0.2)
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
                // Hero icon placeholder
                Container(
                  width: double.infinity,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _heroEmoji(bundle.heroId),
                      style: GoogleFonts.notoColorEmoji(
                        textStyle: const TextStyle(fontSize: 44),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  bundle.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bundle.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 10),
                _BundleContentsRow(bundle: bundle),
                const Spacer(),
                _PriceButton(
                  priceUsd: bundle.priceUsd,
                  onTap: () => _onPurchase(context),
                ),
              ],
            ),
          ),
          if (bundle.badgeText != null)
            Positioned(
              top: 10,
              right: 10,
              child: _Badge(text: bundle.badgeText!),
            ),
        ],
      ),
    );
  }

  void _onPurchase(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Comprando ${bundle.name}… (próximamente)'),
        backgroundColor: const Color(0xFF1A1A2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        _ContentLine(icon: '🦸', text: '1 Héroe: ${bundle.heroName}'),
        const SizedBox(height: 2),
        _ContentLine(icon: '🃏', text: '${bundle.cardCount} Cartas de mazo'),
        const SizedBox(height: 2),
        _ContentLine(
          icon: '🪙',
          text: '${bundle.tokenAmount} Tokens',
        ),
      ],
    );
  }
}

class _ContentLine extends StatelessWidget {
  final String icon;
  final String text;
  const _ContentLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          icon,
          style: GoogleFonts.notoColorEmoji(
            textStyle: const TextStyle(fontSize: 11),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFFB0B0B0),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// ─── SECCIÓN TOKEN PACKS ────────────────────────────────────────────────────

class _TokenPacksSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
        itemBuilder: (context, i) => _TokenPackCard(pack: packs[i]),
      ),
    );
  }
}

class _TokenPackCard extends StatelessWidget {
  final TokenPack pack;
  const _TokenPackCard({required this.pack});

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
            ? Border.all(color: const Color(0xFFF5B800).withOpacity(0.6))
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
                    Text(
                      pack.icon,
                      style: GoogleFonts.notoColorEmoji(
                        textStyle: const TextStyle(fontSize: 28),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${_formatPrice(pack.priceUsd)}',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_formatTokens(pack.totalTokens)} 🪙',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (pack.bonusTokens > 0)
                      Text(
                        '+${pack.bonusTokens} de regalo',
                        style: const TextStyle(
                          color: Color(0xFFF5B800),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => _onPurchase(context),
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
                            style: TextStyle(
                              color: Color(0xFF0D0D0D),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
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
            Positioned(
              top: 8,
              left: 8,
              child: _Badge(text: pack.badgeText!),
            ),
        ],
      ),
    );
  }

  void _onPurchase(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Comprando ${pack.name}… (próximamente)'),
        backgroundColor: const Color(0xFF1A1A2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─── SECCIÓN HÉROES ─────────────────────────────────────────────────────────

class _HeroesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final heroes = PremiumShopConfig.heroOffers;
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: heroes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _HeroCard(hero: heroes[i]),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final HeroOffer hero;
  const _HeroCard({required this.hero});

  @override
  Widget build(BuildContext context) {
    final rarityColor = Color(hero.rarity.colorHex);

    return Container(
      width: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(hero.gradientStart),
            Color(hero.gradientEnd),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: rarityColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: rarityColor.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero portrait
                Container(
                  width: double.infinity,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _heroEmoji(hero.heroId),
                      style: GoogleFonts.notoColorEmoji(
                        textStyle: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Rarity badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: rarityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: rarityColor.withOpacity(0.5),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    hero.rarity.label,
                    style: TextStyle(
                      color: rarityColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hero.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  hero.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 9,
                    height: 1.3,
                  ),
                ),
                const Spacer(),
                _PriceButton(
                  priceUsd: hero.priceUsd,
                  onTap: () => _onPurchase(context),
                ),
              ],
            ),
          ),
          if (hero.isNew)
            Positioned(
              top: 8,
              right: 8,
              child: _Badge(text: 'NUEVO', color: const Color(0xFF00C853)),
            ),
          if (hero.isFeatured && !hero.isNew)
            Positioned(
              top: 8,
              right: 8,
              child:
                  _Badge(text: 'DESTACADO', color: const Color(0xFFFFD700)),
            ),
        ],
      ),
    );
  }

  void _onPurchase(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Comprando ${hero.name}… (próximamente)'),
        backgroundColor: const Color(0xFF1A1A2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFE65100)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            '\$${_formatPrice(priceUsd)} USD',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
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

  const _Badge({
    required this.text,
    this.color = const Color(0xFFFFD700),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── HELPERS ────────────────────────────────────────────────────────────────

String _heroEmoji(String heroId) => switch (heroId) {
      'ninja' => '🥷',
      'samurai' => '⚔️',
      'viking' => '🪓',
      'spartan' => '🛡️',
      'gladiator' => '🏟️',
      'muaythai' => '🥊',
      'monk' => '🧘',
      'templar' => '✝️',
      'karate' => '🥋',
      'kungfu' => '🐉',
      'sumo' => '🏆',
      'wrestler' => '💪',
      'capoeira' => '🎭',
      'berserker' => '🔥',
      'pirate' => '🏴‍☠️',
      'amazon' => '🏹',
      'shaman' => '🌿',
      'mongol' => '🐎',
      'taichi' => '☯️',
      'wushu' => '🌀',
      _ => '⚔️',
    };

String _formatPrice(double price) =>
    price == price.floorToDouble() ? price.toInt().toString() : price.toStringAsFixed(2);

String _formatTokens(int tokens) =>
    tokens >= 1000 ? '${(tokens / 1000).toStringAsFixed(tokens % 1000 == 0 ? 0 : 1)}K' : '$tokens';
