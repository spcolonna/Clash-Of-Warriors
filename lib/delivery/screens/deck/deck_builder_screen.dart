// lib/delivery/screens/deck/deck_builder_screen.dart
//
// Pantalla de construcción de mazo. Dividida en tres secciones:
//   - Héroes (arriba): seleccionar el héroe activo entre los desbloqueados
//   - Mazo actual (medio): cartas que el jugador usa en batalla
//   - Colección (abajo): cartas que tiene pero no están en el mazo

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/config/game_config.dart' as cfg;
import '../../theme/app_theme.dart' as theme;
import '../../../infra/local/heroes_data.dart';
import '../../../infra/services/haptics_service.dart';
import '../../../infra/sound/sound_service.dart';
import '../../../domain/entities/hero_entity.dart';
import '../../../domain/entities/game_card.dart';
import '../../state/providers.dart';
import '../../state/deck_builder_provider.dart';
import '../../widgets/deck/deck_card_tile.dart';
import '../../widgets/deck/deck_section_header.dart';
import '../../widgets/game_card_widget.dart';
import '../../widgets/hero_stats_dialog.dart';

class DeckBuilderScreen extends ConsumerStatefulWidget {
  const DeckBuilderScreen({super.key});

  @override
  ConsumerState<DeckBuilderScreen> createState() => _DeckBuilderScreenState();
}

