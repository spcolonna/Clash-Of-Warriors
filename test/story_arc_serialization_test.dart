import 'package:flutter_test/flutter_test.dart';
import 'package:clash_of_styles/domain/entities/battle_state.dart'
    show BotDifficulty;
import 'package:clash_of_styles/domain/entities/story_arc.dart';

void main() {
  group('StoryArc serialización', () {
    test('round-trip toMap → fromMap conserva campos cómic', () {
      final arc = StoryArc(
        heroId: 'puo_liu',
        rarity: 'rare',
        title: 'Las Cenizas del Consejo',
        actNumber: 2,
        coverSubtitle: 'Acto II',
        synopsis: 'El Consejo cayó, pero sus células siguen vivas.',
        stages: [
          StoryStage.dialogue(
            stage: const DialogueStage(
              stageIndex: 0,
              locationName: 'La Montaña Sagrada',
              locationId: 'montana_sagrada',
              pageLayout: 'vertical2',
              lines: [
                DialogueLine(
                  speakerId: 'puo_liu',
                  speakerName: 'Puo Liu',
                  text: '¡No escaparás!',
                  speakerIsLeft: false,
                  emotion: 'angry',
                  bubbleType: BubbleType.shout,
                  sfxText: '¡CRACK!',
                  panelIndex: 1,
                ),
              ],
            ),
          ),
          StoryStage.battle(
            stage: const BattleStage(
              stageIndex: 1,
              botHeroId: 'kage_rare',
              difficulty: BotDifficulty.normal,
              briefingText: 'El Lugarteniente te espera.',
              bossName: 'El Lugarteniente',
              locationId: 'puerto',
            ),
          ),
        ],
      );

      final restored = StoryArc.fromMap(arc.arcId, arc.toMap());

      expect(restored.heroId, 'puo_liu');
      expect(restored.rarity, 'rare');
      expect(restored.actNumber, 2);
      expect(restored.coverSubtitle, 'Acto II');
      expect(restored.synopsis, isNotNull);

      final d = restored.stages[0].dialogue!;
      expect(d.locationId, 'montana_sagrada');
      expect(d.pageLayout, 'vertical2');
      final line = d.lines.first;
      expect(line.emotion, 'angry');
      expect(line.bubbleType, BubbleType.shout);
      expect(line.sfxText, '¡CRACK!');
      expect(line.panelIndex, 1);

      final b = restored.stages[1].battle!;
      expect(b.bossName, 'El Lugarteniente');
      expect(b.locationId, 'puerto');
      expect(b.difficulty, BotDifficulty.normal);
    });

    test('maps con formato viejo (sin campos cómic) usan defaults', () {
      final legacyMap = {
        'heroId': 'kage',
        'rarity': 'common',
        'title': 'La Sombra Tiene Nombre',
        'stages': [
          {
            'type': 'dialogue',
            'dialogue': {
              'stageIndex': 0,
              'locationName': 'El Puerto de La Ciudadela',
              'lines': [
                {
                  'speakerId': 'kage',
                  'speakerName': 'Kage',
                  'text': 'Una orden más.',
                  'speakerIsLeft': true,
                },
              ],
            },
          },
          {
            'type': 'battle',
            'battle': {
              'stageIndex': 1,
              'botHeroId': 'ryoto',
              'difficulty': 'easy',
              'briefingText': 'Un mercenario bloquea el paso.',
            },
          },
        ],
      };

      final arc = StoryArc.fromMap('kage_common', legacyMap);

      expect(arc.actNumber, 1); // derivado de rarity common
      expect(arc.synopsis, isNull);

      final d = arc.stages[0].dialogue!;
      expect(d.pageLayout, 'auto');
      expect(d.locationId, isNull);
      expect(d.effectiveLocationId, 'el_puerto_de_la_ciudadela');
      final line = d.lines.first;
      expect(line.bubbleType, BubbleType.speech);
      expect(line.emotion, isNull);
      expect(line.panelIndex, isNull);

      final b = arc.stages[1].battle!;
      expect(b.bossName, isNull);
      expect(b.vsSfxText, '¡VS!');
    });

    test('actNumber derivado por rareza', () {
      const rarities = {'common': 1, 'rare': 2, 'epic': 3, 'legendary': 4};
      rarities.forEach((rarity, act) {
        final arc = StoryArc(
            heroId: 'kai', rarity: rarity, title: 't', stages: const []);
        expect(arc.actNumber, act, reason: rarity);
      });
    });
  });
}
