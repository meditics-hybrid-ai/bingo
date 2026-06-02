import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meditics_bingo/main.dart';

void main() {
  testWidgets('starts automatic bingo drawing', (tester) async {
    await tester.pumpWidget(const MediticsBingoApp());

    expect(find.text('Meditics BINGO'), findsOneWidget);
    expect(find.text('Ready to play'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('FREE'), findsOneWidget);

    await tester.ensureVisible(find.text('Start'));
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    expect(find.text('Drawing every 5 seconds'), findsOneWidget);
    expect(find.text('Running'), findsOneWidget);
    expect(find.text('No numbers drawn yet.'), findsNothing);
  });

  testWidgets('confirms refresh after game has started', (tester) async {
    await tester.pumpWidget(const MediticsBingoApp());

    await tester.ensureVisible(find.text('Start'));
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();

    expect(find.text('Start a new game?'), findsOneWidget);
    expect(
      find.text(
        'Are you sure you want to start a new game? Your current progress will be lost.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Start a new game?'), findsNothing);
    expect(find.text('Running'), findsOneWidget);
  });
}
