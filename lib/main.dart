import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'delivery/router/app_router.dart';
import 'infra/services/admob_service.dart';
import 'delivery/state/providers.dart';
import 'delivery/theme/app_theme.dart';
import 'infra/services/game_seed_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Firebase.initializeApp();
  final seedService = GameSeedService();
  await seedService.runIfNeeded();
  
  await AdMobService().initialize();

  runApp(const ProviderScope(child: ClashOfStylesApp()));
}

class ClashOfStylesApp extends ConsumerWidget {
  const ClashOfStylesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final router = ref.watch(appRouterProvider);

    // Listener global — carga el player apenas hay usuario logueado
    ref.listen(authStateProvider, (prev, next) {
      next.whenData((user) {
        if (user != null && ref.read(playerProvider) == null) {
          ref.read(playerProvider.notifier).loadPlayer(user.uid);
        }
      });
    });

    return MaterialApp.router(
      title: 'Clash Of Warriors',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      locale: locale,
      routerConfig: router,
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
        Locale('pt'),
        Locale('ja'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}