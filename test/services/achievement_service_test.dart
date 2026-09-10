import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_path/data/repositories/local_game_repository.dart';
import 'package:arrow_path/domain/models/arrow.dart';
import 'package:arrow_path/domain/models/arrow_direction.dart';
import 'package:arrow_path/domain/models/level_definition.dart';
import 'package:arrow_path/services/achievement_service.dart';
import 'package:arrow_path/services/progression_service.dart';
import 'package:arrow_path/services/reward_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  const level1 = LevelDefinition(
    levelNumber: 1,
    rows: 4,
    cols: 4,
    initialArrows: [
      Arrow(id: 'a1', row: 0, column: 0, direction: ArrowDirection.up),
    ],
    parMoves: 5,
  );

  group('AchievementService', () {
    test('evaluates and unlocks achievements on progress milestone', () async {
      final repo = LocalGameRepository();
      final rewardService = RewardService(repository: repo);
      final achievementService = AchievementService(
        repository: repo,
        rewardService: rewardService,
      );
      final progService = ProgressionService(repository: repo);

      // Record level 1 completion
      await progService.recordLevelCompletion(level: level1, movesTaken: 3);

      final newlyUnlocked = await achievementService.evaluateAchievements();

      expect(newlyUnlocked.any((a) => a.id == 'first_victory'), isTrue);
      expect(newlyUnlocked.any((a) => a.id == 'first_move'), isTrue);

      final all = await achievementService.getAllAchievements();
      final firstVictory = all.firstWhere((a) => a.id == 'first_victory');

      expect(firstVictory.isUnlocked, isTrue);
    });
  });
}
