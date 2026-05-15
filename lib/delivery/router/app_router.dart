// lib/delivery/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/battle/battle_screen.dart';
import '../screens/battle/end_battle_screen.dart';
import '../screens/battle/pre_battle_screens.dart';
import '../screens/heroes/character_select_screen.dart';
import '../screens/shell/main_shell_scaffold.dart';
import '../state/providers.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final player = ref.read(playerProvider);
      final location = state.matchedLocation;

      if (player == null) return null;

      if (player.isOnboardingComplete) {
        // Solo bloqueamos character-select; las rutas de batalla quedan libres
        // para batallas de arena post-tutorial.
        if (location == '/character-select') return '/home';
        return null;
      }

      if (player.selectedFactionId == null) {
        if (location == '/character-select') return null;
        return '/character-select';
      }

      if (!player.tutorialBattleComplete) {
        if (['/pre-battle', '/battle', '/end-battle'].contains(location)) {
          return null;
        }
        return '/pre-battle';
      }

      if (location == '/character-select') return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (_, __) => _fadeSlidePage(const CharacterSelectScreen()),
      ),
      GoRoute(
        path: '/character-select',
        pageBuilder: (_, __) => _fadeSlidePage(const CharacterSelectScreen()),
      ),
      GoRoute(
        path: '/pre-battle',
        pageBuilder: (_, __) => _fadeSlidePage(const PreBattleScreen()),
      ),
      GoRoute(
        path: '/battle',
        pageBuilder: (_, __) => _fadeSlidePage(const BattleScreen()),
      ),
      GoRoute(
        path: '/end-battle',
        pageBuilder: (_, __) => _fadeSlidePage(const EndBattleScreen()),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (_, __) => _fadeSlidePage(const MainShellScaffold()),
      ),
    ],
  );
});

/// Transición slide puro — Transform.translate, sin saveLayer, sin FadeTransition.
/// FadeTransition requiere un offscreen buffer (saveLayer) en cada frame,
/// igual que Opacity. Solo SlideTransition usa GPU matrix: mucho más barato.
CustomTransitionPage<T> _fadeSlidePage<T>(Widget child) =>
    CustomTransitionPage<T>(
      child: child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          child,
    );
