// lib/delivery/screens/deck/deck_builder_screen.dart
//
// Pantalla de construcción de mazo. Dividida en dos secciones:
//   - Mazo actual (arriba): cartas que el jugador usa en batalla
//   - Colección (abajo): cartas que tiene pero no están en el mazo
// Se pueden mover cartas de una sección a la otra con animación.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
                    // SECCIÓN MAZO
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

                    // SECCIÓN COLECCIÓN
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
