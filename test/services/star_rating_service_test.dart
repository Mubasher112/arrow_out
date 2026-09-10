import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_path/data/repositories/local_game_repository.dart';
import 'package:arrow_path/domain/models/arrow.dart';
import 'package:arrow_path/domain/models/arrow_direction.dart';
import 'package:arrow_path/domain/models/level_definition.dart';
import 'package:arrow_path/domain/models/level_progress.dart';
import 'package:arrow_path/services/progression_service.dart';
import 'package:arrow_path/services/star_rating_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  const sampleLevel = LevelDefinition(
    levelNumber: 1,
    rows: 4,
    cols: 4,
    initialArrows: [
      Arrow(id: 'a1', row: 0, column: 0, direction: ArrowDirection.up),
    ],
    parMoves: 5,
  );

  group('StarRatingService', () {
    test('star threshold calculation', () {
      expect(StarRatingService.calculateStars(4, sampleLevel), 3);
      expect(StarRatingService.calculateStars(5, sampleLevel), 3);
      expect(StarRatingService.calculateStars(7, sampleLevel), 2);
      expect(StarRatingService.calculateStars(8, sampleLevel), 2);
      expect(StarRatingService.calculateStars(12, sampleLevel), 1);
    });

    test('evaluates new best score accurately', () {
      // First run: 8 moves = 2 stars
      final eval1 = StarRatingService.evaluateRun(
        movesTaken: 8,
        level: sampleLevel,
      );
      expect(eval1.stars, 2);
      expect(eval1.isNewBest, isTrue);

      const existing1 = LevelProgress(levelNumber: 1, isCompleted: true, stars: 2, bestMoves: 8);

      // Replay run: 10 moves = 1 star (worse score)
      final evalWorse = StarRatingService.evaluateRun(
        movesTaken: 10,
        level: sampleLevel,
        existingProgress: existing1,
      );
      expect(evalWorse.isNewBest, isFalse);

      // Replay run: 4 moves = 3 stars (improved score!)
      final evalBetter = StarRatingService.evaluateRun(
        movesTaken: 4,
        level: sampleLevel,
        existingProgress: existing1,
      );
      expect(evalBetter.isNewBest, isTrue);
      expect(evalBetter.isStarImproved, isTrue);
    });

    test('calculateTotalStars avoids duplicate counting', () {
      final progressMap = {
        1: const LevelProgress(levelNumber: 1, isCompleted: true, stars: 3, bestMoves: 5),
        2: const LevelProgress(levelNumber: 2, isCompleted: true, stars: 2, bestMoves: 8),
        3: const LevelProgress(levelNumber: 3, isCompleted: false, stars: 0, bestMoves: 0),
      };

      expect(StarRatingService.calculateTotalStars(progressMap), 5);
    });
  });

  group('ProgressionService', () {
    test('records level completion and unlocks next level', () async {
      final repo = LocalGameRepository();
      final progService = ProgressionService(repository: repo);

      expect(await progService.getHighestUnlockedLevel(), 1);

      final eval = await progService.recordLevelCompletion(
        level: sampleLevel,
        movesTaken: 4,
      );

      expect(eval.stars, 3);
      expect(eval.isNewBest, isTrue);
      expect(await progService.getHighestUnlockedLevel(), 2);
      expect(await progService.getTotalStars(), 3);
    });
  });
}
