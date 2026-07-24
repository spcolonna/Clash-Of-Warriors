// lib/delivery/widgets/reward_feedback.dart
//
// Feedback corto y reutilizable al reclamar una recompensa (misión, hito,
// progreso): sonido + haptic + un banner central que aparece con overshoot y
// se desvanece solo. No bloquea la UI (va por Overlay, se auto-remueve).

import 'package:flutter/material.dart';
import '../../infra/services/haptics_service.dart';
import '../../infra/sound/sound_service.dart';

/// Dispara la celebración de recompensa. [label] es el texto grande (ej.
/// "¡RECOMPENSA!"), [detail] el subtítulo opcional (ej. "+150 monedas").
void showRewardBurst(BuildContext context, {required String label, String? detail}) {
  SoundService().play('coin');
  HapticsService().success();

  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _RewardBurst(label: label, detail: detail, onDone: () => entry.remove()),
  );
  overlay.insert(entry);
}

class _RewardBurst extends StatefulWidget {
  final String label;
  final String? detail;
  final VoidCallback onDone;

  const _RewardBurst({required this.label, this.detail, required this.onDone});

  @override
  State<_RewardBurst> createState() => _RewardBurstState();
}

class _RewardBurstState extends State<_RewardBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final t = _c.value;
              final scale = Curves.elasticOut.transform((t / 0.5).clamp(0.0, 1.0));
              final opacity = t < 0.6 ? 1.0 : (1 - (t - 0.6) / 0.4).clamp(0.0, 1.0);
              return Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: 0.6 + 0.4 * scale,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14100C).withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF5B800), width: 2),
                      boxShadow: const [
                        BoxShadow(color: Color(0x66F5B800), blurRadius: 20, spreadRadius: 1),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          style: const TextStyle(
                            color: Color(0xFFF5B800),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        if (widget.detail != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.detail!,
                            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
