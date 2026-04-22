import 'package:flutter/material.dart';
import '../../domain/entities/technique.dart';

class StatBar extends StatelessWidget {
  final Technique technique;
  final int value;
  final int maxValue;

  const StatBar({
    super.key,
    required this.technique,
    required this.value,
    this.maxValue = 5,
  });

  @override
  Widget build(BuildContext context) {
    final data = TechniqueRegistry.get(technique);
    final color = Color(data.colorHex);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text(data.icon, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (value / maxValue).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}
