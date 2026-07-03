import 'package:flutter/material.dart';
import 'comic_theme.dart';

/// "Página" de cómic: papel crema con textura sutil que contiene las
/// viñetas apiladas verticalmente (lectura tipo webtoon, ideal en mobile).
class ComicPage extends StatelessWidget {
  /// Cinta negra con el nombre de la locación (caption de apertura).
  final String? locationLabel;
  final List<Widget> panels;
  final ScrollController? controller;
  final EdgeInsets padding;

  const ComicPage({
    super.key,
    this.locationLabel,
    required this.panels,
    this.controller,
    this.padding = const EdgeInsets.fromLTRB(14, 12, 14, 120),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ComicTheme.paper, Color(0xFFE6DCC4)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ListView(
        controller: controller,
        padding: padding,
        children: [
          if (locationLabel != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: const BoxDecoration(
                  color: ComicTheme.ink,
                  boxShadow: [
                    BoxShadow(color: Color(0x44141414), offset: Offset(2, 3)),
                  ],
                ),
                child: Text(
                  locationLabel!.toUpperCase(),
                  style: ComicTheme.display(size: 16, color: ComicTheme.paper),
                ),
              ),
            ),
          ...panels.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: p,
              )),
        ],
      ),
    );
  }
}

/// Sello/etiqueta estilo sticker de cómic (botones, badges).
class ComicSticker extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback? onTap;
  final double fontSize;

  const ComicSticker({
    super.key,
    required this.text,
    this.color = const Color(0xFFE74C3C),
    this.onTap,
    this.fontSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    final sticker = Transform.rotate(
      angle: -0.03,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
        decoration: BoxDecoration(
          color: onTap == null ? color.withValues(alpha: 0.45) : color,
          border: Border.all(color: ComicTheme.ink, width: 3),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(color: ComicTheme.ink, offset: Offset(4, 4)),
          ],
        ),
        child: Text(
          text,
          style: ComicTheme.display(size: fontSize, color: Colors.white),
        ),
      ),
    );

    if (onTap == null) return sticker;
    return GestureDetector(onTap: onTap, child: sticker);
  }
}
