import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clash_of_styles/domain/entities/game_card.dart';
import 'package:clash_of_styles/delivery/widgets/player_hand_widget.dart';
import 'package:clash_of_styles/delivery/widgets/game_card_widget.dart';

GameCard _card(String id, {int cost = 1}) => GameCard(
      id: id, name: id, lore: '', category: CardCategory.punch,
      rarity: CardRarity.neutral, staminaCost: cost, baseDamage: 10,
    );

/// Invoca el onTap del GestureDetector que envuelve la carta [id]. Prueba la
/// LÓGICA de gating sin depender del hit-testing del abanico (transforms).
void _tapCard(WidgetTester tester, String id) {
  final gd = tester.widget<GestureDetector>(
    find
        .ancestor(
          of: find.byWidgetPredicate((w) => w is GameCardWidget && w.card.id == id),
          matching: find.byType(GestureDetector),
        )
        .first,
  );
  gd.onTap?.call();
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
  await tester.pump(const Duration(seconds: 1));
}

Widget _hand(List<GameCard> cards, void Function(GameCard) onPlay) =>
    PlayerHandWidget(
      cards: cards,
      remainingStamina: 10,
      onCardPlay: onPlay,
      playableCardIds: const {'permitida'},
      allowDrag: false,
      directTapPlay: true,
      onDealAnimationComplete: () {},
    );

void main() {
  testWidgets('directTapPlay: tocar una carta NO permitida no la juega', (tester) async {
    final played = <String>[];
    await _pump(tester, _hand([_card('permitida'), _card('otra')], (c) => played.add(c.id)));
    _tapCard(tester, 'otra');
    await tester.pump();
    expect(played, isEmpty);
  });

  testWidgets('directTapPlay: tocar la carta permitida la juega una vez', (tester) async {
    final played = <String>[];
    await _pump(tester, _hand([_card('permitida'), _card('otra')], (c) => played.add(c.id)));
    _tapCard(tester, 'permitida');
    await tester.pump();
    expect(played, ['permitida']);
  });
}
