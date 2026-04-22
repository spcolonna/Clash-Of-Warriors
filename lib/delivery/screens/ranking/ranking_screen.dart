import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/hero_avatar.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    if (player == null) return const SizedBox();

    // For now, generate some mock leaderboard entries including the player
    final entries = _buildLeaderboard(player.name, player.elo, player.wins, player.streak);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, size: 18, color: Colors.white70),
                label: const Text('Volver', style: TextStyle(color: Colors.white70)),
              ),
              const Icon(Icons.leaderboard, size: 36, color: AppColors.gold),
              const SizedBox(height: 4),
              const Text('RANKING', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.gold)),
              const SizedBox(height: 16),

              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 30, child: Text('#', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary))),
                    Expanded(child: Text('Guerrero', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary))),
                    SizedBox(width: 60, child: Text('ELO', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary))),
                    SizedBox(width: 40, child: Text('W', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary))),
                    SizedBox(width: 40, child: Text('Racha', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary))),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              Expanded(
                child: ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (_, i) {
                    final e = entries[i];
                    final isPlayer = e['name'] == player.name;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isPlayer ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: isPlayer ? Border.all(color: AppColors.primary, width: 2) : null,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: i < 3 ? AppColors.gold : Colors.white,
                              ),
                            ),
                          ),
                          Expanded(child: Text(
                            '${e['name']}',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isPlayer ? AppColors.primary : Colors.white),
                            overflow: TextOverflow.ellipsis,
                          )),
                          SizedBox(width: 60, child: Text(
                            '${e['elo']}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.accent),
                          )),
                          SizedBox(width: 40, child: Text(
                            '${e['wins']}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32)),
                          )),
                          SizedBox(width: 40, child: Text(
                            '${e['streak']}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.accent),
                          )),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _buildLeaderboard(String playerName, int playerElo, int playerWins, int playerStreak) {
    final bots = [
      {'name': 'DragonFist_99', 'elo': 1450, 'wins': 42, 'streak': 8},
      {'name': 'ShadowKick', 'elo': 1380, 'wins': 35, 'streak': 5},
      {'name': 'IronPalm_X', 'elo': 1320, 'wins': 30, 'streak': 3},
      {'name': 'TigerClaw', 'elo': 1280, 'wins': 28, 'streak': 4},
      {'name': 'StormBlock', 'elo': 1240, 'wins': 25, 'streak': 2},
      {'name': 'GrappleMaster', 'elo': 1200, 'wins': 22, 'streak': 1},
      {'name': 'FuryPunch', 'elo': 1150, 'wins': 18, 'streak': 0},
      {'name': 'SwiftStrike', 'elo': 1100, 'wins': 15, 'streak': 2},
      {'name': 'SteelGuard', 'elo': 1050, 'wins': 12, 'streak': 0},
    ];
    final all = <Map<String, dynamic>>[
      {'name': playerName, 'elo': playerElo, 'wins': playerWins, 'streak': playerStreak},
      ...bots,
    ];
    all.sort((a, b) => (b['elo'] as int).compareTo(a['elo'] as int));
    return all;
  }
}
