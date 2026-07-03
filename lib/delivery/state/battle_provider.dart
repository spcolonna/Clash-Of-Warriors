// lib/delivery/state/battle_provider.dart

import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/config/game_config.dart';
import '../../domain/entities/battle_state.dart';
import '../../domain/entities/game_card.dart';
import '../../domain/entities/hero_entity.dart';
import '../../domain/usecases/resolve_combat_use_case.dart';
import '../../infra/local/neutral_cards_data.dart';
import 'providers.dart' show gameConfigProvider;

export '../../domain/entities/battle_state.dart' show BotDifficulty, GameMode;

final battleProvider = NotifierProvider<BattleNotifier, BattleState>(
  BattleNotifier.new,
);

class BattleNotifier extends Notifier<BattleState> {
  BotDifficulty? _botDifficulty; // null = tutorial

  @override
  BattleState build() => _emptyState();

  BattleState _emptyState() => const BattleState(
    phase: BattlePhase.planning,
    player: CombatantState(
      hero: HeroEntity(
        id: '',
        name: '',
        title: '',
        faction: Faction.shaolin,
        rarity: 'common',
        stats: HeroStats(
            punch: 0, kick: 0, grapple: 0, defense: 0, dodge: 0),
        maxHp: 0,
        maxStamina: 0,
        passive: GameCard(
          id: '',
          name: '',
          lore: '',
          category: CardCategory.punch,
          rarity: CardRarity.neutral,
          staminaCost: 0,
        ),
        lore: '',
        imagePath: '',
      ),
      currentHp: 0,
      currentStamina: 0,
      hand: [],
      deck: [],
      discardPile: [],
    ),
    opponent: CombatantState(
      hero: HeroEntity(
        id: '',
        name: '',
        title: '',
        faction: Faction.shaolin,
        rarity: 'common',
        stats: HeroStats(
            punch: 0, kick: 0, grapple: 0, defense: 0, dodge: 0),
        maxHp: 0,
        maxStamina: 0,
        passive: GameCard(
          id: '',
          name: '',
          lore: '',
          category: CardCategory.punch,
          rarity: CardRarity.neutral,
          staminaCost: 0,
        ),
        lore: '',
        imagePath: '',
      ),
      currentHp: 0,
      currentStamina: 0,
      hand: [],
      deck: [],
      discardPile: [],
    ),
  );

  GameMode _gameMode = GameMode.expert;

  static const _simpleCategories = {
    CardCategory.punch,
    CardCategory.kick,
    CardCategory.defense,
  };

  /// Batalla de arena contra bot con IA escalable (no tutorial).
  void initArenaBattle({
    required HeroEntity playerHero,
    required HeroEntity botHero,
    required BotDifficulty difficulty,
    GameMode gameMode = GameMode.expert,
  }) {
    _botDifficulty = difficulty;
    _gameMode = gameMode;

    final config = ref.read(gameConfigProvider).value;
    final firestoreCards = config?.cards ?? [];

    var fullDeck = firestoreCards.isNotEmpty
        ? NeutralCardsData.buildStarterDeckFromConfig(firestoreCards)
        : NeutralCardsData.buildStarterDeck();

    if (gameMode == GameMode.normal) {
      fullDeck = fullDeck.where((c) => _simpleCategories.contains(c.category)).toList();
    }

    final deck = List<GameCard>.from(fullDeck)..shuffle(Random());
    final hand = deck.take(5).toList();
    final remainingDeck = deck.skip(5).toList();

    final botFullDeck = firestoreCards.isNotEmpty
        ? NeutralCardsData.buildStarterDeckFromConfig(firestoreCards)
        : NeutralCardsData.buildStarterDeck();

    var botFilteredDeck = gameMode == GameMode.normal
        ? botFullDeck.where((c) => _simpleCategories.contains(c.category)).toList()
        : botFullDeck;

    final botDeck = List<GameCard>.from(botFilteredDeck)..shuffle(Random());
    final botHand = botDeck.take(5).toList();
    final botRemainingDeck = botDeck.skip(5).toList();

    // Curva de stamina: ronda 1 arranca escasa
    final playerStamina = GameConfig.staminaForRound(1, playerHero.maxStamina);
    final botStamina = GameConfig.staminaForRound(1, botHero.maxStamina);

    // Pre-computar secuencia del bot para ronda 1 (habilita scout desde el inicio)
    final initialBotSequence = BotAI.decideSequence(
      botHand, botHero, difficulty, mode: gameMode, stamina: botStamina,
    );

    state = BattleState(
      phase: BattlePhase.planning,
      isTutorial: false,
      botDifficulty: difficulty,
      gameMode: gameMode,
      scoutTokensRemaining: GameConfig.scoutInitialTokens,
      revealedOpponentSlots: const {},
      player: CombatantState(
        hero: playerHero,
        currentHp: playerHero.maxHp,
        currentStamina: playerStamina,
        hand: hand,
        deck: remainingDeck,
        discardPile: [],
        plannedSequence: List.filled(3, null),
      ),
      opponent: CombatantState(
        hero: botHero,
        currentHp: botHero.maxHp,
        currentStamina: botStamina,
        hand: botHand,
        deck: botRemainingDeck,
        discardPile: [],
        plannedSequence: initialBotSequence,
      ),
      currentRound: 1,
      roundHistory: [],
    );
  }

