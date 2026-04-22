import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HpBar extends StatelessWidget {
  final int hp;
  final int maxHp;
  final double height;
  final bool showText;

  const HpBar({
    super.key,
    required this.hp,
    required this.maxHp,
    this.height = 10,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (hp / maxHp).clamp(0.0, 1.0);
    final color = hpColor(hp, maxHp);

    return Row(
      children: [
        if (showText)
          Text(
            '$hp',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color),
          ),
        if (showText) const SizedBox(width: 6),
        Expanded(
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(height / 2),
            ),
            child: AnimatedFractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: pct,
              duration: const Duration(milliseconds: 500),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
