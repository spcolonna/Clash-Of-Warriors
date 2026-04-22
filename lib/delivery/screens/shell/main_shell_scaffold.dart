// lib/delivery/screens/shell/main_shell_scaffold.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../deck/deck_builder_screen.dart';
import '../home/home_screen.dart';
import '../shop/shop_screen.dart';

final activeTabProvider = StateProvider<int>((_) => 0);

class MainShellScaffold extends ConsumerWidget {
  const MainShellScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(activeTabProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: KeyedSubtree(
          key: ValueKey(activeTab),
          child: _screenFor(activeTab),
        ),
      ),
      bottomNavigationBar: _BottomNav(
        active: activeTab,
        onChanged: (i) => ref.read(activeTabProvider.notifier).state = i,
      ),
    );
  }

  Widget _screenFor(int tab) {
    switch (tab) {
      case 0:
        return const HomeScreen();
      case 1:
        return const ShopScreen();
      case 2:
        return const DeckBuilderScreen();
      default:
        return const HomeScreen();
    }
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
                icon: '🏠',
                label: 'Inicio',
                active: active == 0,
                onTap: () => onChanged(0),
              ),
              _NavItem(
                key: const GlobalObjectKey('nav_shop'),
                icon: '🃏',
                label: 'Tienda',
                active: active == 1,
                onTap: () => onChanged(1),
              ),
              _NavItem(
                key: const GlobalObjectKey('nav_deck'),
                icon: '⚔️',
                label: 'Mazo',
                active: active == 2,
                onTap: () => onChanged(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String icon;
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
              child: Text(
                icon,
                style: GoogleFonts.notoColorEmoji(
                  textStyle: const TextStyle(fontSize: 22),
                ),
              ),
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
