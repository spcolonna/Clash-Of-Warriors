// lib/delivery/screens/battle/end_battle_screen.dart

import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/battle_state.dart' show BattleState;
import '../../../domain/entities/game_config.dart' show BattleRewardsConfig;
import '../../../domain/config/rank_ladder.dart';
import '../../widgets/rank_badge.dart';
import '../../widgets/level_up_dialog.dart';
import '../../../infra/local/heroes_data.dart';
import '../../../infra/local/daily_rewards_data.dart';
import '../../../infra/services/admob_service.dart';
import '../../../infra/services/haptics_service.dart';
import '../../../infra/sound/sound_service.dart';
import '../../state/battle_provider.dart';
import '../../state/providers.dart';
import '../../state/story_provider.dart';

class EndBattleScreen extends ConsumerStatefulWidget {
  const EndBattleScreen({super.key});

  @override
  ConsumerState<EndBattleScreen> createState() => _EndBattleScreenState();
}

class _EndBattleScreenState extends ConsumerState<EndBattleScreen> {
  // Rewarded "duplicar XP" (solo derrota): usable una vez por batalla.
  bool _xpDoubled = false;
  bool _showingAd = false;

  @override
  void initState() {
    super.initState();
    final won = ref.read(battleProvider).playerWon ?? true;
    SoundService().play(won ? 'victory' : 'defeat');
    if (won) {
      HapticsService().success();
    } else {
      HapticsService().medium();
    }
  }

  /// Monedas de consolación por derrota: proporcional al daño infligido.
  int _consolationCoins(BattleState battle) {
    final dealt = battle.roundHistory
        .fold<double>(0, (s, r) => s + r.totalPlayerDamage);
    return (dealt / 4).round().clamp(5, 40);
  }

  Future<void> _watchAdToDoubleXp(int xpReward) async {
    if (_xpDoubled || _showingAd) return;
    setState(() => _showingAd = true);
    final completed = await AdMobService().showRewarded(
      onRewarded: (_) {
        // La recompensa acá es XP extra, no los tokens default del servicio.
        ref.read(playerProvider.notifier).addAccountXp(xpReward);
      },
    );
    if (!mounted) return;
    setState(() {
      _showingAd = false;
      _xpDoubled = completed;
    });
    if (completed) {
      SoundService().play('level_up');
      HapticsService().success();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('El anuncio no está disponible ahora. Probá en un rato.'),
        duration: Duration(milliseconds: 1600),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  /// Interstitial suave cada N batallas (fire-and-forget tras salir).
  Future<void> _maybeShowInterstitial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = (prefs.getInt('battleCount') ?? 0) + 1;
      await prefs.setInt('battleCount', count);
      if (AdMobService().shouldShowInterstitial(count)) {
        await AdMobService().showInterstitial();
      }
    } catch (_) {
      // Ads nunca deben romper el flujo del juego
    }
  }

