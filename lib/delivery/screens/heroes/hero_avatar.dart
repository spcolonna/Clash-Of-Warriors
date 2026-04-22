import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class HeroAvatar extends StatelessWidget {
  final String emoji;
  final Color color;
  final double size;
  final String? imagePath;

  const HeroAvatar({super.key, 
    required this.emoji,
    required this.color,
    this.size = 60,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.5), width: 2),
        boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 10)],
      ),
      child: ClipOval(
        child: imagePath != null
            ? Image.asset(
          imagePath!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Text(
              emoji,
              style: GoogleFonts.notoColorEmoji(
                textStyle: TextStyle(fontSize: size * 0.5),
              ),
            ),
          ),
        )
            : Center(
          child: Text(
            emoji,
            style: GoogleFonts.notoColorEmoji(
              textStyle: TextStyle(fontSize: size * 0.5),
            ),
          ),
        ),
      ),
    );
  }
}