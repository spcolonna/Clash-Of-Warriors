import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../infra/services/haptics_service.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final authUser = ref.watch(authStateProvider).value;
    final sound = ref.read(soundProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AJUSTES', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.gold)),
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
                Text(authUser?.displayName ?? authUser?.email ?? 'Guerrero',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.diamond, size: 14, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text('${player?.tokens ?? 0} tokens · ${player?.medals ?? 0} medallas',
                      style: const TextStyle(fontSize: 14, color: AppColors.accent, fontWeight: FontWeight.w700)),
                  ],
                ),
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
              onChanged: (_) => setState(() => sound.toggleSfx()),
            ),
          ),
          _SettingTile(
            title: '🎵 Música',
            trailing: Switch(
              value: sound.musicEnabled,
              activeColor: AppColors.primary,
              onChanged: (_) => setState(() => sound.toggleMusic()),
            ),
          ),
          _SettingTile(
            title: '📳 Vibración',
            trailing: Switch(
              value: HapticsService().enabled,
              activeColor: AppColors.primary,
              onChanged: (_) => setState(() {
                HapticsService().toggle();
                HapticsService().medium(); // feedback inmediato al activar
              }),
            ),
          ),

          // (Selector de idioma retirado: el juego es solo-español por ahora;
          //  el UI nunca consumió las traducciones, así que el selector era
          //  una promesa falsa.)

          const SizedBox(height: 16),

          // Recargar contenido: vuelve a pedir cartas/héroes/config a Firestore
          // sin reiniciar la app. Útil al iterar arte/balance desde el admin.
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ref.invalidate(gameConfigProvider);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Contenido actualizado desde el servidor'),
                  duration: Duration(milliseconds: 1500),
                  behavior: SnackBarBehavior.floating,
                ));
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Recargar contenido del juego'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.accent),
                foregroundColor: AppColors.accent,
              ),
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
