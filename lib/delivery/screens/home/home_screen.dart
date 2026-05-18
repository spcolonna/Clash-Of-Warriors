// lib/delivery/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/game_config.dart';
import '../../../domain/entities/hero_entity.dart';
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

    final gameConfig = ref.watch(gameConfigProvider).value ?? GameConfig.defaults;
    final currentReward = gameConfig.rewardAt(player.lastClaimedCycleIndex);

    final needsShopTutorial =
        player.tutorialBattleComplete && !player.starterCardPurchased;

    final activeHero = player.activeHeroId != null
        ? HeroesData.findById(player.activeHeroId!)
        : null;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Barra de recursos + botón "Cómo jugar" (arriba derecha) ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      _ResourceBar(
                        softCoins: player.softCoins,
                        medals: player.medals,
                        tokens: player.tokens,
                      ),
                      const Spacer(),
                      _HowToPlayChip(
                        onTap: () => Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const HowToPlayScreen(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                // ── Banner de bienvenida (desde el borde izquierdo) ───────
                _WelcomeBanner(factionId: player.selectedFactionId),
                const SizedBox(height: 16),
                // ── Barra de progreso de victorias ────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ProgressCycleBar(
                    player: player,
                    reward: currentReward,
                    onClaim: () =>
                        ref.read(playerProvider.notifier).claimProgressReward(),
                  ),
                ),
                const Spacer(),
                // ── Botón principal con héroe sobresaliendo ───────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ArenaButton(
                    hero: activeHero,
                    onTap: () {
                      if (activeHero == null) return;
                      ref.read(selectedHeroForBattleProvider.notifier).state =
                          activeHero;
                      context.go('/pre-battle');
                    },
                  ),
                ),
                const SizedBox(height: 14),
                // ── Tienda Premium (compacta) ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ShopButton(
                    onTap: () => Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const PremiumShopScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
        if (needsShopTutorial) const _ShopTabSpotlight(),
      ],
    );
  }
}

// ── Banner de bienvenida ────────────────────────────────────────────────────
// Arranca desde el borde izquierdo de la pantalla con esquinas redondeadas
// sólo en el lado derecho, dando el efecto de "banner que sale de la pared".

class _WelcomeBanner extends StatelessWidget {
  final String? factionId;

