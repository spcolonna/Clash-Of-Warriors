// lib/delivery/widgets/deck_counter_widget.dart

import 'package:flutter/material.dart';

class DeckCounterWidget extends StatelessWidget {
  final int remaining;
  final int total;

  const DeckCounterWidget({
    super.key,
    required this.remaining,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stack de cartitas (visual del mazo)
          SizedBox(
            width: 18,
            height: 22,
            child: Stack(
              children: [
                for (int i = 0; i < 3; i++)
                  Positioned(
                    left: i * 2.0,
                    top: i * 1.0,
                    child: Container(
                      width: 12,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15 + i * 0.15),
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: Colors.white38, width: 0.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$remaining/$total',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}