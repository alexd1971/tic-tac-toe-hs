import 'package:flutter_test/flutter_test.dart';

import 'package:tic_tac_toe_app/main.dart';

void main() {
  testWidgets('Setup screen shows difficulty and mark choices', (tester) async {
    await tester.pumpWidget(const TicTacToeApp());

    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);
    expect(find.text('X (first)'), findsOneWidget);
    expect(find.text('O (second)'), findsOneWidget);
    expect(find.text('Start game'), findsOneWidget);
  });
}
