// lib/domain/entities/game_config.dart

import 'battle_state.dart' show BotDifficulty;

class ProgressRewardConfig {
  final int requiredPoints;
  final String type; // 'coins' | 'tokens' | 'card'
  final int amount;
  final String? cardId;

  const ProgressRewardConfig({
    required this.requiredPoints,
    required this.type,
    this.amount = 0,
    this.cardId,
  });

  factory ProgressRewardConfig.fromMap(Map<String, dynamic> m) =>
      ProgressRewardConfig(
        requiredPoints: m['requiredPoints'] as int? ?? 10,
        type: m['type'] as String? ?? 'coins',
        amount: m['amount'] as int? ?? 0,
        cardId: m['cardId'] as String?,
      );

  Map<String, dynamic> toMap() => {
    'requiredPoints': requiredPoints,
    'type': type,
    'amount': amount,
    if (cardId != null) 'cardId': cardId,
  };
}

/// Configuración del juego cargada desde Firestore al iniciar la app.
/// Reemplaza los valores hardcodeados en los archivos *_data.dart.
class GameConfig {
  /// Cartas habilitadas (isEnabled == true) con todos sus campos.
  final List<Map<String, dynamic>> cards;

  /// Todos los héroes con sus stats actuales desde Firestore.
  final List<Map<String, dynamic>> heroes;

  final List<ProgressRewardConfig> progressRewards;
  final Map<BotDifficulty, int> pointsPerWin;

  const GameConfig({
    required this.cards,
    required this.heroes,
    required this.progressRewards,
    required this.pointsPerWin,
  });

  bool isCardEnabled(String id) => cards.any((c) => c['id'] == id);

  ProgressRewardConfig rewardAt(int claimedIndex) =>
      progressRewards[claimedIndex % progressRewards.length];

  int pointsFor(BotDifficulty difficulty) => pointsPerWin[difficulty] ?? 3;

  static const List<ProgressRewardConfig> _defaultRewards = [
    ProgressRewardConfig(requiredPoints: 10, type: 'coins',  amount: 150),
    ProgressRewardConfig(requiredPoints: 12, type: 'tokens', amount: 2),
    ProgressRewardConfig(requiredPoints: 15, type: 'coins',  amount: 300),
    ProgressRewardConfig(requiredPoints: 10, type: 'tokens', amount: 5),
  ];

  static const Map<BotDifficulty, int> _defaultPoints = {
    BotDifficulty.easy:   3,
    BotDifficulty.normal: 5,
    BotDifficulty.hard:   8,
  };

  static GameConfig get defaults => const GameConfig(
    cards: [],
    heroes: [],
    progressRewards: _defaultRewards,
    pointsPerWin: _defaultPoints,
  );
}
