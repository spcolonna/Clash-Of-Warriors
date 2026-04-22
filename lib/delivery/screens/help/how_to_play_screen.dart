// lib/delivery/screens/help/how_to_play_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/entities/game_card.dart';

/// Pantalla completa — accesible desde Home
class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text('Cómo jugar'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: HowToPlayContent(),
        ),
      ),
    );
  }
}

/// Dialog — accesible desde BattleScreen (botón "?")
class HowToPlayDialog extends StatelessWidget {
  const HowToPlayDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Cómo jugar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: HowToPlayContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Contenido compartido entre Dialog y pantalla completa.
class HowToPlayContent extends StatelessWidget {
  const HowToPlayContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _Section(
          title: 'Objetivo',
          body: 'Derrotá a tu rival reduciendo su HP a 0. Cada round armás una '
              'secuencia de 5 cartas que se enfrentan simultáneamente contra '
              'las del rival.',
        ),
        _Section(
          title: 'Tipos de cartas',
          body: 'Hay 5 tipos de cartas. Cada una le gana a dos y pierde contra dos:',
        ),
        _MatchupTable(),
        _Section(
          title: 'Cómo se calcula el daño',
          body: 'daño_base × (stat_del_heroe / 10)\n\n'
              'Ejemplo: tu héroe tiene Puño 7, y usás un Golpe Básico '
              '(daño base 8) → daño real = 8 × (7/10) = 5.6 ≈ 6 de daño.\n\n'
              'Si la carta coincide con tu facción, sumás +10% extra.',
        ),
        _Section(
          title: 'Stamina',
          body: 'Cada carta cuesta stamina. Tu héroe empieza el round con su '
              'stamina máxima. Si no te alcanza, dejá el slot vacío — pero '
              'cuidado: si el rival te ataca en ese slot, el daño entra sin '
              'resistencia.',
        ),
        _Section(
          title: 'Rondas y mazo',
          body: 'Arrancás con 7 cartas en mano de un mazo de 20. Al final de '
              'cada round, las cartas usadas van al descarte y robás hasta '
              'tener 7 otra vez. Si el mazo se vacía, el descarte se mezcla y '
              'vuelve a ser mazo.',
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFE74C3C),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFFF0F0F0),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchupTable extends StatelessWidget {
  const _MatchupTable();

  static const _data = [
    ('👊', 'Puño',    Color(0xFFE74C3C), CardCategory.kick,    CardCategory.dodge),
    ('🦵', 'Patada',  Color(0xFFE67E22), CardCategory.grapple, CardCategory.defense),
    ('🤼', 'Agarre',  Color(0xFF8E44AD), CardCategory.punch,   CardCategory.dodge),
    ('🛡️', 'Defensa', Color(0xFF2980B9), CardCategory.punch,   CardCategory.grapple),
    ('💨', 'Esquive', Color(0xFF27AE60), CardCategory.kick,    CardCategory.defense),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(32),   // emoji
          1: FixedColumnWidth(72),   // nombre
          2: FixedColumnWidth(48),   // "gana a"
          3: FixedColumnWidth(28),   // emoji1
          4: FlexColumnWidth(),      // nombre1
          5: FixedColumnWidth(28),   // emoji2
          6: FlexColumnWidth(),      // nombre2
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: _data.map((row) {
          return TableRow(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.06),
                  width: 1,
                ),
              ),
            ),
            children: [
              // Emoji del tipo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                child: Text(
                  row.$1,
                  style: GoogleFonts.notoColorEmoji(
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              // Nombre del tipo
              Text(
                row.$2,
                style: TextStyle(
                  color: row.$3,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // "gana a"
              Text(
                'gana a',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
              // Emoji ganado 1
              Text(
                _emoji(row.$4),
                style: GoogleFonts.notoColorEmoji(
                  textStyle: const TextStyle(fontSize: 16),
                ),
                textAlign: TextAlign.center,
              ),
              // Nombre ganado 1
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  _label(row.$4),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              // Emoji ganado 2
              Text(
                _emoji(row.$5),
                style: GoogleFonts.notoColorEmoji(
                  textStyle: const TextStyle(fontSize: 16),
                ),
                textAlign: TextAlign.center,
              ),
              // Nombre ganado 2
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  _label(row.$5),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _emoji(CardCategory c) => switch (c) {
    CardCategory.punch   => '👊',
    CardCategory.kick    => '🦵',
    CardCategory.grapple => '🤼',
    CardCategory.defense => '🛡️',
    CardCategory.dodge   => '💨',
  };

  String _label(CardCategory c) => switch (c) {
    CardCategory.punch   => 'Puño',
    CardCategory.kick    => 'Patada',
    CardCategory.grapple => 'Agarre',
    CardCategory.defense => 'Defensa',
    CardCategory.dodge   => 'Esquive',
  };
}
