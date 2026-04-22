import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

class MiniChip extends StatelessWidget {
  final String icon;
  final String value;

  const MiniChip({super.key, required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            icon,
            style: GoogleFonts.notoColorEmoji(
              textStyle: const TextStyle(fontSize: 9),
            ),
          ),
          const SizedBox(width: 2),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}