  void initTutorialBattle({
    required HeroEntity playerHero,
    required HeroEntity botHero,
  }) {
    _botDifficulty = null;
    final config = ref.read(gameConfigProvider).value;
    final firestoreCards = config?.cards ?? [];

    final deck = (firestoreCards.isNotEmpty
            ? NeutralCardsData.buildStarterDeckFromConfig(firestoreCards)
            : NeutralCardsData.buildStarterDeck())
        ..shuffle(Random());
    final hand = deck.take(5).toList();
    final remainingDeck = deck.skip(5).toList();

    final botDeck = (firestoreCards.isNotEmpty
            ? NeutralCardsData.buildStarterDeckFromConfig(firestoreCards)
            : NeutralCardsData.buildStarterDeck())
        ..shuffle(Random());
    final botHand = botDeck.take(5).toList();
    final botRemainingDeck = botDeck.skip(5).toList();

    final weakenedBot = botHero.copyWith(maxHp: 5); // seba

    state = BattleState(
      phase: BattlePhase.planning,
      player: CombatantState(
        hero: playerHero,
        currentHp: playerHero.maxHp,
        currentStamina: GameConfig.staminaForRound(1, playerHero.maxStamina),
        hand: hand,
        deck: remainingDeck,
        discardPile: [],
        plannedSequence: List.filled(3, null),
      ),
      opponent: CombatantState(
        hero: weakenedBot,
        currentHp: weakenedBot.maxHp,
        currentStamina: GameConfig.staminaForRound(1, weakenedBot.maxStamina),
        hand: botHand,
        deck: botRemainingDeck,
        discardPile: [],
        plannedSequence: List.filled(3, null),
      ),
      currentRound: 1,
      roundHistory: [],
    );
  }

  void initStoryBattle({
    required HeroEntity playerHero,
    required HeroEntity botHero,
    required BotDifficulty difficulty,
    GameMode gameMode = GameMode.expert,
  }) {
    _botDifficulty = difficulty;
    _gameMode = gameMode;

    final config = ref.read(gameConfigProvider).value;
    final firestoreCards = config?.cards ?? [];

    // El jugador usa su propio mazo (igual que arena)
    var fullDeck = firestoreCards.isNotEmpty
        ? NeutralCardsData.buildStarterDeckFromConfig(firestoreCards)
        : NeutralCardsData.buildStarterDeck();

    if (gameMode == GameMode.normal) {
      fullDeck = fullDeck.where((c) => _simpleCategories.contains(c.category)).toList();
    }

    final deck = List<GameCard>.from(fullDeck)..shuffle(Random());
    final hand = deck.take(5).toList();
    final remainingDeck = deck.skip(5).toList();

    final botFullDeck = firestoreCards.isNotEmpty
        ? NeutralCardsData.buildStarterDeckFromConfig(firestoreCards)
        : NeutralCardsData.buildStarterDeck();
    final botDeck = List<GameCard>.from(botFullDeck)..shuffle(Random());
    final botHand = botDeck.take(5).toList();
    final botRemainingDeck = botDeck.skip(5).toList();

    final storyPlayerStamina =
        GameConfig.staminaForRound(1, playerHero.maxStamina);
    final storyBotStamina = GameConfig.staminaForRound(1, botHero.maxStamina);

    final storyInitialBotSequence = BotAI.decideSequence(
      botHand, botHero, difficulty, mode: gameMode, stamina: storyBotStamina,
    );

    state = BattleState(
      phase: BattlePhase.planning,
      isTutorial: false,
      isStoryBattle: true,
      botDifficulty: difficulty,
      gameMode: gameMode,
      scoutTokensRemaining: GameConfig.scoutInitialTokens,
      revealedOpponentSlots: const {},
      player: CombatantState(
        hero: playerHero,
        currentHp: playerHero.maxHp,
        currentStamina: storyPlayerStamina,
        hand: hand,
        deck: remainingDeck,
        discardPile: [],
        plannedSequence: List.filled(3, null),
      ),
      opponent: CombatantState(
        hero: botHero,
        currentHp: botHero.maxHp,
        currentStamina: storyBotStamina,
        hand: botHand,
        deck: botRemainingDeck,
        discardPile: [],
        plannedSequence: storyInitialBotSequence,
      ),
      currentRound: 1,
      roundHistory: [],
    );
  }

