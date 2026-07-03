// lib/delivery/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/game_config.dart';
import '../../../domain/entities/hero_entity.dart';
import '../../../domain/entities/player_profile.dart';
import '../../../domain/entities/daily_mission.dart';
import '../../../infra/local/heroes_data.dart';
import '../../../infra/local/daily_rewards_data.dart';
import '../../../infra/local/new_player_journey_data.dart';
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
  bool _dailyChecked = false;

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

    // ── Login diario: contabilizar racha y mostrar recompensa (una vez) ──────
    if (!_dailyChecked) {
      _dailyChecked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(playerProvider.notifier).ensureDailyMissions();
        final result = ref.read(playerProvider.notifier).processDailyLogin();
        if (result != null && mounted) {
          _showDailyRewardDialog(context, result);
        }
      });
    }

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
                // ── Nivel de cuenta (XP) ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _LevelBar(player: player),
                ),
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
                const SizedBox(height: 12),
                // ── Misiones diarias ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _MissionsButton(
                    player: player,
                    onTap: () => _showMissionsSheet(context),
                  ),
                ),
                // ── Camino del nuevo jugador (se oculta al completarse) ────
                if (!NewPlayerJourneyData.allClaimed(player)) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _JourneyButton(
                      player: player,
                      onTap: () => _showJourneySheet(context),
                    ),
                  ),
                ],
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

  void _showDailyRewardDialog(BuildContext context, DailyLoginResult result) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.78),
      builder: (_) => _DailyRewardDialog(result: result),
    );
  }

  void _showMissionsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _MissionsSheet(),
    );
  }

  void _showJourneySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _JourneySheet(),
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

// ── Barra de nivel de cuenta (XP) ───────────────────────────────────────────

