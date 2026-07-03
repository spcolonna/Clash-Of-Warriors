// lib/delivery/screens/story/story_reward_screen.dart
//
// Contratapa del número: héroe desbloqueado con burst + teaser
// "En el próximo número..." como gancho al siguiente acto.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../infra/local/heroes_data.dart';
import '../../../infra/local/story_arcs_data.dart';
import '../../state/providers.dart';
import '../../widgets/comic/chapter_cover.dart' show NarratorBoxWide;
import '../../widgets/comic/comic_page.dart';
import '../../widgets/comic/comic_portrait.dart';
import '../../widgets/comic/comic_theme.dart';
import '../../widgets/comic/halftone_painter.dart';
import '../../widgets/comic/onomatopeia.dart';

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

    // Teaser del próximo número: el arco de la rareza recién desbloqueada
    final baseHeroId = recentlyUnlocked
        ?.replaceAll(RegExp(r'_(rare|epic|legendary)$'), '');
    final nextArc = baseHeroId != null
        ? StoryArcsData.findArc(baseHeroId, rarity)
        : null;

    return Scaffold(
      backgroundColor: ComicTheme.paper,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: SunburstPainter(color: color, rays: 22, opacity: 0.22),
          ),
          CustomPaint(
            painter: HalftonePainter(
              dotColor: color,
              focus: Alignment.topCenter,
              opacity: 0.14,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),
                  OnomatopoeiaText(
                    isLegendaryAchievement
                        ? '¡SAGA COMPLETA!'
                        : '¡NUEVO HÉROE!',
                    size: 40,
                    gradient: [color, ComicTheme.ink],
                  ),
                  const SizedBox(height: 24),
                  if (hero != null) ...[
                    ComicPortrait(speakerId: baseHeroId ?? hero.id, height: 210),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: ComicTheme.ink,
                        boxShadow: [
                          BoxShadow(color: color, offset: const Offset(3, 3)),
                        ],
                      ),
                      child: Text(
                        '${hero.name} — ${hero.title}'.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: ComicTheme.display(
                            size: 18, color: ComicTheme.paper),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _rarityLabels[rarity] ?? rarity,
                      style: ComicTheme.display(size: 14, color: color)
                          .copyWith(shadows: const [
                        Shadow(color: ComicTheme.ink, offset: Offset(1, 1)),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    NarratorBoxWide(text: hero.lore),
                  ] else ...[
                    const Icon(Icons.emoji_events_rounded,
                        color: Color(0xFFB8860B), size: 90),
                    const SizedBox(height: 16),
                    const NarratorBoxWide(
                      text:
                          'Completaste el camino completo de este héroe. Su leyenda ya es parte de La Ciudadela.',
                    ),
                  ],
                  const Spacer(),
                  // Teaser del próximo número
                  if (nextArc != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ComicTheme.ink,
                        border: Border.all(color: color, width: 2),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'EN EL PRÓXIMO NÚMERO...',
                            style: ComicTheme.display(size: 14, color: color),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nextArc.synopsis ?? nextArc.title,
                            textAlign: TextAlign.center,
                            style: ComicTheme.caption(size: 12.5)
                                .copyWith(color: ComicTheme.paper),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  ComicSticker(
                    text: 'CONTINUAR ▸',
                    color: const Color(0xFF27AE60),
                    onTap: () => context.go('/home'),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