  /// Retorna true si la carta se colocó; false si no alcanzó la stamina
  /// o el slot/carta no eran válidos (para que la UI dé feedback de error).
  /// El slot 0 (apertura) queda sellado una vez colocado: al comprometerla
  /// se revela la apertura del rival, así que no se puede cambiar.
  bool placeCardInSlot(GameCard card, int slotIndex) {
    final player = state.player;
    if (slotIndex < 0 || slotIndex >= 3) return false;
    if (slotIndex == 0 && player.plannedSequence[0] != null) return false;
    if (!player.hand.contains(card)) return false;

    final currentSequence = List<GameCard?>.from(player.plannedSequence);
    final currentHand = List<GameCard>.from(player.hand);
    final previousCard = currentSequence[slotIndex];

    if (previousCard != null) {
      currentHand.add(previousCard);
      currentSequence[slotIndex] = null;
    }

    final usedWithoutSlot = currentSequence
        .whereType<GameCard>()
        .fold(0, (s, c) => s + c.staminaCost);

    if (usedWithoutSlot + card.staminaCost > player.currentStamina) {
      if (previousCard != null) {
        currentSequence[slotIndex] = previousCard;
        currentHand.remove(previousCard);
      }
      return false;
    }

    currentHand.remove(card);
    currentSequence[slotIndex] = card;

    state = state.copyWith(
      player: player.copyWith(
        plannedSequence: currentSequence,
        hand: currentHand,
      ),
    );
    return true;
  }

  /// Coloca la carta en el primer slot libre (y no bloqueado).
  /// Retorna el índice del slot usado, o -1 si no se pudo colocar.
  int playCardToFirstFreeSlot(GameCard card) {
    final blockedSlots = state.player.statusEffects
        .where((e) => e.type == StatusEffectType.slotBlocked)
        .map((e) => e.value)
        .toSet();
    for (int i = 0; i < 3; i++) {
      if (blockedSlots.contains(i)) continue;
      if (state.player.plannedSequence[i] != null) continue;
      if (placeCardInSlot(card, i)) return i;
      return -1; // slot libre pero sin stamina suficiente
    }
    return -1; // no hay slots libres
  }

  void removeCardFromSlot(int slotIndex) {
    // La apertura queda sellada (ya reveló la del rival)
    if (slotIndex == 0) return;
    final player = state.player;
    final sequence = List<GameCard?>.from(player.plannedSequence);
    final hand = List<GameCard>.from(player.hand);

    final card = sequence[slotIndex];
    if (card != null) {
      hand.add(card);
      sequence[slotIndex] = null;
    }

    state = state.copyWith(
      player: player.copyWith(
        plannedSequence: sequence,
        hand: hand,
      ),
    );
  }