class _LevelBar extends StatelessWidget {
  final PlayerProfile player;
  const _LevelBar({required this.player});

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF3498DB);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: blue.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: blue.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: blue, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              '${player.accountLevel}',
              style: const TextStyle(
                color: blue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'Nivel de cuenta',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${player.xpIntoLevel} / ${PlayerProfile.xpPerLevel} XP',
                      style: const TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: player.levelProgress,
                    minHeight: 7,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation(blue),
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

// ── Dialog de recompensa de login diario ────────────────────────────────────

class _DailyRewardDialog extends StatelessWidget {
  final DailyLoginResult result;
  const _DailyRewardDialog({required this.result});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF5B800);
    final reward = result.reward;
    final (rewardIcon, rewardColor, rewardLabel) = switch (reward.type) {
      DailyRewardType.coins  => (Icons.monetization_on, const Color(0xFF27AE60), '+${reward.amount} monedas'),
      DailyRewardType.tokens => (Icons.diamond,         const Color(0xFFB39DDB), '+${reward.amount} tokens'),
      DailyRewardType.card   => (Icons.style,           const Color(0xFF3498DB), 'Una carta'),
    };

    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, color: gold, size: 40),
            const SizedBox(height: 12),
            const Text(
              'Recompensa diaria',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Racha de ${result.streak} ${result.streak == 1 ? "día" : "días"}',
              style: const TextStyle(color: gold, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            // Calendario de 7 días
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(DailyRewardsData.calendar.length, (i) {
                final dayNum = i + 1;
                final currentDay = ((result.streak - 1) % 7) + 1;
                final isToday = dayNum == currentDay;
                final isPast = dayNum < currentDay;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 30,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isToday
                        ? gold.withValues(alpha: 0.22)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isToday ? gold : Colors.white12,
                      width: isToday ? 1.5 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: isPast
                      ? const Icon(Icons.check, color: Color(0xFF27AE60), size: 16)
                      : Text(
                          '$dayNum',
                          style: TextStyle(
                            color: isToday ? gold : Colors.white38,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                );
              }),
            ),
            const SizedBox(height: 20),
            // Recompensa de hoy
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: rewardColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: rewardColor.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(rewardIcon, color: rewardColor, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    rewardLabel,
                    style: TextStyle(color: rewardColor, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('¡Reclamar!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Misiones diarias: helpers + UI ───────────────────────────────────────────

String missionLabel(DailyMission m) => switch (m.type) {
      DailyMissionType.winBattles  => 'Ganá ${m.target} batallas',
      DailyMissionType.playBattles => 'Jugá ${m.target} batallas',
      DailyMissionType.winSlots    => 'Ganá ${m.target} slots',
      DailyMissionType.useScout    => 'Usá ${m.target} scouts',
      DailyMissionType.playHard    => 'Jugá ${m.target} en Difícil',
    };

class _MissionsButton extends StatelessWidget {
  final PlayerProfile player;
  final VoidCallback onTap;
  const _MissionsButton({required this.player, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF9B59B6);
    final missions = player.dailyMissions;
    final completed = missions.where((m) => m.isComplete).length;
    final claimable = missions.any((m) => m.isComplete && !m.claimed);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: claimable ? purple : purple.withValues(alpha: 0.35),
              width: claimable ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.assignment_turned_in, color: purple, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Misiones diarias',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (claimable)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5B800),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '¡Cobrar!',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Text(
                '$completed/${missions.length}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionsSheet extends ConsumerWidget {
  const _MissionsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final missions = player?.dailyMissions ?? const <DailyMission>[];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Misiones diarias',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Se renuevan cada día',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          if (missions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('No hay misiones por ahora.',
                  style: TextStyle(color: Colors.white38)),
            )
          else
            ...missions.map((m) => _MissionRow(
                  mission: m,
                  onClaim: () =>
                      ref.read(playerProvider.notifier).claimMission(m.id),
                )),
        ],
      ),
    );
  }
}

class _MissionRow extends StatelessWidget {
  final DailyMission mission;
  final VoidCallback onClaim;
  const _MissionRow({required this.mission, required this.onClaim});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF9B59B6);
    final progress = (mission.progress / mission.target).clamp(0.0, 1.0);
    final isTokens = mission.rewardType == 'tokens';
    final rewardColor = isTokens ? const Color(0xFFB39DDB) : const Color(0xFF27AE60);
    final rewardLabel = '+${mission.rewardAmount}';
    final rewardIcon = isTokens ? Icons.diamond : Icons.monetization_on;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: mission.isComplete && !mission.claimed
              ? const Color(0xFFF5B800).withValues(alpha: 0.5)
              : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  missionLabel(mission),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(rewardIcon, color: rewardColor, size: 15),
              const SizedBox(width: 3),
              Text(
                rewardLabel,
                style: TextStyle(
                  color: rewardColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation(purple),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${mission.progress}/${mission.target}',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
          if (mission.isComplete) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 34,
              child: ElevatedButton(
                onPressed: mission.claimed ? null : onClaim,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5B800),
                  disabledBackgroundColor: Colors.white10,
                  foregroundColor: Colors.black,
                  // El theme global fuerza padding vertical 16 y el botón mide
                  // 34px → el texto quedaba recortado e invisible.
                  padding: EdgeInsets.zero,
                  textStyle: const TextStyle(fontSize: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  mission.claimed ? 'Cobrada ✓' : 'Cobrar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: mission.claimed ? Colors.white38 : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Camino del nuevo jugador: UI ─────────────────────────────────────────────

class _JourneyButton extends StatelessWidget {
  final PlayerProfile player;
  final VoidCallback onTap;
  const _JourneyButton({required this.player, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF1ABC9C);
    final milestones = NewPlayerJourneyData.milestones;
    final claimed = milestones.where((m) => player.claimedMilestones.contains(m.id)).length;
    final claimable = milestones.any(
      (m) => m.isComplete(player) && !player.claimedMilestones.contains(m.id),
    );

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: claimable ? teal : teal.withValues(alpha: 0.35),
              width: claimable ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.flag, color: teal, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Primeros pasos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (claimable)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5B800),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '¡Cobrar!',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Text(
                '$claimed/${milestones.length}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _JourneySheet extends ConsumerWidget {
  const _JourneySheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final milestones = NewPlayerJourneyData.milestones;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Primeros pasos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Completá estos hitos para arrancar con todo',
            style: TextStyle(color: Colors.white54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (player != null)
            ...milestones.map((m) => _JourneyRow(
                  milestone: m,
                  complete: m.isComplete(player),
                  claimed: player.claimedMilestones.contains(m.id),
                  onClaim: () =>
                      ref.read(playerProvider.notifier).claimMilestone(m.id),
                )),
        ],
      ),
    );
  }
}

class _JourneyRow extends StatelessWidget {
  final JourneyMilestone milestone;
  final bool complete;
  final bool claimed;
  final VoidCallback onClaim;
  const _JourneyRow({
    required this.milestone,
    required this.complete,
    required this.claimed,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final isTokens = milestone.rewardType == 'tokens';
    final rewardColor = isTokens ? const Color(0xFFB39DDB) : const Color(0xFF27AE60);
    final rewardIcon = isTokens ? Icons.diamond : Icons.monetization_on;
    final canClaim = complete && !claimed;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canClaim
              ? const Color(0xFFF5B800).withValues(alpha: 0.5)
              : Colors.white12,
        ),
      ),
      child: Row(
        children: [
          Icon(
            claimed
                ? Icons.check_circle
                : complete
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
            color: claimed
                ? const Color(0xFF27AE60)
                : complete
                    ? const Color(0xFFF5B800)
                    : Colors.white24,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              milestone.label,
              style: TextStyle(
                color: claimed ? Colors.white38 : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                decoration: claimed ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          if (canClaim)
            SizedBox(
              height: 32,
              child: ElevatedButton(
                onPressed: onClaim,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5B800),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cobrar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(rewardIcon, color: rewardColor, size: 15),
                const SizedBox(width: 3),
                Text(
                  '+${milestone.rewardAmount}',
                  style: TextStyle(
                    color: rewardColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

