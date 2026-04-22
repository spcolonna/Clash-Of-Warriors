// lib/domain/entities/player_profile.dart

class PlayerProfile {
  final String uid;
  final bool isOnboardingComplete;
  final String? selectedFactionId;
  final String? activeHeroId;
  final int softCoins;
  final int medals;
  final List<String> unlockedHeroIds;
  final List<OwnedCard> ownedCards;

  // Mazo activo del jugador — ids con repeticiones hasta llegar a 20
  final List<String> deckCardIds;

  // Progreso del tutorial
  final bool tutorialBattleComplete;
  final bool starterCardPurchased;
  final bool starterCardAddedToDeck;

  const PlayerProfile({
    required this.uid,
    this.isOnboardingComplete = false,
    this.selectedFactionId,
    this.activeHeroId,
    this.softCoins = 0,
    this.medals = 0,
    this.unlockedHeroIds = const [],
    this.ownedCards = const [],
    this.deckCardIds = const [],
    this.tutorialBattleComplete = false,
    this.starterCardPurchased = false,
    this.starterCardAddedToDeck = false,
  });

  PlayerProfile copyWith({
    bool? isOnboardingComplete,
    String? selectedFactionId,
    String? activeHeroId,
    int? softCoins,
    int? medals,
    List<String>? unlockedHeroIds,
    List<OwnedCard>? ownedCards,
    List<String>? deckCardIds,
    bool? tutorialBattleComplete,
    bool? starterCardPurchased,
    bool? starterCardAddedToDeck,
  }) =>
      PlayerProfile(
        uid: uid,
        isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
        selectedFactionId: selectedFactionId ?? this.selectedFactionId,
        activeHeroId: activeHeroId ?? this.activeHeroId,
        softCoins: softCoins ?? this.softCoins,
        medals: medals ?? this.medals,
        unlockedHeroIds: unlockedHeroIds ?? this.unlockedHeroIds,
        ownedCards: ownedCards ?? this.ownedCards,
        deckCardIds: deckCardIds ?? this.deckCardIds,
        tutorialBattleComplete:
        tutorialBattleComplete ?? this.tutorialBattleComplete,
        starterCardPurchased: starterCardPurchased ?? this.starterCardPurchased,
        starterCardAddedToDeck:
        starterCardAddedToDeck ?? this.starterCardAddedToDeck,
      );

  Map<String, dynamic> toFirestore() => {
    'isOnboardingComplete': isOnboardingComplete,
    'selectedFactionId': selectedFactionId,
    'activeHeroId': activeHeroId,
    'softCoins': softCoins,
    'medals': medals,
    'unlockedHeroIds': unlockedHeroIds,
    'ownedCards': ownedCards.map((c) => c.toMap()).toList(),
    'deckCardIds': deckCardIds,
    'tutorialBattleComplete': tutorialBattleComplete,
    'starterCardPurchased': starterCardPurchased,
    'starterCardAddedToDeck': starterCardAddedToDeck,
  };

  factory PlayerProfile.fromFirestore(String uid, Map<String, dynamic> data) =>
      PlayerProfile(
        uid: uid,
        isOnboardingComplete: data['isOnboardingComplete'] ?? false,
        selectedFactionId: data['selectedFactionId'],
        activeHeroId: data['activeHeroId'],
        softCoins: data['softCoins'] ?? 0,
        medals: data['medals'] ?? 0,
        unlockedHeroIds: List<String>.from(data['unlockedHeroIds'] ?? []),
        ownedCards: (data['ownedCards'] as List<dynamic>? ?? [])
            .map((e) => OwnedCard.fromMap(e as Map<String, dynamic>))
            .toList(),
        deckCardIds: List<String>.from(data['deckCardIds'] ?? []),
        tutorialBattleComplete: data['tutorialBattleComplete'] ?? false,
        starterCardPurchased: data['starterCardPurchased'] ?? false,
        starterCardAddedToDeck: data['starterCardAddedToDeck'] ?? false,
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
