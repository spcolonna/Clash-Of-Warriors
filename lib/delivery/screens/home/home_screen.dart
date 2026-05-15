// lib/delivery/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../infra/local/heroes_data.dart';
import '../../state/providers.dart';
import '../../widgets/tutorial_spotlight_overlay.dart';
import '../help/how_to_play_screen.dart';
import '../premium_shop/premium_shop_screen.dart';
import '../shell/main_shell_scaffold.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _loadAttempted = false;

  @override
  Widget build(BuildContext context) {
    final t0 = DateTime.now().millisecondsSinceEpoch;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('[HOME] first frame: ${DateTime.now().millisecondsSinceEpoch - t0}ms');
    });

    final player = ref.watch(playerProvider);
    // Watch auth state — rebuild automático cuando Firebase Auth resuelve
    final authState = ref.watch(authStateProvider);

    if (player == null) {
      debugPrint('[HOME] player=null auth=${authState.runtimeType} user=${authState.value?.uid ?? "null"} attempted=$_loadAttempted');
      final user = authState.value;
      if (user != null && !_loadAttempted) {
        _loadAttempted = true;
        debugPrint('[HOME] → scheduling loadPlayer');
        Future.microtask(
          () => ref.read(playerProvider.notifier).loadPlayer(user.uid),
        );
      }
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D0D),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    _loadAttempted = false;

    final needsShopTutorial =
        player.tutorialBattleComplete && !player.starterCardPurchased;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ResourceBar(
                    softCoins: player.softCoins,
                    medals: player.medals,
                    tokens: player.tokens,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '¡Bienvenido,\nGuerrero!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    player.selectedFactionId != null
                        ? 'Facción: ${_factionName(player.selectedFactionId!)}'
                        : '',
                    style: const TextStyle(
                      color: Color(0xFF8A8A9A),
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  _PrimaryActionCard(
                    icon: Icons.sports_mma,
                    title: 'Entrar a la Arena',
                    subtitle: 'Elegí dificultad y combatí contra la IA',
                    onTap: () {
                      final activeHeroId = player.activeHeroId;
                      if (activeHeroId == null) return;
                      final hero = HeroesData.findById(activeHeroId);
                      ref.read(selectedHeroForBattleProvider.notifier).state = hero;
                      context.go('/pre-battle');
                    },
                  ),
                  const SizedBox(height: 16),
                  _SecondaryActionCard(
                    icon: Icons.workspace_premium,
                    title: 'Tienda Premium',
                    subtitle: 'Héroes legendarios, tokens y packs exclusivos',
                    onTap: () => Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const PremiumShopScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SecondaryActionCard(
                    icon: Icons.help_outline,
                    title: 'Cómo jugar',
                    subtitle: 'Tabla de choques, cálculo de daño y stats',
                    onTap: () => Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const HowToPlayScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
        if (needsShopTutorial) const _ShopTabSpotlight(),
      ],
    );
  }

  String _factionName(String factionId) => switch (factionId) {
    'shaolin' => 'Guardianes Shaolin',
    'ninja' => 'Clan de las Sombras',
    'judoka' => 'Hermandad de Hierro',
    'boxer' => 'Boxeadores del Cemento',
    'capoeira' => 'Capoeiristas Libres',
    _ => '',
  };
}

class _ShopTabSpotlight extends ConsumerWidget {
  const _ShopTabSpotlight();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TutorialSpotlightOverlay(
      targetKey: const GlobalObjectKey('nav_shop'),
      message:
      '¡Hora de fortalecer tu mazo!\nTocá la Tienda para comprar tu primera carta de facción.',
      onDismiss: () {
        ref.read(activeTabProvider.notifier).state = 1;
      },
      spotlightPadding: 8,
    );
  }
}

class _ResourceBar extends StatelessWidget {
  final int softCoins;
  final int medals;
  final int tokens;

  const _ResourceBar({
    required this.softCoins,
    required this.medals,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ResourceChip(icon: Icons.monetization_on, value: softCoins, color: const Color(0xFFF5B800)),
        const SizedBox(width: 8),
        _ResourceChip(icon: Icons.military_tech, value: medals, color: Colors.amber),
        const SizedBox(width: 8),
        _ResourceChip(icon: Icons.diamond, value: tokens, color: const Color(0xFFB39DDB)),
      ],
    );
  }
}

class _ResourceChip extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color color;

  const _ResourceChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PrimaryActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE74C3C).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card secundaria con estilo más discreto — usada para "Cómo jugar".
class _SecondaryActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SecondaryActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.white70),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF8A8A9A),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
