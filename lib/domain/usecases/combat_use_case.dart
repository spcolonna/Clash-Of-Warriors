// import '../entities/technique.dart';
// import '../entities/hero.dart';
// import '../config/game_config.dart';
// import 'dart:math';
//
// /// ═══ LÓGICA DE COMBATE ═══
// /// Portada desde el prototipo JSX. Toda la resolución pasa por acá.
//
// class CombatUseCase {
//   final Random _rng = Random();
//
//   // ── 1v1 ──────────────────────────────────────────────
//
//   /// Resolver un round 1v1
//   ClashResult resolve1v1({
//     required Technique playerTech,
//     required Technique botTech,
//     required HeroStats playerStats,
//     required HeroStats botStats,
//   }) {
//     final result = resolveTechniques(playerTech, botTech);
//     int damage = 0;
//
//     switch (result) {
//       case CombatResult.attackerWins:
//         damage = playerStats.get(playerTech);
//         break;
//       case CombatResult.defenderWins:
//         damage = botStats.get(botTech);
//         break;
//       case CombatResult.draw:
//         final pStat = playerStats.get(playerTech);
//         final bStat = botStats.get(botTech);
//         if (pStat > bStat) damage = GameConfig.drawDamage;
//         else if (bStat > pStat) damage = GameConfig.drawDamage;
//         // Si son iguales, damage = 0
//         break;
//     }
//
//     final String winner;
//     if (result == CombatResult.attackerWins) {
//       winner = 'player';
//     } else if (result == CombatResult.defenderWins) {
//       winner = 'bot';
//     } else {
//       final pStat = playerStats.get(playerTech);
//       final bStat = botStats.get(botTech);
//       winner = pStat > bStat ? 'player' : bStat > pStat ? 'bot' : 'draw';
//     }
//
//     return ClashResult(
//       side: 'player',
//       fromIdx: 0,
//       toIdx: 0,
//       attackTech: playerTech,
//       defenseTech: botTech,
//       result: result,
//       damage: damage,
//     );
//   }
//
//   // ── BOT AI ───────────────────────────────────────────
//
//   /// Elegir técnica del bot según dificultad
//   Technique botPickTechnique({
//     required Difficulty difficulty,
//     required HeroStats botStats,
//     Technique? playerLastTech,
//   }) {
//     switch (difficulty) {
//       case Difficulty.easy:
//         return Technique.values[_rng.nextInt(5)];
//
//       case Difficulty.normal:
//         // Elige la técnica con mejor stat
//         final techs = Technique.values.toList()
//           ..sort((a, b) => botStats.get(b).compareTo(botStats.get(a)));
//         // Top 2 con algo de variación
//         return techs[_rng.nextInt(2)];
//
//       case Difficulty.hard:
//         // Intenta leer la última jugada del player
//         if (playerLastTech != null &&
//             _rng.nextDouble() < GameConfig.botHardReadChance) {
//           // Elige algo que venza lo que el player usó
//           final counters = TechniqueRegistry.all
//               .where((t) => t.beats.contains(playerLastTech))
//               .toList();
//           if (counters.isNotEmpty) {
//             return counters[_rng.nextInt(counters.length)].id;
//           }
//         }
//         // Fallback a normal
//         final techs = Technique.values.toList()
//           ..sort((a, b) => botStats.get(b).compareTo(botStats.get(a)));
//         return techs[_rng.nextInt(2)];
//     }
//   }
//
//   // ── 3v3 ──────────────────────────────────────────────
//
//   /// Resolver ronda 3v3 completa (simultánea)
//   /// Retorna lista de ClashResults + daño acumulado por equipo
//   B3RoundResult resolve3v3({
//     required List<BattleHero> pTeam,
//     required List<BattleHero> bTeam,
//     required Map<int, TechTarget> playerPicks,
//     required Map<int, TechTarget> botPicks,
//     required HeroStats Function(String heroId) getPlayerStats,
//     required HeroStats Function(String heroId) getBotStats,
//   }) {
//     final results = <ClashResult>[];
//     final dmgToBot = <int, int>{};
//     final dmgToPlayer = <int, int>{};
//
//     // 1) Player attacks
//     for (int pi = 0; pi < pTeam.length; pi++) {
//       if (!pTeam[pi].isAlive) continue;
//       final pick = playerPicks[pi];
//       if (pick == null) continue;
//       final target = bTeam[pick.targetIdx];
//       if (!target.isAlive) continue;
//       final botDef = botPicks[pick.targetIdx]?.technique;
//       if (botDef == null) continue;
//
//       final res = resolveTechniques(pick.technique, botDef);
//       final pS = getPlayerStats(pTeam[pi].heroId);
//       final bS = getBotStats(target.heroId);
//       int dmg = 0;
//       if (res == CombatResult.attackerWins) {
//         dmg = pS.get(pick.technique);
//       } else if (res == CombatResult.draw) {
//         dmg = pS.get(pick.technique) > bS.get(botDef)
//             ? GameConfig.drawDamage
//             : 0;
//       }
//       dmgToBot[pick.targetIdx] = (dmgToBot[pick.targetIdx] ?? 0) + dmg;
//       results.add(ClashResult(
//         side: 'player', fromIdx: pi, toIdx: pick.targetIdx,
//         attackTech: pick.technique, defenseTech: botDef,
//         result: res, damage: dmg,
//       ));
//     }
//
//     // 2) Bot attacks
//     for (int bi = 0; bi < bTeam.length; bi++) {
//       if (!bTeam[bi].isAlive) continue;
//       final pick = botPicks[bi];
//       if (pick == null) continue;
//       final target = pTeam[pick.targetIdx];
//       if (!target.isAlive) continue;
//       final pDef = playerPicks[pick.targetIdx]?.technique;
//       if (pDef == null) continue;
//
//       final res = resolveTechniques(pick.technique, pDef);
//       final bS = getBotStats(bTeam[bi].heroId);
//       final pS = getPlayerStats(target.heroId);
//       int dmg = 0;
//       if (res == CombatResult.attackerWins) {
//         dmg = bS.get(pick.technique);
//       } else if (res == CombatResult.draw) {
//         dmg = bS.get(pick.technique) > pS.get(pDef)
//             ? GameConfig.drawDamage
//             : 0;
//       }
//       dmgToPlayer[pick.targetIdx] = (dmgToPlayer[pick.targetIdx] ?? 0) + dmg;
//       results.add(ClashResult(
//         side: 'bot', fromIdx: bi, toIdx: pick.targetIdx,
//         attackTech: pick.technique, defenseTech: pDef,
//         result: res, damage: dmg,
//       ));
//     }
//
//     // 3) Apply damage simultaneously
//     dmgToBot.forEach((idx, dmg) {
//       bTeam[idx].hp = (bTeam[idx].hp - dmg).clamp(0, GameConfig.maxHP);
//     });
//     dmgToPlayer.forEach((idx, dmg) {
//       pTeam[idx].hp = (pTeam[idx].hp - dmg).clamp(0, GameConfig.maxHP);
//     });
//
//     final pAlive = pTeam.where((h) => h.isAlive).length;
//     final bAlive = bTeam.where((h) => h.isAlive).length;
//
//     return B3RoundResult(
//       clashes: results,
//       isFinished: pAlive == 0 || bAlive == 0,
//       winner: pAlive == 0 && bAlive == 0
//           ? 'draw'
//           : bAlive == 0
//               ? 'player'
//               : pAlive == 0
//                   ? 'bot'
//                   : null,
//     );
//   }
//
//   /// Bot pick para 3v3
//   Map<int, TechTarget> botPick3v3({
//     required Difficulty difficulty,
//     required List<BattleHero> bTeam,
//     required List<BattleHero> pTeam,
//     required HeroStats Function(String heroId) getBotStats,
//   }) {
//     final picks = <int, TechTarget>{};
//     final alivePlayers = pTeam
//         .asMap()
//         .entries
//         .where((e) => e.value.isAlive)
//         .map((e) => e.key)
//         .toList();
//
//     if (alivePlayers.isEmpty) return picks;
//
//     for (int bi = 0; bi < bTeam.length; bi++) {
//       if (!bTeam[bi].isAlive) continue;
//       final stats = getBotStats(bTeam[bi].heroId);
//
//       final tech = botPickTechnique(
//         difficulty: difficulty,
//         botStats: stats,
//       );
//       final target = alivePlayers[_rng.nextInt(alivePlayers.length)];
//
//       picks[bi] = TechTarget(technique: tech, targetIdx: target);
//     }
//     return picks;
//   }
//
//   // ── ELO ──────────────────────────────────────────────
//
//   int calculateEloDelta(String result, Difficulty difficulty) {
//     final multiplier = switch (difficulty) {
//       Difficulty.easy => GameConfig.eloMultiplierEasy,
//       Difficulty.normal => GameConfig.eloMultiplierNormal,
//       Difficulty.hard => GameConfig.eloMultiplierHard,
//     };
//
//     return switch (result) {
//       'win' => (GameConfig.eloWinBase * multiplier).round(),
//       'loss' => -(GameConfig.eloLossBase * multiplier).round(),
//       'draw' => GameConfig.eloDrawBonus,
//       _ => 0,
//     };
//   }
//
//   /// Token reward según resultado y dificultad
//   int calculateTokenReward(String result, Difficulty difficulty) {
//     if (result != 'win') return GameConfig.tokenRewardLoss;
//     return switch (difficulty) {
//       Difficulty.easy => GameConfig.tokenRewardEasy,
//       Difficulty.normal => GameConfig.tokenRewardNormal,
//       Difficulty.hard => GameConfig.tokenRewardHard,
//     };
//   }
// }
//
// // ── Models auxiliares ──
//
// class TechTarget {
//   final Technique technique;
//   final int targetIdx;
//   const TechTarget({required this.technique, required this.targetIdx});
// }
//
// class B3RoundResult {
//   final List<ClashResult> clashes;
//   final bool isFinished;
//   final String? winner; // null si sigue, 'player'|'bot'|'draw' si terminó
//   const B3RoundResult({
//     required this.clashes,
//     required this.isFinished,
//     this.winner,
//   });
// }
