// lib/infra/local/new_player_journey_data.dart

import '../../domain/entities/player_profile.dart';

/// Hito del camino del nuevo jugador. Su completitud se deriva del estado
/// actual del perfil — no requiere tracking adicional.
class JourneyMilestone {
  final String id;
  final String label;
  final String rewardType; // 'coins' | 'tokens'
  final int rewardAmount;
  final bool Function(PlayerProfile) isComplete;

  const JourneyMilestone({
    required this.id,
    required this.label,
    required this.rewardType,
    required this.rewardAmount,
    required this.isComplete,
  });
}

class NewPlayerJourneyData {
  static final List<JourneyMilestone> milestones = [
    JourneyMilestone(
      id: 'choose_faction',
      label: 'Elegí tu facción',
      rewardType: 'coins',
      rewardAmount: 100,
      isComplete: (p) => p.selectedFactionId != null,
    ),
    JourneyMilestone(
      id: 'finish_tutorial',
      label: 'Completá el tutorial',
      rewardType: 'coins',
      rewardAmount: 150,
      isComplete: (p) => p.isOnboardingComplete,
    ),
    JourneyMilestone(
      id: 'buy_card',
      label: 'Conseguí una carta nueva',
      rewardType: 'coins',
      rewardAmount: 150,
      isComplete: (p) => p.starterCardPurchased || p.ownedCards.isNotEmpty,
    ),
    JourneyMilestone(
      id: 'reach_level_3',
      label: 'Alcanzá el nivel de cuenta 3',
      rewardType: 'tokens',
      rewardAmount: 3,
      isComplete: (p) => p.accountLevel >= 3,
    ),
    JourneyMilestone(
      id: 'first_story_arc',
      label: 'Completá un arco de historia',
      rewardType: 'tokens',
      rewardAmount: 4,
      isComplete: (p) => p.completedStoryArcs.isNotEmpty,
    ),
    JourneyMilestone(
      id: 'streak_3',
      label: 'Entrá 3 días seguidos',
      rewardType: 'tokens',
      rewardAmount: 5,
      isComplete: (p) => p.loginStreak >= 3,
    ),
  ];

  /// True si todos los hitos ya fueron cobrados (para ocultar la sección).
  static bool allClaimed(PlayerProfile p) =>
      milestones.every((m) => p.claimedMilestones.contains(m.id));
}
