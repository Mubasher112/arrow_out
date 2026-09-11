import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_path/data/repositories/local_game_repository.dart';
import 'package:arrow_path/domain/models/arrow.dart';
import 'package:arrow_path/domain/models/arrow_direction.dart';
import 'package:arrow_path/domain/models/level_definition.dart';
import 'package:arrow_path/services/progression_service.dart';
import 'package:arrow_path/services/reward_service.dart';
import 'package:arrow_path/services/weekly_challenge_service.dart';

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

  group('WeeklyChallengeService', () {
    test('tracks gameplay progress and claims reward', () async {
      final repo = LocalGameRepository();
      final rewardService = RewardService(repository: repo);
      final weeklyService = WeeklyChallengeService(
        repository: repo,
        rewardService: rewardService,
      );
      final progService = ProgressionService(repository: repo);

      await progService.recordLevelCompletion(level: level1, movesTaken: 3);
      await weeklyService.evaluateProgress();

      final challenges = await weeklyService.getWeeklyChallenges();
      expect(challenges.isNotEmpty, isTrue);

      final levelChallenge = challenges.firstWhere((c) => c.id == 'week_levels_20');
      expect(levelChallenge.progress, 1);
    });
  });
}
