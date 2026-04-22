// lib/domain/repositories/player_repository.dart

import '../entities/player_profile.dart';

abstract class PlayerRepository {
  Future<PlayerProfile?> getPlayer(String uid);
  Future<void> savePlayer(PlayerProfile player);
}