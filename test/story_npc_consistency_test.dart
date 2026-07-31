import 'package:flutter_test/flutter_test.dart';
import 'package:clash_of_styles/domain/entities/story_arc.dart';
import 'package:clash_of_styles/infra/local/heroes_data.dart';
import 'package:clash_of_styles/infra/local/story/story_npcs.dart';
import 'package:clash_of_styles/infra/local/story_arcs_data.dart';

/// Diálogo que precede a la batalla del stage [battleIndex] del arco.
DialogueStage? _dialogueBefore(StoryArc arc, int battleIndex) {
  for (int i = battleIndex - 1; i >= 0; i--) {
    if (arc.stages[i].type == StageType.dialogue) return arc.stages[i].dialogue;
  }
  return null;
}

void main() {
  group('Consistencia de personajes del modo historia', () {
    // Este test atrapa el bug reportado: "El Falsario" se dibujaba con cuerpo
    // shaolin en la viñeta y después se peleaba contra un ninja.
    test('la silueta del jefe coincide con la facción del rival real', () {
      final fallos = <String>[];

      for (final arc in StoryArcsData.allArcs) {
        for (final stage in arc.stages) {
          final b = stage.battle;
          if (b == null || b.bossName == null) continue;

          final rival = HeroesData.findByIdSafe(b.botHeroId);
          if (rival == null) continue;

          final prev = _dialogueBefore(arc, stage.index);
          if (prev == null) continue;

          for (final line in prev.lines) {
            // Solo interesa el NPC que ES el jefe de la pelea siguiente.
            if (line.speakerName.trim().toLowerCase() !=
                b.bossName!.trim().toLowerCase()) {
              continue;
            }
            final npcFaction = StoryNpcs.factionFor(line.speakerId);
            if (npcFaction == null) continue;
            if (npcFaction != rival.faction) {
              fallos.add('${arc.arcId} stage ${stage.index}: '
                  '"${b.bossName}" silueta=${npcFaction.name} '
                  'pero se pelea contra ${b.botHeroId} (${rival.faction.name})');
            }
          }
        }
      }

      expect(fallos, isEmpty, reason: '\n${fallos.join('\n')}\n');
    });

    test('todo speakerId es narrador, héroe conocido o NPC del catálogo', () {
      final desconocidos = <String>{};
      for (final arc in StoryArcsData.allArcs) {
        for (final stage in arc.stages) {
          for (final line in stage.dialogue?.lines ?? const <DialogueLine>[]) {
            if (line.isNarrator) continue;
            if (HeroesData.findByIdSafe(line.speakerId) != null) continue;
            if (StoryNpcs.byId(line.speakerId) != null) continue;
            desconocidos.add('${arc.arcId}: "${line.speakerId}"');
          }
        }
      }
      // Un speakerId no reconocido cae a una silueta gris genérica sin aviso.
      expect(desconocidos, isEmpty,
          reason: 'speakerIds sin retrato definido:\n${desconocidos.join('\n')}');
    });

    test('un mismo NPC tiene una sola facción en toda la saga', () {
      // El catálogo es la fuente única: si el mismo personaje apareciera con
      // cuerpos distintos según el arco, la saga dejaría de ser una sola.
      final ids = StoryNpcs.all.map((n) => n.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'hay ids duplicados');
    });
  });
}
