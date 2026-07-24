import 'dart:math' show Random, pi;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/battle_state.dart' show GameMode;
import '../../../domain/entities/hero_entity.dart';
import '../../../infra/local/heroes_data.dart';
import '../../state/battle_provider.dart';
import '../../state/providers.dart';
import '../heroes/character_select_screen.dart';
import '../../widgets/tap_scale_button.dart';
import 'package:go_router/go_router.dart';

class PreBattleScreen extends ConsumerStatefulWidget {
  const PreBattleScreen({super.key});

  @override
  ConsumerState<PreBattleScreen> createState() => _PreBattleScreenState();
}

class _PreBattleScreenState extends ConsumerState<PreBattleScreen> {
  HeroEntity? _rival;
  final _random = Random();

  /// Rival aleatorio ponderado por dificultad: Fácil = commons,
  /// Normal = commons+rares, Difícil = rares+epics. Nunca tu mismo héroe.
  HeroEntity _rollRival(HeroEntity playerHero, BotDifficulty difficulty) {
    final pool = switch (difficulty) {
      BotDifficulty.easy => HeroesData.allHeroes
          .where((h) => h.rarity == 'common')
          .toList(),
      BotDifficulty.normal => HeroesData.allHeroes
          .where((h) => h.rarity == 'common' || h.rarity == 'rare')
          .toList(),
      BotDifficulty.hard => HeroesData.allHeroes
          .where((h) => h.rarity == 'rare' || h.rarity == 'epic')
          .toList(),
    };
    final candidates = pool
        .where((h) => h.id != playerHero.id && h.id != _rival?.id)
        .toList();
    if (candidates.isEmpty) return pool.first;
    return candidates[_random.nextInt(candidates.length)];
  }

