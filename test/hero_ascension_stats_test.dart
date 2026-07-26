import 'package:flutter_test/flutter_test.dart';
import 'package:clash_of_styles/domain/entities/game_card.dart';
import 'package:clash_of_styles/domain/entities/hero_entity.dart';

HeroEntity _hero({int stars = 1}) => HeroEntity(
      id: 'monje', name: 'Monje', title: '', faction: Faction.shaolin,
      rarity: 'common',
      stats: const HeroStats(punch: 8, kick: 6, grapple: 4, defense: 7, dodge: 5),
      maxHp: 100, maxStamina: 10,
      passive: const GameCard(id: 'p', name: 'p', lore: '',
          category: CardCategory.punch, rarity: CardRarity.neutral, staminaCost: 0),
      lore: '', imagePath: '', stars: stars,
    );

void main() {
  group('Stats por ascensión', () {
    test('con 1★ boostedStats es igual a las stats base', () {
      final h = _hero();
      expect(h.boostedStats.punch, h.stats.punch);
      expect(h.boostedStats.dodge, h.stats.dodge);
    });

    // Este test atrapa el bug reportado: héroe con 2★ mostrando stats de 1★.
    test('cada estrella extra suma +1 a todas las stats', () {
      final h = _hero(stars: 3);
      expect(h.boostedStats.punch, 8 + 2);
      expect(h.boostedStats.kick, 6 + 2);
      expect(h.boostedStats.grapple, 4 + 2);
      expect(h.boostedStats.defense, 7 + 2);
      expect(h.boostedStats.dodge, 5 + 2);
    });

    test('boostedStats coincide con lo que usa el combate para el daño', () {
      const card = GameCard(id: 'c', name: 'c', lore: '',
          category: CardCategory.punch, rarity: CardRarity.neutral,
          staminaCost: 1, baseDamage: 10);
      final h = _hero(stars: 2);
      // effectiveDamage = base * (statBoosteado / 10); sin sinergia de héroe.
      expect(h.effectiveDamage(card), 10 * (h.boostedStats.punch / 10.0));
    });
  });
}
