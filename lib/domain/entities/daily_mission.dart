// lib/domain/entities/daily_mission.dart

enum DailyMissionType {
  winBattles,   // ganar N batallas
  playBattles,  // jugar N batallas (gane o pierda)
  winSlots,     // ganar N slots acumulados
  useScout,     // usar N scouts
  playHard,     // jugar N batallas en dificultad Difícil
}

DailyMissionType _parseType(String s) => DailyMissionType.values.firstWhere(
      (t) => t.name == s,
      orElse: () => DailyMissionType.playBattles,
    );

/// Una misión diaria con su progreso. Inmutable.
class DailyMission {
  final String id;
  final DailyMissionType type;
  final int target;
  final int progress;
  final bool claimed;
  final String rewardType; // 'coins' | 'tokens'
  final int rewardAmount;

  const DailyMission({
    required this.id,
    required this.type,
    required this.target,
    this.progress = 0,
    this.claimed = false,
    required this.rewardType,
    required this.rewardAmount,
  });

  bool get isComplete => progress >= target;

  DailyMission copyWith({int? progress, bool? claimed}) => DailyMission(
        id: id,
        type: type,
        target: target,
        progress: progress ?? this.progress,
        claimed: claimed ?? this.claimed,
        rewardType: rewardType,
        rewardAmount: rewardAmount,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'target': target,
        'progress': progress,
        'claimed': claimed,
        'rewardType': rewardType,
        'rewardAmount': rewardAmount,
      };

  factory DailyMission.fromMap(Map<String, dynamic> m) => DailyMission(
        id: m['id'] as String? ?? '',
        type: _parseType(m['type'] as String? ?? 'playBattles'),
        target: m['target'] as int? ?? 1,
        progress: m['progress'] as int? ?? 0,
        claimed: m['claimed'] as bool? ?? false,
        rewardType: m['rewardType'] as String? ?? 'coins',
        rewardAmount: m['rewardAmount'] as int? ?? 50,
      );
}
