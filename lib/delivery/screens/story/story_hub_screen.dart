// lib/delivery/screens/story/story_hub_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/hero_entity.dart';
import '../../../infra/local/heroes_data.dart';
import '../../../infra/local/story_arcs_data.dart';
import '../../state/providers.dart';
import '../../state/story_provider.dart';
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
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final heroId = _heroIds[i];
                  final hero = HeroesData.findByIdSafe(heroId);
                  if (hero == null) return const SizedBox.shrink();

                  final isUnlocked = player?.unlockedHeroIds.contains(heroId) ?? false;
                  final rarity = player?.nextPlayableRarity(heroId) ?? 'common';
                  final stagesDone = (player?.storyStageFor(heroId, rarity) ?? -1) + 1;
                  final isAllComplete = player?.nextPlayableRarity(heroId) == null;
                  final color = _factionColors[hero.faction] ?? const Color(0xFFE5A93C);

                  return _HeroArcCard(
                    hero: hero,
                    color: color,
                    rarity: rarity,
                    stagesDone: stagesDone,
                    isAllComplete: isAllComplete,
                    isUnlocked: isUnlocked,
                    onPlay: () => _startArc(context, ref, heroId, rarity),
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

// ─── Hero Arc Card ─────────────────────────────────────────────────────────────

class _HeroArcCard extends StatelessWidget {
  final HeroEntity hero;
  final Color color;
  final String rarity;
  final int stagesDone;
  final bool isAllComplete;
  final bool isUnlocked;
  final VoidCallback onPlay;
  final VoidCallback onLocked;

  const _HeroArcCard({
    required this.hero,
    required this.color,
    required this.rarity,
    required this.stagesDone,
    required this.isAllComplete,
    required this.isUnlocked,
    required this.onPlay,
    required this.onLocked,
  });

  static const _rarityLabels = {
    'common': 'Común',
    'rare': 'Rara',
    'epic': 'Épica',
    'legendary': 'Legendaria',
  };

  static const _rarityColors = {
    'common':    Color(0xFFAAAAAA),
    'rare':      Color(0xFF4FC3F7),
    'epic':      Color(0xFFCE93D8),
    'legendary': Color(0xFFFFD700),
  };

  @override
  Widget build(BuildContext context) {
    final arc = StoryArcsData.findArc(hero.id, rarity);
    final title = arc?.title ?? '—';
    final rarityColor = _rarityColors[rarity] ?? const Color(0xFFAAAAAA);
    final cardColor = isUnlocked ? color : const Color(0xFF4A4A5A);

    return GestureDetector(
      onTap: isUnlocked ? null : onLocked,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardColor.withValues(alpha: 0.35), width: 1),
        ),
        child: Row(
          children: [
            // Portrait
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: ColorFiltered(
                    colorFilter: isUnlocked
                        ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                        : const ColorFilter.matrix([
                            0.33, 0.33, 0.33, 0, 0,
                            0.33, 0.33, 0.33, 0, 0,
                            0.33, 0.33, 0.33, 0, 0,
                            0,    0,    0,    1, 0,
                          ]),
                    child: Image.asset(
                      hero.imagePath,
                      width: 88,
                      height: 104,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 88,
                        height: 104,
                        color: cardColor.withValues(alpha: 0.15),
                        child: Icon(Icons.person, color: cardColor, size: 40),
                      ),
                    ),
                  ),
                ),
                if (!isUnlocked)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.lock_rounded, color: Colors.white54, size: 28),
                      ),
                    ),
                  ),
              ],
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          hero.name,
                          style: TextStyle(
                            color: isUnlocked ? color : const Color(0xFF6A6A7A),
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (isUnlocked) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: rarityColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: rarityColor.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              _rarityLabels[rarity] ?? rarity,
                              style: TextStyle(color: rarityColor, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isUnlocked ? title : 'Héroe bloqueado',
                      style: TextStyle(
                        color: isUnlocked ? const Color(0xFF8A8A9A) : const Color(0xFF5A5A6A),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isUnlocked)
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: isAllComplete ? 1.0 : stagesDone / 10,
                                backgroundColor: const Color(0xFF2A2A3E),
                                valueColor: AlwaysStoppedAnimation(
                                  isAllComplete ? const Color(0xFFFFD700) : color,
                                ),
                                minHeight: 5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isAllComplete ? '✓' : '$stagesDone/10',
                            style: TextStyle(
                              color: isAllComplete ? const Color(0xFFFFD700) : const Color(0xFF8A8A9A),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    else
                      const Text(
                        'Desbloquealo en la Tienda',
                        style: TextStyle(color: Color(0xFF5A5A6A), fontSize: 10),
                      ),
                  ],
                ),
              ),
            ),
            // Acción
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: isAllComplete
                  ? const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD700), size: 28)
                  : isUnlocked
                      ? GestureDetector(
                          onTap: onPlay,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'JUGAR',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: onLocked,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A3A),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: const Icon(Icons.lock_rounded, color: Colors.white38, size: 18),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
