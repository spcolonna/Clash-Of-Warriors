// lib/delivery/screens/home/home_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../state/providers.dart';
import '../../widgets/tutorial_spotlight_overlay.dart';
import '../help/how_to_play_screen.dart';
import '../shell/main_shell_scaffold.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);

    if (player == null) {
      Future.microtask(() async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await ref.read(playerProvider.notifier).loadPlayer(user.uid);
        }
      });
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D0D),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final needsShopTutorial =
        player.tutorialBattleComplete && !player.starterCardPurchased;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ResourceBar(
                    softCoins: player.softCoins,
                    medals: player.medals,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '¡Bienvenido,\nGuerrero!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    player.selectedFactionId != null
                        ? 'Facción: ${_factionName(player.selectedFactionId!)}'
                        : '',
                    style: const TextStyle(
                      color: Color(0xFF8A8A9A),
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  _PrimaryActionCard(
                    title: '⚔️ Entrar a la Arena',
                    subtitle: 'Buscar combate contra otro guerrero',
                    onTap: () {
                      // TODO: matchmaking real
                    },
                  ),
                  const SizedBox(height: 16),
                  _SecondaryActionCard(
                    icon: '📖',
                    title: 'Cómo jugar',
                    subtitle: 'Tabla de choques, cálculo de daño y stats',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HowToPlayScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
        if (needsShopTutorial) const _ShopTabSpotlight(),
      ],
    );
  }

  String _factionName(String factionId) => switch (factionId) {
    'shaolin' => 'Guardianes Shaolin',
    'ninja' => 'Clan de las Sombras',
    'judoka' => 'Hermandad de Hierro',
    'boxer' => 'Boxeadores del Cemento',
    'capoeira' => 'Capoeiristas Libres',
    _ => '',
  };
}

class _ShopTabSpotlight extends ConsumerWidget {
  const _ShopTabSpotlight();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TutorialSpotlightOverlay(
      targetKey: const GlobalObjectKey('nav_shop'),
      message:
      '¡Hora de fortalecer tu mazo!\nTocá la Tienda para comprar tu primera carta de facción.',
      onDismiss: () {
        ref.read(activeTabProvider.notifier).state = 1;
      },
      spotlightPadding: 8,
    );
  }
}

class _ResourceBar extends StatelessWidget {
  final int softCoins;
  final int medals;

  const _ResourceBar({required this.softCoins, required this.medals});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ResourceChip(
          icon: '🪙',
          value: softCoins,
          color: const Color(0xFFF5B800),
        ),
        const SizedBox(width: 12),
        _ResourceChip(icon: '🏅', value: medals, color: Colors.amber),
      ],
    );
  }
}

class _ResourceChip extends StatelessWidget {
  final String icon;
  final int value;
  final Color color;

  const _ResourceChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: GoogleFonts.notoColorEmoji(
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PrimaryActionCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE74C3C).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.notoColorEmoji(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card secundaria con estilo más discreto — usada para "Cómo jugar".
class _SecondaryActionCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SecondaryActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Text(
              icon,
              style: GoogleFonts.notoColorEmoji(
                textStyle: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF8A8A9A),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
