// lib/infra/services/game_seed_service.dart
//
// Verifica si el seed fue cargado en Firebase y lo ejecuta si no.
// Se llama una sola vez al inicializar la app.
//
// Lógica:
//   - Lee gameSettings/seed { firstLoad: bool }
//   - Si firstLoad == false o el documento no existe → ejecuta el seed
//   - Si firstLoad == true → no hace nada
//
// Para forzar recarga en dev: llamar a resetSeedFlag() desde FirebaseGameService.

import '../firebase/firebase_game_service.dart';
import '../local/game_seed_data.dart';

class GameSeedService {
  final FirebaseGameService _firebase;

  GameSeedService({FirebaseGameService? firebase})
      : _firebase = firebase ?? FirebaseGameService();

  /// Verificar y ejecutar el seed si es necesario.
  /// Retorna true si se ejecutó el seed, false si ya estaba cargado.
  Future<bool> runIfNeeded() async {
    final alreadyLoaded = await _firebase.isSeedLoaded();

    if (alreadyLoaded) {
      print('[GameSeedService] Seed ya cargado. No se hace nada.');
      return false;
    }

    print('[GameSeedService] Seed no encontrado. Ejecutando...');
    await _runSeed();
    print('[GameSeedService] Seed completado.');
    return true;
  }

  /// Fuerza la recarga del seed (solo para desarrollo).
  Future<void> forceReload() async {
    print('[GameSeedService] Forzando recarga del seed...');
    await _firebase.resetSeedFlag();
    await _runSeed();
    print('[GameSeedService] Recarga completada.');
  }

  Future<void> _runSeed() async {
    await _firebase.writeSeed(
      heroes: GameSeedData.heroes,
      cards: GameSeedData.cards,
    );
  }
}