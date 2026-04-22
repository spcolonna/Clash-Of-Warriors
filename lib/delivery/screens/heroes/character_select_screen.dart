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

class _CharacterSelectScreenState
    extends ConsumerState<CharacterSelectScreen> {
  HeroEntity? _selected;
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  final _heroes = HeroesData.starterHeroes;

  @override
  void initState() {
    super.initState();
    _selected = _heroes.first;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

            // Carrusel fluido (T9) — animación sincronizada al PageController
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _heroes.length,
                physics: const PageScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                    _selected = _heroes[index];
                  });
                },
                itemBuilder: (context, index) {
                  final hero = _heroes[index];
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value = _pageController.page! - index;
                        value = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0);
                      }
                      return Transform.scale(
                        scale: value,
                        child: Opacity(
                          opacity: value.clamp(0.7, 1.0),
                          child: child,
                        ),
                      );
                    },
                    child: _HeroCard(
                      hero: hero,
                      isSelected: index == _currentPage,
                    ),
                  );
                },
              ),
            ),

            // Indicadores
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_heroes.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _currentPage ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: i == _currentPage
                        ? factionColor(_selected!.faction)
                        : AppColors.textSecondary.withOpacity(0.3),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // Botón confirmar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selected == null ? null : _onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selected != null
                        ? factionColor(_selected!.faction)
                        : AppColors.textSecondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Elegir ${_selected?.name ?? ''}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
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

  Future<void> _onConfirm() async {
    if (_selected == null) return;

    final playerNotifier = ref.read(playerProvider.notifier);
    ref.read(selectedHeroForBattleProvider.notifier).state = _selected;

    // Espera a que se guarde en Firebase con el mazo starter asignado
    await playerNotifier.selectFaction(
      _selected!.faction.name,
      _selected!.id,
    );

    if (mounted) context.go('/pre-battle');
  }
}

class _HeroCard extends StatelessWidget {
  final HeroEntity hero;
  final bool isSelected;

  const _HeroCard({required this.hero, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final color = factionColor(hero.faction);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? color : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 20,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen del héroe con gradiente + badge de facción
          ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(22)),
            child: SizedBox(
              height: 250,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    hero.imagePath,
                    fit: BoxFit.fill,
                    errorBuilder: (_, __, ___) => Container(
                      color: color.withOpacity(0.15),
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
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withOpacity(0.6)),
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

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
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
                  const SizedBox(height: 12),

                  // Stats compactas en 2 columnas
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _StatRow(
                                label: 'Puño',
                                value: hero.stats.punch,
                                color: color),
                            const SizedBox(height: 4),
                            _StatRow(
                                label: 'Patada',
                                value: hero.stats.kick,
                                color: color),
                            const SizedBox(height: 4),
                            _StatRow(
                                label: 'Agarre',
                                value: hero.stats.grapple,
                                color: color),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: [
                            _StatRow(
                                label: 'Defensa',
                                value: hero.stats.defense,
                                color: color),
                            const SizedBox(height: 4),
                            _StatRow(
                                label: 'Esquive',
                                value: hero.stats.dodge,
                                color: color),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                MiniChip(icon: '❤️', value: '${hero.maxHp}'),
                                const SizedBox(width: 4),
                                MiniChip(
                                    icon: '⚡', value: '${hero.maxStamina}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Divider(
                      color: AppColors.textSecondary.withOpacity(0.15),
                      height: 16),

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

class _StatRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 12.0,
              backgroundColor: AppColors.textSecondary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ─── Helpers de facción ─────────────────────────────────────────────────────

Color factionColor(Faction faction) => switch (faction) {
  Faction.shaolin => const Color(0xFFD4A017),
  Faction.ninja => const Color(0xFF4A4A6A),
  Faction.judoka => const Color(0xFF1A5276),
  Faction.boxer => const Color(0xFFC0392B),
  Faction.capoeira => const Color(0xFF27AE60),
};

String factionEmoji(Faction faction) => switch (faction) {
  Faction.shaolin => '🏯',
  Faction.ninja => '🥷',
  Faction.judoka => '🥋',
  Faction.boxer => '🥊',
  Faction.capoeira => '💃',
};

String factionName(Faction faction) => switch (faction) {
  Faction.shaolin => 'Guardianes Shaolin',
  Faction.ninja => 'Clan de las Sombras',
  Faction.judoka => 'Hermandad de Hierro',
  Faction.boxer => 'Boxeadores del Cemento',
  Faction.capoeira => 'Capoeiristas Libres',
};

class AppColors {
  static const background = Color(0xFF0D0D0D);
  static const cardBackground = Color(0xFF1A1A2E);
  static const textPrimary = Color(0xFFF0F0F0);
  static const textSecondary = Color(0xFF8A8A9A);
}
