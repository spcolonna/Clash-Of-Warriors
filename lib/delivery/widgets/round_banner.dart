import 'package:flutter/material.dart';

/// Banner animado central: entra con zoom + slide, se sostiene y sale con fade.
/// Usado para "RONDA N", "¡RONDA PERFECTA!", combos, eventos de ring, etc.
///
/// La entrada y la salida son de duración FIJA (240/300ms): lo que se estira
/// con [duration] es el hold, o sea el tiempo real de lectura. Los banners que
/// explican una mecánica (combo, evento, pasiva) usan [readable] para que se
/// puedan leer sin apuro; el de "RONDA N" se queda con el default corto.
class RoundBanner extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback onComplete;
  final Duration duration;

  /// Duración pensada para banners con información que hay que leer.
  static const readable = Duration(milliseconds: 2600);

  const RoundBanner({
    super.key,
    required this.title,
    this.subtitle = '¡PELEA!',
    required this.onComplete,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<RoundBanner> createState() => _RoundBannerState();
}

class _RoundBannerState extends State<RoundBanner>
    with SingleTickerProviderStateMixin {
  static const _entryMs = 240;
  static const _exitMs = 300;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward().then((_) {
        if (mounted) widget.onComplete();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Subtítulos largos (descripciones de evento) necesitan menos tracking y
    // menos cuerpo para entrar en pantalla y leerse cómodos.
    final longSubtitle = widget.subtitle.length > 24;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final totalMs = widget.duration.inMilliseconds;
          final ms = _controller.value * totalMs;
          final inT = Curves.easeOutBack.transform((ms / _entryMs).clamp(0.0, 1.0));
          final outT = ((ms - (totalMs - _exitMs)) / _exitMs).clamp(0.0, 1.0);
          final opacity = (inT.clamp(0.0, 1.0) * (1 - outT)).clamp(0.0, 1.0);
          final scale = 0.6 + inT * 0.4 + outT * 0.3;

          return Opacity(
            opacity: opacity,
            child: Center(
              child: Transform.scale(
                scale: scale,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0),
                              Colors.black.withValues(alpha: 0.75),
                              Colors.black.withValues(alpha: 0),
                            ],
                          ),
                        ),
                        // Los nombres de combo largos se achican en vez de
                        // desbordar la pantalla.
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFFF6B35), Color(0xFFE5A93C)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 4,
                                shadows: [
                                  Shadow(color: Colors.black, blurRadius: 12),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: longSubtitle ? 15 : 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withValues(alpha: 0.92),
                          letterSpacing: longSubtitle ? 0.5 : 6,
                          height: longSubtitle ? 1.35 : 1.0,
                          shadows: const [
                            Shadow(color: Colors.black, blurRadius: 8),
                            Shadow(color: Colors.black, blurRadius: 3),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
