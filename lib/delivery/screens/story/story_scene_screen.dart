// lib/delivery/screens/story/story_scene_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/hero_entity.dart';
import '../../../domain/entities/story_arc.dart';
import '../../../infra/local/heroes_data.dart';
import '../../state/battle_provider.dart';
import '../../state/providers.dart';
import '../../state/story_provider.dart';
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

  static final _factionImages = {
    Faction.shaolin:  'assets/images/heros/withoutBG/shaolin_common.png',
    Faction.ninja:    'assets/images/heros/withoutBG/ninja_common.png',
    Faction.judoka:   'assets/images/heros/withoutBG/judo_common.png',
    Faction.boxer:    'assets/images/heros/withoutBG/boxer_common.png',
    Faction.capoeira: 'assets/images/heros/withoutBG/capoeira_common.png',
  };

  @override
  Widget build(BuildContext context) {
    if (hero == null) return const SizedBox(width: 120);
    final imagePath = _factionImages[hero.faction] ?? hero.imagePath as String;
    return Transform(
      alignment: Alignment.center,
      transform: mirrored ? (Matrix4.identity()..scale(-1.0, 1.0)) : Matrix4.identity(),
      child: SizedBox(
        width: 140,
        height: 240,
        child: Image.asset(
          imagePath,
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

    final fColor = playerHero != null ? factionColor(playerHero.faction) : const Color(0xFFE5A93C);
    final bColor = botHero != null ? factionColor(botHero.faction) : const Color(0xFFE74C3C);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Mismo fondo que PreBattleScreen
          Image.asset(
            'assets/images/pre_battle_bg.png',
            fit: BoxFit.cover,
            frameBuilder: (_, child, frame, sync) =>
                (sync || frame != null) ? child : const SizedBox.shrink(),
          ),
          ColoredBox(color: Colors.black.withValues(alpha: 0.2)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Header
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
                        onPressed: () => context.go('/home'),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'MODO HISTORIA',
                        style: TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 2, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Etapa ${session.currentStageIndex + 1} de 10',
                    style: const TextStyle(
                      color: Color(0xFFF0F0F0),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Cards VS
                  Row(
                    children: [
                      Expanded(
                        child: _StoryHeroCard(hero: playerHero, color: fColor, label: 'Tú'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: const Column(
                            children: [
                              Text('VS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: 1)),
                              Text('HISTORIA', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: _StoryHeroCard(hero: botHero, color: bColor, label: 'Rival'),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Briefing
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '"${battleStage.briefingText}"',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(),
                  // Botón combate
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchBattle(context, ref, battleStage, playerHero, botHero),
                      icon: const Icon(Icons.sports_mma, size: 20),
                      label: const Text(
                        'Comenzar Batalla',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE74C3C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
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

class _StoryHeroCard extends StatelessWidget {
  final dynamic hero;
  final Color color;
  final String label;

  const _StoryHeroCard({required this.hero, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    if (hero == null) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: const Center(child: Icon(Icons.person, color: Colors.white24, size: 40)),
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 10, letterSpacing: 1.5)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: double.infinity,
              height: 96,
              child: Image(
                image: ResizeImage(AssetImage(hero.imagePath as String), width: 300, height: 200),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: color.withValues(alpha: 0.15),
                  child: Center(child: Icon(Icons.sports_mma, size: 36, color: color)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hero.name as String,
            style: const TextStyle(color: Color(0xFFF0F0F0), fontSize: 13, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            hero.title as String,
            style: const TextStyle(color: Color(0xFF8A8A9A), fontSize: 10),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          _StoryStatBar(icon: Icons.favorite, value: hero.maxHp as int, max: 92, color: Colors.red),
          const SizedBox(height: 4),
          _StoryStatBar(icon: Icons.bolt, value: hero.maxStamina as int, max: 14, color: Colors.amber),
        ],
      ),
    );
  }
}

class _StoryStatBar extends StatelessWidget {
  final IconData icon;
  final int value;
  final int max;
  final Color color;

  const _StoryStatBar({required this.icon, required this.value, required this.max, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (value / max).clamp(0.0, 1.0),
              backgroundColor: const Color(0xFF2A2A3E),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 5,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text('$value', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
