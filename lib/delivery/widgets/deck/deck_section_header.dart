// lib/delivery/widgets/deck/deck_section_header.dart

import 'package:flutter/material.dart';

class DeckSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const DeckSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF8A8A9A),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
