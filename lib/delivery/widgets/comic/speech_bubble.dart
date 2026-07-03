import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/story_arc.dart' show BubbleType;
import 'comic_theme.dart';

enum TailDirection { downLeft, downRight, none }

/// Globo de diálogo estilo cómic con cola apuntando al personaje.
/// Cuatro variantes: speech (normal), shout (spiky), thought (nube),
/// whisper (borde punteado).
class SpeechBubble extends StatelessWidget {
  final String text;
  final BubbleType type;
  final TailDirection tail;
  /// Nombre del speaker (tab sobre el globo). Null = sin tab.
  final String? speakerName;
  final Color speakerColor;
  final double maxWidth;

  const SpeechBubble({
    super.key,
    required this.text,
    this.type = BubbleType.speech,
    this.tail = TailDirection.downLeft,
    this.speakerName,
    this.speakerColor = ComicTheme.ink,
    this.maxWidth = 280,
  });

  @override
  Widget build(BuildContext context) {
    final bubble = CustomPaint(
      painter: _BubblePainter(type: type, tail: tail),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: EdgeInsets.fromLTRB(
          14,
          10,
          14,
          tail == TailDirection.none ? 10 : 24,
        ),
        child: Text(
          text,
          style: ComicTheme.speech(
            size: type == BubbleType.shout ? 14.5 : 13.5,
          ).copyWith(
            fontStyle:
                type == BubbleType.whisper ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );

    if (speakerName == null) return bubble;

    return Column(
      crossAxisAlignment: tail == TailDirection.downRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: speakerColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6)),
              border: Border.all(color: ComicTheme.ink, width: 2),
            ),
            child: Text(
              speakerName!.toUpperCase(),
              style: ComicTheme.display(size: 13, color: Colors.white),
            ),
          ),
        ),
        bubble,
      ],
    );
  }
}

class _BubblePainter extends CustomPainter {
  final BubbleType type;
  final TailDirection tail;

  const _BubblePainter({required this.type, required this.tail});

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = Colors.white;
    final stroke = Paint()
      ..color = ComicTheme.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;

    final bodyH = tail == TailDirection.none ? size.height : size.height - 14;
    final body = Rect.fromLTWH(0, 0, size.width, bodyH);

    final path = switch (type) {
      BubbleType.shout => _spikyPath(body),
      BubbleType.thought => _cloudPath(body),
      _ => (Path()
        ..addRRect(RRect.fromRectAndRadius(body, const Radius.circular(14)))),
    };

    // Cola
    if (tail != TailDirection.none && type != BubbleType.thought) {
      final tx = tail == TailDirection.downLeft
          ? size.width * 0.22
          : size.width * 0.78;
      final tip = tail == TailDirection.downLeft ? tx - 16 : tx + 16;
      path.moveTo(tx - 8, bodyH - 1);
      path.quadraticBezierTo(tx, bodyH + 8, tip, size.height);
      path.quadraticBezierTo(tx + 4, bodyH + 6, tx + 10, bodyH - 1);
      path.close();
    }

    canvas.drawPath(path, fill);
    if (type == BubbleType.whisper) {
      _drawDashed(canvas, path, stroke);
    } else {
      canvas.drawPath(path, stroke);
    }

    // Burbujas de pensamiento hacia el personaje
    if (type == BubbleType.thought && tail != TailDirection.none) {
      final tx = tail == TailDirection.downLeft
          ? size.width * 0.2
          : size.width * 0.8;
      for (int i = 0; i < 3; i++) {
        final r = 4.0 - i * 1.1;
        final c = Offset(
          tx + (tail == TailDirection.downLeft ? -1 : 1) * i * 7.0,
          bodyH + 3 + i * 5.0,
        );
        canvas.drawCircle(c, r, fill);
        canvas.drawCircle(c, r, stroke..strokeWidth = 1.8);
      }
    }
  }

  Path _spikyPath(Rect body) {
    final path = Path();
    const spikes = 14;
    final cx = body.center.dx, cy = body.center.dy;
    final rx = body.width / 2, ry = body.height / 2;
    for (int i = 0; i < spikes * 2; i++) {
      final angle = i * math.pi / spikes;
      final f = i.isEven ? 1.12 : 0.88;
      final x = cx + math.cos(angle) * rx * f;
      final y = cy + math.sin(angle) * ry * f;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  Path _cloudPath(Rect body) {
    final path = Path();
    const bumps = 8;
    // aproximación: rrect + arcos superpuestos en el borde
    path.addRRect(
        RRect.fromRectAndRadius(body.deflate(4), const Radius.circular(18)));
    for (int i = 0; i < bumps; i++) {
      final t = i / bumps;
      final angle = t * 2 * math.pi;
      final cx = body.center.dx + math.cos(angle) * body.width * 0.42;
      final cy = body.center.dy + math.sin(angle) * body.height * 0.38;
      path.addOval(Rect.fromCircle(
          center: Offset(cx, cy),
          radius: 8 + (i.isEven ? 4 : 0)));
    }
    return path;
  }

  void _drawDashed(Canvas canvas, Path path, Paint stroke) {
    const dash = 6.0, gap = 4.0;
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(
            metric.extractPath(d, math.min(d + dash, metric.length)), stroke);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter old) =>
      old.type != type || old.tail != tail;
}

/// Caja de narrador: rectángulo amarillo-crema con borde negro,
/// convención clásica de cómic para la voz en off.
class NarratorBox extends StatelessWidget {
  final String text;
  final double maxWidth;

  const NarratorBox({super.key, required this.text, this.maxWidth = 320});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ComicTheme.narratorBg,
        border: Border.all(color: ComicTheme.ink, width: 2.5),
        boxShadow: const [
          BoxShadow(color: ComicTheme.ink, offset: Offset(3, 3)),
        ],
      ),
      child: Text(text, style: ComicTheme.caption()),
    );
  }
}
