// lib/delivery/screens/story/story_hub_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/hero_entity.dart';
import '../../../domain/entities/player_profile.dart';
import '../../../infra/local/heroes_data.dart';
import '../../../infra/local/story_arcs_data.dart';
import '../../../infra/services/haptics_service.dart';
import '../../../infra/sound/sound_service.dart';
import '../../state/providers.dart';
import '../../state/story_provider.dart';
import '../../widgets/comic/comic_cover.dart';
import '../shell/main_shell_scaffold.dart';

class StoryHubScreen extends ConsumerWidget {
  const StoryHubScreen({super.key});

  static const _heroIds = ['puo_liu', 'kage', 'ryoto', 'kai', 'mila'];

  static const _factionColors = {
    Faction.shaolin:  Color(0xFFE5A93C),
    Faction.ninja:    Color(0xFF7B68EE),
    Faction.judoka:   Color(0xFF4FC3F7),
    Faction.boxer:    Color(0xFFEF5350),
    Faction.capoeira: Color(0xFF66BB6A),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Modo Historia',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'La Ciudadela espera. Cada héroe tiene su camino.',
                style: TextStyle(color: Color(0xFF8A8A9A), fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: _heroIds.length,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (ctx, i) {
                  final heroId = _heroIds[i];
                  final hero = HeroesData.findByIdSafe(heroId);
                  if (hero == null) return const SizedBox.shrink();

                  final isUnlocked = player?.unlockedHeroIds.contains(heroId) ?? false;
                  final color = _factionColors[hero.faction] ?? const Color(0xFFE5A93C);

                  return _HeroSeriesShelf(
                    hero: hero,
                    color: color,
                    player: player,
                    isUnlocked: isUnlocked,
                    onPlay: (rarity) => _startArc(context, ref, heroId, rarity),
                    onLocked: () => _showLockedDialog(context, ref, hero, color),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startArc(BuildContext context, WidgetRef ref, String heroId, String rarity) {
    final started = ref.read(storySessionProvider.notifier).startArc(heroId, rarity);
    if (started) context.push('/story-scene');
  }

  void _showLockedDialog(BuildContext context, WidgetRef ref, HeroEntity hero, Color color) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _LockedHeroDialog(hero: hero, color: color, ref: ref),
    );
  }
}

// ─── Locked Hero Dialog ───────────────────────────────────────────────────────

class _LockedHeroDialog extends StatelessWidget {
  final HeroEntity hero;
  final Color color;
  final WidgetRef ref;

  const _LockedHeroDialog({
    required this.hero,
    required this.color,
    required this.ref,
  });

  static const _rarityLabels = {
    'common': 'Común', 'rare': 'Rara', 'epic': 'Épica', 'legendary': 'Legendaria',
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Portrait con overlay de candado
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      0.33, 0.33, 0.33, 0, 0,
                      0.33, 0.33, 0.33, 0, 0,
                      0.33, 0.33, 0.33, 0, 0,
                      0,    0,    0,    1, 0,
                    ]),
                    child: Image.asset(
                      hero.imagePath,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 220,
                        color: color.withValues(alpha: 0.1),
                        child: Icon(Icons.person, color: color, size: 80),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, const Color(0xFF1A1A2E).withValues(alpha: 0.7)],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 1.5),
                  ),
                  child: const Icon(Icons.lock_rounded, color: Colors.white70, size: 36),
                ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                          color: const Color(0xFFAAAAAA).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFAAAAAA).withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          _rarityLabels['common']!,
                          style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hero.title,
                    style: const TextStyle(color: Color(0xFF8A8A9A), fontSize: 13),
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 20),
                  // Botón tienda
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ref.read(activeTabProvider.notifier).state = 1;
                      },
                      icon: const Icon(Icons.store_rounded, size: 18),
                      label: const Text(
                        'Ir a la Tienda',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar', style: TextStyle(color: Color(0xFF8A8A9A))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero Series Shelf ────────────────────────────────────────────────────────

/// Serie de cómics de un héroe: título de la serie + carrusel horizontal de
/// 4 números (Acto I–IV = common/rare/epic/legendary).
class _HeroSeriesShelf extends StatelessWidget {
  final HeroEntity hero;
  final Color color;
  final PlayerProfile? player;
  final bool isUnlocked;
  final void Function(String rarity) onPlay;
  final VoidCallback onLocked;

  const _HeroSeriesShelf({
    required this.hero,
    required this.color,
    required this.player,
    required this.isUnlocked,
    required this.onPlay,
    required this.onLocked,
  });

  static const _rarities = ['common', 'rare', 'epic', 'legendary'];

  @override
  Widget build(BuildContext context) {
    final nextRarity =
        isUnlocked ? player?.nextPlayableRarity(hero.id) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la serie
        Row(
          children: [
            Container(width: 4, height: 18, color: color),
            const SizedBox(width: 8),
            Text(
              '${hero.name.toUpperCase()} — ${_seriesName(hero.id)}',
              style: TextStyle(
                color: isUnlocked ? Colors.white : const Color(0xFF6A6A7A),
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            if (!isUnlocked) ...[
              const SizedBox(width: 8),
              const Icon(Icons.lock_rounded, color: Colors.white38, size: 14),
            ],
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 118 * 1.5 + 8,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _rarities.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (ctx, i) {
              final rarity = _rarities[i];
              final arc = StoryArcsData.findArc(hero.id, rarity);
              final complete =
                  player?.isArcComplete(hero.id, rarity) ?? false;
              final stagesDone =
                  (player?.storyStageFor(hero.id, rarity) ?? -1) + 1;

              final CoverState state;
              if (!isUnlocked) {
                state = CoverState.locked;
              } else if (complete) {
                state = CoverState.completed;
              } else if (rarity == nextRarity && stagesDone > 0) {
                state = CoverState.inProgress;
              } else if (rarity == nextRarity) {
                state = CoverState.unread;
              } else {
                state = CoverState.locked;
              }

              return ComicCover(
                heroId: hero.id,
                title: arc?.title ?? '—',
                actNumber: arc?.actNumber ?? (i + 1),
                state: state,
                currentPage:
                    state == CoverState.inProgress ? stagesDone : null,
                onTap: () {
                  if (!isUnlocked) {
                    onLocked();
                    return;
                  }
                  if (state == CoverState.locked) {
                    HapticsService().error();
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text(
                            'Terminá el número anterior para leer el Nº ${arc?.actNumber ?? i + 1}'),
                        duration: const Duration(milliseconds: 1400),
                        behavior: SnackBarBehavior.floating,
                      ));
                    return;
                  }
                  HapticsService().medium();
                  SoundService().play('page_flip');
                  onPlay(rarity);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  static String _seriesName(String heroId) => switch (heroId) {
        'puo_liu' => 'EL CAMINO DEL DRAGÓN',
        'kage' => 'LA SOMBRA',
        'ryoto' => 'HONOR EN EL TATAMI',
        'kai' => 'BARRIO SUR',
        'mila' => 'LA DANZA LIBRE',
        _ => 'LA SAGA',
      };
}
