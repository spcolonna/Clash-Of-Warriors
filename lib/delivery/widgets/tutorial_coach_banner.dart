import 'package:flutter/material.dart';
import '../../infra/services/haptics_service.dart';

/// Banner de coaching del tutorial: el "Maestro" guía la primera batalla
/// paso a paso. Se muestra sobre la arena; cada paso se descarta con OK.
class TutorialCoachBanner extends StatelessWidget {
  final String text;
  final VoidCallback onDismiss;

  const TutorialCoachBanner({
    super.key,
    required this.text,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF5B800);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Transform.translate(
        offset: Offset(0, -20 * (1 - t)),
        child: Opacity(opacity: t, child: child),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: gold.withValues(alpha: 0.7), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(color: gold.withValues(alpha: 0.15), blurRadius: 16),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar del maestro
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: gold, width: 1.5),
              ),
              child: const Icon(Icons.school, color: gold, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MAESTRO',
                    style: TextStyle(
                      color: gold,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {
                HapticsService().light();
                onDismiss();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
