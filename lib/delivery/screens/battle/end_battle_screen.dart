// lib/delivery/screens/battle/end_battle_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../infra/local/heroes_data.dart';
import '../../state/battle_provider.dart';
import '../../state/providers.dart';

class EndBattleScreen extends ConsumerWidget {
  const EndBattleScreen({super.key});

  static const int medalReward = 25;
  static const int coinReward = 150;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final battle = ref.watch(battleProvider);
    final playerWon = battle.playerWon ?? true;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              Text(
                playerWon ? '🏆' : '💀',
                style: GoogleFonts.notoColorEmoji(
                  textStyle: const TextStyle(fontSize: 72),
                ),
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
                  style: TextStyle(
                    color: Color(0xFF8A8A9A),
                    fontSize: 11,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                _RewardRow(
                  emoji: '🏅',
                  label: 'Medallas',
                  value: '+$medalReward',
                  color: Colors.amber,
                ),
                const SizedBox(height: 12),
                _RewardRow(
                  emoji: '🪙',
                  label: 'Monedas',
                  value: '+$coinReward',
                  color: const Color(0xFF27AE60),
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
                    _StatLine(
                      'Daño total infligido',
                      '${battle.roundHistory.fold<double>(0, (s, r) => s + r.totalPlayerDamage).round()}',
                    ),
                    const SizedBox(height: 8),
                    _StatLine(
                      'Daño total recibido',
                      '${battle.roundHistory.fold<double>(0, (s, r) => s + r.totalOpponentDamage).round()}',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    // Asegurarnos de que el player esté cargado
                    if (ref.read(playerProvider) == null) {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await ref
                            .read(playerProvider.notifier)
                            .loadPlayer(user.uid);
                      }
                    }

                    final player = ref.read(playerProvider);
                    if (playerWon && player != null) {
                      final playerHero =
                      ref.read(selectedHeroForBattleProvider);
                      final rivalHeroId = playerHero != null
                          ? HeroesData
                          .tutorialBotFor(playerHero.faction.name)
                          .id
                          : '';

                      // NO await — corre en background, estado local ya se actualiza
                      ref.read(playerProvider.notifier).completeTutorialBattle(
                        medals: medalReward,
                        coins: coinReward,
                        rivalHeroId: rivalHeroId,
                      );
                    }

                    // Navegar de inmediato
                    if (context.mounted) context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continuar →',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _RewardRow({
    required this.emoji,
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
          Text(
            emoji,
            style: GoogleFonts.notoColorEmoji(
              textStyle: const TextStyle(fontSize: 24),
            ),
          ),
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
