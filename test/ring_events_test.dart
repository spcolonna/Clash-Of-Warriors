import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:clash_of_styles/domain/config/ring_events.dart';
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

GameCard _card(String id, CardCategory cat, {int dmg = 10}) => GameCard(
      id: id, name: id, lore: '', category: cat, rarity: CardRarity.common,
      staminaCost: 1, baseDamage: dmg);

CombatantState _c(List<GameCard?> seq) => CombatantState(
      hero: _hero(), currentHp: 100, currentStamina: 10, hand: const [],
      deck: const [], discardPile: const [], plannedSequence: seq);

void main() {
  test('Cuerdas Flojas: una patada puede fallar (con RNG que fuerza el fallo)', () {
    // rng que devuelve 0.0 siempre → nextDouble() < 0.20 se cumple → falla.
    final res = CombatEngine.resolveRound(
      roundNumber: 1,
      player: _c([_card('k', CardCategory.kick), null, null]),
      opponent: _c([null, null, null]),
      ringRule: RingEventRule.kicksMayFail,
      rng: _FixedRandom(0.0),
    );
    // La patada del jugador se anuló → no hay carta ni daño en el slot 0.
    expect(res.slotResults[0].playerCard, isNull);
    expect(res.slotResults[0].playerDamageDealt, 0);
  });

  test('Público Enfervorizado: los Puños pegan más fuerte', () {
    final base = CombatEngine.resolveRound(
      roundNumber: 1,
      player: _c([_card('p', CardCategory.punch), null, null]),
      opponent: _c([null, null, null]),
    );
    final boosted = CombatEngine.resolveRound(
      roundNumber: 1,
      player: _c([_card('p', CardCategory.punch), null, null]),
      opponent: _c([null, null, null]),
      ringRule: RingEventRule.punchPriority,
    );
    expect(boosted.totalPlayerDamage, greaterThan(base.totalPlayerDamage));
  });

  test('byId resuelve y devuelve null para ids desconocidos', () {
    expect(RingEvents.byId('loose_ropes')?.rule, RingEventRule.kicksMayFail);
    expect(RingEvents.byId('inexistente'), isNull);
    expect(RingEvents.byId(null), isNull);
  });
}

/// Random determinista para tests: nextDouble() siempre devuelve [value].
class _FixedRandom implements Random {
  final double value;
  _FixedRandom(this.value);
  @override
  double nextDouble() => value;
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => false;
}
