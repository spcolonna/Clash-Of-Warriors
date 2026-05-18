// lib/infra/local/progress_rewards_data.dart

import '../../domain/entities/battle_state.dart' show BotDifficulty;

enum ProgressRewardType { coins, tokens, card }

class ProgressReward {
  final int requiredPoints;
  final ProgressRewardType type;
  final int amount;
  final String? cardId;

  const ProgressReward({
    required this.requiredPoints,
    required this.type,
    this.amount = 0,
    this.cardId,
  });
}

class ProgressRewardsData {
  static const List<ProgressReward> rewardCycle = [
    ProgressReward(requiredPoints: 10, type: ProgressRewardType.coins,  amount: 150),
    ProgressReward(requiredPoints: 12, type: ProgressRewardType.tokens, amount: 2),
    ProgressReward(requiredPoints: 15, type: ProgressRewardType.coins,  amount: 300),
    ProgressReward(requiredPoints: 10, type: ProgressRewardType.tokens, amount: 5),
  ];

  static const Map<BotDifficulty, int> pointsPerWin = {
    BotDifficulty.easy:   3,
    BotDifficulty.normal: 5,
    BotDifficulty.hard:   8,
  };

  static ProgressReward currentReward(int claimedIndex) =>
      rewardCycle[claimedIndex % rewardCycle.length];
}
