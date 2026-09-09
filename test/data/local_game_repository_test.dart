import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_path/data/repositories/local_game_repository.dart';
import 'package:arrow_path/domain/models/level_progress.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('LocalGameRepository', () {
    test('default values', () async {
      final repo = LocalGameRepository();

      expect(await repo.getCurrentLevel(), 1);
      expect(await repo.isSoundEnabled(), isTrue);
      expect(await repo.isMusicEnabled(), isTrue);
      expect(await repo.isVibrationEnabled(), isTrue);
      expect(await repo.getAllProgress(), isEmpty);
    });

    test('saves and loads level progress', () async {
      final repo = LocalGameRepository();

      const progress1 = LevelProgress(
        levelNumber: 1,
        isCompleted: true,
        stars: 3,
        bestMoves: 5,
      );

      await repo.saveLevelProgress(progress1);
      final saved = await repo.getLevelProgress(1);

      expect(saved, isNotNull);
      expect(saved!.levelNumber, 1);
      expect(saved.stars, 3);
      expect(saved.bestMoves, 5);

      // Save a run with higher moves, bestMoves should keep lower moves (5)
      const progress1Again = LevelProgress(
        levelNumber: 1,
        isCompleted: true,
        stars: 2,
        bestMoves: 8,
      );

      await repo.saveLevelProgress(progress1Again);
      final updated = await repo.getLevelProgress(1);

      expect(updated!.stars, 3); // Keeps max stars
      expect(updated.bestMoves, 5); // Keeps best moves (lower is better)
    });

    test('settings toggles persist correctly', () async {
      final repo = LocalGameRepository();

      await repo.setSoundEnabled(false);
      await repo.setMusicEnabled(false);
      await repo.setCurrentLevel(5);

      expect(await repo.isSoundEnabled(), isFalse);
      expect(await repo.isMusicEnabled(), isFalse);
      expect(await repo.getCurrentLevel(), 5);

      await repo.clearAllData();
      expect(await repo.getCurrentLevel(), 1);
      expect(await repo.isSoundEnabled(), isTrue);
    });
  });
}
