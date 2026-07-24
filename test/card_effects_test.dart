import 'package:flutter_test/flutter_test.dart';
import 'package:clash_of_styles/domain/config/game_config.dart';
import 'package:clash_of_styles/domain/entities/battle_state.dart';
import 'package:clash_of_styles/domain/entities/game_card.dart';
import 'package:clash_of_styles/domain/entities/hero_entity.dart';
import 'package:clash_of_styles/domain/usecases/resolve_combat_use_case.dart';

HeroEntity _hero() => HeroEntity(
      id: 'h', name: 'H', title: '', faction: Faction.boxer, rarity: 'common',
      stats: const HeroStats(punch: 10, kick: 10, grapple: 10, defense: 10, dodge: 10),
      maxHp: 100, maxStamina: 10,
      passive: const GameCard(id: 'p', name: 'p', lore: '', category: CardCategory.punch, rarity: CardRarity.neutral, staminaCost: 0),
      lore: '', imagePath: '',
    );

GameCard _card(String id, CardCategory cat, {int dmg = 10, CardEffect? effect}) =>
    GameCard(id: id, name: id, lore: '', category: cat, rarity: CardRarity.common,
        staminaCost: 1, baseDamage: dmg, effect: effect);

void main() {
  test('pierce: la carta ganadora ignora la mitigación de Defensa', () {
    // Patada vence a Defensa. Sin pierce el daño se mitiga a la mitad; con
    // pierce pega completo.
    final normal = CombatEngine.resolveSlot(
      slotIndex: 0,
      playerCard: _card('kick', CardCategory.kick),
      opponentCard: _card('def', CardCategory.defense),
      playerHero: _hero(), opponentHero: _hero(),
    );
    final piercing = CombatEngine.resolveSlot(
      slotIndex: 0,
      playerCard: _card('kick', CardCategory.kick, effect: CardEffect.pierce),
      opponentCard: _card('def', CardCategory.defense),
      playerHero: _hero(), opponentHero: _hero(),
    );
    expect(normal.winner, 'player');
    expect(piercing.winner, 'player');
    expect(piercing.playerDamageDealt, greaterThan(normal.playerDamageDealt));
    expect(normal.mitigatedBy, 'opponent');
    expect(piercing.mitigatedBy, isNull);
  });

  test('weaken: −50% reduce el daño a la mitad', () {
    final base = CombatEngine.resolveSlot(
      slotIndex: 0,
      playerCard: _card('punch', CardCategory.punch),
      opponentCard: null,
      playerHero: _hero(), opponentHero: _hero(),
    );
    final weak = CombatEngine.resolveSlot(
      slotIndex: 0,
      playerCard: _card('punch', CardCategory.punch),
      opponentCard: null,
      playerHero: _hero(), opponentHero: _hero(),
      playerWeakenPct: 50,
    );
    expect(weak.playerDamageDealt, closeTo(base.playerDamageDealt / 2, 0.01));
  });

  test('denyDefense: anula las cartas de Defensa del rival en el round', () {
    final player = CombatantState(
      hero: _hero(), currentHp: 100, currentStamina: 10, hand: const [],
      deck: const [], discardPile: const [],
      plannedSequence: [_card('punch', CardCategory.punch), null, null],
    );
    // Oponente con Defensa planeada pero con defenseDenied activo → su Defensa
    // se anula, así que el Puño del jugador conecta sin resistencia.
    final opponent = CombatantState(
      hero: _hero(), currentHp: 100, currentStamina: 10, hand: const [],
      deck: const [], discardPile: const [],
      plannedSequence: [_card('def', CardCategory.defense), null, null],
      statusEffects: const [StatusEffect(type: StatusEffectType.defenseDenied, value: 0, roundsRemaining: 1)],
    );
    final res = CombatEngine.resolveRound(roundNumber: 1, player: player, opponent: opponent);
    expect(res.slotResults[0].opponentCard, isNull); // Defensa anulada
    expect(res.slotResults[0].winner, 'player');
    expect(res.slotResults[0].playerDamageDealt, greaterThan(0));
  });

  // Guard: readMultiplier sigue siendo el esperado (regresión de constantes).
  test('constantes de balance presentes', () {
    expect(GameConfig.readMultiplier, 2.0);
  });
}
