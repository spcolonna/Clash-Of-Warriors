// lib/delivery/widgets/tutorial/rps_demo.dart
//
// Demo animada y compacta de la "regla de oro" del combate: en vez de leer
// "Puño gana a Patada…", el jugador VE los choques resolverse en loop. Dos
// fichas entran desde los costados, chocan, el ganador crece con un ✓ y el
// perdedor se desvanece con una ✗. Tap para pasar al siguiente choque.

import 'package:flutter/material.dart';

class RpsDemo extends StatefulWidget {
  const RpsDemo({super.key});

  @override
  State<RpsDemo> createState() => _RpsDemoState();
}

class _Move {
  final String name;
  final IconData icon;
  final Color color;
  const _Move(this.name, this.icon, this.color);
}

class _RpsDemoState extends State<RpsDemo> with SingleTickerProviderStateMixin {
  static const _punch = _Move('PUÑO', Icons.sports_mma, Color(0xFFE74C3C));
  static const _kick = _Move('PATADA', Icons.sports_martial_arts, Color(0xFF2980B9));
  static const _defense = _Move('DEFENSA', Icons.shield, Color(0xFF27AE60));

  // (izquierda = jugador/ganador, derecha = rival/perdedor)
  static const _matchups = <(_Move, _Move)>[
    (_punch, _kick),     // Puño gana a Patada
    (_kick, _defense),   // Patada gana a Defensa
    (_defense, _punch),  // Defensa gana a Puño
  ];

  late final AnimationController _c;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          setState(() => _index = (_index + 1) % _matchups.length);
          _c.forward(from: 0);
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _next() {
    setState(() => _index = (_index + 1) % _matchups.length);
    _c.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final (winner, loser) = _matchups[_index];
    return GestureDetector(
      onTap: _next,
      child: Container(
        height: 172,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            // Fases: entrada (0-.35), choque+flash (.35-.5), veredicto (.5-.85).
            final entry = Curves.easeOut.transform((t / 0.35).clamp(0.0, 1.0));
            final clash = ((t - 0.35) / 0.15).clamp(0.0, 1.0);
            final verdict = Curves.easeOut.transform(((t - 0.5) / 0.35).clamp(0.0, 1.0));

            final leftDx = (1 - entry) * -70 + clash * 12;
            final rightDx = (1 - entry) * 70 - clash * 12;

            final winScale = 1.0 + verdict * 0.18;
            final loseScale = 1.0 - verdict * 0.25;
            final loseOpacity = 1.0 - verdict * 0.7;

            return Stack(
              alignment: Alignment.center,
              children: [
                // Flash del choque
                if (clash > 0 && clash < 1)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white.withValues(
                            alpha: (clash < 0.5 ? clash : 1 - clash) * 0.5),
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: Offset(leftDx, 0),
                      child: Transform.scale(
                        scale: winScale,
                        child: _MoveChip(
                          move: winner,
                          verdict: verdict > 0.3 ? _Verdict.win : _Verdict.none,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text('VS',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 14,
                              fontWeight: FontWeight.w900)),
                    ),
                    Transform.translate(
                      offset: Offset(rightDx, 0),
                      child: Transform.scale(
                        scale: loseScale,
                        child: Opacity(
                          opacity: loseOpacity.clamp(0.0, 1.0),
                          child: _MoveChip(
                            move: loser,
                            verdict: verdict > 0.3 ? _Verdict.lose : _Verdict.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Resultado en texto abajo
                if (verdict > 0.4)
                  Positioned(
                    bottom: 10,
                    child: Opacity(
                      opacity: verdict,
                      child: Text(
                        '${winner.name} gana a ${loser.name}',
                        style: TextStyle(
                          color: winner.color,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                // Puntitos indicadores + hint de tap
                Positioned(
                  top: 8,
                  right: 10,
                  child: Row(
                    children: List.generate(_matchups.length, (i) {
                      return Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _index ? Colors.white : Colors.white24,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

enum _Verdict { none, win, lose }

class _MoveChip extends StatelessWidget {
  final _Move move;
  final _Verdict verdict;

  const _MoveChip({required this.move, required this.verdict});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 20,
          child: switch (verdict) {
            _Verdict.win => const _VerdictTag(text: '✓ GANA', color: Color(0xFF27AE60)),
            _Verdict.lose => const _VerdictTag(text: '✗ PIERDE', color: Color(0xFFE74C3C)),
            _Verdict.none => const SizedBox.shrink(),
          },
        ),
        const SizedBox(height: 4),
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: move.color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: move.color, width: 2),
            boxShadow: verdict == _Verdict.win
                ? [BoxShadow(color: move.color.withValues(alpha: 0.6), blurRadius: 18, spreadRadius: 2)]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(move.icon, color: move.color, size: 34),
              const SizedBox(height: 4),
              Text(move.name,
                  style: TextStyle(color: move.color, fontSize: 11, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerdictTag extends StatelessWidget {
  final String text;
  final Color color;
  const _VerdictTag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }
}
