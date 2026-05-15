// lib/delivery/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/login_screen.dart';
import '../screens/battle/battle_screen.dart';
import '../screens/battle/end_battle_screen.dart';
import '../screens/battle/pre_battle_screens.dart';
import '../screens/heroes/character_select_screen.dart';
import '../screens/shell/main_shell_scaffold.dart';
import '../state/providers.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Notifica al router cuando auth o player cambian para re-evaluar redirects
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final authState = ref.read(authStateProvider);

      // Auth todavía resolviendo — no redirigir (evita flash de login)
      if (authState is AsyncLoading) return null;

      // Sin usuario autenticado → login
      final user = authState.value;
      if (user == null) {
        if (location == '/login') return null;
        return '/login';
      }

      // Usuario autenticado — verificar onboarding
      final player = ref.read(playerProvider);
      if (player == null) return null;

      if (player.isOnboardingComplete) {
        if (location == '/character-select' || location == '/login') return '/home';
        return null;
      }

      if (player.selectedFactionId == null) {
        if (location == '/character-select') return null;
        return '/character-select';
      }

      if (!player.tutorialBattleComplete) {
        if (['/pre-battle', '/battle', '/end-battle'].contains(location)) return null;
        return '/pre-battle';
      }

      if (location == '/character-select' || location == '/login') return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (_, __) => _fadeSlidePage(const LoginScreen()),
      ),
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

/// Notifica al GoRouter cuando auth o player cambian,
/// forzando re-evaluación del redirect sin necesidad de navegación manual.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
    ref.listen(playerProvider,    (_, __) => notifyListeners());
  }
}

CustomTransitionPage<T> _fadeSlidePage<T>(Widget child) =>
    CustomTransitionPage<T>(
      child: child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          child,
    );
