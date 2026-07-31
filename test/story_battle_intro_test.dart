import 'package:flutter_test/flutter_test.dart';
import 'package:clash_of_styles/domain/entities/story_arc.dart';
import 'package:clash_of_styles/infra/local/story_arcs_data.dart';

/// Normaliza para comparar: minúsculas, sin tildes y sin artículo inicial.
String _norm(String s) {
  const acentos = {
    'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u',
    'à': 'a', 'è': 'e', 'ì': 'i', 'ò': 'o', 'ù': 'u',
    'ü': 'u', 'ñ': 'n',
  };
  var out = s.toLowerCase();
  acentos.forEach((k, v) => out = out.replaceAll(k, v));
  out = out.replaceAll(RegExp(r'^(el|la|los|las)\s+'), '');
  return out.replaceAll(RegExp(r'\s+'), ' ').trim();
}

DialogueStage? _dialogueBefore(StoryArc arc, int battleIndex) {
  for (int i = battleIndex - 1; i >= 0; i--) {
    if (arc.stages[i].type == StageType.dialogue) return arc.stages[i].dialogue;
  }
  return null;
}

void main() {
  group('Continuidad narrativa del modo historia', () {
    // Atrapa el salto reportado: venías charlando con un personaje y de golpe
    // peleabas contra otro que el cómic nunca había presentado.
    test('toda batalla con jefe lo presenta en el diálogo previo', () {
      final sinPresentar = <String>[];

      for (final arc in StoryArcsData.allArcs) {
        for (final stage in arc.stages) {
          final b = stage.battle;
          if (b == null || b.bossName == null) continue;

          final prev = _dialogueBefore(arc, stage.index);
          if (prev == null) {
            sinPresentar.add('${arc.arcId} stage ${stage.index}: sin diálogo previo');
            continue;
          }

          final texto = _norm(prev.lines
              .map((l) => '${l.speakerName} ${l.text}')
              .join(' '));
          if (!texto.contains(_norm(b.bossName!))) {
            sinPresentar
                .add('${arc.arcId} stage ${stage.index}: "${b.bossName}" '
                    'nunca se nombra en "${prev.locationName}"');
          }
        }
      }

      expect(sinPresentar, isEmpty,
          reason: '\nRivales que aparecen sin presentación:\n'
              '${sinPresentar.join('\n')}\n');
    });

    test('ninguna línea de diálogo quedó vacía ni con literales pegados', () {
      for (final arc in StoryArcsData.allArcs) {
        for (final stage in arc.stages) {
          for (final l in stage.dialogue?.lines ?? const <DialogueLine>[]) {
            expect(l.text.trim(), isNotEmpty, reason: arc.arcId);
            // Al partir textos largos en literales adyacentes es fácil comerse
            // el espacio ('por' + 'caminar' = 'porcaminar').
            expect(RegExp(r'[a-záéíóúñ][A-ZÁÉÍÓÚÑ]').hasMatch(l.text), isFalse,
                reason: '${arc.arcId} stage ${stage.index}: '
                    'palabras pegadas en "${l.text}"');
          }
        }
      }
    });
  });

  group('Ortografía de los guiones', () {
    // El usuario detectó "Fabricé" (debe ser "Fabriqué"). Los verbos en -car
    // cambian c→qu antes de e: que no se vuelva a colar ninguno.
    test('pretéritos de verbos en -car bien escritos', () {
      // Formas incorrectas: la correcta lleva "qu" (fabriqué, busqué, toqué...).
      // 'empecé' NO va acá: es de -zar y se escribe con c.
      const revisar = [
        'fabricé', 'buscé', 'tocé', 'explicé', 'sacé', 'acercé', 'aplicé',
        'marcé', 'colocé', 'arrancé el',
      ];

      final hallados = <String>[];
      for (final arc in StoryArcsData.allArcs) {
        for (final stage in arc.stages) {
          final textos = [
            ...?stage.dialogue?.lines.map((l) => l.text),
            if (stage.battle != null) stage.battle!.briefingText,
          ];
          for (final t in textos) {
            final lower = t.toLowerCase();
            for (final err in revisar) {
              if (lower.contains(err)) {
                hallados.add('${arc.arcId}: "$err" en "$t"');
              }
            }
          }
        }
      }
      expect(hallados, isEmpty, reason: '\n${hallados.join('\n')}\n');
    });
  });
}
