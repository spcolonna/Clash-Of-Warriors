// lib/delivery/screens/shell/main_shell_scaffold.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../deck/deck_builder_screen.dart';
import '../donations/donations_screen.dart';
import '../home/home_screen.dart';
import '../shop/shop_screen.dart';
import '../story/story_hub_screen.dart';
import '../../state/providers.dart';
import '../../widgets/tutorial_spotlight_overlay.dart';

final activeTabProvider = StateProvider<int>((_) => 0);

class MainShellScaffold extends ConsumerWidget {
  const MainShellScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(activeTabProvider);
    final player = ref.watch(playerProvider);

    // Spotlight "andá a la Tienda": debe pintar SOBRE la barra de navegación
    // (que es un slot aparte del Scaffold), así que va a nivel del shell —
    // dentro del home quedaba tapado por la nav bar.
    final needsShopTutorial = activeTab == 0 &&
        (player?.tutorialBattleComplete ?? false) &&
        !(player?.starterCardPurchased ?? true);

    final scaffold = Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Fondo panorámico ──────────────────────────────────────────────
          // DecorationImage con alignment controla qué porción de la imagen
          // se ve: alignment.x = -1 muestra el borde izquierdo, +1 el derecho.
          // fit: BoxFit.cover llena el contenedor sin distorsión.
          // El contenedor ocupa el 55% superior → menos zoom que a pantalla completa.
          // tab 0 → borde izquierdo, tab 1 → centro, tab 2 → borde derecho
          Builder(
            builder: (context) {
              const positions = [-1.0, -0.33, 0.33, 1.0, 1.0];
              final targetAlignX = positions[activeTab];

              return TweenAnimationBuilder<double>(
                tween: Tween<double>(end: targetAlignX),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOut,
                builder: (_, alignX, __) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage('assets/images/bg_home.png'),
                      fit: BoxFit.cover,
                      // -1 = borde izquierdo de la imagen, +1 = borde derecho
                      alignment: Alignment(alignX, 0.5),
                    ),
                  ),
                  // Capa oscura encima para que el contenido sea legible
                  foregroundDecoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x1A0D0D0D), // 10% arriba
                        Color(0x550D0D0D), // 33% abajo
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // ── Contenido de tabs ─────────────────────────────────────────────
          IndexedStack(
            index: activeTab,
            children: const [
              HomeScreen(),
              ShopScreen(),
              DeckBuilderScreen(),
              StoryHubScreen(),
              DonationsScreen(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        active: activeTab,
        onChanged: (i) => ref.read(activeTabProvider.notifier).state = i,
      ),
    );

    if (!needsShopTutorial) return scaffold;

    // El spotlight va por encima del Scaffold ENTERO (body + nav bar), así el
    // círculo puede caer sobre el tab "Tienda" sin quedar tapado.
    return Stack(
      children: [
        scaffold,
        TutorialSpotlightOverlay(
          targetKey: const GlobalObjectKey('nav_shop'),
          message:
              '¡Hora de fortalecer tu mazo!\nTocá la Tienda para comprar tu primera carta de facción.',
          onDismiss: () => ref.read(activeTabProvider.notifier).state = 1,
          spotlightPadding: 8,
        ),
      ],
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int active;
  final ValueChanged<int> onChanged;

  const _BottomNav({required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        border: Border(top: BorderSide(color: Color(0xFF2A2A3E))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                key: const GlobalObjectKey('nav_home'),
                icon: Icons.home_rounded,
                label: 'Inicio',
                active: active == 0,
                onTap: () => onChanged(0),
              ),
              _NavItem(
                key: const GlobalObjectKey('nav_shop'),
                icon: Icons.store_rounded,
                label: 'Tienda',
                active: active == 1,
                onTap: () => onChanged(1),
              ),
              _NavItem(
                key: const GlobalObjectKey('nav_deck'),
                icon: Icons.style_rounded,
                label: 'Mazo',
                active: active == 2,
                onTap: () => onChanged(2),
              ),
              _NavItem(
                key: const GlobalObjectKey('nav_story'),
                icon: Icons.auto_stories_rounded,
                label: 'Historia',
                active: active == 3,
                onTap: () => onChanged(3),
              ),
              _NavItem(
                key: const GlobalObjectKey('nav_donations'),
                icon: Icons.favorite_rounded,
                label: 'Apoyar',
                active: active == 4,
                onTap: () => onChanged(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFFE74C3C) : const Color(0xFF8A8A9A);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: active ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
