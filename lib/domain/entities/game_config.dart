// lib/domain/entities/game_config.dart

import 'battle_state.dart' show BotDifficulty;

class GameFeatures {
  final bool simpleModeEnabled;

  /// Tienda premium (packs USD): oculta por defecto hasta tener IAP real.
  /// Se habilita desde el admin en gameConfig/settings → features.
  final bool premiumShopEnabled;

  const GameFeatures({
    this.simpleModeEnabled = false,
    this.premiumShopEnabled = false,
  });

  factory GameFeatures.fromMap(Map<String, dynamic> m) => GameFeatures(
        simpleModeEnabled: m['simpleModeEnabled'] as bool? ?? false,
        premiumShopEnabled: m['premiumShopEnabled'] as bool? ?? false,
      );
}

/// Recompensas de batalla, ajustables desde el admin (gameConfig/settings →
/// battleRewards). Ancla de valor de la economía gratuita:
///   1 anuncio (~30s, cooldown 10 min) = 20 tokens = 100 monedas
///   (conversión base 100 tokens → 500 coins)
///   Victoria arena ≈ 1 anuncio · carta common ≈ 1.5-2.5 · rare ≈ 4 ·
///   epic ≈ 7.5 · legendary ≈ 12 · héroe starter ≈ 5 anuncios.
class BattleRewardsConfig {
  final int tutorialMedals;
  final int tutorialCoins;
  final int tutorialTokens;
  final int arenaMedals;
  final int arenaCoins;
  final int arenaTokensEasy;
  final int arenaTokensNormal;
  final int arenaTokensHard;

  const BattleRewardsConfig({
    this.tutorialMedals = 25,
    this.tutorialCoins = 150,
    this.tutorialTokens = 5,
    this.arenaMedals = 15,
    this.arenaCoins = 100,
    this.arenaTokensEasy = 1,
    this.arenaTokensNormal = 2,
    this.arenaTokensHard = 3,
  });

  factory BattleRewardsConfig.fromMap(Map<String, dynamic> m) =>
      BattleRewardsConfig(
        tutorialMedals: m['tutorialMedals'] as int? ?? 25,
        tutorialCoins: m['tutorialCoins'] as int? ?? 150,
        tutorialTokens: m['tutorialTokens'] as int? ?? 5,
        arenaMedals: m['arenaMedals'] as int? ?? 15,
        arenaCoins: m['arenaCoins'] as int? ?? 100,
        arenaTokensEasy: m['arenaTokensEasy'] as int? ?? 1,
        arenaTokensNormal: m['arenaTokensNormal'] as int? ?? 2,
        arenaTokensHard: m['arenaTokensHard'] as int? ?? 3,
      );

  int medalsFor(bool isTutorial) => isTutorial ? tutorialMedals : arenaMedals;
  int coinsFor(bool isTutorial) => isTutorial ? tutorialCoins : arenaCoins;

  int tokensFor(bool isTutorial, BotDifficulty? difficulty) {
    if (isTutorial) return tutorialTokens;
    return switch (difficulty) {
      BotDifficulty.easy => arenaTokensEasy,
      BotDifficulty.normal => arenaTokensNormal,
      BotDifficulty.hard => arenaTokensHard,
      null => arenaTokensNormal,
    };
  }
}

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

  /// Arcos de historia cargados desde Firestore (colección storyArcs).
  final List<Map<String, dynamic>> storyArcs;

  final List<ProgressRewardConfig> progressRewards;
  final Map<BotDifficulty, int> pointsPerWin;
  final Map<BotDifficulty, int> pointsPerWinSimple;
  final GameFeatures features;
  final BattleRewardsConfig battleRewards;

  const GameConfig({
    required this.cards,
    required this.heroes,
    this.storyArcs = const [],
    required this.progressRewards,
    required this.pointsPerWin,
    this.pointsPerWinSimple = _defaultPointsSimple,
    this.features = const GameFeatures(),
    this.battleRewards = const BattleRewardsConfig(),
  });

  bool isCardEnabled(String id) => cards.any((c) => c['id'] == id);

  ProgressRewardConfig rewardAt(int claimedIndex) =>
      progressRewards[claimedIndex % progressRewards.length];

  int pointsFor(BotDifficulty difficulty) => pointsPerWin[difficulty] ?? 3;
  int pointsForSimple(BotDifficulty difficulty) => pointsPerWinSimple[difficulty] ?? 2;

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

  static const Map<BotDifficulty, int> _defaultPointsSimple = {
    BotDifficulty.easy:   2,
    BotDifficulty.normal: 3,
    BotDifficulty.hard:   5,
  };

  static GameConfig get defaults => const GameConfig(
    cards: [],
    heroes: [],
    storyArcs: [],
    progressRewards: _defaultRewards,
    pointsPerWin: _defaultPoints,
  );
}
