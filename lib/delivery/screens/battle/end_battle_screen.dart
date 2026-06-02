// lib/delivery/screens/battle/end_battle_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../infra/local/heroes_data.dart';
import '../../../infra/local/daily_rewards_data.dart';
import '../../state/battle_provider.dart';
import '../../state/providers.dart';
import '../../state/story_provider.dart';

class EndBattleScreen extends ConsumerWidget {
  const EndBattleScreen({super.key});

  static const int tutorialMedalReward = 25;
  static const int tutorialCoinReward = 150;
  static const int arenaMedalReward = 15;
  static const int arenaCoinReward = 100;
  static const int tutorialTokenReward = 5;
  static const int arenaTokenRewardEasy = 1;
  static const int arenaTokenRewardNormal = 2;
  static const int arenaTokenRewardHard = 3;

  int _tokenReward(bool isTutorial, BotDifficulty? difficulty) {
    if (isTutorial) return tutorialTokenReward;
    return switch (difficulty) {
      BotDifficulty.easy   => arenaTokenRewardEasy,
      BotDifficulty.normal => arenaTokenRewardNormal,
      BotDifficulty.hard   => arenaTokenRewardHard,
      null                 => arenaTokenRewardNormal,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final battle = ref.watch(battleProvider);
    final playerWon = battle.playerWon ?? true;
    final isTutorial = battle.isTutorial;
    final isStoryBattle = battle.isStoryBattle;

    final medals = isTutorial ? tutorialMedalReward : arenaMedalReward;
    final baseCoins = isTutorial ? tutorialCoinReward : arenaCoinReward;
    final tokens = _tokenReward(isTutorial, battle.botDifficulty);

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              children: [
              const SizedBox(height: 32),
              Icon(
                playerWon ? Icons.emoji_events : Icons.sentiment_very_dissatisfied,
                size: 72,
                color: playerWon ? Colors.amber : Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                playerWon ? '¡Victoria!' : 'Derrota',
                style: TextStyle(
                  color: playerWon ? Colors.amber : Colors.red,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                playerWon
                    ? 'Demostraste tu valía en la Arena'
                    : 'La batalla continúa. Volvé más fuerte.',
                style: const TextStyle(color: Color(0xFF8A8A9A), fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              const Text(
                'RECOMPENSAS',
                style: TextStyle(color: Color(0xFF8A8A9A), fontSize: 11, letterSpacing: 2),
              ),
              const SizedBox(height: 16),
              if (playerWon) ...[
                _RewardRow(icon: Icons.military_tech,   label: 'Medallas', value: '+$medals', color: Colors.amber),
                const SizedBox(height: 12),
                _RewardRow(
                  icon: Icons.monetization_on,
                  label: 'Monedas',
                  value: '+$coins',
                  color: const Color(0xFF27AE60),
                  badge: isFirstWinOfDay ? '1ª del día · x2' : null,
                ),
                const SizedBox(height: 12),
                _RewardRow(icon: Icons.diamond,         label: 'Tokens',   value: '+$tokens', color: const Color(0xFFB39DDB)),
                const SizedBox(height: 12),
              ],
              // XP siempre se otorga, gane o pierda — la progresión nunca es nula.
              _RewardRow(
                icon: Icons.trending_up,
                label: 'XP',
                value: '+$xpReward',
                color: const Color(0xFF3498DB),
              ),
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
                    final botHero = HeroesData.tutorialBotFor(playerHero.faction.name);
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

                    // XP de cuenta + progreso de misiones (gane o pierda)
                    notifier.addAccountXp(xpReward);
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
                        notifier.addBattlePoints(pts);
                      }
                    }
                    if (context.mounted) context.go('/home');
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
    );
  }
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
