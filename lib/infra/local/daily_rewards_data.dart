// lib/infra/local/daily_rewards_data.dart

enum DailyRewardType { coins, tokens, card }

/// Una recompensa del calendario de login diario.
class DailyReward {
  final int day; // 1–7
  final DailyRewardType type;
  final int amount;
  final String? cardId;

  const DailyReward({
    required this.day,
    required this.type,
    this.amount = 0,
    this.cardId,
  });
}

class DailyRewardsData {
  /// Calendario de 7 días, escalado. Reinicia tras completarse o al perder un día.
  static const List<DailyReward> calendar = [
    DailyReward(day: 1, type: DailyRewardType.coins,  amount: 50),
    DailyReward(day: 2, type: DailyRewardType.coins,  amount: 100),
    DailyReward(day: 3, type: DailyRewardType.tokens, amount: 2),
    DailyReward(day: 4, type: DailyRewardType.coins,  amount: 150),
    DailyReward(day: 5, type: DailyRewardType.coins,  amount: 200),
    DailyReward(day: 6, type: DailyRewardType.tokens, amount: 3),
    DailyReward(day: 7, type: DailyRewardType.coins,  amount: 400),
  ];

  /// Recompensa para una racha dada (1-indexada). Cicla cada 7 días.
  static DailyReward rewardForStreak(int streak) {
    if (streak < 1) return calendar.first;
    final index = (streak - 1) % calendar.length;
    return calendar[index];
  }

  // ── XP de cuenta ───────────────────────────────────────────────────────────
  // XP otorgada por batalla. Se gana siempre, incluso al perder, para que la
  // progresión nunca se sienta nula tras una derrota.
  static const int xpForWin = 30;
  static const int xpForLoss = 12;

  /// Monedas otorgadas al subir un nivel de cuenta.
  static const int coinsPerLevelUp = 50;
}
