import 'package:flutter/material.dart';
import '../../../domain/entities/story_arc.dart';
import '../../../infra/local/heroes_data.dart';
import '../../screens/heroes/character_select_screen.dart' show factionColor;
import 'comic_portrait.dart';
import 'comic_theme.dart';
import 'halftone_painter.dart';
import 'comic_page.dart';

/// Portada de capítulo estilo comic-book: burst radial, retrato del héroe,
/// título gigante, banda de acto y "Nº" en la esquina.
/// Con [resumeSynopsis] se muestra la variante "Anteriormente..." al reanudar.
class ChapterCover extends StatelessWidget {
  final StoryArc arc;
  final VoidCallback onContinue;
  /// Si no es null, se muestra como recap "ANTERIORMENTE..." en vez de portada.
  final String? resumeSynopsis;

  const ChapterCover({
    super.key,
    required this.arc,
    required this.onContinue,
    this.resumeSynopsis,
  });

  @override
  Widget build(BuildContext context) {
    final hero = HeroesData.findByIdSafe(arc.heroId);
    final color =
        hero != null ? factionColor(hero.faction) : const Color(0xFF3A1458);
    final isResume = resumeSynopsis != null;

    return GestureDetector(
      onTap: onContinue,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: ComicTheme.paper,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Arte de portada real (hook) o render procedural
            if (arc.coverImagePath != null)
              Image.asset(
                arc.coverImagePath!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              )
            else ...[
              CustomPaint(
                painter: SunburstPainter(
                    color: color.withValues(alpha: 0.85), rays: 22, opacity: 0.28),
              ),
              CustomPaint(
                painter: HalftonePainter(
                  dotColor: color,
                  focus: Alignment.topLeft,
                  opacity: 0.18,
                ),
              ),
            ],

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Cabecera comic-book: serie + número
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'CLASH OF WARRIORS',
                            style: ComicTheme.display(size: 15)
                                .copyWith(letterSpacing: 3),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: color,
                            border:
                                Border.all(color: ComicTheme.ink, width: 2.5),
                          ),
                          child: Text(
                            'Nº ${arc.actNumber}',
                            style: ComicTheme.display(
                                size: 17, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (isResume) ...[
                      Text('ANTERIORMENTE...',
                          style: ComicTheme.display(size: 30, color: color)),
                      const SizedBox(height: 16),
                      NarratorBoxWide(text: resumeSynopsis!),
                      const SizedBox(height: 24),
                      ComicPortrait(speakerId: arc.heroId, height: 170),
                    ] else ...[
                      ComicPortrait(speakerId: arc.heroId, height: 230),
                      const SizedBox(height: 18),
                      // Banda de acto
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 4),
                        color: ComicTheme.ink,
                        child: Text(
                          'ACTO ${_roman(arc.actNumber)}',
                          style: ComicTheme.display(
                              size: 16, color: ComicTheme.paper),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        arc.title.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: ComicTheme.display(size: 42).copyWith(
                          shadows: [
                            Shadow(color: color, offset: const Offset(3, 3)),
                          ],
                        ),
                      ),
                      if (arc.coverSubtitle != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          arc.coverSubtitle!,
                          textAlign: TextAlign.center,
                          style: ComicTheme.caption(size: 14),
                        ),
                      ],
                    ],
                    const Spacer(),
                    ComicSticker(
                      text: isResume ? 'CONTINUAR ▸' : '¡EMPEZAR! ▸',
                      color: color,
                      onTap: onContinue,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _roman(int n) => switch (n) {
        1 => 'I',
        2 => 'II',
        3 => 'III',
        4 => 'IV',
        _ => '$n',
      };
}

/// Caja de narrador ancha para portadas/recaps.
class NarratorBoxWide extends StatelessWidget {
  final String text;
  const NarratorBoxWide({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ComicTheme.narratorBg,
        border: Border.all(color: ComicTheme.ink, width: 2.5),
        boxShadow: const [
          BoxShadow(color: ComicTheme.ink, offset: Offset(4, 4)),
        ],
      ),
      child: Text(text,
          textAlign: TextAlign.center, style: ComicTheme.caption(size: 14)),
    );
  }
}
