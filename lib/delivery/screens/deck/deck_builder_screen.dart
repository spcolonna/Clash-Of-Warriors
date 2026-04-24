// lib/delivery/screens/deck/deck_builder_screen.dart
//
// Pantalla de construcción de mazo. Dividida en tres secciones:
//   - Héroes (arriba): seleccionar el héroe activo entre los desbloqueados
//   - Mazo actual (medio): cartas que el jugador usa en batalla
//   - Colección (abajo): cartas que tiene pero no están en el mazo

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../infra/local/heroes_data.dart';
import '../../../domain/entities/hero_entity.dart';
import '../../state/providers.dart';
import '../../state/deck_builder_provider.dart';
import '../../widgets/deck/deck_card_tile.dart';
import '../../widgets/deck/deck_section_header.dart';

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

  @override
  Widget build(BuildContext context) {
    final deckState = ref.watch(deckBuilderProvider);
    final player = ref.watch(playerProvider);

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
                        unlockedHeroIds:
                            player?.unlockedHeroIds ?? const [],
                        onSelect: (heroId) => ref
                            .read(playerProvider.notifier)
                            .updateActiveHero(heroId),
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
                                text:
                                    'Tu mazo está vacío.\nAgregá cartas desde tu colección.',
                              ),
                            )
                          : SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.7,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final entry = state.deck[index];
                                  return DeckCardTile(
                                    key: ValueKey('deck_${entry.cardId}'),
                                    cardId: entry.cardId,
                                    quantity: entry.quantity,
                                    inDeck: true,
                                    onTap: () => ref
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
                        subtitle:
                            '${state.collection.length} cartas disponibles',
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
                                childAspectRatio: 0.7,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final entry = state.collection[index];
                                  return DeckCardTile(
                                    key: ValueKey('col_${entry.cardId}'),
                                    cardId: entry.cardId,
                                    quantity: entry.quantity,
                                    inDeck: false,
                                    onTap: () => ref
                                        .read(deckBuilderProvider.notifier)
                                        .addToDeck(entry.cardId),
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

  const _HeroCard({
    required this.hero,
    required this.isActive,
    required this.onTap,
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
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  // Avatar
                  _HeroPortrait(hero: hero, factionColor: factionColor),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 2),
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
                  const SizedBox(height: 6),
                  // Stats mini
                  _MiniStatBar(hero: hero),
                ],
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
      child: Text(
        _factionEmoji(hero.faction),
        style: GoogleFonts.notoColorEmoji(
          textStyle: const TextStyle(fontSize: 26),
        ),
      ),
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

Color _factionColor(Faction faction) => switch (faction) {
      Faction.shaolin => const Color(0xFFE65100),
      Faction.ninja => const Color(0xFF1A1A2E),
      Faction.judoka => const Color(0xFF1565C0),
      Faction.boxer => const Color(0xFFC62828),
      Faction.capoeira => const Color(0xFF2E7D32),
    };

String _factionEmoji(Faction faction) => switch (faction) {
      Faction.shaolin => '🥋',
      Faction.ninja => '🥷',
      Faction.judoka => '🤼',
      Faction.boxer => '🥊',
      Faction.capoeira => '🎭',
    };
