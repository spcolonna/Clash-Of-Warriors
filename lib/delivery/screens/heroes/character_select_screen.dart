// lib/delivery/screens/heroes/character_select_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/hero_entity.dart';
import '../../../infra/local/heroes_data.dart';
import '../../state/providers.dart';
import 'mini_chip.dart';

class CharacterSelectScreen extends ConsumerStatefulWidget {
  const CharacterSelectScreen({super.key});

  @override
  ConsumerState<CharacterSelectScreen> createState() =>
      _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends ConsumerState<CharacterSelectScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;
  final _heroes = HeroesData.starterHeroes;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Hero images del carousel
      for (final hero in _heroes) {
        precacheImage(
          ResizeImage(AssetImage(hero.imagePath), width: 380, height: 260),
          context,
        );
      }
      // Fondo y bot-heroes de pre-battle con las mismas dimensiones que usa _HeroPreviewCard
      precacheImage(const AssetImage('assets/images/pre_battle_bg.png'), context);
      for (final hero in _heroes) {
        // héroe del jugador en pre-battle (misma clave que _HeroPreviewCard usa)
        precacheImage(
          ResizeImage(AssetImage(hero.imagePath), width: 300, height: 200),
          context,
        );
        final bot = HeroesData.tutorialBotFor(hero.faction.name);
        precacheImage(
          ResizeImage(AssetImage(bot.imagePath), width: 300, height: 200),
          context,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (index < 0 || index >= _heroes.length) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hero  = _heroes[_currentIndex];
    final color = factionColor(hero.faction);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(
              'Elige tu Camino',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu facción define tu estilo de combate',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // ── Carousel ────────────────────────────────────────────────────
            // PageView usa el scroll engine nativo de Flutter — corre en el
            // raster thread, gestos continuos, física de página incorporada.
            Expanded(
              child: Row(
                children: [
                  _NavArrow(
                    icon: Icons.chevron_left_rounded,
                    enabled: _currentIndex > 0,
                    onTap: () => _goTo(_currentIndex - 1),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _heroes.length,
                      onPageChanged: (i) => setState(() => _currentIndex = i),
                      itemBuilder: (context, i) => RepaintBoundary(
                        child: _HeroCard(hero: _heroes[i]),
                      ),
                    ),
                  ),
                  _NavArrow(
                    icon: Icons.chevron_right_rounded,
                    enabled: _currentIndex < _heroes.length - 1,
                    onTap: () => _goTo(_currentIndex + 1),
                  ),
                ],
              ),
            ),

            // ── Indicadores ─────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_heroes.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _currentIndex ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: i == _currentIndex
                        ? color
                        : AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // ── Botón confirmar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: GestureDetector(
                onTap: () => _onConfirm(hero),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Elegir ${hero.name}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 20, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _onConfirm(HeroEntity selected) async {
    final t0 = DateTime.now();
    debugPrint('[NAV] _onConfirm START');

    ref.read(selectedHeroForBattleProvider.notifier).state = selected;
    debugPrint('[NAV] selectedHero set: ${DateTime.now().difference(t0).inMilliseconds}ms');

    ref.read(playerProvider.notifier).selectFaction(selected.faction.name, selected.id);
    debugPrint('[NAV] selectFaction called: ${DateTime.now().difference(t0).inMilliseconds}ms');

    if (!mounted) return;
    debugPrint('[NAV] context.go START: ${DateTime.now().difference(t0).inMilliseconds}ms');
    context.go('/pre-battle');
    debugPrint('[NAV] context.go DONE: ${DateTime.now().difference(t0).inMilliseconds}ms');
  }
}

// ── Flecha de navegación ─────────────────────────────────────────────────────

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _NavArrow(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(
          icon,
          size: 32,
          color: enabled
              ? AppColors.textSecondary
              : AppColors.textSecondary.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}

// ── HeroCard ─────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final HeroEntity hero;

  const _HeroCard({required this.hero});

  @override
  Widget build(BuildContext context) {
    final color = factionColor(hero.faction);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen con badge de facción
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: SizedBox(
              height: 220,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: ResizeImage(
                      AssetImage(hero.imagePath),
                      width: 380,
                      height: 260,
                    ),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: color.withValues(alpha: 0.15),
                      child: Center(
                        child: Text(
                          factionEmoji(hero.faction),
                          style: const TextStyle(fontSize: 56),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: color.withValues(alpha: 0.6)),
                      ),
                      child: Text(
                        factionName(hero.faction).toUpperCase(),
                        style: TextStyle(
                          color: color,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats + lore
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hero.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    hero.title,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _StatRow(label: 'Puño',   value: hero.stats.punch,   color: color),
                            const SizedBox(height: 4),
                            _StatRow(label: 'Patada', value: hero.stats.kick,    color: color),
                            const SizedBox(height: 4),
                            _StatRow(label: 'Agarre', value: hero.stats.grapple, color: color),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: [
                            _StatRow(label: 'Defensa', value: hero.stats.defense, color: color),
                            const SizedBox(height: 4),
                            _StatRow(label: 'Esquive', value: hero.stats.dodge,   color: color),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Flexible(child: MiniChip(icon: '❤️', value: '${hero.maxHp}')),
                                const SizedBox(width: 4),
                                Flexible(child: MiniChip(icon: '⚡', value: '${hero.maxStamina}')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: AppColors.textSecondary.withValues(alpha: 0.15),
                    height: 14,
                  ),
                  Text(
                    hero.lore,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── StatRow ──────────────────────────────────────────────────────────────────
// Sin LayoutBuilder — FractionallySizedBox ya es relativo al padre (Expanded),
// elimina 25 layout callbacks (5 stats × 5 heroes) durante la animación.

class _StatRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatRow(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final fill = (value / 12.0).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 58,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 6,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: fill,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ─── Helpers de facción ──────────────────────────────────────────────────────

Color factionColor(Faction faction) => switch (faction) {
      Faction.shaolin  => const Color(0xFFD4A017),
      Faction.ninja    => const Color(0xFF4A4A6A),
      Faction.judoka   => const Color(0xFF1A5276),
      Faction.boxer    => const Color(0xFFC0392B),
      Faction.capoeira => const Color(0xFF27AE60),
    };

String factionEmoji(Faction faction) => switch (faction) {
      Faction.shaolin  => '🏯',
      Faction.ninja    => '🥷',
      Faction.judoka   => '🥋',
      Faction.boxer    => '🥊',
      Faction.capoeira => '💃',
    };

String factionName(Faction faction) => switch (faction) {
      Faction.shaolin  => 'Guardianes Shaolin',
      Faction.ninja    => 'Clan de las Sombras',
      Faction.judoka   => 'Hermandad de Hierro',
      Faction.boxer    => 'Boxeadores del Cemento',
      Faction.capoeira => 'Capoeiristas Libres',
    };

class AppColors {
  static const background     = Color(0xFF0D0D0D);
  static const cardBackground = Color(0xFF1A1A2E);
  static const textPrimary    = Color(0xFFF0F0F0);
  static const textSecondary  = Color(0xFF8A8A9A);
}
