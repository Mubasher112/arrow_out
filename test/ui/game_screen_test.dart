import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_path/data/repositories/local_game_repository.dart';
import 'package:arrow_path/domain/models/arrow.dart';
import 'package:arrow_path/domain/models/arrow_direction.dart';
import 'package:arrow_path/domain/models/level_definition.dart';
import 'package:arrow_path/domain/repositories/level_repository.dart';
import 'package:arrow_path/services/audio_service.dart';
import 'package:arrow_path/services/level_loader_service.dart';
import 'package:arrow_path/ui/screens/game_screen.dart';
import 'package:arrow_path/ui/widgets/arrow_tile_widget.dart';

class MockErrorLevelRepository implements LevelRepository {
  @override
  Future<List<LevelDefinition>> getAllLevels() async => throw Exception('Asset load error');

  @override
  Future<LevelDefinition?> getLevelById(int id) async => throw Exception('Level not found');

  @override
  Future<List<LevelDefinition>> getLevelRange(int startId, int count) async => throw Exception('Error');

  @override
  Future<bool> validateLevel(LevelDefinition level) async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Widget createGameScreenWidget({int levelNumber = 1, LevelRepository? repo}) {
    final gameRepo = LocalGameRepository();
    final audioService = AudioService(repository: gameRepo);

    return MaterialApp(
      home: GameScreen(
        levelNumber: levelNumber,
        repository: gameRepo,
        audioService: audioService,
      ),
    );
  }

  group('GameScreen Widget Tests', () {
    testWidgets('renders game header, moves counter and action buttons', (tester) async {
      await tester.pumpWidget(createGameScreenWidget(levelNumber: 1));
      await tester.pumpAndSettle();

      expect(find.text('LEVEL 1'), findsOneWidget);
      expect(find.textContaining('Moves: 0'), findsOneWidget);
      expect(find.text('Restart'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
      expect(find.text('Hint'), findsOneWidget);
    });

    testWidgets('pause menu opens and displays resume, restart, level select buttons', (tester) async {
      await tester.pumpWidget(createGameScreenWidget(levelNumber: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.pause_circle_filled_rounded));
      await tester.pumpAndSettle();

      expect(find.textContaining('GAME PAUSED'), findsOneWidget);
      expect(find.text('Resume'), findsOneWidget);
      expect(find.text('Restart Level'), findsOneWidget);
      expect(find.text('Level Select'), findsOneWidget);

      // Tap Resume
      await tester.tap(find.text('Resume'));
      await tester.pumpAndSettle();

      expect(find.textContaining('GAME PAUSED'), findsNothing);
    });

    testWidgets('restart level shows confirmation dialog', (tester) async {
      await tester.pumpWidget(createGameScreenWidget(levelNumber: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.pause_circle_filled_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Restart Level'));
      await tester.pumpAndSettle();

      expect(find.text('Restart level?'), findsOneWidget);
      expect(find.text('Your current progress on this level will be lost.'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Restart level?'), findsNothing);
    });

    testWidgets('hint button highlights arrow and displays snackbar', (tester) async {
      await tester.pumpWidget(createGameScreenWidget(levelNumber: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hint'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Hint: Highlighted arrow is ready to exit!'), findsOneWidget);
    });

    testWidgets('tapping valid arrow removes it and updates moves counter', (tester) async {
      await tester.pumpWidget(createGameScreenWidget(levelNumber: 1));
      await tester.pumpAndSettle();

      // Find an arrow tile on board
      final arrowFinder = find.byType(ArrowTileWidget).first;
      await tester.tap(arrowFinder);
      await tester.pumpAndSettle();

      expect(find.textContaining('Moves: 1'), findsOneWidget);
    });

    testWidgets('renders all board sizes 4x4, 5x5, 6x6, 7x7, 8x8 without errors', (tester) async {
      for (final levelNum in [1, 15, 35, 65, 85]) {
        await tester.pumpWidget(createGameScreenWidget(levelNumber: levelNum));
        await tester.pumpAndSettle();

        expect(find.text('LEVEL $levelNum'), findsOneWidget);
        expect(find.byType(ArrowTileWidget), findsNotEmpty);
      }
    });
  });
}
