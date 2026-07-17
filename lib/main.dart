import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'delivery/router/app_router.dart';
import 'delivery/state/providers.dart';
import 'infra/services/admob_service.dart';
import 'delivery/theme/app_theme.dart';
import 'infra/services/game_seed_service.dart';
import 'infra/sound/sound_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Firebase.initializeApp();
  try {
    final seedService = GameSeedService();
    await seedService.runIfNeeded();
  } catch (e) {
    // El seed check requiere auth — se omite en dispositivos sin sesión activa.
    // El seed se ejecuta la primera vez desde una sesión autenticada.
    debugPrint('[main] Seed check omitido: $e');
  }
  
  await AdMobService().initialize();

  // Pre-carga de SFX en background (no bloquea el arranque)
  SoundService().init().ignore();

  runApp(const ProviderScope(child: ClashOfStylesApp()));
}

class ClashOfStylesApp extends ConsumerWidget {
  const ClashOfStylesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final router = ref.watch(appRouterProvider);

    // Carga el player si hay usuario y aún no está en memoria.
    // ref.watch (no listen) garantiza que esto corre en CADA build,
    // incluida la primera vez que auth ya tiene valor.
    // Pre-carga config del juego desde Firestore (cartas, héroes, rewards)
    ref.watch(gameConfigProvider);

    final authState = ref.watch(authStateProvider);
    debugPrint('[AUTH] state=${authState.runtimeType} user=${authState.value?.uid ?? "null"}');
    authState.whenData((user) {
      debugPrint('[AUTH] whenData user=${user?.uid ?? "null"} player=${ref.read(playerProvider) == null ? "null" : "loaded"}');
      if (user != null && ref.read(playerProvider) == null) {
        debugPrint('[AUTH] → scheduling loadPlayer');
        Future.microtask(
          () => ref.read(playerProvider.notifier).loadPlayer(user.uid),
        );
      }
    });

    return MaterialApp.router(
      title: 'Clash Of Warriors',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      locale: locale,
      routerConfig: router,
      // Decisión de producto: el UI está escrito en español; declarar otros
      // idiomas sin traducciones reales era una promesa falsa. Si más adelante
      // se quiere EN/PT, la migración empieza por home + batalla.
      supportedLocales: const [
        Locale('es'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}