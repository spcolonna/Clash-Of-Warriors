import 'package:flutter/material.dart';
import 'hero_sprites.dart';

class HeroAvatar extends StatelessWidget {
  final String heroId;
  final double size;

  const HeroAvatar({super.key, required this.heroId, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final bytes = HeroSprites.getBytes(heroId);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFF4A4E5A), Color(0xFF3A3D47), Color(0xFF2D2F38)],
          stops: [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Center(
        child: bytes != null
            ? Image.memory(
                bytes,
                height: size * 0.88,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
              )
            : Text(
                '⚔️',
                style: TextStyle(fontSize: size * 0.4),
              ),
      ),
    );
  }
}
