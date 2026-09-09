import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_path/data/repositories/local_game_repository.dart';
import 'package:arrow_path/services/audio_service.dart';
import 'package:arrow_path/ui/screens/game_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Widget createGameScreenWidget({int levelNumber = 1}) {
    final repository = LocalGameRepository();
    final audioService = AudioService(repository: repository);

    return MaterialApp(
      home: GameScreen(
        levelNumber: levelNumber,
        repository: repository,
        audioService: audioService,
      ),
    );
  }

  group('GameScreen Widget Tests', () {
    testWidgets('renders game header and board elements', (tester) async {
      await tester.pumpWidget(createGameScreenWidget(levelNumber: 1));
      await tester.pumpAndSettle();

      expect(find.text('LEVEL 1'), findsOneWidget);
      expect(find.textContaining('Moves: 0'), findsOneWidget);
      expect(find.text('Restart'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
      expect(find.text('Hint'), findsOneWidget);
    });

    testWidgets('tapping hint button highlights an arrow and shows snackbar', (tester) async {
      await tester.pumpWidget(createGameScreenWidget(levelNumber: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hint'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Hint: Highlighted arrow is ready to exit!'), findsOneWidget);
    });
  });
}
