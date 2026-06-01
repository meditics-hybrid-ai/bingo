import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meditics_bingo/main.dart';

void main() {
  testWidgets('shows playable bingo screen and draws a number', (tester) async {
    await tester.pumpWidget(const MediticsBingoApp());

    expect(find.text('Meditics BINGO'), findsOneWidget);
    expect(find.text('Ready to play'), findsOneWidget);
    expect(find.text('Draw Number'), findsOneWidget);
    expect(find.text('FREE'), findsOneWidget);

    await tester.ensureVisible(find.text('Draw Number'));
    await tester.tap(find.byIcon(Icons.casino_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Current number'), findsOneWidget);
    expect(find.text('No numbers drawn yet.'), findsNothing);
  });
}
