// lib/domain/entities/player_profile.dart

import 'daily_mission.dart';

class PlayerProfile {
  final String uid;
  final bool isOnboardingComplete;
  final String? selectedFactionId;
  final String? activeHeroId;
  final int softCoins;
  final int medals;
  final int tokens;
  final List<String> unlockedHeroIds;
  final List<OwnedCard> ownedCards;

  // Mazo activo del jugador — ids con repeticiones hasta llegar a 20
  final List<String> deckCardIds;

  // Progreso del tutorial
  final bool tutorialBattleComplete;
  final bool starterCardPurchased;
  final bool starterCardAddedToDeck;

  // Ciclo de progreso por victorias
  final int battlePoints;
  final int lastClaimedCycleIndex;

  // Modo historia
  // Key: "{heroId}_{rarity}" (ej: "puo_liu_common"), Value: índice del último stage completado (0-9, -1 = no iniciado)
  final Map<String, int> storyProgress;
  // Set de arcos completados ("{heroId}_{rarity}")
  final Set<String> completedStoryArcs;
  // Logros desbloqueados (ej: "dragon_path_puo_liu")
  final List<String> achievements;

  // ── Retención: login diario + XP de cuenta ─────────────────────────────────
  // Fecha del último login contabilizado (formato 'yyyy-MM-dd'). null = nunca.
  final String? lastLoginDate;
  // Racha de días consecutivos de login (1 = primer día).
  final int loginStreak;
  // Fecha de la última "primera victoria del día" cobrada ('yyyy-MM-dd').
  final String? lastDailyWinDate;
  // XP de cuenta acumulada (sube con toda batalla, gane o pierda).
  final int accountXp;

  // Misiones diarias activas + la fecha en que se generaron ('yyyy-MM-dd').
  final List<DailyMission> dailyMissions;
  final String? missionsDate;

  // Hitos del "camino del nuevo jugador" ya cobrados (por id).
  final List<String> claimedMilestones;

  // Ascensión de héroes: heroId → estrellas (1-5). Se sube gastando medallas.
  final Map<String, int> heroStars;

  /// XP necesaria para subir un nivel de cuenta.
  static const int xpPerLevel = 100;

  const PlayerProfile({
    required this.uid,
    this.isOnboardingComplete = false,
    this.selectedFactionId,
    this.activeHeroId,
    this.softCoins = 0,
    this.medals = 0,
    this.tokens = 0,
    this.unlockedHeroIds = const [],
    this.ownedCards = const [],
    this.deckCardIds = const [],
    this.tutorialBattleComplete = false,
    this.starterCardPurchased = false,
    this.starterCardAddedToDeck = false,
    this.battlePoints = 0,
    this.lastClaimedCycleIndex = 0,
    this.storyProgress = const {},
    this.completedStoryArcs = const {},
    this.achievements = const [],
    this.lastLoginDate,
    this.loginStreak = 0,
    this.lastDailyWinDate,
    this.accountXp = 0,
    this.dailyMissions = const [],
    this.missionsDate,
    this.claimedMilestones = const [],
    this.heroStars = const {},
  });

  // ── Helpers de nivel de cuenta ─────────────────────────────────────────────

  /// Estrellas actuales de un héroe (mínimo 1).
  int heroStarsFor(String heroId) => heroStars[heroId] ?? 1;

  /// Nivel actual (empieza en 1).
  int get accountLevel => (accountXp ~/ xpPerLevel) + 1;

  /// XP acumulada dentro del nivel actual.
  int get xpIntoLevel => accountXp % xpPerLevel;

  /// Progreso 0.0–1.0 dentro del nivel actual.
  double get levelProgress => xpIntoLevel / xpPerLevel;

  // ── Helpers de modo historia ─────────────────────────────────────────────

  /// Índice del último stage completado (-1 = no iniciado).
  int storyStageFor(String heroId, String rarity) =>
      storyProgress['${heroId}_$rarity'] ?? -1;

  bool isArcComplete(String heroId, String rarity) =>
      completedStoryArcs.contains('${heroId}_$rarity');

  /// La rareza más baja pendiente de completar para un héroe dado.
  /// Retorna null si todos los arcos están completos.
  String? nextPlayableRarity(String heroId) {
    for (final rarity in ['common', 'rare', 'epic', 'legendary']) {
      if (!isArcComplete(heroId, rarity)) return rarity;
    }
    return null;
  }

  /// ID del héroe que se desbloquea al completar el arco de esta rareza.
  /// Retorna null si es legendary (se otorga achievement en su lugar).
  static String? rewardHeroId(String heroId, String rarity) => switch (rarity) {
    'common'    => '${heroId}_rare',
    'rare'      => '${heroId}_epic',
    'epic'      => '${heroId}_legendary',
    _           => null,
  };

