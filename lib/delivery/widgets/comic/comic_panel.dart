import 'package:flutter/material.dart';
import '../../../domain/entities/story_arc.dart';
import '../../screens/heroes/character_select_screen.dart' show factionColor;
import '../../../infra/local/heroes_data.dart';
import 'comic_portrait.dart';
import 'comic_theme.dart';
import 'halftone_painter.dart';
import 'onomatopeia.dart';
import 'speech_bubble.dart';

/// Datos de una viñeta: las líneas que se muestran juntas.
class ComicPanelData {
  final List<DialogueLine> lines;
  const ComicPanelData(this.lines);

  /// Agrupa las líneas de un stage en viñetas usando `panelIndex`;
  /// las líneas sin panelIndex son cada una su propio panel.
  static List<ComicPanelData> fromStage(DialogueStage stage) {
    final panels = <ComicPanelData>[];
    List<DialogueLine> current = [];
    int? currentIndex;

    for (final line in stage.lines) {
      if (line.panelIndex != null && line.panelIndex == currentIndex) {
        current.add(line);
        continue;
      }
      if (current.isNotEmpty) panels.add(ComicPanelData(current));
      current = [line];
      currentIndex = line.panelIndex;
    }
    if (current.isNotEmpty) panels.add(ComicPanelData(current));
    return panels;
  }

  /// Índice de panel (0-based) al que pertenece la línea [lineIndex] del stage.
  static int panelOfLine(DialogueStage stage, int lineIndex) {
    final panels = fromStage(stage);
    int count = 0;
    for (int p = 0; p < panels.length; p++) {
      count += panels[p].lines.length;
      if (lineIndex < count) return p;
    }
    return panels.length - 1;
  }
}

/// Una viñeta de cómic: borde de tinta grueso, fondo de locación tintado
/// con trama de medios tonos, retratos y globos de diálogo.
class ComicPanel extends StatelessWidget {
  final ComicPanelData data;
  final ComicPalette palette;
  /// Semilla para la micro-rotación determinística (índice del panel).
  final int seed;
  /// Cuántas líneas del panel se muestran (revelado progresivo).
  final int visibleLines;

  const ComicPanel({
    super.key,
    required this.data,
    required this.palette,
    required this.seed,
    int? visibleLines,
  }) : visibleLines = visibleLines ?? 99;

  @override
  Widget build(BuildContext context) {
    final lines = data.lines.take(visibleLines).toList();
    if (lines.isEmpty) return const SizedBox.shrink();

    final narratorLines = lines.where((l) => l.isNarrator).toList();
    final speechLines = lines.where((l) => !l.isNarrator).toList();

    // Speakers presentes en el panel (para los retratos)
    final leftSpeaker =
        speechLines.where((l) => l.speakerIsLeft).lastOrNull;
    final rightSpeaker =
        speechLines.where((l) => !l.speakerIsLeft).lastOrNull;
    final activeSpeakerId = speechLines.lastOrNull?.speakerId;
    final sfx = lines.map((l) => l.sfxText).whereType<String>().lastOrNull;

    // Rotación determinística ±0.6°
    final rotation = (((seed * 2654435761) & 0xFF) / 255.0 - 0.5) * 0.021;

    final onlyNarration = speechLines.isEmpty;
    final panelHeight = onlyNarration
        ? 110.0 + narratorLines.length * 30.0
        : 180.0 + speechLines.length * 52.0 + narratorLines.length * 34.0;

    return Transform.rotate(
      angle: rotation,
      child: Container(
        height: panelHeight.clamp(100.0, 420.0),
        decoration: BoxDecoration(
          border: Border.all(color: ComicTheme.ink, width: 3),
          boxShadow: const [
            BoxShadow(color: Color(0x66141414), offset: Offset(3, 4)),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Fondo de locación tintado (duotono)
            ColorFiltered(
              colorFilter: palette.duotoneFilter,
              child: Image.asset(
                palette.bgAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: palette.shadow),
              ),
            ),
            // Trama de medios tonos
            CustomPaint(
              painter: HalftonePainter(
                dotColor: palette.halftone,
                focus: seed.isEven ? Alignment.bottomRight : Alignment.bottomLeft,
                opacity: 0.2,
              ),
            ),
            // Retratos (anclados abajo)
            if (leftSpeaker != null)
              Positioned(
                left: 2,
                bottom: 0,
                child: ComicPortrait(
                  speakerId: leftSpeaker.speakerId,
                  height: 128,
                  mirrored: false,
                  emotion: leftSpeaker.emotion,
                  imagePath: leftSpeaker.imagePath,
                  dimmed: leftSpeaker.speakerId != activeSpeakerId,
                ),
              ),
            if (rightSpeaker != null)
              Positioned(
                right: 2,
                bottom: 0,
                child: ComicPortrait(
                  speakerId: rightSpeaker.speakerId,
                  height: 128,
                  mirrored: true,
                  emotion: rightSpeaker.emotion,
                  imagePath: rightSpeaker.imagePath,
                  dimmed: rightSpeaker.speakerId != activeSpeakerId,
                ),
              ),
            // Contenido: narrador arriba + globos
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...narratorLines.map((l) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: NarratorBox(text: l.text),
                      )),
                  ...speechLines.map((l) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Align(
                          alignment: l.speakerIsLeft
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: l.speakerIsLeft ? 0 : 40,
                              right: l.speakerIsLeft ? 40 : 0,
                            ),
                            child: SpeechBubble(
                              text: l.text,
                              type: l.bubbleType,
                              tail: l.speakerIsLeft
                                  ? TailDirection.downLeft
                                  : TailDirection.downRight,
                              speakerName: l.speakerName,
                              speakerColor: _speakerColor(l.speakerId),
                              maxWidth: 250,
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
            // Onomatopeya
            if (sfx != null)
              Positioned(
                right: 14,
                bottom: 24,
                child: OnomatopoeiaText(sfx, size: 34),
              ),
          ],
        ),
      ),
    );
  }

  Color _speakerColor(String speakerId) {
    final hero = HeroesData.findByIdSafe(speakerId);
    if (hero != null) return factionColor(hero.faction);
    return const Color(0xFF3A1458); // NPCs: violeta Consejo
  }
}