  /// Resuelve el round SIN aplicar HP final.
  /// La secuencia del bot ya fue pre-computada en initArenaBattle/startNextRound
  /// y almacenada en opponent.plannedSequence (el scout la puede revelar).
  Future<void> confirmSequenceAndResolve() async {
    final playerBlockedSlots = state.player.statusEffects
        .where((e) => e.type == StatusEffectType.slotBlocked)
        .map((e) => e.value)
        .toList();
    final opponentBlockedSlots = state.opponent.statusEffects
        .where((e) => e.type == StatusEffectType.slotBlocked)
        .map((e) => e.value)
        .toList();

    // La secuencia del bot ya está almacenada — solo transicionar a Resolving
    state = state.copyWith(phase: BattlePhase.resolving);

    await Future.delayed(const Duration(milliseconds: 300));

    final result = CombatEngine.resolveRound(
      roundNumber: state.currentRound,
      player: state.player,
      opponent: state.opponent,
      playerBlockedSlots: playerBlockedSlots,
      opponentBlockedSlots: opponentBlockedSlots,
      mode: _gameMode,
    );

    final newHistory = [...state.roundHistory, result];
    state = state.copyWith(roundHistory: newHistory);
  }

  /// El jugador elige qué carta conservar para la próxima ronda.
  void holdCard(GameCard card) {
    if (state.phase != BattlePhase.roundEnd) return;
    if (!state.player.hand.contains(card)) return;
    state = state.copyWith(
      player: state.player.copyWith(heldCard: card),
    );
  }

  /// Revela la carta del oponente en un slot específico consumiendo un scout token.
  /// El slot 0 (apertura) ya es visible gratis, no se puede scoutear.
  void useScout(int slotIndex) {
    if (slotIndex == 0) return;
    if (state.scoutTokensRemaining <= 0) return;
    if (state.phase != BattlePhase.planning) return;
    if (state.revealedOpponentSlots.containsKey(slotIndex)) return;

    final revealedCard = state.opponent.plannedSequence[slotIndex];
    final newRevealedSlots = Map<int, GameCard>.from(state.revealedOpponentSlots);
    if (revealedCard != null) {
      newRevealedSlots[slotIndex] = revealedCard;
    } else {
      // El bot descansa en este slot — marcarlo como visto (null entry no funciona, usamos un centinela)
      // Lo representamos como "slot escaneado vacío": no agregamos carta pero sí descontamos el token
    }

    state = state.copyWith(
      scoutTokensRemaining: state.scoutTokensRemaining - 1,
      revealedOpponentSlots: newRevealedSlots,
    );
  }

  /// Aplica el daño de UN slot específico al HP actual.
  /// Se llama slot por slot durante la animación de resolución.
  void applySlotDamage(int slotIndex) {
    if (state.roundHistory.isEmpty) return;
    final lastRound = state.roundHistory.last;
    if (slotIndex < 0 || slotIndex >= lastRound.slotResults.length) return;

    final slotResult = lastRound.slotResults[slotIndex];

    final newPlayerHp =
    (state.player.currentHp - slotResult.opponentDamageDealt)
        .ceil()
        .clamp(0, state.player.hero.maxHp);
    final newOpponentHp =
    (state.opponent.currentHp - slotResult.playerDamageDealt)
        .ceil()
        .clamp(0, state.opponent.hero.maxHp);

    state = state.copyWith(
      player: state.player.copyWith(currentHp: newPlayerHp),
      opponent: state.opponent.copyWith(currentHp: newOpponentHp),
    );
  }

