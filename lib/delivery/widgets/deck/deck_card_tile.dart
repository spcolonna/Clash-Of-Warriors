// lib/delivery/widgets/deck/deck_card_tile.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeckCardTile extends StatefulWidget {
  final String cardId;
  final int quantity;
  final bool inDeck;
  final VoidCallback onTap;

  const DeckCardTile({
    super.key,
    required this.cardId,
    required this.quantity,
    required this.inDeck,
    required this.onTap,
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
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.inDeck
                  ? const Color(0xFFE74C3C).withOpacity(0.5)
                  : const Color(0xFF888888).withOpacity(0.5),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAEAEA),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '🃏',
                            style: GoogleFonts.notoColorEmoji(
                              textStyle: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.cardId,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Badge de cantidad
              if (widget.quantity > 1)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(10),
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
              // Badge de acción
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: widget.inDeck
                        ? Colors.red
                        : const Color(0xFF27AE60),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.inDeck ? Icons.remove : Icons.add,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
