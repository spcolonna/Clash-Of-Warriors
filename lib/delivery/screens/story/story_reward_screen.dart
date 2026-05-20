// lib/delivery/screens/story/story_reward_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../infra/local/heroes_data.dart';
import '../../state/providers.dart';

class StoryRewardScreen extends ConsumerWidget {
  const StoryRewardScreen({super.key});

  static const _rarityColors = {
    'common':    Color(0xFFAAAAAA),
    'rare':      Color(0xFF4FC3F7),
    'epic':      Color(0xFFCE93D8),
    'legendary': Color(0xFFFFD700),
  };

  static const _rarityLabels = {
    'common':    'Común',
    'rare':      'Rara',
    'epic':      'Épica',
    'legendary': 'Legendaria',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);

    // Identificar el héroe recién desbloqueado: el último de la lista que no sea common
    final recentlyUnlocked = player?.unlockedHeroIds
        .where((id) => id.contains('_rare') || id.contains('_epic') || id.contains('_legendary'))
        .lastOrNull;

    final hero = recentlyUnlocked != null
        ? HeroesData.findByIdSafe(recentlyUnlocked)
        : null;

    final isLegendaryAchievement = recentlyUnlocked == null;
    final rarity = hero?.rarity ?? 'legendary';
    final color = _rarityColors[rarity] ?? const Color(0xFFE5A93C);

    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              // Título
              Text(
                isLegendaryAchievement
                    ? '¡LOGRO DESBLOQUEADO!'
                    : '¡HÉROE DESBLOQUEADO!',
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (isLegendaryAchievement)
                const Text(
                  'Camino del Dragón',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 32),
              // Hero card
              if (hero != null) ...[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.6), width: 2),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [color.withValues(alpha: 0.15), const Color(0xFF0D0D1A)],
                    ),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                        child: Image.asset(
                          hero.imagePath,
                          height: 260,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            height: 260,
                            color: color.withValues(alpha: 0.1),
                            child: Icon(Icons.person, color: color, size: 80),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  hero.name,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: color.withValues(alpha: 0.5)),
                                  ),
                                  child: Text(
                                    _rarityLabels[rarity] ?? rarity,
                                    style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hero.title,
                              style: const TextStyle(color: Color(0xFF8A8A9A), fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              hero.lore,
                              style: const TextStyle(
                                color: Color(0xFFD0D0D0),
                                fontSize: 12,
                                height: 1.5,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Achievement visual para Legendary
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFD700), width: 3),
                    gradient: RadialGradient(
                      colors: [const Color(0xFFFFD700).withValues(alpha: 0.2), const Color(0xFF050510)],
                    ),
                  ),
                  child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD700), size: 80),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Completaste el camino completo\nde este héroe.',
                  style: TextStyle(color: Color(0xFF8A8A9A), fontSize: 14, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ],
              const Spacer(),
              // Botón continuar
              GestureDetector(
                onTap: () => context.go('/home'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'CONTINUAR',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: rarity == 'legendary' ? Colors.black : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
