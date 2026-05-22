// lib/delivery/widgets/deck/deck_card_tile.dart

import 'package:flutter/material.dart';
import '../../../domain/entities/game_card.dart';
import '../card_preview_dialog.dart';
import '../game_card_widget.dart';

class DeckCardTile extends StatefulWidget {
  final GameCard card;
  final int quantity;
  final bool inDeck;
  final VoidCallback onAction;

  const DeckCardTile({
    super.key,
    required this.card,
    required this.quantity,
    required this.inDeck,
    required this.onAction,
  });

  @override
  State<DeckCardTile> createState() => _DeckCardTileState();
}

class _DeckCardTileState extends State<DeckCardTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeOutBack.transform(_controller.value);
        return Transform.scale(
          scale: t,
          child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Carta completa — tap abre preview con lore
              GestureDetector(
                onTap: () => CardPreviewDialog.show(context, widget.card),
                child: GameCardWidget(
                  card: widget.card,
                  width: cardWidth,
                ),
              ),

              // Badge cantidad (arriba izquierda)
              if (widget.quantity > 1)
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '×${widget.quantity}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Botón agregar / quitar (abajo derecha)
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: widget.onAction,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: widget.inDeck
                          ? const Color(0xFFE74C3C)
                          : const Color(0xFF27AE60),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.inDeck ? Icons.remove : Icons.add,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
