// lib/delivery/widgets/surrender_dialog.dart
//
// Confirmación de abandono de combate. Mismo lenguaje visual que
// LevelUpDialog/RankUpDialog (entrada elástica + glow + borde de color) pero
// en clave de advertencia: rojo, ícono de bandera y aviso explícito de que
// rendirse NO paga monedas de consolación.

import 'package:flutter/material.dart';
import '../../infra/services/haptics_service.dart';

class SurrenderDialog extends StatelessWidget {
  const SurrenderDialog({super.key});

  /// Devuelve true si el jugador confirmó la rendición.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (_) => const SurrenderDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    const danger = Color(0xFFE74C3C);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, v, child) =>
            Transform.scale(scale: v.clamp(0.0, 1.15), child: child),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
          decoration: BoxDecoration(
            color: const Color(0xFF16100F),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: danger, width: 2),
            boxShadow: [
              BoxShadow(
                  color: danger.withValues(alpha: 0.45),
                  blurRadius: 24,
                  spreadRadius: 2),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ABANDONAR COMBATE',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: danger.withValues(alpha: 0.12),
                  border: Border.all(color: danger.withValues(alpha: 0.5), width: 2),
                ),
                child: const Icon(Icons.flag_rounded, size: 36, color: danger),
              ),
              const SizedBox(height: 18),
              const Text(
                '¿Tirás la toalla?',
                style: TextStyle(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              const Text(
                'Vas a perder esta batalla al instante.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.35),
              ),
              const SizedBox(height: 14),
              // Aviso de costo real: rendirse no paga consolación.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: danger.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: danger.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.money_off_rounded, size: 18, color: danger),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Sin monedas de consolación:\nesas se ganan peleando.',
                        style: TextStyle(
                            color: danger, fontSize: 12.5, height: 1.3,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        HapticsService().light();
                        Navigator.of(context).pop(false);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Seguir peleando',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13.5)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        HapticsService().medium();
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: danger,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Rendirme',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13.5)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
