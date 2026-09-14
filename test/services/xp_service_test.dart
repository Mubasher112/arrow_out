import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_path/data/repositories/mock_game_repository.dart';
import 'package:arrow_path/services/reward_service.dart';
import 'package:arrow_path/services/xp_service.dart';

void main() {
  group('XpService', () {
    late MockGameRepository repository;
    late RewardService rewardService;
    late XpService xpService;

    setUp(() {
      repository = MockGameRepository();
      rewardService = RewardService(repository: repository);
      xpService = XpService(repository: repository, rewardService: rewardService);
    });

    test('awards XP and updates player level', () async {
      final result = await xpService.addXp(XpService.xpLevelComplete);

      expect(result.xpGained, equals(50));
      expect(result.newPlayerLevel.level, equals(1));
      expect(result.newPlayerLevel.currentXp, equals(50));
      expect(result.didLevelUp, isFalse);
    });

    test('levels up when XP exceeds threshold', () async {
      final result = await xpService.addXp(300);

      expect(result.newPlayerLevel.level, equals(2));
      expect(result.newPlayerLevel.currentXp, equals(50));
      expect(result.didLevelUp, isTrue);
      expect(result.coinsBonusEarned, equals(100));
    });
  });
}
