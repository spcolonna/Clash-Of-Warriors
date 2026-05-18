// lib/delivery/screens/battle/end_battle_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../infra/local/heroes_data.dart';
import '../../state/battle_provider.dart';
import '../../state/providers.dart';

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

    final medals = isTutorial ? tutorialMedalReward : arenaMedalReward;
    final coins  = isTutorial ? tutorialCoinReward  : arenaCoinReward;
    final tokens = _tokenReward(isTutorial, battle.botDifficulty);

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
              if (playerWon) ...[
                const Text(
                  'RECOMPENSAS',
                  style: TextStyle(color: Color(0xFF8A8A9A), fontSize: 11, letterSpacing: 2),
                ),
                const SizedBox(height: 16),
                _RewardRow(icon: Icons.military_tech,   label: 'Medallas', value: '+$medals', color: Colors.amber),
                const SizedBox(height: 12),
                _RewardRow(icon: Icons.monetization_on, label: 'Monedas',  value: '+$coins',  color: const Color(0xFF27AE60)),
                const SizedBox(height: 12),
                _RewardRow(icon: Icons.diamond,         label: 'Tokens',   value: '+$tokens', color: const Color(0xFFB39DDB)),
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
                  child: const Text('⚔️  Revancha',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),

              // Botón Continuar
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (ref.read(playerProvider) == null) {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await ref.read(playerProvider.notifier).loadPlayer(user.uid);
                      }
                    }
                    final player = ref.read(playerProvider);
                    if (playerWon && player != null) {
                      if (isTutorial && !player.tutorialBattleComplete) {
                        // Solo la primera vez
                        final playerHero = ref.read(selectedHeroForBattleProvider);
                        final rivalHeroId = playerHero != null
                            ? HeroesData.tutorialBotFor(playerHero.faction.name).id
                            : '';
                        ref.read(playerProvider.notifier).completeTutorialBattle(
                          medals: medals,
                          coins: coins,
                          rivalHeroId: rivalHeroId,
                        );
                        ref.read(playerProvider.notifier).addTokens(tokens);
                      } else if (!isTutorial) {
                        // Arena: sumar recompensas sin completar tutorial
                        ref.read(playerProvider.notifier).addMedals(medals);
                        ref.read(playerProvider.notifier).addSoftCoins(coins);
                        ref.read(playerProvider.notifier).addTokens(tokens);
                        // Puntos de progreso por victoria en arena
                        final config = ref.read(gameConfigProvider).value;
                        final difficulty = battle.botDifficulty ?? BotDifficulty.normal;
                        final pts = config?.pointsFor(difficulty) ?? 3;
                        ref.read(playerProvider.notifier).addBattlePoints(pts);
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

  const _RewardRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Color(0xFFF0F0F0), fontSize: 15),
          ),
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
