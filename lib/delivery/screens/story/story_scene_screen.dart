// lib/delivery/screens/story/story_scene_screen.dart
//
// Comic reader del modo historia: portada de capítulo, viñetas con revelado
// progresivo y splash de batalla estilo página de acción.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/story_arc.dart';
import '../../../infra/local/heroes_data.dart';
import '../../../infra/services/haptics_service.dart';
import '../../../infra/sound/sound_service.dart';
import '../../state/battle_provider.dart';
import '../../state/providers.dart';
import '../../state/story_provider.dart';
import '../../widgets/comic/chapter_cover.dart';
import '../../widgets/comic/comic_page.dart';
import '../../widgets/comic/comic_panel.dart';
import '../../widgets/comic/comic_portrait.dart';
import '../../widgets/comic/comic_theme.dart';
import '../../widgets/comic/halftone_painter.dart';
import '../../widgets/comic/onomatopeia.dart';
import '../../widgets/comic/speech_bubble.dart';
import '../heroes/character_select_screen.dart' show factionColor;

class StorySceneScreen extends ConsumerWidget {
  const StorySceneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(storySessionProvider);

    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/home'));
      return const SizedBox.shrink();
    }

    // Sonido de pasar página al cambiar de stage
    ref.listen(storySessionProvider, (prev, next) {
      if (prev != null &&
          next != null &&
          next.currentStageIndex != prev.currentStageIndex) {
        SoundService().play('page_flip');
        HapticsService().light();
      }
    });

    // Portada (arranque) o recap "Anteriormente..." (reanudación)
    if (!session.coverShown) {
      final resuming = session.startedAtStage > 0;
      return ChapterCover(
        arc: session.arc,
        resumeSynopsis: resuming
            ? (session.arc.synopsis ??
                'La historia continúa donde la dejaste...')
            : null,
        onContinue: () {
          SoundService().play('page_flip');
          HapticsService().medium();
          ref.read(storySessionProvider.notifier).markCoverShown();
        },
      );
    }

    final stage = session.currentStage;
    if (stage.type == StageType.dialogue) {
      return _ComicDialogueView(session: session);
    }
    return _ComicBattleSplash(session: session);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMIC DIALOGUE VIEW — viñetas con revelado progresivo
// ─────────────────────────────────────────────────────────────────────────────

class _ComicDialogueView extends ConsumerStatefulWidget {
  final StorySessionState session;
  const _ComicDialogueView({required this.session});

  @override
  ConsumerState<_ComicDialogueView> createState() => _ComicDialogueViewState();
}

class _ComicDialogueViewState extends ConsumerState<_ComicDialogueView> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  void _advance() {
    HapticsService().selection();
    SoundService().play('panel_pop');
    ref.read(storySessionProvider.notifier).advanceLine();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final stage = session.currentStage.dialogue!;
    final palette = ComicTheme.paletteFor(stage.effectiveLocationId);

    final panels = ComicPanelData.fromStage(stage);
    final lineIdx =
        session.currentDialogueLine.clamp(0, stage.lines.length - 1);
    final currentPanel = ComicPanelData.panelOfLine(stage, lineIdx);

    // Cuántas líneas del panel actual están reveladas
    int linesBefore = 0;
    for (int p = 0; p < currentPanel; p++) {
      linesBefore += panels[p].lines.length;
    }
    final visibleInCurrent = lineIdx - linesBefore + 1;

