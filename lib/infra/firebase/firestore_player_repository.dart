// lib/infra/firebase/firestore_player_repository.dart
//
// El repositorio ya no habla directamente con Firestore.
// Delega todas las operaciones en FirebaseGameService.

import '../../domain/entities/player_profile.dart';
import '../../domain/repositories/player_repository.dart';
import 'firebase_game_service.dart';

class FirestorePlayerRepository implements PlayerRepository {
  final FirebaseGameService _service;

  FirestorePlayerRepository({FirebaseGameService? service})
      : _service = service ?? FirebaseGameService();

  @override
  Future<PlayerProfile?> getPlayer(String uid) => _service.getPlayer(uid);

  @override
  Future<void> savePlayer(PlayerProfile player) => _service.savePlayer(player);

  // ── Tutorial steps ───────────────────────────────────────────────────────

  Future<void> saveFactionSelection({
    required String uid,
    required String factionId,
    required String heroId,
    required List<String> starterDeckIds,
  }) =>
      _service.saveFactionSelection(
        uid: uid,
        factionId: factionId,
        heroId: heroId,
        starterDeckIds: starterDeckIds,  
      );

  Future<void> completeTutorialBattle({
    required String uid,
    required int medalsEarned,
    required int coinsEarned,
    required String rivalHeroId,
  }) =>
      _service.completeTutorialBattle(
        uid: uid,
        medalsEarned: medalsEarned,
        coinsEarned: coinsEarned,
        rivalHeroId: rivalHeroId,
      );

  Future<void> purchaseStarterCard({
    required String uid,
    required String cardId,
    required int cost,
  }) =>
      _service.purchaseStarterCard(uid: uid, cardId: cardId, cost: cost);

  Future<void> addStarterCardToDeckAndComplete(String uid) =>
      _service.addStarterCardToDeckAndComplete(uid);
}