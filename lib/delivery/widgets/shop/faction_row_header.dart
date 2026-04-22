// lib/delivery/widgets/shop/faction_row_header.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FactionRowHeader extends StatelessWidget {
  final String factionId;
  final String factionName;
  final bool isUnlocked;

  const FactionRowHeader({
    super.key,
    required this.factionId,
    required this.factionName,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final color = _factionColor(factionId);
    final emoji = _factionEmoji(factionId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            emoji,
            style: GoogleFonts.notoColorEmoji(
              textStyle: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              factionName,
              style: TextStyle(
                color: isUnlocked ? Colors.white : Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (!isUnlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock, color: Colors.white54, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'BLOQUEADA',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.6), blurRadius: 8),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _factionColor(String id) => switch (id) {
        'shaolin' => const Color(0xFFD4A017),
        'ninja' => const Color(0xFF4A4A6A),
        'judoka' => const Color(0xFF1A5276),
        'boxer' => const Color(0xFFC0392B),
        'capoeira' => const Color(0xFF27AE60),
        _ => Colors.white,
      };

  String _factionEmoji(String id) => switch (id) {
        'shaolin' => '🏯',
        'ninja' => '🥷',
        'judoka' => '🥋',
        'boxer' => '🥊',
        'capoeira' => '💃',
        _ => '⚔️',
      };
}
