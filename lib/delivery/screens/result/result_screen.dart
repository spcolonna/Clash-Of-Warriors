import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/hero.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/hero_avatar.dart';

// class ResultScreen extends ConsumerWidget {
  // final String winner; // 'player' | 'bot' | 'draw'
  // final int playerHP;
  // final int botHP;
  // final GameHero playerHero;
  // final GameHero botHero;
  // final String botName;
  // final List<RoundLog> rounds;
  // final VoidCallback onRematch;
  // final VoidCallback onChangeHero;
  // final VoidCallback onHome;
  //
  // const ResultScreen({
  //   super.key,
  //   required this.winner,
  //   required this.playerHP,
  //   required this.botHP,
  //   required this.playerHero,
  //   required this.botHero,
  //   required this.botName,
  //   required this.rounds,
  //   required this.onRematch,
  //   required this.onChangeHero,
  //   required this.onHome,
  // });
  //
  // @override
  // Widget build(BuildContext context, WidgetRef ref) {
  //   final player = ref.watch(playerProvider);
  //   final diff = ref.watch(difficultyProvider);
  //   final won = winner == 'player';
  //   final draw = winner == 'draw';
  //   final isPro = player?.isPro ?? false;
  //   final reward = won ? diff.tokenReward : 2;
  //
  //   return Scaffold(
  //     body: SafeArea(
  //       child: SingleChildScrollView(
  //         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
  //         child: Column(
  //           children: [
  //             // Result icon
  //             Icon(
  //               won ? Icons.emoji_events : draw ? Icons.handshake : Icons.sentiment_very_dissatisfied,
  //               size: 56,
  //               color: won ? AppColors.gold : draw ? AppColors.accent : Colors.grey,
  //             ),
  //             const SizedBox(height: 8),
  //             Text(
  //               won ? '¡VICTORIA!' : draw ? 'EMPATE' : 'DERROTA',
  //               style: TextStyle(
  //                 fontSize: 26,
  //                 fontWeight: FontWeight.w900,
  //                 color: won ? AppColors.primary : draw ? AppColors.accent : Colors.grey,
  //               ),
  //             ),
  //             const SizedBox(height: 4),
  //             Text(
  //               '${rounds.length} rounds · ${diff.icon} ${diff.label}',
  //               style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
  //             ),
  //
  //             // Token reward (PRO only)
  //             if (isPro) ...[
  //               const SizedBox(height: 10),
  //               Container(
  //                 padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
  //                 decoration: BoxDecoration(
  //                   color: const Color(0xFFFFF9C4),
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //                 child: Row(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Text('+$reward', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.accent)),
  //                     const SizedBox(width: 4),
  //                     const Icon(Icons.monetization_on, size: 16, color: AppColors.accent),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //             const SizedBox(height: 16),
  //
  //             // Player vs Bot HP
  //             Container(
  //               padding: const EdgeInsets.all(14),
  //               decoration: BoxDecoration(
  //                 color: AppColors.surface,
  //                 borderRadius: BorderRadius.circular(14),
  //               ),
  //               child: Column(
  //                 children: [
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                     children: [
  //                       _Combatant(
  //                         heroId: playerHero.id,
  //                         name: player?.name ?? 'Tú',
  //                         hp: playerHP,
  //                         color: AppColors.primary,
  //                       ),
  //                       _Combatant(
  //                         heroId: botHero.id,
  //                         name: botName,
  //                         hp: botHP,
  //                         color: AppColors.secondary,
  //                       ),
  //                     ],
  //                   ),
  //                   if (rounds.isNotEmpty) ...[
  //                     const SizedBox(height: 10),
  //                     const Divider(color: Colors.white12),
  //                     SizedBox(
  //                       height: 90,
  //                       child: ListView.builder(
  //                         itemCount: rounds.length,
  //                         itemBuilder: (_, i) {
  //                           final r = rounds[i];
  //                           return Padding(
  //                             padding: const EdgeInsets.symmetric(vertical: 2),
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 Text(r.playerTech.icon, style: const TextStyle(fontSize: 14)),
  //                                 const SizedBox(width: 8),
  //                                 Container(
  //                                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  //                                   decoration: BoxDecoration(
  //                                     color: r.roundWinner == 'player'
  //                                         ? const Color(0xFF2E7D32)
  //                                         : r.roundWinner == 'bot'
  //                                             ? AppColors.primary
  //                                             : const Color(0xFFF9A825),
  //                                     borderRadius: BorderRadius.circular(8),
  //                                   ),
  //                                   child: Text(
  //                                     r.roundWinner == 'player' ? 'WIN' : r.roundWinner == 'bot' ? 'LOSS' : '=',
  //                                     style: TextStyle(
  //                                       fontSize: 11,
  //                                       fontWeight: FontWeight.w800,
  //                                       color: r.roundWinner == 'draw' ? Colors.black87 : Colors.white,
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 const SizedBox(width: 8),
  //                                 Text(r.botTech.icon, style: const TextStyle(fontSize: 14)),
  //                               ],
  //                             ),
  //                           );
  //                         },
  //                       ),
  //                     ),
  //                   ],
  //                 ],
  //               ),
  //             ),
  //
  //             // ELO / Stats
  //             if (player != null && player.totalBattles > 0) ...[
  //               const SizedBox(height: 12),
  //               Container(
  //                 padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  //                 decoration: BoxDecoration(
  //                   color: AppColors.surface,
  //                   borderRadius: BorderRadius.circular(14),
  //                 ),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                   children: [
  //                     _MiniStat('ELO', '${player.elo}', AppColors.accent),
  //                     _MiniStat('Victorias', '${player.wins}', const Color(0xFF2E7D32)),
  //                     _MiniStat('Racha', '${player.streak}', AppColors.accent, suffix: player.streak > 0 ? ' 🔥' : ''),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //             const SizedBox(height: 24),
  //
  //             // Action buttons
  //             SizedBox(
  //               width: double.infinity,
  //               child: ElevatedButton.icon(
  //                 onPressed: onRematch,
  //                 icon: const Icon(Icons.flash_on, size: 20),
  //                 label: const Text('REVANCHA', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: AppColors.primary,
  //                   padding: const EdgeInsets.symmetric(vertical: 16),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 10),
  //             SizedBox(
  //               width: double.infinity,
  //               child: OutlinedButton.icon(
  //                 onPressed: onChangeHero,
  //                 icon: const Icon(Icons.swap_horiz, size: 18, color: Colors.white70),
  //                 label: const Text('CAMBIAR GUERRERO', style: TextStyle(fontSize: 14)),
  //               ),
  //             ),
  //             const SizedBox(height: 10),
  //             SizedBox(
  //               width: double.infinity,
  //               child: OutlinedButton(
  //                 onPressed: onHome,
  //                 child: const Text('MENÚ PRINCIPAL', style: TextStyle(fontSize: 14)),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
// }

class _Combatant extends StatelessWidget {
  final String heroId;
  final String name;
  final int hp;
  final Color color;
  const _Combatant({required this.heroId, required this.name, required this.hp, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HeroAvatar(heroId: heroId, size: 44),
        const SizedBox(height: 2),
        Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        Text('$hp HP', style: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w900,
          color: hp > 0 ? const Color(0xFF2E7D32) : AppColors.primary,
        )),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String suffix;
  const _MiniStat(this.label, this.value, this.color, {this.suffix = ''});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value$suffix', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: color)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

/// Log entry for a single round
// class RoundLog {
//   final Technique playerTech;
//   final Technique botTech;
//   final String roundWinner; // 'player' | 'bot' | 'draw'
//   final int damage;
//   const RoundLog({required this.playerTech, required this.botTech, required this.roundWinner, required this.damage});
// }