    return GestureDetector(
      onTap: _advance,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: ComicTheme.paper,
        body: Stack(
          children: [
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                child: ComicPage(
                  controller: _scrollController,
                  locationLabel: stage.locationName,
                  panels: [
                    for (int p = 0; p <= currentPanel; p++)
                      ComicPanel(
                        key: ValueKey(
                            '${session.currentStageIndex}_p$p'),
                        data: panels[p],
                        palette: palette,
                        seed: session.currentStageIndex * 7 + p,
                        visibleLines:
                            p == currentPanel ? visibleInCurrent : null,
                      ),
                  ],
                ),
              ),
            ),

            // Header: cerrar + página
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 14, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/home'),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: ComicTheme.paper,
                          border: Border.all(color: ComicTheme.ink, width: 2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: ComicTheme.ink, size: 16),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: ComicTheme.paper,
                        border: Border.all(color: ComicTheme.ink, width: 2),
                      ),
                      child: Text(
                        'PÁG. ${session.currentStageIndex + 1}/10',
                        style: ComicTheme.display(size: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Indicador de avance
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.only(top: 30, bottom: 26),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ComicTheme.paper.withValues(alpha: 0),
                        ComicTheme.paper.withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'TOCÁ PARA SEGUIR ▸',
                      style: ComicTheme.display(
                        size: 14,
                        color: ComicTheme.ink.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMIC BATTLE SPLASH — página de acción pre-combate
// ─────────────────────────────────────────────────────────────────────────────

class _ComicBattleSplash extends ConsumerWidget {
  final StorySessionState session;
  const _ComicBattleSplash({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final battleStage = session.currentStage.battle!;
    final botHero = HeroesData.findByIdSafe(battleStage.botHeroId);
    final playerHero = HeroesData.findByIdSafe(session.heroId);
    final palette =
        ComicTheme.paletteFor(battleStage.locationId ?? 'arena');

    final playerColor = playerHero != null
        ? factionColor(playerHero.faction)
        : const Color(0xFFE5A93C);
    final bossDisplayName = battleStage.bossName ?? botHero?.name ?? 'Rival';
    // Jefe narrativo (bossName) → silueta misteriosa
    final bossIsMystery = battleStage.bossName != null;

    return Scaffold(
      backgroundColor: ComicTheme.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 6),
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: ComicTheme.paper,
                        border: Border.all(color: ComicTheme.ink, width: 2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: ComicTheme.ink, size: 16),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: ComicTheme.paper,
                      border: Border.all(color: ComicTheme.ink, width: 2),
                    ),
                    child: Text(
                      'PÁG. ${session.currentStageIndex + 1}/10',
                      style: ComicTheme.display(size: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Panel splash de acción
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: ComicTheme.ink, width: 3.5),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x66141414), offset: Offset(4, 5)),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Fondo tintado + speed lines
                      ColorFiltered(
                        colorFilter: palette.duotoneFilter,
                        child: Image.asset(
                          palette.bgAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: palette.shadow),
                        ),
                      ),
                      CustomPaint(
                        painter: SpeedLinesPainter(
                          color: ComicTheme.ink,
                          focus: Alignment.center,
                          opacity: 0.3,
                        ),
                      ),
                      // Retratos enfrentados
                      Positioned(
                        left: 4,
                        bottom: 10,
                        child: ComicPortrait(
                          speakerId: session.heroId,
                          height: 190,
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 16,
                        child: ComicPortrait(
                          speakerId: battleStage.botHeroId,
                          height: 170,
                          mirrored: true,
                          silhouetteTint:
                              bossIsMystery ? const Color(0xFF2A1040) : null,
                        ),
                      ),
                      // Nombres
                      Positioned(
                        left: 8,
                        bottom: 206,
                        child: _NameTag(
                          name: playerHero?.name ?? 'Tú',
                          color: playerColor,
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 190,
                        child: _NameTag(
                          name: bossDisplayName,
                          color: const Color(0xFF3A1458),
                        ),
                      ),
                      // VS central
                      Center(
                        child: OnomatopoeiaText(
                          battleStage.vsSfxText,
                          size: 62,
                          withBurst: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Briefing como caja de narrador
              NarratorBox(
                text: battleStage.briefingText,
                maxWidth: double.infinity,
              ),
              const SizedBox(height: 16),

              ComicSticker(
                text: '¡A PELEAR!',
                color: const Color(0xFFE74C3C),
                onTap: () {
                  HapticsService().medium();
                  SoundService().play('select');
                  _launchBattle(context, ref, battleStage, playerHero, botHero);
                },
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }

  void _launchBattle(
    BuildContext context,
    WidgetRef ref,
    BattleStage battleStage,
    dynamic playerHero,
    dynamic botHero,
  ) {
    if (playerHero == null || botHero == null) return;

    ref.read(storyBattleContextProvider.notifier).state = StoryBattleContext(
      heroId: session.heroId,
      rarity: session.rarity,
      stageIndex: session.currentStageIndex,
    );

    ref.read(battleProvider.notifier).initStoryBattle(
      playerHero: playerHero,
      botHero: botHero,
      difficulty: battleStage.difficulty,
      gameMode: battleStage.gameMode,
    );

    context.go('/battle');
  }
}

class _NameTag extends StatelessWidget {
  final String name;
  final Color color;
  const _NameTag({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: ComicTheme.ink, width: 2),
        boxShadow: const [
          BoxShadow(color: ComicTheme.ink, offset: Offset(2, 2)),
        ],
      ),
      child: Text(
        name.toUpperCase(),
        style: ComicTheme.display(size: 14, color: Colors.white),
      ),
    );
  }
}
