// lib/delivery/screens/story/story_scene_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/story_arc.dart';
import '../../../infra/local/heroes_data.dart';
import '../../state/battle_provider.dart';
import '../../state/providers.dart';
import '../../state/story_provider.dart';

class StorySceneScreen extends ConsumerWidget {
  const StorySceneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(storySessionProvider);

    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/home'));
      return const SizedBox.shrink();
    }

    final stage = session.currentStage;

    if (stage.type == StageType.dialogue) {
      return _DialogueView(session: session);
    } else {
      return _BattleInterstitial(session: session);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIALOGUE VIEW
// ─────────────────────────────────────────────────────────────────────────────

class _DialogueView extends ConsumerWidget {
  final StorySessionState session;
  const _DialogueView({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stage = session.currentStage.dialogue!;
    final lines = stage.lines;
    final lineIdx = session.currentDialogueLine.clamp(0, lines.length - 1);
    final line = lines[lineIdx];
    final isNarrator = line.speakerId == 'narrator';
    final isLastLine = lineIdx >= lines.length - 1;

    // Determinar los personajes de la escena
    final leftSpeakerId = lines.firstWhere(
      (l) => l.speakerIsLeft && l.speakerId != 'narrator',
      orElse: () => lines.first,
    ).speakerId;
    final rightSpeakerId = lines.firstWhere(
      (l) => !l.speakerIsLeft && l.speakerId != 'narrator',
      orElse: () => lines.last,
    ).speakerId;

    final leftHero = HeroesData.findByIdSafe(leftSpeakerId);
    final rightHero = HeroesData.findByIdSafe(rightSpeakerId);

    final activeSide = line.speakerIsLeft;

    return GestureDetector(
      onTap: () => ref.read(storySessionProvider.notifier).advanceLine(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A14),
        body: Stack(
          children: [
            // Fondo con gradiente por locación
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0D0D1A), Color(0xFF050510)],
                ),
              ),
            ),

            // Nombre de locación arriba
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/home'),
                      child: const Icon(Icons.close, color: Color(0xFF4A4A5A), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      stage.locationName,
                      style: const TextStyle(
                        color: Color(0xFF6A6A7A),
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Etapa ${session.currentStageIndex + 1}/10',
                      style: const TextStyle(color: Color(0xFF4A4A5A), fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),

            // Personajes
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Izquierda
                    AnimatedOpacity(
                      opacity: (!isNarrator && activeSide) ? 1.0 : 0.45,
                      duration: const Duration(milliseconds: 300),
                      child: _CharacterPortrait(hero: leftHero, mirrored: false),
                    ),
                    // Derecha
                    AnimatedOpacity(
                      opacity: (!isNarrator && !activeSide) ? 1.0 : 0.45,
                      duration: const Duration(milliseconds: 300),
                      child: _CharacterPortrait(hero: rightHero, mirrored: true),
                    ),
                  ],
                ),
              ),
            ),

            // Panel de diálogo inferior
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _DialoguePanel(
                line: line,
                isNarrator: isNarrator,
                isLastLine: isLastLine,
                stageIndex: session.currentStageIndex,
                arc: session.arc,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterPortrait extends StatelessWidget {
  final dynamic hero; // HeroEntity?
  final bool mirrored;
  const _CharacterPortrait({required this.hero, required this.mirrored});

  @override
  Widget build(BuildContext context) {
    if (hero == null) return const SizedBox(width: 120);
    return Transform(
      alignment: Alignment.center,
      transform: mirrored ? (Matrix4.identity()..scale(-1.0, 1.0)) : Matrix4.identity(),
      child: SizedBox(
        width: 140,
        height: 240,
        child: Image.asset(
          hero.imagePath as String,
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _DialoguePanel extends StatelessWidget {
  final DialogueLine line;
  final bool isNarrator;
  final bool isLastLine;
  final int stageIndex;
  final StoryArc arc;

  const _DialoguePanel({
    required this.line,
    required this.isNarrator,
    required this.isLastLine,
    required this.stageIndex,
    required this.arc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00050510), Color(0xEE050510), Color(0xFF050510)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del speaker
            if (!isNarrator)
              Text(
                line.speakerName,
                style: const TextStyle(
                  color: Color(0xFFE5A93C),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              )
            else
              const Text(
                'NARRADOR',
                style: TextStyle(
                  color: Color(0xFF6A6A7A),
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
            const SizedBox(height: 8),
            // Texto
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isNarrator
                    ? const Color(0xFF0D0D1A)
                    : const Color(0xFF141428),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isNarrator
                      ? const Color(0xFF2A2A3E)
                      : const Color(0xFF3A3A5E),
                  width: 1,
                ),
              ),
              child: Text(
                line.text,
                style: TextStyle(
                  color: isNarrator
                      ? const Color(0xFF8A8A9A)
                      : Colors.white,
                  fontSize: 14,
                  height: 1.5,
                  fontStyle: isNarrator ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Indicador "Tocá para continuar"
            Center(
              child: Text(
                isLastLine ? 'Tocá para continuar ▸' : 'Tocá para avanzar ▸',
                style: const TextStyle(
                  color: Color(0xFF4A4A5A),
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BATTLE INTERSTITIAL
// ─────────────────────────────────────────────────────────────────────────────

class _BattleInterstitial extends ConsumerWidget {
  final StorySessionState session;
  const _BattleInterstitial({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final battleStage = session.currentStage.battle!;
    final botHero = HeroesData.findByIdSafe(battleStage.botHeroId);
    final playerHero = HeroesData.findByIdSafe(session.heroId);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: const Icon(Icons.close, color: Color(0xFF4A4A5A), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Etapa ${session.currentStageIndex + 1}/10 — Combate',
                    style: const TextStyle(color: Color(0xFF6A6A7A), fontSize: 11, letterSpacing: 1),
                  ),
                ],
              ),
              const Spacer(),
              // VS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _VSHeroCard(hero: playerHero, label: 'TÚ'),
                  const Text('VS', style: TextStyle(
                    color: Color(0xFFE74C3C),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  )),
                  _VSHeroCard(hero: botHero, label: 'RIVAL', mirrored: true),
                ],
              ),
              const SizedBox(height: 32),
              // Briefing
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF141428),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3A3A5E)),
                ),
                child: Text(
                  battleStage.briefingText,
                  style: const TextStyle(
                    color: Color(0xFFD0D0D0),
                    fontSize: 13,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              // Botón combate
              GestureDetector(
                onTap: () => _launchBattle(context, ref, battleStage, playerHero, botHero),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE74C3C),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'ENTRAR AL COMBATE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
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

    // Setear contexto de historia para que EndBattleScreen sepa volver
    ref.read(storyBattleContextProvider.notifier).state = StoryBattleContext(
      heroId: session.heroId,
      rarity: session.rarity,
      stageIndex: session.currentStageIndex,
    );

    // Inicializar la batalla de historia
    ref.read(battleProvider.notifier).initStoryBattle(
      playerHero: playerHero,
      botHero: botHero,
      difficulty: battleStage.difficulty,
      gameMode: battleStage.gameMode,
    );

    context.go('/battle');
  }
}

class _VSHeroCard extends StatelessWidget {
  final dynamic hero;
  final String label;
  final bool mirrored;
  const _VSHeroCard({required this.hero, required this.label, this.mirrored = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF8A8A9A), fontSize: 10, letterSpacing: 1)),
        const SizedBox(height: 8),
        if (hero != null)
          Transform(
            alignment: Alignment.center,
            transform: mirrored ? (Matrix4.identity()..scale(-1.0, 1.0)) : Matrix4.identity(),
            child: Image.asset(
              hero.imagePath as String,
              width: 100,
              height: 140,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: 100,
                height: 140,
                color: const Color(0xFF1A1A2E),
                child: const Icon(Icons.person, color: Colors.white38, size: 40),
              ),
            ),
          )
        else
          Container(
            width: 100,
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Colors.white38, size: 40),
          ),
        if (hero != null) ...[
          const SizedBox(height: 8),
          Text(hero.name as String,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ],
    );
  }
}
