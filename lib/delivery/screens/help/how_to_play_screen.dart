// lib/delivery/screens/help/how_to_play_screen.dart

import 'package:flutter/material.dart';

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
          body: 'Cada carta cuesta stamina. La stamina arranca escasa (3 en la '
              'ronda 1) y crece +1 por ronda hasta el máximo de tu héroe: las '
              'primeras rondas son de tanteo y las últimas son los golpes '
              'grandes. Si no gastás todo, la ronda siguiente arrancás con +1. '
              'Un slot vacío recibe daño sin resistencia.',
        ),
        _Section(
          title: 'Apertura',
          body: 'Cuando colocás tu carta en el slot 1 se revela la apertura del '
              'rival — y la tuya queda sellada: ya no se puede cambiar. Tocá su '
              'carta revelada para verla en grande. Usá esa información para '
              'planear los slots 2 y 3.',
        ),
        _Section(
          title: 'Cadenas de combo',
          body: 'Puño → Patada → Agarre → Puño. Si ganás un slot y en el '
              'siguiente jugás la categoría que encadena, esa carta pega +50%. '
              'El eslabón dorado entre tus slots avisa cuando armaste cadena.',
        ),
        _Section(
          title: 'Defensa y ronda perfecta',
          body: 'La Defensa, aunque pierda el choque, bloquea la mitad del daño '
              'entrante: es la jugada segura. Y si ganás los 3 slots de una '
              'ronda hacés RONDA PERFECTA: +25% de daño extra.',
        ),
        _Section(
          title: 'Scouts',
          body: 'Empezás con 1 scout para espiar un slot oculto del rival. '
              'Ganás otro por cada ronda que ganes (máximo 2 en reserva). '
              'Gastalo cuando la información valga más que la sorpresa.',
        ),
        _Section(
          title: 'Rondas y mazo',
          body: 'Arrancás con 5 cartas en mano de un mazo de 20. Al final de '
              'cada round podés guardar una carta; el resto se descarta y '
              'robás hasta tener 5 otra vez. Si el mazo se vacía, el descarte '
              'se mezcla y vuelve a ser mazo.',
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
    (Icons.sports_mma,      'Puño',    Color(0xFFE74C3C), CardCategory.kick,    CardCategory.dodge),
    (Icons.sports_martial_arts,  'Patada',  Color(0xFFE67E22), CardCategory.grapple, CardCategory.defense),
    (Icons.people_alt,      'Agarre',  Color(0xFF8E44AD), CardCategory.punch,   CardCategory.dodge),
    (Icons.shield,          'Defensa', Color(0xFF2980B9), CardCategory.punch,   CardCategory.grapple),
    (Icons.directions_run,  'Esquive', Color(0xFF27AE60), CardCategory.kick,    CardCategory.defense),
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
          0: FixedColumnWidth(32),
          1: FixedColumnWidth(72),
          2: FixedColumnWidth(48),
          3: FixedColumnWidth(28),
          4: FlexColumnWidth(),
          5: FixedColumnWidth(28),
          6: FlexColumnWidth(),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                child: Icon(row.$1, size: 18, color: row.$3),
              ),
              Text(
                row.$2,
                style: TextStyle(
                  color: row.$3,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'gana a',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Icon(_icon(row.$4), size: 16, color: _color(row.$4)),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  _label(row.$4),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              Icon(_icon(row.$5), size: 16, color: _color(row.$5)),
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

  IconData _icon(CardCategory c) => switch (c) {
    CardCategory.punch   => Icons.sports_mma,
    CardCategory.kick    => Icons.sports_martial_arts,
    CardCategory.grapple => Icons.people_alt,
    CardCategory.defense => Icons.shield,
    CardCategory.dodge   => Icons.directions_run,
  };

  Color _color(CardCategory c) => switch (c) {
    CardCategory.punch   => const Color(0xFFE74C3C),
    CardCategory.kick    => const Color(0xFFE67E22),
    CardCategory.grapple => const Color(0xFF8E44AD),
    CardCategory.defense => const Color(0xFF2980B9),
    CardCategory.dodge   => const Color(0xFF27AE60),
  };

  String _label(CardCategory c) => switch (c) {
    CardCategory.punch   => 'Puño',
    CardCategory.kick    => 'Patada',
    CardCategory.grapple => 'Agarre',
    CardCategory.defense => 'Defensa',
    CardCategory.dodge   => 'Esquive',
  };
}