  @override
  Widget build(BuildContext context) {
    final battle = ref.watch(battleProvider);
    final playerWon = battle.playerWon ?? true;
    final isTutorial = battle.isTutorial;
    final isStoryBattle = battle.isStoryBattle;
    // Abandonar la pelea no paga consolación: la recompensa es por pelearla.
    final surrendered = battle.surrendered;

    final rewards = ref.watch(gameConfigProvider).value?.battleRewards ??
        const BattleRewardsConfig();
    final medals = rewards.medalsFor(isTutorial);
    final baseCoins = rewards.coinsFor(isTutorial);
    final tokens = rewards.tokensFor(isTutorial, battle.botDifficulty);

    // ── Retención: primera victoria del día (x2) + XP de toda batalla ──────────
    final player = ref.watch(playerProvider);
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final isFirstWinOfDay = playerWon &&
        !isTutorial &&
        !isStoryBattle &&
        player != null &&
        player.lastDailyWinDate != todayStr;
    final coins = isFirstWinOfDay ? baseCoins * 2 : baseCoins;
    final xpReward =
        playerWon ? DailyRewardsData.xpForWin : DailyRewardsData.xpForLoss;

    // Métricas para misiones diarias
    final slotsWonCount = battle.roundHistory.fold<int>(
      0,
      (s, r) => s + r.slotResults.where((sr) => sr.winner == 'player').length,
    );
    final scoutsUsedCount = (3 - battle.scoutTokensRemaining).clamp(0, 3);
    final wasHard = battle.botDifficulty == BotDifficulty.hard;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          if (playerWon)
            const Positioned.fill(
              child: IgnorePointer(child: _ConfettiOverlay()),
            ),
          SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              children: [
              const SizedBox(height: 32),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Icon(
                  playerWon
                      ? Icons.emoji_events
                      : Icons.sentiment_very_dissatisfied,
                  size: 72,
                  color: playerWon ? Colors.amber : Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              _Appear(
                delayMs: 150,
                child: Text(
                  playerWon ? '¡Victoria!' : 'Derrota',
                  style: TextStyle(
                    color: playerWon ? Colors.amber : Colors.red,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _Appear(
                delayMs: 250,
                child: Text(
                  playerWon
                      ? 'Demostraste tu valía en la Arena'
                      : surrendered
                          ? 'Abandonaste el combate. Sin pelea no hay recompensa.'
                          : 'La batalla continúa. Volvé más fuerte.',
                  style: const TextStyle(color: Color(0xFF8A8A9A), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'RECOMPENSAS',
                style: TextStyle(color: Color(0xFF8A8A9A), fontSize: 11, letterSpacing: 2),
              ),
              const SizedBox(height: 16),
              if (playerWon) ...[
                _Appear(
                  delayMs: 350,
                  child: _RewardRow(icon: Icons.military_tech, label: 'Medallas', value: '+$medals', color: Colors.amber),
                ),
                const SizedBox(height: 12),
                _Appear(
                  delayMs: 470,
                  child: _RewardRow(
                    icon: Icons.monetization_on,
                    label: 'Monedas',
                    value: '+$coins',
                    color: const Color(0xFF27AE60),
                    badge: isFirstWinOfDay ? '1ª del día · x2' : null,
                  ),
                ),
                const SizedBox(height: 12),
                _Appear(
                  delayMs: 590,
                  child: _RewardRow(icon: Icons.diamond, label: 'Tokens', value: '+$tokens', color: const Color(0xFFB39DDB)),
                ),
                const SizedBox(height: 12),
              ],
              // Derrota: consolación proporcional al daño infligido —
              // toda batalla peleada deja algo (rendirse no).
              if (!playerWon && !isTutorial && !surrendered) ...[
                _Appear(
                  delayMs: 350,
                  child: _RewardRow(
                    icon: Icons.monetization_on,
                    label: 'Monedas',
                    value: '+${_consolationCoins(battle)}',
                    color: const Color(0xFF27AE60),
                    badge: 'peleaste bien',
                  ),
                ),
                const SizedBox(height: 12),
              ],
              // XP siempre se otorga, gane o pierda — la progresión nunca es nula.
              _Appear(
                delayMs: playerWon ? 710 : 470,
                child: _RewardRow(
                  icon: Icons.trending_up,
                  label: 'XP',
                  value: _xpDoubled ? '+${xpReward * 2}' : '+$xpReward',
                  color: const Color(0xFF3498DB),
                  badge: _xpDoubled ? 'x2 ✓' : null,
                ),
              ),
              // Derrota: duplicar XP viendo un anuncio (una vez)
              if (!playerWon && !_xpDoubled) ...[
                const SizedBox(height: 12),
                _Appear(
                  delayMs: 590,
                  child: SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _showingAd
                          ? null
                          : () => _watchAdToDoubleXp(xpReward),
                      icon: const Icon(Icons.ondemand_video, size: 18),
                      label: Text(
                        _showingAd
                            ? 'Cargando anuncio…'
                            : 'Duplicá tu XP viendo un anuncio',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3498DB),
                        side: const BorderSide(color: Color(0xFF3498DB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _StatLine('Rounds jugados', '${battle.currentRound - 1}'),
                    const SizedBox(height: 8),
                    _StatLine('Daño total infligido',
                        '${battle.roundHistory.fold<double>(0, (s, r) => s + r.totalPlayerDamage).round()}'),
                    const SizedBox(height: 8),
                    _StatLine('Daño total recibido',
                        '${battle.roundHistory.fold<double>(0, (s, r) => s + r.totalOpponentDamage).round()}'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botón Revancha
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    if (isStoryBattle) {
                      // Revancha en historia: re-iniciar con el mismo contexto
                      final storyCtx = ref.read(storyBattleContextProvider);
                      final session = ref.read(storySessionProvider);
                      if (storyCtx != null && session != null) {
                        final playerHero = HeroesData.findByIdSafe(storyCtx.heroId);
                        final battleStage = session.currentStage.battle;
                        final botHero = battleStage != null
                            ? HeroesData.findByIdSafe(battleStage.botHeroId)
                            : null;
                        if (playerHero != null && botHero != null && battleStage != null) {
                          ref.read(battleProvider.notifier).initStoryBattle(
                            playerHero: playerHero,
                            botHero: botHero,
                            difficulty: battleStage.difficulty,
                            gameMode: battleStage.gameMode,
                          );
                          context.go('/battle');
                        }
                      }
                      return;
                    }
                    final playerHero = ref.read(selectedHeroForBattleProvider);
                    if (playerHero == null) return;
                    // Revancha contra el MISMO rival de la batalla anterior
                    final botHero = battle.opponent.hero;
                    if (isTutorial) {
                      ref.read(battleProvider.notifier).initTutorialBattle(
                        playerHero: playerHero,
                        botHero: botHero,
                      );
                    } else {
                      final difficulty = ref.read(selectedDifficultyProvider);
                      ref.read(battleProvider.notifier).initArenaBattle(
                        playerHero: playerHero,
                        botHero: botHero,
                        difficulty: difficulty,
                      );
                    }
                    context.go('/battle');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sports_mma, size: 18),
                      SizedBox(width: 8),
                      Text('Revancha', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Botón Continuar
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    // ── Historia ────────────────────────────────────────────
                    if (isStoryBattle) {
                      // XP de cuenta + progreso de misiones (gane o pierda)
                      ref.read(playerProvider.notifier).addAccountXp(xpReward);
                      if (playerWon) {
                        // Las mismas recompensas que ya se muestran en pantalla
                        // (medals/coins/tokens) nunca se aplicaban al Player.
                        ref.read(playerProvider.notifier).addMedals(medals);
                        ref.read(playerProvider.notifier).addSoftCoins(coins);
                        ref.read(playerProvider.notifier).addTokens(tokens);
                      } else if (!surrendered) {
                        ref
                            .read(playerProvider.notifier)
                            .addSoftCoins(_consolationCoins(battle));
                      }
                      ref.read(playerProvider.notifier).reportBattleResult(
                            won: playerWon,
                            slotsWon: slotsWonCount,
                            wasHard: wasHard,
                            scoutsUsed: scoutsUsedCount,
                          );
                      final storyCtx = ref.read(storyBattleContextProvider);
                      if (storyCtx != null) {
                        if (playerWon && storyCtx.stageIndex == 9) {
                          // Stage final ganado → completar arco y mostrar recompensa
                          await ref.read(playerProvider.notifier).completeStoryArc(
                            storyCtx.heroId, storyCtx.rarity,
                          );
                          ref.read(storySessionProvider.notifier).reset();
                          ref.read(storyBattleContextProvider.notifier).state = null;
                          if (context.mounted) context.go('/story-reward');
                        } else if (playerWon) {
                          // Stage intermedio ganado → marcar y continuar historia
                          ref.read(storySessionProvider.notifier).completeBattleStage();
                          ref.read(storyBattleContextProvider.notifier).state = null;
                          if (context.mounted) context.go('/story-scene');
                        } else {
                          // Derrota → volver a la escena para reintentar
                          ref.read(storyBattleContextProvider.notifier).state = null;
                          if (context.mounted) context.go('/story-scene');
                        }
                      } else {
                        if (context.mounted) context.go('/home');
                      }
                      return;
                    }

                    // ── Tutorial / Arena ────────────────────────────────────
                    if (ref.read(playerProvider) == null) {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await ref.read(playerProvider.notifier).loadPlayer(user.uid);
                      }
                    }
                    final notifier = ref.read(playerProvider.notifier);
                    final loadedPlayer = ref.read(playerProvider);

                    // XP de cuenta + progreso de misiones (gane o pierda).
                    // Capturar niveles subidos para celebrar (hoy se ignoraba).
                    final levelsGained = notifier.addAccountXp(xpReward);
                    final newLevel = ref.read(playerProvider)?.accountLevel ?? 1;
                    notifier.reportBattleResult(
                      won: playerWon,
                      slotsWon: slotsWonCount,
                      wasHard: wasHard,
                      scoutsUsed: scoutsUsedCount,
                    );

                    if (playerWon && loadedPlayer != null) {
                      if (isTutorial && !loadedPlayer.tutorialBattleComplete) {
                        final playerHero = ref.read(selectedHeroForBattleProvider);
                        final rivalHeroId = playerHero != null
                            ? HeroesData.tutorialBotFor(playerHero.faction.name).id
                            : '';
                        notifier.completeTutorialBattle(
                          medals: medals,
                          coins: coins,
                          rivalHeroId: rivalHeroId,
                        );
                        notifier.addTokens(tokens);
                      } else if (!isTutorial) {
                        // Marca la primera victoria del día (el monto x2 ya está en `coins`)
                        if (isFirstWinOfDay) notifier.consumeFirstWinOfDay();
                        notifier.addMedals(medals);
                        notifier.addSoftCoins(coins);
                        notifier.addTokens(tokens);
                        final config = ref.read(gameConfigProvider).value;
                        final difficulty = battle.botDifficulty ?? BotDifficulty.normal;
                        final pts = battle.gameMode == GameMode.normal
                            ? config?.pointsForSimple(difficulty) ?? 2
                            : config?.pointsFor(difficulty) ?? 3;
                        // Ascenso de rango: comparar el rango antes/después de
                        // sumar los puntos y celebrar si subió.
                        final pointsBefore = loadedPlayer.battlePoints;
                        notifier.addBattlePoints(pts);
                        final rankBefore = RankLadder.rankFor(pointsBefore);
                        final rankAfter = RankLadder.rankFor(pointsBefore + pts);
                        if (rankAfter.tier > rankBefore.tier && context.mounted) {
                          SoundService().play('level_up');
                          HapticsService().success();
                          await RankUpDialog.show(context, rankAfter);
                        }
                      }
                    }
                    // Consolación por derrota (arena; ni tutorial ni rendición)
                    if (!playerWon && !isTutorial && !surrendered) {
                      notifier.addSoftCoins(_consolationCoins(battle));
                    }
                    // Level-up de cuenta: celebrar si subiste de nivel.
                    if (levelsGained > 0 && context.mounted) {
                      SoundService().play('level_up');
                      HapticsService().success();
                      await LevelUpDialog.show(
                        context,
                        newLevel: newLevel,
                        coinsReward: levelsGained * DailyRewardsData.coinsPerLevelUp,
                      );
                    }
                    if (context.mounted) context.go('/home');
                    // Interstitial cada N batallas, después de salir
                    _maybeShowInterstitial();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Continuar →',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
          ),
        ),
      ),
        ],
      ),
    );
  }
}

/// Aparece con fade + slide-up después de [delayMs].
class _Appear extends StatefulWidget {
  final int delayMs;
  final Widget child;

  const _Appear({required this.delayMs, required this.child});

  @override
  State<_Appear> createState() => _AppearState();
}

class _AppearState extends State<_Appear> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.25),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// Confetti que cae desde arriba (victoria). ~3.5s y se detiene.
class _ConfettiOverlay extends StatefulWidget {
  const _ConfettiOverlay();

  @override
  State<_ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<_ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        painter: _ConfettiPainter(progress: _controller.value),
        size: Size.infinite,
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  const _ConfettiPainter({required this.progress});

  static const _colors = [
    Color(0xFFF5B800),
    Color(0xFFE74C3C),
    Color(0xFF27AE60),
    Color(0xFF3498DB),
    Color(0xFFB39DDB),
  ];

  @override
  void paint(Canvas canvas, Size size, ) {
    const count = 60;
    final paint = Paint();
    for (int i = 0; i < count; i++) {
      // Pseudoaleatorio determinístico por índice
      final seed = (i * 2654435761) & 0xFFFFFF;
      final rx = (seed % 1000) / 1000.0;
      final rSpeed = 0.6 + ((seed >> 6) % 1000) / 1000.0 * 0.8;
      final rDelay = ((seed >> 10) % 1000) / 1000.0 * 0.5;
      final rSize = 4.0 + ((seed >> 14) % 100) / 100.0 * 5.0;
      final color = _colors[i % _colors.length];

      final t = ((progress - rDelay) / (1 - rDelay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final x = rx * size.width +
          math.sin((t * 4 + i) * math.pi) * 20; // vaivén lateral
      final y = t * rSpeed * (size.height + 60) - 30;
      final fade = progress > 0.8 ? (1 - progress) / 0.2 : 1.0;

      paint.color = color.withValues(alpha: 0.85 * fade);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate((t * 6 + i) * 0.7);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset.zero, width: rSize, height: rSize * 0.6),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.progress != progress;
}

class _RewardRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? badge;

  const _RewardRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Color(0xFFF0F0F0), fontSize: 15),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF5B800).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF5B800).withValues(alpha: 0.6)),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  color: Color(0xFFF5B800),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  final String label;
  final String value;

  const _StatLine(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Color(0xFF8A8A9A), fontSize: 13)),
        Text(value,
            style: const TextStyle(
              color: Color(0xFFF0F0F0),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            )),
      ],
    );
  }
}
