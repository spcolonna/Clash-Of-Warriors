// lib/domain/config/rank_ladder.dart
//
// Escalera de rangos derivada de battlePoints (acumulador de por vida del
// PlayerProfile). Función pura: el rango no se guarda, se calcula. Da una
// identidad de progresión ("soy Profesional") además del leaderboard semanal.

import 'package:flutter/material.dart';

class Rank {
  final int tier;          // 0..5
  final String name;
  final int minPoints;     // battlePoints necesarios para alcanzarlo
  final int colorHex;
  final IconData icon;

  const Rank({
    required this.tier,
    required this.name,
    required this.minPoints,
    required this.colorHex,
    required this.icon,
  });

  Color get color => Color(colorHex);
}

class RankLadder {
  // Umbrales tunables. minPoints ascendente. El primero debe ser 0.
  static const List<Rank> ranks = [
    Rank(tier: 0, name: 'Novato',            minPoints: 0,    colorHex: 0xFF9E9E9E, icon: Icons.shield_outlined),
    Rank(tier: 1, name: 'Amateur',           minPoints: 150,  colorHex: 0xFF8D6E63, icon: Icons.shield),
    Rank(tier: 2, name: 'Profesional',       minPoints: 400,  colorHex: 0xFF4FC3F7, icon: Icons.military_tech_outlined),
    Rank(tier: 3, name: 'Campeón Nacional',  minPoints: 900,  colorHex: 0xFFB39DDB, icon: Icons.military_tech),
    Rank(tier: 4, name: 'Campeón Mundial',   minPoints: 1800, colorHex: 0xFFFFD700, icon: Icons.emoji_events),
    Rank(tier: 5, name: 'Leyenda',           minPoints: 3500, colorHex: 0xFFFF7043, icon: Icons.local_fire_department),
  ];

  /// Rango actual según los battlePoints acumulados.
  static Rank rankFor(int battlePoints) {
    var current = ranks.first;
    for (final r in ranks) {
      if (battlePoints >= r.minPoints) {
        current = r;
      } else {
        break;
      }
    }
    return current;
  }

  /// Siguiente rango, o null si ya es el máximo.
  static Rank? nextRank(int battlePoints) {
    final current = rankFor(battlePoints);
    if (current.tier + 1 >= ranks.length) return null;
    return ranks[current.tier + 1];
  }

  /// Progreso [0..1] dentro del rango actual hacia el siguiente.
  /// 1.0 si ya está en el rango máximo.
  static double progress(int battlePoints) {
    final current = rankFor(battlePoints);
    final next = nextRank(battlePoints);
    if (next == null) return 1.0;
    final span = next.minPoints - current.minPoints;
    if (span <= 0) return 1.0;
    return ((battlePoints - current.minPoints) / span).clamp(0.0, 1.0);
  }
}
