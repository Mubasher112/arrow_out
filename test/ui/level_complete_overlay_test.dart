import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_path/ui/widgets/level_complete_overlay.dart';

void main() {
  testWidgets('LevelCompleteOverlay renders cleared text, stars and action buttons', (tester) async {
    bool nextLevelTapped = false;
    bool replayTapped = false;
    bool levelSelectTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LevelCompleteOverlay(
            levelNumber: 5,
            movesTaken: 7,
            bestMoves: 7,
            starsEarned: 3,
            onNextLevel: () => nextLevelTapped = true,
            onReplay: () => replayTapped = true,
            onLevelSelect: () => levelSelectTapped = true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('LEVEL 5 CLEARED!'), findsOneWidget);
    expect(find.text('Moves Taken: 7'), findsOneWidget);
    expect(find.text('NEXT LEVEL'), findsOneWidget);
    expect(find.text('Replay'), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);

    await tester.tap(find.text('NEXT LEVEL'));
    expect(nextLevelTapped, isTrue);

    await tester.tap(find.text('Replay'));
    expect(replayTapped, isTrue);

    await tester.tap(find.text('Map'));
    expect(levelSelectTapped, isTrue);
  });
}
