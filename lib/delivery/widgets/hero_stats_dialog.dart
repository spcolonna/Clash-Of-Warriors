// lib/delivery/widgets/hero_stats_dialog.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/hero_entity.dart';
import '../screens/heroes/character_select_screen.dart'; // factionColor, factionEmoji, factionName

class HeroStatsDialog extends StatelessWidget {
  final HeroEntity hero;
  final int currentHp;
  final int currentStamina;

  const HeroStatsDialog({
    super.key,
    required this.hero,
    required this.currentHp,
    required this.currentStamina,
  });

  static Future<void> show(
      BuildContext context, {
        required HeroEntity hero,
        required int currentHp,
        required int currentStamina,
      }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (_) => HeroStatsDialog(
        hero: hero,
        currentHp: currentHp,
        currentStamina: currentStamina,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = factionColor(hero.faction);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.5), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar + nombre
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        hero.imagePath,
                        fit: BoxFit.fill,
                        errorBuilder: (_, __, ___) => Container(
                          color: color.withOpacity(0.15),
                          child: Center(
                            child: Text(
                              factionEmoji(hero.faction),
                              style: GoogleFonts.notoColorEmoji(
                                textStyle: const TextStyle(fontSize: 60),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Gradiente para que el nombre se lea
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hero.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              hero.title,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Badge de facción
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: color.withOpacity(0.6)),
                          ),
                          child: Text(
                            factionName(hero.faction),
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // HP y Stamina actuales
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: _CurrentStatBar(
                        label: 'HP',
                        emoji: '❤️',
                        current: currentHp,
                        max: hero.maxHp,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CurrentStatBar(
                        label: 'ST',
                        emoji: '⚡',
                        current: currentStamina,
                        max: hero.maxStamina,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),

              // Stats del héroe
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  children: [
                    _StatRow(label: 'Puño',    value: hero.stats.punch,   max: 12, color: color),
                    const SizedBox(height: 6),
                    _StatRow(label: 'Patada',  value: hero.stats.kick,    max: 12, color: color),
                    const SizedBox(height: 6),
                    _StatRow(label: 'Agarre',  value: hero.stats.grapple, max: 12, color: color),
                    const SizedBox(height: 6),
                    _StatRow(label: 'Defensa', value: hero.stats.defense, max: 12, color: color),
                    const SizedBox(height: 6),
                    _StatRow(label: 'Esquive', value: hero.stats.dodge,   max: 12, color: color),
                  ],
                ),
              ),

              // Cerrar
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Cerrar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrentStatBar extends StatelessWidget {
  final String label;
  final String emoji;
  final int current;
  final int max;
  final Color color;

  const _CurrentStatBar({
    required this.label,
    required this.emoji,
    required this.current,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              emoji,
              style: GoogleFonts.notoColorEmoji(
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$current / $max',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: (current / max).clamp(0.0, 1.0),
            minHeight: 5,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / max,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}