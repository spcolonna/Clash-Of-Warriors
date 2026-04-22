import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/config/game_config.dart';
import '../../../domain/entities/hero.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/hero_avatar.dart';

class UpgradesScreen extends ConsumerWidget {
  const UpgradesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    if (player == null) return const SizedBox();
    final tokens = player.tokens;
    final allHeroes = HeroRegistry.all;
    final unlockedHeroes = allHeroes.where((h) => player.unlockedHeroes.contains(h.id)).toList();
    final lockedHeroes = allHeroes.where((h) => !player.unlockedHeroes.contains(h.id)).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, size: 18, color: Colors.white70),
                label: const Text('Volver', style: TextStyle(color: Colors.white70)),
              ),
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.upgrade, size: 32, color: AppColors.primary),
                    const SizedBox(height: 4),
                    const Text('MEJORAS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on, size: 18, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text('$tokens tokens', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.accent)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Level up section
              if (unlockedHeroes.isNotEmpty) ...[
                const Text('SUBIR DE NIVEL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: unlockedHeroes.length,
                  itemBuilder: (_, i) {
                    final h = unlockedHeroes[i];
                    final lv = player.getHeroLevel(h.id);
                    final cc = player.getHeroCards(h.id);
                    final need = GameConfig.cardsNeeded(lv);
                    final pct = need > 0 ? (cc / need).clamp(0.0, 1.0) : 1.0;
                    final rar = _getRarity(lv);
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              HeroAvatar(heroId: h.id, size: 36),
                              const SizedBox(width: 6),
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(h.id[0].toUpperCase() + h.id.substring(1),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: rar.color,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(rar.name, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                                      ),
                                      const SizedBox(width: 4),
                                      Text('Lv$lv', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Cartas: $cc/$need', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 6,
                              backgroundColor: Colors.white12,
                              valueColor: AlwaysStoppedAnimation(rar.color),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: tokens >= GameConfig.cardCost
                                  ? () => _confirmBuyCard(context, ref, h)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: tokens >= GameConfig.cardCost ? AppColors.primary : Colors.grey,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: Text('MEJORAR (${GameConfig.cardCost})', style: const TextStyle(fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Unlock section
              if (lockedHeroes.isNotEmpty) ...[
                const Text('DESBLOQUEAR HÉROES', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: lockedHeroes.length,
                  itemBuilder: (_, i) {
                    final h = lockedHeroes[i];
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Opacity(opacity: 0.5, child: HeroAvatar(heroId: h.id, size: 36)),
                              const SizedBox(width: 6),
                              Expanded(child: Text(h.id[0].toUpperCase() + h.id.substring(1),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white70))),
                            ],
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: tokens >= GameConfig.heroUnlockCost
                                  ? () => _confirmUnlock(context, ref, h)
                                  : null,
                              icon: const Icon(Icons.lock_open, size: 14),
                              label: Text('${GameConfig.heroUnlockCost}', style: const TextStyle(fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: tokens >= GameConfig.heroUnlockCost ? AppColors.primary : Colors.grey,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _confirmBuyCard(BuildContext context, WidgetRef ref, GameHero hero) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Mejorar ${hero.id}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800)),
        content: Text('¿Comprar carta por ${GameConfig.cardCost} tokens?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () {
              ref.read(playerProvider.notifier).buyCard(hero.id);
              Navigator.pop(context);
            },
            child: const Text('COMPRAR'),
          ),
        ],
      ),
    );
  }

  void _confirmUnlock(BuildContext context, WidgetRef ref, GameHero hero) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            HeroAvatar(heroId: hero.id, size: 40),
            const SizedBox(width: 10),
            Expanded(child: Text('Desbloquear ${hero.id}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800))),
          ],
        ),
        content: Text('¿Desbloquear por ${GameConfig.heroUnlockCost} tokens?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () {
              ref.read(playerProvider.notifier).unlockHero(hero.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('DESBLOQUEAR'),
          ),
        ],
      ),
    );
  }

  static _Rarity _getRarity(int level) {
    if (level >= 10) return _Rarity('Legendary', AppColors.accent);
    if (level >= 7) return _Rarity('Epic', AppColors.secondary);
    if (level >= 4) return _Rarity('Rare', const Color(0xFF1565C0));
    return _Rarity('Common', AppColors.textSecondary);
  }
}

class _Rarity {
  final String name;
  final Color color;
  const _Rarity(this.name, this.color);
}
