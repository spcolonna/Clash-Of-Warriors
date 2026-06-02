// lib/infra/local/daily_missions_data.dart

import 'dart:math';
import '../../domain/entities/daily_mission.dart';

/// Plantilla de una misión posible (sin progreso). El pool del que se
/// eligen las 3 misiones diarias.
class _MissionTemplate {
  final String id;
  final DailyMissionType type;
  final int target;
  final String rewardType;
  final int rewardAmount;

  const _MissionTemplate({
    required this.id,
    required this.type,
    required this.target,
    required this.rewardType,
    required this.rewardAmount,
  });

  DailyMission toMission() => DailyMission(
        id: id,
        type: type,
        target: target,
        rewardType: rewardType,
        rewardAmount: rewardAmount,
      );
}

class DailyMissionsData {
  static const List<_MissionTemplate> _pool = [
    _MissionTemplate(id: 'win_2',   type: DailyMissionType.winBattles,  target: 2, rewardType: 'coins',  rewardAmount: 100),
    _MissionTemplate(id: 'win_4',   type: DailyMissionType.winBattles,  target: 4, rewardType: 'coins',  rewardAmount: 200),
    _MissionTemplate(id: 'play_3',  type: DailyMissionType.playBattles, target: 3, rewardType: 'coins',  rewardAmount: 80),
    _MissionTemplate(id: 'play_5',  type: DailyMissionType.playBattles, target: 5, rewardType: 'coins',  rewardAmount: 150),
    _MissionTemplate(id: 'slots_6', type: DailyMissionType.winSlots,    target: 6, rewardType: 'coins',  rewardAmount: 120),
    _MissionTemplate(id: 'slots_10',type: DailyMissionType.winSlots,    target: 10,rewardType: 'tokens', rewardAmount: 2),
    _MissionTemplate(id: 'scout_2', type: DailyMissionType.useScout,    target: 2, rewardType: 'coins',  rewardAmount: 80),
    _MissionTemplate(id: 'hard_1',  type: DailyMissionType.playHard,    target: 1, rewardType: 'tokens', rewardAmount: 2),
    _MissionTemplate(id: 'hard_2',  type: DailyMissionType.playHard,    target: 2, rewardType: 'tokens', rewardAmount: 3),
  ];

  /// Genera 3 misiones diarias distintas (por tipo, en lo posible).
  static List<DailyMission> generateDaily({Random? random}) {
    final rng = random ?? Random();
    final shuffled = List<_MissionTemplate>.from(_pool)..shuffle(rng);

    final picked = <_MissionTemplate>[];
    final usedTypes = <DailyMissionType>{};
    // Primero, una por tipo distinto
    for (final t in shuffled) {
      if (picked.length >= 3) break;
      if (usedTypes.add(t.type)) picked.add(t);
    }
    // Completar si faltan (pools chicos)
    for (final t in shuffled) {
      if (picked.length >= 3) break;
      if (!picked.contains(t)) picked.add(t);
    }

    return picked.take(3).map((t) => t.toMission()).toList();
  }
}