  const _WelcomeBanner({this.factionId});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);

    return Container(
      // Sin margen izquierdo → se pega al borde de la pantalla
      margin: const EdgeInsets.only(right: 28),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.60),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: const Border(
          top: BorderSide(color: gold, width: 1.5),
          right: BorderSide(color: gold, width: 1.5),
          bottom: BorderSide(color: gold, width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(3, 4),
          ),
          BoxShadow(
            color: gold.withValues(alpha: 0.12),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Escudo / emblema
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2A5E),
              shape: BoxShape.circle,
              border: Border.all(color: gold, width: 2),
              boxShadow: [
                BoxShadow(
                  color: gold.withValues(alpha: 0.35),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(Icons.shield, color: gold, size: 26),
          ),
          const SizedBox(width: 14),
          // Texto
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¡Bienvenido,',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
              ),
              const Text(
                'Guerrero!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.15,
                ),
              ),
              if (factionId != null) ...[
                const SizedBox(height: 3),
                Text(
                  _factionLabel(factionId!),
                  style: const TextStyle(
                    color: gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _factionLabel(String id) => switch (id) {
    'shaolin'  => 'Guardianes Shaolin',
    'ninja'    => 'Clan de las Sombras',
    'judoka'   => 'Hermandad de Hierro',
    'boxer'    => 'Boxeadores del Cemento',
    'capoeira' => 'Capoeiristas Libres',
    _          => '',
  };
}

// ── Botón de arena con héroe sobresaliendo ─────────────────────────────────

class _ArenaButton extends StatelessWidget {
  final HeroEntity? hero;
  final VoidCallback onTap;

  const _ArenaButton({this.hero, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // El héroe sobresale 48px por encima del botón
    const overflowTop = 48.0;
    const heroHeight = 136.0;

    return Padding(
      // Reserva espacio arriba para el héroe que sobresale
      padding: const EdgeInsets.only(top: overflowTop),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Botón ──────────────────────────────────────────────────────
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                // Padding derecho amplio para dejar espacio al héroe
                padding: EdgeInsets.fromLTRB(
                    22, 20, hero != null ? 118 : 22, 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2A323D),
                      Color(0xFF5E483A),
                      Color(0xFFE5A93C),
                    ],
                    stops: [0.0, 0.55, 1.0],
                    begin: Alignment(-0.87, -0.5),
                    end: Alignment(0.87, 0.5),
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE5A93C).withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Entrar a la Arena',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'VS IA',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ── Héroe sobresaliendo desde arriba-derecha ───────────────────
          if (hero != null)
            Positioned(
              right: 0,
              // Sube el héroe overflowTop px sobre el borde del botón
              top: -overflowTop,
              child: Image.asset(
                // Mismos nombres de archivo, subcarpeta sin fondo
                hero!.imagePath.replaceFirst('heros/', 'heros/withoutBG/'),
                height: heroHeight + overflowTop,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Widgets secundarios ────────────────────────────────────────────────────

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
        _ResourceChip(
            icon: Icons.monetization_on,
            value: softCoins,
            color: const Color(0xFFF5B800)),
        const SizedBox(width: 8),
        _ResourceChip(
            icon: Icons.military_tech, value: medals, color: Colors.amber),
        const SizedBox(width: 8),
        _ResourceChip(
            icon: Icons.diamond,
            value: tokens,
            color: const Color(0xFFB39DDB)),
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
        border: Border.all(color: color.withValues(alpha: 0.3)),
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

// ── Chip pequeño "Cómo jugar" (arriba derecha) ────────────────────────────

class _HowToPlayChip extends StatelessWidget {
  final VoidCallback onTap;
  const _HowToPlayChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.80),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.help_outline, size: 14, color: Colors.white54),
            SizedBox(width: 5),
            Text(
              'Cómo jugar',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Barra de progreso de victorias ────────────────────────────────────────

class _ProgressCycleBar extends StatelessWidget {
  final dynamic player;
  final ProgressRewardConfig reward;
  final VoidCallback onClaim;

  const _ProgressCycleBar({
    required this.player,
    required this.reward,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final pts = (player.battlePoints as int).clamp(0, reward.requiredPoints);
    final progress = pts / reward.requiredPoints;
    final isClaimable = pts >= reward.requiredPoints;

    const gold = Color(0xFFD4AF37);
    const purple = Color(0xFFB39DDB);

    final (rewardIcon, rewardColor, rewardLabel) = switch (reward.type) {
      'tokens' => (Icons.diamond,         purple,                     '+${reward.amount}'),
      'card'   => (Icons.style,           const Color(0xFF27AE60),    'Carta'),
      _        => (Icons.monetization_on, gold,                       '+${reward.amount}'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: gold.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(rewardIcon, size: 20, color: rewardColor),
          const SizedBox(width: 8),
          Text(
            rewardLabel,
            style: TextStyle(
              color: rewardColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFF2A2A3E),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isClaimable ? gold : rewardColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$pts / ${reward.requiredPoints} pts',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: isClaimable ? onClaim : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isClaimable
                    ? gold.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isClaimable ? gold : Colors.white24,
                ),
              ),
              child: Text(
                'RECLAMAR',
                style: TextStyle(
                  color: isClaimable ? gold : Colors.white30,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Botón compacto Tienda Premium ──────────────────────────────────────────

class _ShopButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ShopButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFB39DDB).withValues(alpha: 0.35),
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.workspace_premium, size: 20, color: Color(0xFFB39DDB)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tienda Premium',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white38, size: 18),
          ],
        ),
      ),
    );
  }
}