class _DeckBuilderScreenState extends ConsumerState<DeckBuilderScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(deckBuilderProvider.notifier).loadFromPlayer(),
    );
  }

  // Busca la GameCard por id en el catálogo global (neutrales + facción +
  // cartas remotas cargadas desde el admin).
  GameCard? _findCard(String id) =>
      ref.read(cardCatalogProvider).findById(id);

  Future<void> _addToDeck(String cardId) async {
    final added =
        await ref.read(deckBuilderProvider.notifier).addToDeck(cardId);
    if (!mounted) return;
    if (!added) {
      HapticsService().error();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Tu mazo ya tiene 20 cartas. Sacá una para agregar esta.'),
          duration: Duration(milliseconds: 1800),
          behavior: SnackBarBehavior.floating,
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final deckState = ref.watch(deckBuilderProvider);
    final player = ref.watch(playerProvider);
    // Sin este watch, esta pantalla (viva todo el tiempo dentro del
    // IndexedStack del shell) nunca se reconstruye cuando el catálogo de
    // cartas cambia (ej. "Recargar contenido" en Ajustes), y _findCard()
    // sigue devolviendo el snapshot viejo hasta que otro provider fuerce un rebuild.
    ref.watch(cardCatalogProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: deckState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('Error: $e', style: const TextStyle(color: Colors.white)),
          ),
          data: (state) => Column(
            children: [
              _Header(deckSize: state.deck.length, maxDeckSize: 20),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // ── SECCIÓN HÉROES ─────────────────────────────────
                    SliverToBoxAdapter(
                      child: DeckSectionHeader(
                        title: 'Tu Héroe',
                        subtitle: player != null
                            ? '${player.unlockedHeroIds.length} desbloqueados'
                            : '',
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _HeroSelectorSection(
                        activeHeroId: player?.activeHeroId,
                        unlockedHeroIds: player?.unlockedHeroIds ?? const [],
                        onSelect: (heroId) => ref
                            .read(playerProvider.notifier)
                            .updateActiveHero(heroId),
                      ),
                    ),

                    // ── ASCENSIÓN: medallas → estrellas del héroe activo ─
                    if (player?.activeHeroId != null)
                      SliverToBoxAdapter(
                        child: _AscensionPanel(
                          heroId: player!.activeHeroId!,
                          stars: player.heroStarsFor(player.activeHeroId!),
                          medals: player.medals,
                        ),
                      ),

                    // ── SECCIÓN CARTA PASIVA ───────────────────────────
                    SliverToBoxAdapter(
                      child: DeckSectionHeader(
                        title: 'Carta Pasiva',
                        subtitle: 'exclusiva del héroe',
                        color: const Color(0xFFF5B800),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _PassiveCardSection(
                        activeHeroId: player?.activeHeroId,
                      ),
                    ),

                    // ── SECCIÓN MAZO ───────────────────────────────────
                    SliverToBoxAdapter(
                      child: DeckSectionHeader(
                        title: 'Tu Mazo',
                        subtitle: '${state.deck.length} / 20',
                        color: const Color(0xFFE74C3C),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: state.deck.isEmpty
                          ? const SliverToBoxAdapter(
                              child: _EmptyState(
                                text: 'Tu mazo está vacío.\nAgregá cartas desde tu colección.',
                              ),
                            )
                          : SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.63,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final entry = state.deck[index];
                                  final card = _findCard(entry.cardId);
                                  if (card == null) return const SizedBox.shrink();
                                  return DeckCardTile(
                                    key: ValueKey('deck_${entry.cardId}'),
                                    card: card,
                                    quantity: entry.quantity,
                                    inDeck: true,
                                    onAction: () => ref
                                        .read(deckBuilderProvider.notifier)
                                        .removeFromDeck(entry.cardId),
                                  );
                                },
                                childCount: state.deck.length,
                              ),
                            ),
                    ),

                    // ── SECCIÓN COLECCIÓN ──────────────────────────────
                    SliverToBoxAdapter(
                      child: DeckSectionHeader(
                        title: 'Colección',
                        subtitle: '${state.collection.length} cartas disponibles',
                        color: const Color(0xFF2980B9),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: state.collection.isEmpty
                          ? const SliverToBoxAdapter(
                              child: _EmptyState(
                                text: 'Todas tus cartas están en el mazo.',
                              ),
                            )
                          : SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.63,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final entry = state.collection[index];
                                  final card = _findCard(entry.cardId);
                                  if (card == null) return const SizedBox.shrink();
                                  return DeckCardTile(
                                    key: ValueKey('col_${entry.cardId}'),
                                    card: card,
                                    quantity: entry.quantity,
                                    inDeck: false,
                                    onAction: () => _addToDeck(entry.cardId),
                                  );
                                },
                                childCount: state.collection.length,
                              ),
                            ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── SECCIÓN CARTA PASIVA ────────────────────────────────────────────────────

class _PassiveCardSection extends StatelessWidget {
  final String? activeHeroId;

  const _PassiveCardSection({required this.activeHeroId});

  @override
  Widget build(BuildContext context) {
    if (activeHeroId == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: _EmptyState(text: 'Seleccioná un héroe para ver su carta pasiva.'),
      );
    }

    final passive = HeroesData.passiveForHero(activeHeroId!);
    if (passive == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: _EmptyState(text: 'Este héroe no tiene carta pasiva registrada.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GameCardWidget(card: passive, width: 110, isPassive: true),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Se activa automáticamente',
                  style: TextStyle(
                    color: Color(0xFFF5B800),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Esta carta no entra al mazo. Se juega sola cuando tu héroe baja al 40% de HP y tenés stamina suficiente.',
                  style: TextStyle(
                    color: Color(0xFF9A9AB0),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF5B800).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    passive.lore,
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SECCIÓN DE SELECCIÓN DE HÉROES ─────────────────────────────────────────

class _HeroSelectorSection extends StatelessWidget {
  final String? activeHeroId;
  final List<String> unlockedHeroIds;
  final void Function(String heroId) onSelect;

  const _HeroSelectorSection({
    required this.activeHeroId,
    required this.unlockedHeroIds,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final unlockedHeroes = HeroesData.starterHeroes
        .where((h) => unlockedHeroIds.contains(h.id))
        .toList();

    if (unlockedHeroes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: _EmptyState(text: 'Completá el tutorial para desbloquear tu primer héroe.'),
      );
    }

    return SizedBox(
      height: 172,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        itemCount: unlockedHeroes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final hero = unlockedHeroes[i];
          final isActive = hero.id == activeHeroId;
          return _HeroCard(
            hero: hero,
            isActive: isActive,
            onTap: isActive ? null : () => onSelect(hero.id),
            onInfo: () => HeroStatsDialog.show(context, hero: hero),
          );
        },
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final HeroEntity hero;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback onInfo;

  const _HeroCard({
    required this.hero,
    required this.isActive,
    required this.onTap,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    final factionColor = _factionColor(hero.faction);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? const Color(0xFFFFD700)
                : factionColor.withOpacity(0.3),
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // Avatar
                  _HeroPortrait(hero: hero, factionColor: factionColor),
                  const SizedBox(height: 4),
                  // Nombre
                  Text(
                    hero.name,
                    style: TextStyle(
                      color: isActive ? const Color(0xFFFFD700) : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    hero.title,
                    style: const TextStyle(
                      color: Color(0xFF8A8A9A),
                      fontSize: 9,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Stats mini
                  _MiniStatBar(hero: hero),
                ],
              ),
            ),
            // Botón info
            Positioned(
              top: 4,
              left: 4,
              child: GestureDetector(
                onTap: onInfo,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(Icons.info_outline, size: 12, color: Colors.white70),
                ),
              ),
            ),
            // Badge ACTIVO
            if (isActive)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'ACTIVO',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
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

class _HeroPortrait extends StatelessWidget {
  final HeroEntity hero;
  final Color factionColor;

  const _HeroPortrait({required this.hero, required this.factionColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: factionColor.withOpacity(0.15),
        border: Border.all(color: factionColor.withOpacity(0.4), width: 1.5),
      ),
      child: ClipOval(
        child: Image.asset(
          hero.imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _FallbackEmoji(hero: hero),
        ),
      ),
    );
  }
}

class _FallbackEmoji extends StatelessWidget {
  final HeroEntity hero;
  const _FallbackEmoji({required this.hero});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(Icons.sports_mma, size: 26, color: _factionColor(hero.faction)),
    );
  }
}

class _MiniStatBar extends StatelessWidget {
  final HeroEntity hero;
  const _MiniStatBar({required this.hero});

  @override
  Widget build(BuildContext context) {
    final stats = hero.stats;
    final values = [
      stats.punch,
      stats.kick,
      stats.grapple,
      stats.defense,
      stats.dodge,
    ];
    final labels = ['P', 'K', 'G', 'D', 'E'];
    final colors = [
      const Color(0xFFE74C3C),
      const Color(0xFF2980B9),
      const Color(0xFF8E44AD),
      const Color(0xFF27AE60),
      const Color(0xFFE67E22),
    ];
    const maxStat = 10.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (i) {
        return Column(
          children: [
            Container(
              width: 8,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: (values[i] / maxStat).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors[i],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              labels[i],
              style: const TextStyle(
                color: Color(0xFF8A8A9A),
                fontSize: 7,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ─── HEADER ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int deckSize;
  final int maxDeckSize;

  const _Header({required this.deckSize, required this.maxDeckSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Mazo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: deckSize == maxDeckSize
                    ? const Color(0xFF27AE60).withOpacity(0.5)
                    : Colors.white12,
              ),
            ),
            child: Text(
              '$deckSize / $maxDeckSize',
              style: TextStyle(
                color: deckSize == maxDeckSize
                    ? const Color(0xFF27AE60)
                    : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String text;
  const _EmptyState({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white54, fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ─── HELPERS ─────────────────────────────────────────────────────────────────

// Fuente única de colores de facción: theme/app_theme.dart
Color _factionColor(Faction faction) => theme.factionColor(faction);


// ── Panel de ascensión: gastar medallas para subir estrellas ─────────────────

class _AscensionPanel extends ConsumerWidget {
  final String heroId;
  final int stars;
  final int medals;

  const _AscensionPanel({
    required this.heroId,
    required this.stars,
    required this.medals,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const gold = Color(0xFFFFD700);
    final cost = cfg.GameConfig.ascensionCostFrom(stars);
    final maxed = cost == null;
    final affordable = !maxed && medals >= cost;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: gold.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            // Estrellas actuales
            Row(
              children: List.generate(
                cfg.GameConfig.heroMaxStars,
                (i) => Icon(
                  i < stars ? Icons.star : Icons.star_border,
                  size: 18,
                  color: i < stars ? gold : Colors.white24,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                maxed
                    ? 'Ascensión máxima alcanzada'
                    : 'Ascender: +1 a todos los stats',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
            if (!maxed)
              GestureDetector(
                onTap: affordable
                    ? () async {
                        HapticsService().medium();
                        final ok = await ref
                            .read(playerProvider.notifier)
                            .ascendHero(heroId);
                        if (ok) {
                          SoundService().play('level_up');
                          HapticsService().success();
                        }
                      }
                    : () => HapticsService().error(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: affordable
                        ? gold.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: affordable ? gold : Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.military_tech,
                          size: 14, color: affordable ? gold : Colors.white30),
                      const SizedBox(width: 4),
                      Text(
                        '$cost',
                        style: TextStyle(
                          color: affordable ? gold : Colors.white30,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
