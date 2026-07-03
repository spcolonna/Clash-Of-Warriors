import 'package:flutter/material.dart';

/// Banner animado central: entra con zoom + slide, se sostiene un instante
/// y sale con fade. ~1.2s en total. Usado para "RONDA N", "¡RONDA PERFECTA!",
/// etc.
class RoundBanner extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback onComplete;

  const RoundBanner({
    super.key,
    required this.title,
    this.subtitle = '¡PELEA!',
    required this.onComplete,
  });

  @override
  State<RoundBanner> createState() => _RoundBannerState();
}

class _RoundBannerState extends State<RoundBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          // Entrada 0-0.2 · hold 0.2-0.75 · salida 0.75-1.0
          final inT = Curves.easeOutBack.transform((t / 0.2).clamp(0.0, 1.0));
          final outT = ((t - 0.75) / 0.25).clamp(0.0, 1.0);
          final opacity = (inT * (1 - outT)).clamp(0.0, 1.0);
          final scale = 0.6 + inT * 0.4 + outT * 0.3;

          return Opacity(
            opacity: opacity,
            child: Center(
              child: Transform.scale(
                scale: scale,
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
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withValues(alpha: 0.85),
                        letterSpacing: 6,
                        shadows: const [
                          Shadow(color: Colors.black, blurRadius: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