  @override
  Widget build(BuildContext context) {
    // Resolve hero: prefer selectedHeroForBattleProvider, fallback to active hero
    var playerHero = ref.watch(selectedHeroForBattleProvider);
    if (playerHero == null) {
      final player = ref.watch(playerProvider);
      final activeHeroId = player?.activeHeroId;
      if (activeHeroId != null) {
        playerHero = HeroesData.findById(activeHeroId);
      }
    }

    if (playerHero == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final player = ref.watch(playerProvider);
    final isArena = player?.tutorialBattleComplete ?? false;

    // Al cambiar la dificultad, el rival se vuelve a sortear del pool nuevo.
    ref.listen(selectedDifficultyProvider, (prev, next) {
      if (prev != next && isArena) {
        setState(() => _rival = _rollRival(playerHero!, next));
      }
    });

    final difficulty = ref.watch(selectedDifficultyProvider);
    final botHero = isArena
        ? (_rival ??= _rollRival(playerHero, difficulty))
        : HeroesData.tutorialBotFor(playerHero.faction.name);
    final fColor = factionColor(playerHero.faction);
    final bColor = factionColor(botHero.faction);
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen de fondo: carga async, no bloquea el primer frame
          Image.asset(
            'assets/images/pre_battle_bg.png',
            fit: BoxFit.cover,
            frameBuilder: (_, child, frame, sync) =>
                (sync || frame != null) ? child : const SizedBox.shrink(),
          ),
          ColoredBox(color: Colors.black.withValues(alpha: 0.2)),
          SafeArea(
            child: SingleChildScrollView(
            child: Column(
              children: [
                // Botón cancelar (solo en arena, no en tutorial)
                SizedBox(
                  height: 40,
                  child: isArena
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
                            onPressed: () => context.go('/home'),
                          ),
                        )
                      : null,
                ),
                // Título
                Text(
                  isArena ? 'ARENA' : 'PRIMERA BATALLA',
                  style: const TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 2, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  isArena ? 'Elegí tu dificultad' : 'Un rival te espera',
                  style: const TextStyle(
                    color: Color(0xFFF0F0F0),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

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

                            // Badge VS
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white, width: 1),
                              ),
                              child: Column(
                                children: [
                                  const Text('VS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: 1)),
                                  Text(
                                    isArena ? 'ARENA' : 'RIVALIDAD',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            // Re-rollear rival (solo arena)
                            if (isArena) ...[
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () => setState(() => _rival =
                                    _rollRival(playerHero!, difficulty)),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.55),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white38),
                                  ),
                                  child: const Icon(Icons.casino,
                                      color: Colors.white70, size: 18),
                                ),
                              ),
                              const Text(
                                'rival',
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 8),
                              ),
                            ],
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
                      // Arena: el lore del rival sorteado. Tutorial: la
                      // rivalidad histórica de tu facción.
                      isArena
                          ? '"${botHero.lore}"'
                          : '"${_rivalLore(playerHero.faction.name)}"',
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

                const SizedBox(height: 16),

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
                            color: Colors.white,
                            fontSize: 12,
                            letterSpacing: 2.5,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.black87, blurRadius: 6, offset: Offset(0, 1)),
                            ],
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
                              onTap: () => ref.read(selectedDifficultyProvider.notifier).select(BotDifficulty.easy),
                            ),
                            const SizedBox(width: 8),
                            _DifficultyChip(
                              label: 'Normal',
                              difficulty: BotDifficulty.normal,
                              selected: difficulty == BotDifficulty.normal,
                              color: Colors.orange,
                              onTap: () => ref.read(selectedDifficultyProvider.notifier).select(BotDifficulty.normal),
                            ),
                            const SizedBox(width: 8),
                            _DifficultyChip(
                              label: 'Difícil',
                              difficulty: BotDifficulty.hard,
                              selected: difficulty == BotDifficulty.hard,
                              color: Colors.red,
                              onTap: () => ref.read(selectedDifficultyProvider.notifier).select(BotDifficulty.hard),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Selector de modo (solo en arena)
                Consumer(builder: (context, ref, _) {
                  final player = ref.watch(playerProvider);
                  if (player == null || !player.tutorialBattleComplete) {
                    return const SizedBox.shrink();
                  }
                  final mode = ref.watch(selectedGameModeProvider);
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      children: [
                        const Text(
                          'MODO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            letterSpacing: 2.5,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.black87, blurRadius: 6, offset: Offset(0, 1)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _ModeChip(
                              label: 'Normal',
                              subtitle: 'Puño · Patada · Defensa',
                              selected: mode == GameMode.normal,
                              color: Colors.teal,
                              onTap: () => ref.read(selectedGameModeProvider.notifier).select(GameMode.normal),
                            ),
                            const SizedBox(width: 8),
                            _ModeChip(
                              label: 'Experto',
                              subtitle: 'Las 5 categorías',
                              selected: mode == GameMode.expert,
                              color: Colors.deepPurple,
                              onTap: () => ref.read(selectedGameModeProvider.notifier).select(GameMode.expert),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                // Aviso de mazo incompleto (se completa con básicas en batalla)
                Consumer(builder: (context, ref, _) {
                  final player = ref.watch(playerProvider);
                  final isArena = player?.tutorialBattleComplete ?? false;
                  final deckIds = player?.deckCardIds ?? const <String>[];
                  final catalog = ref.watch(cardCatalogProvider);
                  final validCount = catalog.resolveDeck(deckIds).length;
                  if (!isArena || validCount >= 20) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5B800).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFF5B800).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 16, color: Color(0xFFF5B800)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tu mazo tiene $validCount/20 cartas: se completa '
                              'con cartas básicas. Armalo en la pestaña Mazo.',
                              style: const TextStyle(
                                color: Color(0xFFF5B800),
                                fontSize: 11,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // Botón de batalla
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Consumer(builder: (context, ref, _) {
                    final player = ref.watch(playerProvider);
                    final difficulty = ref.watch(selectedDifficultyProvider);
                    final gameMode = ref.watch(selectedGameModeProvider);
                    final isArena = player?.tutorialBattleComplete ?? false;
                    return TapScaleButton(
                      color: const Color(0xFFE74C3C),
                      height: 56,
                      borderRadius: 16,
                      onPressed: () => _startBattle(
                        context, ref, playerHero, botHero,
                        isArena: isArena,
                        difficulty: difficulty,
                        gameMode: gameMode,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sports_mma, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text('Comenzar Batalla', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
              ],
            ),
            ),
          ),
        ],
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
    GameMode gameMode = GameMode.expert,
  }) {
    if (isArena) {
      ref.read(battleProvider.notifier).initArenaBattle(
        playerHero: playerHero,
        botHero: botHero,
        difficulty: difficulty,
        gameMode: gameMode,
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

class _HeroPreviewCard extends StatefulWidget {
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
  State<_HeroPreviewCard> createState() => _HeroPreviewCardState();
}

class _HeroPreviewCardState extends State<_HeroPreviewCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _flip() {
    if (_ctrl.isAnimating) return;
    if (_showBack) {
      _ctrl.reverse().then((_) => setState(() => _showBack = false));
    } else {
      setState(() => _showBack = true);
      _ctrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          final angle = _anim.value * pi;
          final isShowingBack = angle > pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(angle),
            child: isShowingBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: _buildBack(),
                  )
                : _buildFront(),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    final hero = widget.hero;
    final color = widget.color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.label, style: TextStyle(color: color, fontSize: 10, letterSpacing: 1.5)),
              const SizedBox(width: 4),
              Icon(Icons.info_outline, size: 9, color: color.withValues(alpha: 0.5)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: double.infinity,
              height: 100,
              child: Image(
                image: ResizeImage(AssetImage(hero.imagePath), width: 300, height: 200),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: color.withValues(alpha: 0.15),
                  child: Center(child: Icon(Icons.sports_mma, size: 40, color: color)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hero.name,
            style: const TextStyle(color: Color(0xFFF0F0F0), fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            hero.title,
            style: const TextStyle(color: Color(0xFF8A8A9A), fontSize: 10),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _MiniStatBar(icon: Icons.favorite, value: hero.maxHp, max: 92, color: Colors.red),
          const SizedBox(height: 4),
          _MiniStatBar(icon: Icons.bolt, value: hero.maxStamina, max: 14, color: Colors.amber),
        ],
      ),
    );
  }

  Widget _buildBack() {
    final hero = widget.hero;
    final color = widget.color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_rounded, size: 20, color: color.withValues(alpha: 0.7)),
          const SizedBox(height: 8),
          Text(
            hero.name,
            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            textAlign: TextAlign.center,
          ),
          Text(
            hero.title,
            style: const TextStyle(color: Color(0xFF8A8A9A), fontSize: 9),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 1,
            color: color.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          Text(
            hero.lore,
            style: const TextStyle(
              color: Color(0xFFD0D0D0),
              fontSize: 11,
              fontStyle: FontStyle.italic,
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app, size: 10, color: color.withValues(alpha: 0.4)),
              const SizedBox(width: 3),
              Text(
                'Tocá para volver',
                style: TextStyle(color: color.withValues(alpha: 0.4), fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStatBar extends StatelessWidget {
  final IconData icon;
  final int value;
  final int max;
  final Color color;

  const _MiniStatBar({
    required this.icon,
    required this.value,
    required this.max,
    required this.color,
  });

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

class _ModeChip extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.subtitle,
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
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.25) : Colors.black54,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : Colors.white24,
              width: selected ? 2.5 : 1,
            ),
            boxShadow: selected
                ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 3))]
                : null,
          ),
          child: Column(
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  shadows: selected
                      ? [Shadow(color: color.withValues(alpha: 0.8), blurRadius: 8)]
                      : null,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.35) : Colors.black54,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : Colors.white24,
              width: selected ? 2.5 : 1,
            ),
            boxShadow: selected
                ? [BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 14, offset: const Offset(0, 3))]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              shadows: selected
                  ? [Shadow(color: color.withValues(alpha: 0.8), blurRadius: 8)]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}