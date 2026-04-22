import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../state/providers.dart';
import 'login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          final player = ref.watch(playerProvider);

          if (player == null) {
            Future.microtask(() {
              ref.read(playerProvider.notifier).loadPlayer(snapshot.data!.uid);
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Perfil cargado — navegar a la pantalla correcta
          Future.microtask(() {
            if (!context.mounted) return;
            final target = _resolveRoute(player);
            context.go(target);
          });

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return const LoginScreen();
      },
    );
  }

  String _resolveRoute(player) {
    if (player.selectedFactionId == null)    return '/character-select';
    if (!player.tutorialBattleComplete)      return '/pre-battle';
    if (!player.isOnboardingComplete)        return '/home';
    return '/home';
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../state/providers.dart';
// import '../battle/pre_battle_screens.dart';
// import '../heroes/character_select_screen.dart';
// import '../home/home_screen.dart';
// import 'login_screen.dart';
//
// class AuthGate extends ConsumerWidget {
//   const AuthGate({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//
//         if (snapshot.hasData) {
//           final player = ref.watch(playerProvider);
//
//           if (player == null) {
//             Future.microtask(() {
//               ref.read(playerProvider.notifier).loadPlayer(snapshot.data!.uid);
//             });
//             return const Scaffold(
//               body: Center(child: CircularProgressIndicator()),
//             );
//           }
//
//           return _resolveScreen(player);
//         }
//
//         return const LoginScreen();
//       },
//     );
//   }
//
//   Widget _resolveScreen(player) {
//     // Paso 1: no eligió facción todavía
//     if (player.selectedFactionId == null) {
//       return const CharacterSelectScreen();
//     }
//
//     // Paso 2: eligió facción pero no ganó la primera batalla
//     // → va a PreBattleScreen para jugar
//     if (!player.tutorialBattleComplete) {
//       return const PreBattleScreen();
//     }
//
//     // Pasos 3 y 4: ganó la batalla, todavía no completó el onboarding
//     // pero ya tiene que ver la HomeScreen (con el modal forzado de compra)
//     // La HomeScreen misma maneja si mostrar el modal o no
//     return const HomeScreen();
//   }
// }