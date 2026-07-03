import 'package:flutter_test/flutter_test.dart';
import 'package:clash_of_styles/domain/entities/story_arc.dart';
import 'package:clash_of_styles/infra/local/heroes_data.dart';
import 'package:clash_of_styles/infra/local/story_arcs_data.dart';

void main() {
  group('Integridad de los arcos de historia', () {
    test('existen los 20 arcos (5 héroes × 4 rarezas) con contenido único', () {
      const heroes = ['puo_liu', 'kage', 'ryoto', 'kai', 'mila'];
      const rarities = ['common', 'rare', 'epic', 'legendary'];

      expect(StoryArcsData.allArcs.length, 20);

      for (final h in heroes) {
        final titles = <String>{};
        for (final r in rarities) {
          final arc = StoryArcsData.findArc(h, r);
          expect(arc, isNotNull, reason: 'falta el arco ${h}_$r');
          expect(arc!.title, isNotEmpty);
          titles.add(arc.title);
        }
        // Los 4 actos de cada héroe tienen títulos propios (no placeholders)
        expect(titles.length, 4,
            reason: 'títulos repetidos en la serie de $h');
      }
    });

    test('cada arco: 10 stages, pares=diálogo / impares=batalla', () {
      for (final arc in StoryArcsData.allArcs) {
        expect(arc.stages.length, 10, reason: arc.arcId);
        for (int i = 0; i < 10; i++) {
          final expected =
              i.isEven ? StageType.dialogue : StageType.battle;
          expect(arc.stages[i].type, expected,
              reason: '${arc.arcId} stage $i');
          expect(arc.stages[i].index, i, reason: '${arc.arcId} stage $i');
        }
      }
    });

    test('todos los botHeroId existen en HeroesData', () {
      for (final arc in StoryArcsData.allArcs) {
        for (final stage in arc.stages) {
          final b = stage.battle;
          if (b == null) continue;
          expect(HeroesData.findByIdSafe(b.botHeroId), isNotNull,
              reason:
                  '${arc.arcId} stage ${b.stageIndex}: bot "${b.botHeroId}" no existe');
        }
      }
    });

    test('los diálogos tienen líneas y los briefings texto', () {
      for (final arc in StoryArcsData.allArcs) {
        for (final stage in arc.stages) {
          if (stage.dialogue != null) {
            expect(stage.dialogue!.lines, isNotEmpty,
                reason: '${arc.arcId} stage ${stage.index}');
            expect(stage.dialogue!.locationName, isNotEmpty,
                reason: '${arc.arcId} stage ${stage.index}');
          }
          if (stage.battle != null) {
            expect(stage.battle!.briefingText, isNotEmpty,
                reason: '${arc.arcId} stage ${stage.index}');
          }
        }
      }
    });

    test('los actos derivan correctamente y las sinopsis existen', () {
      for (final arc in StoryArcsData.allArcs) {
        final expectedAct = switch (arc.rarity) {
          'rare' => 2,
          'epic' => 3,
          'legendary' => 4,
          _ => 1,
        };
        expect(arc.actNumber, expectedAct, reason: arc.arcId);
        expect(arc.synopsis, isNotNull, reason: '${arc.arcId} sin synopsis');
      }
    });
  });
}
