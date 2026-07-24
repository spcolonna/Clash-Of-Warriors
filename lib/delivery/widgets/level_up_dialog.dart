// lib/delivery/widgets/level_up_dialog.dart
//
// Celebración genérica de "subiste de nivel de cuenta". Mismo lenguaje visual
// que RankUpDialog (elastic + glow) pero para el nivel de cuenta, que hoy sube
// en silencio. Reutilizable para cualquier level-up simple.

import 'package:flutter/material.dart';

class LevelUpDialog extends StatelessWidget {
  final int newLevel;
  final int coinsReward;

  const LevelUpDialog({super.key, required this.newLevel, this.coinsReward = 0});

  static Future<void> show(BuildContext context,
      {required int newLevel, int coinsReward = 0}) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (_) => LevelUpDialog(newLevel: newLevel, coinsReward: coinsReward),
    );
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        builder: (context, v, child) =>
            Transform.scale(scale: v.clamp(0.0, 1.2), child: child),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF14100C),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: gold, width: 2),
            boxShadow: [
              BoxShadow(color: gold.withValues(alpha: 0.5), blurRadius: 24, spreadRadius: 2),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SUBISTE DE NIVEL',
                style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 3, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.shield, size: 84, color: gold),
                  Text(
                    '$newLevel',
                    style: const TextStyle(color: Color(0xFF14100C), fontSize: 30, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Nivel de cuenta $newLevel',
                style: const TextStyle(color: gold, fontSize: 20, fontWeight: FontWeight.w900),
              ),
              if (coinsReward > 0) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on, size: 16, color: Color(0xFFF5B800)),
                    const SizedBox(width: 6),
                    Text('+$coinsReward monedas',
                        style: const TextStyle(color: Color(0xFFF5B800), fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('¡Seguir!', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
