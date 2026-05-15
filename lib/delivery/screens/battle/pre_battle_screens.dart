import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../infra/local/heroes_data.dart';
import '../../state/battle_provider.dart';
import '../../state/providers.dart';
import '../heroes/character_select_screen.dart';
import '../../widgets/tap_scale_button.dart';
import 'package:go_router/go_router.dart';

class PreBattleScreen extends ConsumerWidget {
  const PreBattleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('[NAV] PreBattleScreen.build START ${DateTime.now().millisecondsSinceEpoch}');
    final playerHero = ref.watch(selectedHeroForBattleProvider);

    if (playerHero == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final botHero = HeroesData.tutorialBotFor(playerHero.faction.name);
    final fColor = factionColor(playerHero.faction);
    final bColor = factionColor(botHero.faction);

    return Scaffold(
      // Quitamos el color de fondo sólido
      body: Container(
        // --- CONFIGURACIÓN DEL FONDO ---
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/pre_battle_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // Añadimos un ligero velo oscuro (opcional) para que los textos blancos resalten más
          color: Colors.black.withOpacity(0.2),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Título
                const Text(
                  'Primera Batalla',
                  style: TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 2, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Un rival te espera',
                  style: TextStyle(
                    color: Color(0xFFF0F0F0),
                    fontSize: 28, // Un poco más grande para que sea épico
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black)], // Sombra para legibilidad
                  ),
                ),

                const Spacer(),

                // VS layout
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      // Héroe del jugador
                      Expanded(
                        child: _HeroPreviewCard(
                          hero: playerHero,
                          color: fColor,
                          label: 'Tú',
                          alignLeft: true,
                        ),
                      ),

                      // ESPACIO PARA EL "VS" DE LA IMAGEN
                      // Como la imagen ya tiene el VS, solo dejamos el hueco y el badge
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 40), // Espacio donde cae el VS de la imagen

                            // Badge de rivalidad histórica
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.8), // Más opaco para resaltar sobre el fondo
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white, width: 1),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '⚔️',
                                    style: GoogleFonts.notoColorEmoji(
                                      textStyle: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  const Text(
                                    'RIVALIDAD',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bot
                      Expanded(
                        child: _HeroPreviewCard(
                          hero: botHero,
                          color: bColor,
                          label: 'Rival',
                          alignLeft: false,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Texto de contexto
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '"${_rivalLore(playerHero.faction.name)}"',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const Spacer(),

                // Recordatorio del mazo (con fondo más sólido para que no se pierda)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      Text('🃏',
                        style: GoogleFonts.notoColorEmoji(
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mazo Neutral · 20 cartas',
                              style: TextStyle(
                                color: Color(0xFFF0F0F0),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Puño · Patada · Agarre · Defensa · Esquive',
                              style: TextStyle(color: Color(0xFF8A8A9A), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Selector de dificultad (solo en batallas de arena)
                Consumer(builder: (context, ref, _) {
                  final player = ref.watch(playerProvider);
                  if (player == null || !player.tutorialBattleComplete) {
                    return const SizedBox.shrink();
                  }
                  final difficulty = ref.watch(selectedDifficultyProvider);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const Text(
                          'DIFICULTAD',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _DifficultyChip(
                              label: 'Fácil',
                              difficulty: BotDifficulty.easy,
                              selected: difficulty == BotDifficulty.easy,
                              color: Colors.green,
                              onTap: () => ref.read(selectedDifficultyProvider.notifier).state = BotDifficulty.easy,
                            ),
                            const SizedBox(width: 8),
                            _DifficultyChip(
                              label: 'Normal',
                              difficulty: BotDifficulty.normal,
                              selected: difficulty == BotDifficulty.normal,
                              color: Colors.orange,
                              onTap: () => ref.read(selectedDifficultyProvider.notifier).state = BotDifficulty.normal,
                            ),
                            const SizedBox(width: 8),
                            _DifficultyChip(
                              label: 'Difícil',
                              difficulty: BotDifficulty.hard,
                              selected: difficulty == BotDifficulty.hard,
                              color: Colors.red,
                              onTap: () => ref.read(selectedDifficultyProvider.notifier).state = BotDifficulty.hard,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Botón de batalla
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Consumer(builder: (context, ref, _) {
                    final player = ref.watch(playerProvider);
                    final difficulty = ref.watch(selectedDifficultyProvider);
                    final isArena = player?.tutorialBattleComplete ?? false;
                    return TapScaleButton(
                      color: const Color(0xFFE74C3C),
                      height: 56,
                      borderRadius: 16,
                      onPressed: () => _startBattle(
                        context, ref, playerHero, botHero,
                        isArena: isArena,
                        difficulty: difficulty,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('⚔️', style: GoogleFonts.notoColorEmoji(textStyle: const TextStyle(fontSize: 18))),
                          const SizedBox(width: 10),
                          const Text('Comenzar Batalla', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startBattle(
    BuildContext context,
    WidgetRef ref,
    dynamic playerHero,
    dynamic botHero, {
    bool isArena = false,
    BotDifficulty difficulty = BotDifficulty.normal,
  }) {
    if (isArena) {
      ref.read(battleProvider.notifier).initArenaBattle(
        playerHero: playerHero,
        botHero: botHero,
        difficulty: difficulty,
      );
    } else {
      ref.read(battleProvider.notifier).initTutorialBattle(
        playerHero: playerHero,
        botHero: botHero,
      );
    }
    context.go('/battle');
  }

  String _rivalLore(String factionId) => switch (factionId) {
    'shaolin'  => 'Hace tres siglos abandonaron la Montaña Sagrada. Hoy regresan a demostrar que hicieron bien.',
    'ninja'    => 'El Novicio baja de la Montaña con los ojos de quien tiene algo que probar.',
    'judoka'   => 'El Debate Eterno. Agarre o golpe. Hoy habrá una respuesta.',
    'boxer'    => 'El Judoka espera. Sabe que van a terminar en el suelo. La pregunta es cuánto vas a demorar.',
    'capoeira' => 'La Montaña no entiende el arte que nació en la resistencia. Hora de que aprenda.',
    _          => 'Tu rival te espera en la Arena.',
  };
}

class _HeroPreviewCard extends StatelessWidget {
  final dynamic hero;
  final Color color;
  final String label;
  final bool alignLeft;

  const _HeroPreviewCard({
    required this.hero,
    required this.color,
    required this.label,
    required this.alignLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 10, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: double.infinity,
              height: 100,
              child: Image.asset(
                hero.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: color.withOpacity(0.15),
                  child: Center(
                    child: Text(
                      factionEmoji(hero.faction),
                      style: GoogleFonts.notoColorEmoji(
                        textStyle: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hero.name,
            style: const TextStyle(
              color: Color(0xFFF0F0F0),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            hero.title,
            style: const TextStyle(color: Color(0xFF8A8A9A), fontSize: 10),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _MiniStatBar(label: '❤️', value: hero.maxHp, max: 92, color: Colors.red),
          const SizedBox(height: 4),
          _MiniStatBar(label: '⚡', value: hero.maxStamina, max: 14, color: Colors.amber),
        ],
      ),
    );
  }
}

class _MiniStatBar extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Color color;

  const _MiniStatBar({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.notoColorEmoji(
            textStyle: const TextStyle(fontSize: 10),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value / max,
              backgroundColor: const Color(0xFF2A2A3E),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 5,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$value',
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final String label;
  final BotDifficulty difficulty;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _DifficultyChip({
    required this.label,
    required this.difficulty,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.2) : const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : Colors.white12,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? color : Colors.white54,
              fontSize: 13,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}