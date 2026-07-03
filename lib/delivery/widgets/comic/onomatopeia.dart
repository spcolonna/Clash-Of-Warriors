import 'package:flutter/material.dart';
import 'comic_theme.dart';
import 'halftone_painter.dart';

/// Onomatopeya de cómic: texto Bangers con stroke grueso negro y relleno
/// en gradiente, rotado, con entrada scale+fade y burst opcional detrás.
class OnomatopoeiaText extends StatelessWidget {
  final String text;
  final double size;
  final double rotation;
  final List<Color> gradient;
  final bool withBurst;
  final bool animated;

  const OnomatopoeiaText(
    this.text, {
    super.key,
    this.size = 44,
    this.rotation = -0.08,
    this.gradient = const [Color(0xFFFFE14D), Color(0xFFFF7A1A)],
    this.withBurst = false,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Transform.rotate(
      angle: rotation,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (withBurst)
            Positioned.fill(
              left: -30,
              right: -30,
              top: -20,
              bottom: -20,
              child: CustomPaint(
                painter: SunburstPainter(
                  color: gradient.last,
                  rays: 16,
                  opacity: 0.35,
                ),
              ),
            ),
          // Stroke (detrás)
          Text(
            text,
            textAlign: TextAlign.center,
            style: ComicTheme.display(size: size).copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = size * 0.14
                ..strokeJoin = StrokeJoin.round
                ..color = ComicTheme.ink,
            ),
          ),
          // Relleno con gradiente
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: gradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: ComicTheme.display(size: size, color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (!animated) return content;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Transform.scale(
        scale: 1.6 - 0.6 * t.clamp(0.0, 1.0),
        child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
      ),
      child: content,
    );
  }
}
