import 'package:flutter_test/flutter_test.dart';
import 'package:clash_of_styles/domain/entities/hero_entity.dart';
import 'package:clash_of_styles/infra/local/card_catalog.dart';

void main() {
  group('CardCatalog', () {
    test('incluye cartas locales (neutrales + facción)', () {
      final cat = CardCatalog.build(const []);
      expect(cat.findById('neutral_punch_basic'), isNotNull);
      expect(cat.findById('shaolin_five_beasts'), isNotNull);
      expect(cat.findById('inexistente'), isNull);
    });

    test('las cartas remotas pisan a las locales con el mismo id', () {
      final cat = CardCatalog.build([
        {
          'id': 'neutral_punch_basic',
          'name': 'Golpe Remoto',
          'category': 'punch',
          'rarity': 'common',
          'staminaCost': 3,
          'baseDamage': 99,
        },
      ]);
      final c = cat.findById('neutral_punch_basic');
      expect(c!.name, 'Golpe Remoto');
      expect(c.baseDamage, 99);
    });

    test('byFaction reúne locales + remotas', () {
      final cat = CardCatalog.build([
        {
          'id': 'shaolin_punch_tiger',
          'name': 'Garra del Tigre',
          'category': 'punch',
          'rarity': 'rare',
          'staminaCost': 3,
          'baseDamage': 34,
          'factionId': 'shaolin',
        },
      ]);
      final shaolin = cat.byFaction('shaolin');
      final ids = shaolin.map((c) => c.id).toSet();
      expect(ids, containsAll(['shaolin_five_beasts', 'shaolin_punch_tiger']));
    });

    test('resolveDeck descarta ids inexistentes', () {
      final cat = CardCatalog.build(const []);
      final deck = cat.resolveDeck(
          ['neutral_punch_basic', 'no_existe', 'shaolin_five_beasts']);
      expect(deck.length, 2);
    });

    group('buildFactionDeck', () {
      test('20 cartas y contiene cartas de la facción del bot', () {
        final cat = CardCatalog.build(const []);
        final deck = cat.buildFactionDeck(Faction.shaolin);
        expect(deck.length, 20);
        expect(deck.any((c) => c.factionId == 'shaolin'), isTrue);
      });

      test('escala con más cartas de facción disponibles', () {
        final cat = CardCatalog.build([
          for (int i = 0; i < 5; i++)
            {
              'id': 'shaolin_extra_$i',
              'name': 'Shaolin $i',
              'category': 'punch',
              'rarity': 'rare',
              'staminaCost': 3,
              'baseDamage': 30,
              'factionId': 'shaolin',
            },
        ]);
        final deck = cat.buildFactionDeck(Faction.shaolin);
        expect(deck.length, 20);
        final factionCount = deck.where((c) => c.factionId == 'shaolin').length;
        expect(factionCount, 8); // llena los 8 slots de facción
      });
    });
  });
}