  /// Cierra el round: aplica bonus de ronda perfecta, otorga scouts al
  /// ganador del round, detecta fin de batalla, genera StatusEffects desde
  /// passives ganadores y hace tick-down de efectos existentes.
  void finalizeRound() {
    var player = state.player;
    var opponent = state.opponent;
    var scoutTokens = state.scoutTokensRemaining;

    if (state.roundHistory.isNotEmpty) {
      final last = state.roundHistory.last;

      // 0a. Bonus de ronda perfecta (los 3 slots ganados)
      if (last.playerPerfectBonus > 0) {
        opponent = opponent.copyWith(
          currentHp: (opponent.currentHp - last.playerPerfectBonus)
              .clamp(0, opponent.hero.maxHp),
        );
      }
      if (last.opponentPerfectBonus > 0) {
        player = player.copyWith(
          currentHp: (player.currentHp - last.opponentPerfectBonus)
              .clamp(0, player.hero.maxHp),
        );
      }

      // 0b. Scout ganado: quien gana más slots que el rival gana un scout
      if (!state.isTutorial) {
        final playerSlots =
            last.slotResults.where((s) => s.winner == 'player').length;
        final opponentSlots =
            last.slotResults.where((s) => s.winner == 'opponent').length;
        if (playerSlots > opponentSlots) {
          scoutTokens = (scoutTokens + GameConfig.scoutPerRoundWon)
              .clamp(0, GameConfig.scoutMaxTokens);
        }
      }
    }

    bool? playerWon;
    if (!opponent.isAlive) playerWon = true;
    if (!player.isAlive) playerWon = false;

    // 1. Tick-down de efectos existentes y filtrar expirados
    final tickedPlayerEffects = player.statusEffects
        .map((e) => e.tickDown())
        .where((e) => e.roundsRemaining > 0)
        .toList();
    final tickedOpponentEffects = opponent.statusEffects
        .map((e) => e.tickDown())
        .where((e) => e.roundsRemaining > 0)
        .toList();

    // 2. Generar nuevos StatusEffects desde passives que ganaron slots
    final newPlayerEffects = List<StatusEffect>.from(tickedPlayerEffects);
    final newOpponentEffects = List<StatusEffect>.from(tickedOpponentEffects);

    if (state.roundHistory.isNotEmpty) {
      for (final slot in state.roundHistory.last.slotResults) {
        if (slot.winner == 'player') {
          // Kage passive: daño continuo al oponente durante 2 rounds
          if (slot.playerCard?.id == 'passive_kage') {
            newOpponentEffects.add(const StatusEffect(
              type: StatusEffectType.continuousDamage,
              value: 8,
              roundsRemaining: 2,
            ));
          }
          // Mila passive: bloquea slot 0 del oponente el próximo round
          if (slot.playerCard?.id == 'passive_mila') {
            newOpponentEffects.add(const StatusEffect(
              type: StatusEffectType.slotBlocked,
              value: 0,
              roundsRemaining: 1,
            ));
          }
        }
      }
    }

    state = state.copyWith(
      phase: playerWon != null ? BattlePhase.battleEnd : BattlePhase.roundEnd,
      currentRound: state.currentRound + 1,
      playerWon: playerWon,
      scoutTokensRemaining: scoutTokens,
      player: player.copyWith(statusEffects: newPlayerEffects),
      opponent: opponent.copyWith(statusEffects: newOpponentEffects),
    );
  }

  void surrender() {
    state = state.copyWith(
      phase: BattlePhase.battleEnd,
      playerWon: false,
    );
  }

