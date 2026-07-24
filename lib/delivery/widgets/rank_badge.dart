// lib/delivery/widgets/rank_badge.dart
//
// Badge de rango derivado de battlePoints. Dos formas: compacta (chip con
// ícono + nombre) para el header del home, y completa (con barra de progreso
// al siguiente rango) para el perfil/ajustes.

import 'package:flutter/material.dart';
import '../../domain/config/rank_ladder.dart';

class RankBadge extends StatelessWidget {
  final int battlePoints;
  final bool compact;

  const RankBadge({super.key, required this.battlePoints, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final rank = RankLadder.rankFor(battlePoints);

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: rank.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: rank.color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(rank.icon, size: 14, color: rank.color),
            const SizedBox(width: 5),
            Text(
              rank.name,
              style: TextStyle(
                color: rank.color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    final next = RankLadder.nextRank(battlePoints);
    final progress = RankLadder.progress(battlePoints);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: rank.color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(rank.icon, size: 22, color: rank.color),
              const SizedBox(width: 8),
              Text(
                rank.name,
                style: TextStyle(
                  color: rank.color,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                '$battlePoints pts',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation(rank.color),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            next == null
                ? 'Rango máximo alcanzado'
                : 'Faltan ${next.minPoints - battlePoints} pts para ${next.name}',
            style: const TextStyle(color: Color(0xFF8A8A9A), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

/// Overlay celebratorio al ascender de rango. Se muestra con showDialog.
class RankUpDialog extends StatelessWidget {
  final Rank newRank;

  const RankUpDialog({super.key, required this.newRank});

  static Future<void> show(BuildContext context, Rank newRank) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (_) => RankUpDialog(newRank: newRank),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            border: Border.all(color: newRank.color, width: 2),
            boxShadow: [
              BoxShadow(color: newRank.color.withValues(alpha: 0.5), blurRadius: 24, spreadRadius: 2),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ASCENSO DE RANGO',
                style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 3, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Icon(newRank.icon, size: 72, color: newRank.color),
              const SizedBox(height: 16),
              Text(
                newRank.name,
                style: TextStyle(color: newRank.color, fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: newRank.color,
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
