import 'package:flutter/material.dart';
import '../../../infra/local/heroes_data.dart';
import '../../screens/heroes/character_select_screen.dart' show factionColor;
import 'comic_portrait.dart';
import 'comic_theme.dart';
import 'halftone_painter.dart';

enum CoverState { locked, inProgress, completed, unread }

/// Mini-portada de un "número" (arco) para la estantería del hub.
class ComicCover extends StatelessWidget {
  final String heroId;
  final String title;
  final int actNumber;
  final CoverState state;
  /// Progreso "Pág. X/10" cuando está en curso.
  final int? currentPage;
  final VoidCallback? onTap;
  final double width;

  const ComicCover({
    super.key,
    required this.heroId,
    required this.title,
    required this.actNumber,
    required this.state,
    this.currentPage,
    this.onTap,
    this.width = 118,
  });

  @override
  Widget build(BuildContext context) {
    final hero = HeroesData.findByIdSafe(heroId);
    final color =
        hero != null ? factionColor(hero.faction) : const Color(0xFF3A1458);
    final height = width * 1.5;
    final locked = state == CoverState.locked;

    Widget cover = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: ComicTheme.paper,
        border: Border.all(color: ComicTheme.ink, width: 2.5),
        boxShadow: const [
          BoxShadow(color: Color(0x88141414), offset: Offset(3, 4)),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: SunburstPainter(
                color: color, rays: 14, opacity: locked ? 0.1 : 0.22),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ComicPortrait(speakerId: heroId, height: height * 0.62),
          ),
          // Cabecera: Nº
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: ComicTheme.ink, width: 1.5),
              ),
              child: Text('Nº $actNumber',
                  style: ComicTheme.display(size: 11, color: Colors.white)),
            ),
          ),
          // Título abajo
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: ComicTheme.ink.withValues(alpha: 0.85),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
              child: Text(
                title.toUpperCase(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: ComicTheme.display(size: 10.5, color: ComicTheme.paper)
                    .copyWith(letterSpacing: 0.5, height: 1.05),
              ),
            ),
          ),
          // Estado
          if (state == CoverState.completed)
            Positioned(
              top: height * 0.32,
              left: -6,
              right: -6,
              child: Transform.rotate(
                angle: -0.35,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  color: const Color(0xCC27AE60),
                  child: Text('LEÍDO ✓',
                      textAlign: TextAlign.center,
                      style:
                          ComicTheme.display(size: 14, color: Colors.white)),
                ),
              ),
            ),
          if (state == CoverState.inProgress && currentPage != null)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5B800),
                  border: Border.all(color: ComicTheme.ink, width: 1.5),
                ),
                child: Text('Pág. $currentPage/10',
                    style: ComicTheme.display(size: 9, color: ComicTheme.ink)),
              ),
            ),
          if (locked)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Icon(Icons.lock, color: Colors.white70, size: 28),
              ),
            ),
        ],
      ),
    );

    if (locked) {
      cover = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.3, 0.4, 0.3, 0, 0,
          0.3, 0.4, 0.3, 0, 0,
          0.3, 0.4, 0.3, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: cover,
      );
    }

    return GestureDetector(onTap: onTap, child: cover);
  }
}