  PlayerProfile copyWith({
    bool? isOnboardingComplete,
    String? selectedFactionId,
    String? activeHeroId,
    int? softCoins,
    int? medals,
    int? tokens,
    List<String>? unlockedHeroIds,
    List<OwnedCard>? ownedCards,
    List<String>? deckCardIds,
    bool? tutorialBattleComplete,
    bool? starterCardPurchased,
    bool? starterCardAddedToDeck,
    int? battlePoints,
    int? lastClaimedCycleIndex,
    Map<String, int>? storyProgress,
    Set<String>? completedStoryArcs,
    List<String>? achievements,
    String? lastLoginDate,
    int? loginStreak,
    String? lastDailyWinDate,
    int? accountXp,
    List<DailyMission>? dailyMissions,
    String? missionsDate,
    List<String>? claimedMilestones,
    Map<String, int>? heroStars,
  }) =>
      PlayerProfile(
        uid: uid,
        isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
        selectedFactionId: selectedFactionId ?? this.selectedFactionId,
        activeHeroId: activeHeroId ?? this.activeHeroId,
        softCoins: softCoins ?? this.softCoins,
        medals: medals ?? this.medals,
        tokens: tokens ?? this.tokens,
        unlockedHeroIds: unlockedHeroIds ?? this.unlockedHeroIds,
        ownedCards: ownedCards ?? this.ownedCards,
        deckCardIds: deckCardIds ?? this.deckCardIds,
        tutorialBattleComplete: tutorialBattleComplete ?? this.tutorialBattleComplete,
        starterCardPurchased: starterCardPurchased ?? this.starterCardPurchased,
        starterCardAddedToDeck: starterCardAddedToDeck ?? this.starterCardAddedToDeck,
        battlePoints: battlePoints ?? this.battlePoints,
        lastClaimedCycleIndex: lastClaimedCycleIndex ?? this.lastClaimedCycleIndex,
        storyProgress: storyProgress ?? this.storyProgress,
        completedStoryArcs: completedStoryArcs ?? this.completedStoryArcs,
        achievements: achievements ?? this.achievements,
        lastLoginDate: lastLoginDate ?? this.lastLoginDate,
        loginStreak: loginStreak ?? this.loginStreak,
        lastDailyWinDate: lastDailyWinDate ?? this.lastDailyWinDate,
        accountXp: accountXp ?? this.accountXp,
        dailyMissions: dailyMissions ?? this.dailyMissions,
        missionsDate: missionsDate ?? this.missionsDate,
        claimedMilestones: claimedMilestones ?? this.claimedMilestones,
        heroStars: heroStars ?? this.heroStars,
      );

  Map<String, dynamic> toFirestore() => {
    'isOnboardingComplete': isOnboardingComplete,
    'selectedFactionId': selectedFactionId,
    'activeHeroId': activeHeroId,
    'softCoins': softCoins,
    'medals': medals,
    'tokens': tokens,
    'unlockedHeroIds': unlockedHeroIds,
    'ownedCards': ownedCards.map((c) => c.toMap()).toList(),
    'deckCardIds': deckCardIds,
    'tutorialBattleComplete': tutorialBattleComplete,
    'starterCardPurchased': starterCardPurchased,
    'starterCardAddedToDeck': starterCardAddedToDeck,
    'battlePoints': battlePoints,
    'lastClaimedCycleIndex': lastClaimedCycleIndex,
    'storyProgress': storyProgress,
    'completedStoryArcs': completedStoryArcs.toList(),
    'achievements': achievements,
    'lastLoginDate': lastLoginDate,
    'loginStreak': loginStreak,
    'lastDailyWinDate': lastDailyWinDate,
    'accountXp': accountXp,
    'dailyMissions': dailyMissions.map((m) => m.toMap()).toList(),
    'missionsDate': missionsDate,
    'claimedMilestones': claimedMilestones,
    'heroStars': heroStars,
  };

  factory PlayerProfile.fromFirestore(String uid, Map<String, dynamic> data) =>
      PlayerProfile(
        uid: uid,
        isOnboardingComplete: data['isOnboardingComplete'] ?? false,
        selectedFactionId: data['selectedFactionId'],
        activeHeroId: data['activeHeroId'],
        softCoins: data['softCoins'] ?? 0,
        medals: data['medals'] ?? 0,
        tokens: data['tokens'] ?? 0,
        unlockedHeroIds: List<String>.from(data['unlockedHeroIds'] ?? []),
        ownedCards: (data['ownedCards'] as List<dynamic>? ?? [])
            .map((e) => OwnedCard.fromMap(e as Map<String, dynamic>))
            .toList(),
        deckCardIds: List<String>.from(data['deckCardIds'] ?? []),
        tutorialBattleComplete: data['tutorialBattleComplete'] ?? false,
        starterCardPurchased: data['starterCardPurchased'] ?? false,
        starterCardAddedToDeck: data['starterCardAddedToDeck'] ?? false,
        battlePoints: data['battlePoints'] ?? 0,
        lastClaimedCycleIndex: data['lastClaimedCycleIndex'] ?? 0,
        storyProgress: Map<String, int>.from(
            (data['storyProgress'] as Map<String, dynamic>? ?? {})
                .map((k, v) => MapEntry(k, (v as num).toInt()))),
        completedStoryArcs: Set<String>.from(data['completedStoryArcs'] ?? []),
        achievements: List<String>.from(data['achievements'] ?? []),
        lastLoginDate: data['lastLoginDate'] as String?,
        loginStreak: data['loginStreak'] as int? ?? 0,
        lastDailyWinDate: data['lastDailyWinDate'] as String?,
        accountXp: data['accountXp'] as int? ?? 0,
        dailyMissions: (data['dailyMissions'] as List<dynamic>? ?? [])
            .map((e) => DailyMission.fromMap(e as Map<String, dynamic>))
            .toList(),
        missionsDate: data['missionsDate'] as String?,
        claimedMilestones: List<String>.from(data['claimedMilestones'] ?? []),
        heroStars: Map<String, int>.from(
            (data['heroStars'] as Map<String, dynamic>? ?? {})
                .map((k, v) => MapEntry(k, (v as num).toInt()))),
      );
}

class OwnedCard {
  final String cardId;
  final int quantity;

  const OwnedCard({required this.cardId, required this.quantity});

  Map<String, dynamic> toMap() => {'cardId': cardId, 'quantity': quantity};

  factory OwnedCard.fromMap(Map<String, dynamic> map) =>
      OwnedCard(cardId: map['cardId'], quantity: map['quantity']);
}
