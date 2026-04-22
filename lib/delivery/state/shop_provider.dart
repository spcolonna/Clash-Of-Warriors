// lib/delivery/state/shop_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infra/firebase/game_data_repository.dart';
import 'providers.dart';

// ── Modelos locales ────────────────────────────────────────────────────────

class ShopCard {
  final String id;
  final String name;
  final String category;
  final String rarity;
  final int cost;
  final int? baseDamage;
  final int staminaCost;
  final String lore;
  final bool isTutorialCard;

  const ShopCard({
    required this.id,
    required this.name,
    required this.category,
    required this.rarity,
    required this.cost,
    required this.baseDamage,
    required this.staminaCost,
    required this.lore,
    required this.isTutorialCard,
  });

  factory ShopCard.fromMap(Map<String, dynamic> m) => ShopCard(
    id: m['id'],
    name: m['name'],
    category: m['category'],
    rarity: m['rarity'] ?? 'common',
    cost: (m['shopCost'] as int?) ?? 80,
    baseDamage: m['baseDamage'] as int?,
    staminaCost: (m['staminaCost'] as int?) ?? 1,
    lore: m['lore'] ?? '',
    isTutorialCard: (m['isTutorialCard'] as bool?) ?? false,
  );
}

class FactionShop {
  final String id;
  final String name;
  final List<ShopCard> cards;

  const FactionShop({
    required this.id,
    required this.name,
    required this.cards,
  });
}

// ── Provider del repositorio (T6) ──────────────────────────────────────────

final gameDataRepositoryProvider = Provider((_) => GameDataRepository());

// ── ShopNotifier ───────────────────────────────────────────────────────────

final shopProvider =
StateNotifierProvider<ShopNotifier, AsyncValue<List<FactionShop>>>(
      (ref) => ShopNotifier(ref),
);

class ShopNotifier extends StateNotifier<AsyncValue<List<FactionShop>>> {
  final Ref _ref;

  ShopNotifier(this._ref) : super(const AsyncValue.loading());

  Future<void> loadShop() async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(gameDataRepositoryProvider);
      final allCards = await repo.getAllCards();

      // Agrupar por facción (neutrales quedan fuera del shop)
      final byFaction = <String, List<ShopCard>>{};
      for (final raw in allCards) {
        final factionId = raw['factionId'] as String?;
        if (factionId == null) continue;

        byFaction
            .putIfAbsent(factionId, () => [])
            .add(ShopCard.fromMap(raw));
      }

      const rarityOrder = {
        'common': 0,
        'rare': 1,
        'epic': 2,
        'legendary': 3,
      };

      final factions = byFaction.entries.map((e) {
        final sorted = [...e.value]
          ..sort((a, b) {
            final ra = rarityOrder[a.rarity] ?? 99;
            final rb = rarityOrder[b.rarity] ?? 99;
            return ra.compareTo(rb);
          });
        return FactionShop(
          id: e.key,
          name: _factionDisplayName(e.key),
          cards: sorted,
        );
      }).toList();

      const factionOrder = [
        'shaolin',
        'ninja',
        'judoka',
        'boxer',
        'capoeira'
      ];
      factions.sort((a, b) {
        final ia = factionOrder.indexOf(a.id);
        final ib = factionOrder.indexOf(b.id);
        return ia.compareTo(ib);
      });

      state = AsyncValue.data(factions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  String _factionDisplayName(String id) => switch (id) {
    'shaolin' => 'Guardianes Shaolin',
    'ninja' => 'Clan de las Sombras',
    'judoka' => 'Hermandad de Hierro',
    'boxer' => 'Boxeadores del Cemento',
    'capoeira' => 'Capoeiristas Libres',
    _ => id,
  };
}
