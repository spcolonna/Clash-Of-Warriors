import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final sound = ref.read(soundProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ AJUSTES', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.gold)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(player?.name ?? 'Guerrero',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 4),
                Text('🪙 ${player?.tokens ?? 0} tokens · ELO ${player?.elo ?? 1000}',
                  style: const TextStyle(fontSize: 14, color: AppColors.accent, fontWeight: FontWeight.w700)),
                if (player != null && ref.read(authProvider).isAnonymous) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                      onPressed: () {
                        // TODO: Link account flow
                      },
                      child: const Text('🔗 Vincular cuenta (guardar progreso)'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sound
          _SettingTile(
            title: '🔊 Efectos de sonido',
            trailing: Switch(
              value: sound.sfxEnabled,
              activeColor: AppColors.primary,
              onChanged: (_) { sound.toggleSfx(); },
            ),
          ),
          _SettingTile(
            title: '🎵 Música',
            trailing: Switch(
              value: sound.musicEnabled,
              activeColor: AppColors.primary,
              onChanged: (_) { sound.toggleMusic(); },
            ),
          ),

          const SizedBox(height: 16),

          // Language
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🌐 Idioma', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _LangChip('🇪🇸 Español', 'es', ref),
                    _LangChip('🇬🇧 English', 'en', ref),
                    _LangChip('🇧🇷 Português', 'pt', ref),
                    _LangChip('🇯🇵 日本語', 'ja', ref),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sign out
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                await ref.read(authProvider).signOut();
                if (context.mounted) {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.hp25),
                foregroundColor: AppColors.hp25,
              ),
              child: const Text('Cerrar sesión'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _LangChip(String label, String code, WidgetRef ref) {
    final current = ref.watch(localeProvider);
    final isActive = current?.languageCode == code;
    return ChoiceChip(
      label: Text(label),
      selected: isActive,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: isActive ? Colors.white : AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
      onSelected: (_) {
        ref.read(localeProvider.notifier).state = Locale(code);
      },
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final Widget trailing;
  const _SettingTile({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
          trailing,
        ],
      ),
    );
  }
}
