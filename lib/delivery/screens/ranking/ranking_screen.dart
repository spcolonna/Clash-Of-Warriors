// lib/delivery/screens/ranking/ranking_screen.dart
//
// Ranking semanal: top 50 por puntos de batalla de la semana ISO actual.
// Los puntos se envían al ganar batallas de arena (addBattlePoints).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infra/firebase/firebase_game_service.dart';
import '../../state/providers.dart';

class RankingScreen extends ConsumerStatefulWidget {
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = FirebaseGameService().fetchWeeklyTop();
  }

  @override
  Widget build(BuildContext context) {
    final myUid = ref.watch(playerProvider)?.uid;
    const gold = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Column(
          children: [
            const Text(
              'RANKING SEMANAL',
              style: TextStyle(
                color: gold,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'Semana ${FirebaseGameService.currentWeekKey().split('-W').last} · se reinicia cada lunes',
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(
              child: Text(
                'No se pudo cargar el ranking.\nProbá de nuevo en un rato.',
                style: TextStyle(color: Colors.white54),
                textAlign: TextAlign.center,
              ),
            );
          }
          final entries = snap.data ?? const [];
          if (entries.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Todavía nadie sumó puntos esta semana.\n¡Ganá una batalla y estrená el podio!',
                  style: TextStyle(color: Colors.white54, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final myIndex = entries.indexWhere((e) => e['uid'] == myUid);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _future = FirebaseGameService().fetchWeeklyTop();
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: entries.length + (myIndex >= 3 ? 1 : 0),
              itemBuilder: (context, i) {
                // Fila fija "tu posición" arriba si no estás en el podio
                if (myIndex >= 3 && i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _RankRow(
                      rank: myIndex + 1,
                      entry: entries[myIndex],
                      isMe: true,
                    ),
                  );
                }
                final idx = myIndex >= 3 ? i - 1 : i;
                final entry = entries[idx];
                return _RankRow(
                  rank: idx + 1,
                  entry: entry,
                  isMe: entry['uid'] == myUid,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> entry;
  final bool isMe;

  const _RankRow({required this.rank, required this.entry, required this.isMe});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);
    final medal = switch (rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => null,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe
            ? gold.withValues(alpha: 0.12)
            : const Color(0xFF1A1A2E).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe ? gold : Colors.white10,
          width: isMe ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: medal != null
                ? Text(medal, style: const TextStyle(fontSize: 18))
                : Text(
                    '#$rank',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          Expanded(
            child: Text(
              (entry['name'] as String?)?.trim().isNotEmpty == true
                  ? entry['name'] as String
                  : 'Guerrero',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isMe ? gold : Colors.white,
                fontSize: 14,
                fontWeight: isMe ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ),
          if (isMe)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text(
                'VOS',
                style: TextStyle(
                  color: gold,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          Text(
            '${entry['points'] ?? 0} pts',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
