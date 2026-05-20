import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DonationsScreen extends StatelessWidget {
  const DonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xD9000000), // 85% en la parte superior
              Color(0xF0000000), // 94% en la parte inferior
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(),
                const SizedBox(height: 24),
                _PillarsSection(),
                const SizedBox(height: 28),
                _RoadmapSection(),
                const SizedBox(height: 28),
                _DonateButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Encabezado ──────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.person, size: 13, color: AppColors.gold),
                  SizedBox(width: 5),
                  Text(
                    'UN SOLO DESARROLLADOR',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Apoyá el\nProyecto',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Clash of Warriors es un juego independiente construido por una sola persona, '
          'desde el motor de combate hasta cada carta. Cada donación va directo al juego '
          'que estás jugando — sin inversores, sin intermediarios.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 14,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

// ── Pilares ──────────────────────────────────────────────────────────────────

class _PillarsSection extends StatelessWidget {
  static const _pillars = [
    _Pillar(Icons.extension_rounded,      'Game Design',    'Balanceo de cartas, mecánicas nuevas y profundidad estratégica.'),
    _Pillar(Icons.phone_android_rounded,  'Interfaz',       'Animaciones fluidas, UX pulida y una experiencia visual de nivel.'),
    _Pillar(Icons.menu_book_rounded,      'Historia',       'Lore, facciones con trasfondo y una narrativa que enganche.'),
    _Pillar(Icons.sports_esports_rounded, 'Modos de juego', 'Torneos, modo historia, desafíos diarios y más formas de jugar.'),
    _Pillar(Icons.people_rounded,         'Multijugador',   'Motor online en tiempo real, matchmaking y ranking global.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EN QUÉ QUEREMOS MEJORAR',
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 14),
        ..._pillars.map((p) => _PillarTile(pillar: p)),
      ],
    );
  }
}

class _Pillar {
  final IconData icon;
  final String title;
  final String description;
  const _Pillar(this.icon, this.title, this.description);
}

class _PillarTile extends StatelessWidget {
  final _Pillar pillar;
  const _PillarTile({required this.pillar});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(pillar.icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pillar.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  pillar.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                    height: 1.4,
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

// ── Roadmap ───────────────────────────────────────────────────────────────────

class _RoadmapSection extends StatelessWidget {
  static const _phases = [
    _Phase(
      label: 'FASE 1',
      title: 'Fundaciones',
      color: Color(0xFF4CAF50),
      items: [
        _RoadmapItem(Icons.palette_rounded,       'Ilustraciones de personajes',     'Contratar artistas freelance para ilustraciones originales de héroes y cartas.'),
        _RoadmapItem(Icons.music_note_rounded,    'Música y efectos de sonido',      'Compositor indie para tracks de combate y efectos que transmitan impacto.'),
        _RoadmapItem(Icons.auto_fix_high_rounded, 'Pulido de UX y animaciones',      'Tiempo de desarrollo dedicado a transiciones, feedback visual y fluidez general.'),
      ],
    ),
    _Phase(
      label: 'FASE 2',
      title: 'Contenido',
      color: Color(0xFF2196F3),
      items: [
        _RoadmapItem(Icons.menu_book_rounded,      'Modo historia',                  'Narrativa por capítulos con diálogos, decisiones y progresión de personaje.'),
        _RoadmapItem(Icons.style_rounded,          'Nuevas facciones y cartas',      'Más héroes jugables, habilidades únicas y mazos estratégicos por facción.'),
        _RoadmapItem(Icons.sports_kabaddi_rounded, 'Nuevos modos de juego',          'Modo torneo, desafíos diarios, modo draft y eventos de temporada.'),
      ],
    ),
    _Phase(
      label: 'FASE 3',
      title: 'Multijugador',
      color: Color(0xFF9C27B0),
      items: [
        _RoadmapItem(Icons.dns_rounded,           'Servidor dedicado',               'Infraestructura backend robusta para partidas online en tiempo real.'),
        _RoadmapItem(Icons.people_rounded,        'Matchmaking y ranking global',    'Sistema de emparejamiento justo, ELO global y tabla de líderes en vivo.'),
        _RoadmapItem(Icons.emoji_events_rounded,  'Torneos online',                  'Competencias organizadas, premios en tokens y eventos para la comunidad.'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ROADMAP',
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'A dónde va cada donación',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        ..._phases.map((phase) => _PhaseCard(phase: phase)),
      ],
    );
  }
}

class _Phase {
  final String label;
  final String title;
  final Color color;
  final List<_RoadmapItem> items;
  const _Phase({
    required this.label,
    required this.title,
    required this.color,
    required this.items,
  });
}

class _RoadmapItem {
  final IconData icon;
  final String title;
  final String detail;
  const _RoadmapItem(this.icon, this.title, this.detail);
}

class _PhaseCard extends StatefulWidget {
  final _Phase phase;
  const _PhaseCard({required this.phase});

  @override
  State<_PhaseCard> createState() => _PhaseCardState();
}

class _PhaseCardState extends State<_PhaseCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final phase = widget.phase;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: phase.color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: phase.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: phase.color.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      phase.label,
                      style: TextStyle(
                        color: phase.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      phase.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white38,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            Divider(color: Colors.white.withValues(alpha: 0.07), height: 1),
            ...phase.items.map((item) => _RoadmapTile(item: item, color: phase.color)),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

class _RoadmapTile extends StatelessWidget {
  final _RoadmapItem item;
  final Color color;
  const _RoadmapTile({required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 16, color: color.withValues(alpha: 0.8)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.detail,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Botón de donación ─────────────────────────────────────────────────────────

class _DonateButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              const Icon(Icons.favorite_rounded, color: AppColors.gold, size: 32),
              const SizedBox(height: 10),
              const Text(
                '¿Querés apoyar el proyecto?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Cualquier monto ayuda a que esto siga creciendo.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: abrir URL de donación (Ko-fi, Patreon, etc.)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_rounded, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Donar al proyecto',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'El 100% de lo donado se reinvierte en el juego.\nNo hay empresa. Solo el juego y quienes lo juegan.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 12,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