  void startNextRound() {
    // Resetear passiveJustUnlocked del round anterior
    state = state.copyWith(passiveJustUnlocked: false);

    // Capturar si el jugador agotó toda su stamina este round (antes de drawCards)
    final playerUsedAllStamina = state.player.remainingStamina == 0;

    // Bot Hard: auto-conservar la carta más poderosa de la mano restante
    var currentOpponent = state.opponent;
    if (_botDifficulty == BotDifficulty.hard && currentOpponent.hand.isNotEmpty) {
      final best = currentOpponent.hand.reduce(
        (a, b) => currentOpponent.hero.effectiveDamage(a) >= currentOpponent.hero.effectiveDamage(b) ? a : b,
      );
      currentOpponent = currentOpponent.copyWith(heldCard: best);
    }

    // En tutorial no se descarta la mano completa (mantiene el comportamiento clásico)
    final fullDiscard = !state.isTutorial;
    var player = _drawCards(state.player, fullDiscard: fullDiscard);
    var opponent = _drawCards(currentOpponent, fullDiscard: fullDiscard);

    // Aplicar daño continuo (DoT) desde efectos activos
    final playerDoT = player.statusEffects
        .where((e) => e.type == StatusEffectType.continuousDamage)
        .fold(0, (sum, e) => sum + e.value);
    final opponentDoT = opponent.statusEffects
        .where((e) => e.type == StatusEffectType.continuousDamage)
        .fold(0, (sum, e) => sum + e.value);

    // Curva de stamina: la base crece con cada ronda (arco de batalla).
    // state.currentRound ya fue incrementado en finalizeRound → es la ronda nueva.
    final playerBaseStamina =
        GameConfig.staminaForRound(state.currentRound, player.hero.maxStamina);
    final opponentBaseStamina =
        GameConfig.staminaForRound(state.currentRound, opponent.hero.maxStamina);

    // Aplicar reducción de stamina + carry-over bonus
    final playerStaminaReduction = player.statusEffects
        .where((e) => e.type == StatusEffectType.staminaReduction)
        .fold(0, (sum, e) => sum + e.value);
    final carryBonus = playerUsedAllStamina ? 0 : 1;
    final effectivePlayerStamina =
        (playerBaseStamina - playerStaminaReduction + carryBonus)
            .clamp(1, playerBaseStamina + 1);

    final newPlayerHp = (player.currentHp - playerDoT).clamp(0, player.hero.maxHp);
    final newOpponentHp = (opponent.currentHp - opponentDoT).clamp(0, opponent.hero.maxHp);

    // Inyectar passive en mano si HP ≤ 40% y aún no fue usado
    var playerHand = List<GameCard>.from(player.hand);
    var passiveUsed = player.passiveUsed;
    var passiveJustUnlocked = false;
    final hpThreshold = (player.hero.maxHp * 0.4).round();
    if (!passiveUsed && newPlayerHp > 0 && newPlayerHp <= hpThreshold) {
      playerHand.add(player.hero.passive);
      passiveUsed = true;
      passiveJustUnlocked = true;
    }

    // Si el DoT mata a alguien, terminar la batalla
    bool? playerWon;
    if (newOpponentHp <= 0 && newPlayerHp <= 0) {
      playerWon = true;
    } else if (newOpponentHp <= 0) {
      playerWon = true;
    } else if (newPlayerHp <= 0) {
      playerWon = false;
    }

    // Pre-computar la secuencia del bot para la próxima ronda (habilita scout)
    final updatedOpponent = opponent.copyWith(
      currentHp: newOpponentHp,
      currentStamina: opponentBaseStamina,
      plannedSequence: List.filled(3, null),
    );

    final List<GameCard?> playerLastSequence = state.roundHistory.isNotEmpty
        ? state.roundHistory.last.slotResults.map((r) => r.playerCard).toList()
        : [];

    final nextBotSequence = _botDifficulty != null
        ? BotAI.decideSequence(
            updatedOpponent.hand,
            updatedOpponent.hero,
            _botDifficulty!,
            playerLastSequence: playerLastSequence,
            mode: _gameMode,
            stamina: opponentBaseStamina,
          )
        : TutorialBotAI.decideSequence(updatedOpponent.hand,
            stamina: opponentBaseStamina);

    state = state.copyWith(
      phase: playerWon != null ? BattlePhase.battleEnd : BattlePhase.planning,
      playerWon: playerWon,
      passiveJustUnlocked: passiveJustUnlocked,
      revealedOpponentSlots: const {}, // limpiar scouts al iniciar cada ronda
      player: player.copyWith(
        currentHp: newPlayerHp,
        currentStamina: effectivePlayerStamina,
        plannedSequence: List.filled(3, null),
        hand: playerHand,
        passiveUsed: passiveUsed,
      ),
      opponent: updatedOpponent.copyWith(
        plannedSequence: nextBotSequence,
      ),
    );
  }

  CombatantState _drawCards(CombatantState combatant, {bool fullDiscard = true}) {
    var deck = List<GameCard>.from(combatant.deck);
    var discard = List<GameCard>.from(combatant.discardPile);

    // Siempre descartar cartas jugadas
    for (final card in combatant.plannedSequence.whereType<GameCard>()) {
      discard.add(card);
    }

    List<GameCard> hand;
    if (fullDiscard) {
      // Nueva mecánica: descartar toda la mano (excepto la carta retenida) y robar 4 nuevas
      for (final card in combatant.hand) {
        if (card != combatant.heldCard) discard.add(card);
      }
      hand = combatant.heldCard != null ? [combatant.heldCard!] : [];
    } else {
      // Comportamiento clásico (tutorial): conservar cartas no jugadas
      hand = List<GameCard>.from(combatant.hand);
    }

    while (hand.length < 5) {
      if (deck.isEmpty) {
        if (discard.isEmpty) break;
        deck = List<GameCard>.from(discard)..shuffle(Random());
        discard.clear();
      }
      if (deck.isNotEmpty) {
        hand.add(deck.removeAt(0));
      } else {
        break;
      }
    }

    return combatant.copyWith(
      hand: hand,
      deck: deck,
      discardPile: discard,
      plannedSequence: List.filled(3, null),
      clearHeld: true,
    );
  }
}
