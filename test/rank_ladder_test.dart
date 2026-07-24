import 'package:flutter_test/flutter_test.dart';
import 'package:clash_of_styles/domain/config/rank_ladder.dart';

void main() {
  group('RankLadder.rankFor', () {
    test('novato en 0 y justo antes del primer umbral', () {
      expect(RankLadder.rankFor(0).name, 'Novato');
      expect(RankLadder.rankFor(149).name, 'Novato');
    });

    test('sube exactamente en cada umbral', () {
      expect(RankLadder.rankFor(150).name, 'Amateur');
      expect(RankLadder.rankFor(400).name, 'Profesional');
      expect(RankLadder.rankFor(900).name, 'Campeón Nacional');
      expect(RankLadder.rankFor(1800).name, 'Campeón Mundial');
      expect(RankLadder.rankFor(3500).name, 'Leyenda');
    });

    test('rango máximo se mantiene por encima del último umbral', () {
      expect(RankLadder.rankFor(999999).name, 'Leyenda');
      expect(RankLadder.nextRank(3500), isNull);
      expect(RankLadder.progress(3500), 1.0);
    });

    test('progreso dentro del rango', () {
      // Amateur 150 → Profesional 400: en 275 va a la mitad (125/250).
      expect(RankLadder.progress(275), closeTo(0.5, 0.001));
    });
  });
}
