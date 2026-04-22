import 'package:clash_of_styles/delivery/state/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/hero_entity.dart';
import '../../domain/entities/player_profile.dart';
import '../../infra/local/heroes_data.dart';

class OnboardingState {
  final HeroEntity? selectedHero;
  final bool isOnboardingComplete;
  final bool starterCardUnlocked;
  final int medals;
  final int softCoins;

  const OnboardingState({
    this.selectedHero,
    this.isOnboardingComplete = false,
    this.starterCardUnlocked = false,
    this.medals = 0,
    this.softCoins = 0,
  });

  OnboardingState copyWith({
    HeroEntity? selectedHero,
    bool? isOnboardingComplete,
    bool? starterCardUnlocked,
    int? medals,
    int? softCoins,
  }) =>
      OnboardingState(
        selectedHero: selectedHero ?? this.selectedHero,
        isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
        starterCardUnlocked: starterCardUnlocked ?? this.starterCardUnlocked,
        medals: medals ?? this.medals,
        softCoins: softCoins ?? this.softCoins,
      );
}

final onboardingProvider = NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    // ESTA ES LA CLAVE: Escucha al playerProvider. 
    // Cada vez que playerProvider cambie (en selectFaction), esto se vuelve a ejecutar.
    final player = ref.watch(playerProvider);

    if (player == null || player.activeHeroId == null) {
      return const OnboardingState();
    }

    // Buscamos el héroe basado en el ID que acaba de guardar el PlayerNotifier
    final hero = HeroesData.findById(player.activeHeroId!);

    return OnboardingState(
      selectedHero: hero,
      isOnboardingComplete: player.isOnboardingComplete,
      medals: player.medals,
      softCoins: player.softCoins,
      starterCardUnlocked: player.ownedCards.any(
            (c) => c.cardId.startsWith(hero.faction.name),
      ),
    );
  }

  Future<void> selectHero(HeroEntity hero) async {
    state = state.copyWith(selectedHero: hero);
    // TODO: persistir en Firebase
    // await _playerRepository.updateActiveHero(hero.id);
  }

  Future<void> completeTutorialBattle({
    required int medals,
    required int coins,
  }) async {
    state = state.copyWith(
      isOnboardingComplete: true,
      medals: state.medals + medals,
      softCoins: state.softCoins + coins,
    );
    // TODO: persistir en Firebase
  }

  Future<void> unlockStarterCard() async {
    if (state.selectedHero == null) return;
    const cardCost = 80;
    if (state.softCoins < cardCost) return;

    state = state.copyWith(
      softCoins: state.softCoins - cardCost,
      starterCardUnlocked: true,
    );
    // TODO: agregar carta al mazo en Firebase
    // El mazo ahora tiene 21 cartas (20 neutral + 1 facción)
  }
}