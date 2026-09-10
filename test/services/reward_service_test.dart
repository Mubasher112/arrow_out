import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_path/data/repositories/local_game_repository.dart';
import 'package:arrow_path/services/reward_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('RewardService', () {
    test('grants level completion and 3-star bonus coins without duplicate claims', () async {
      final repo = LocalGameRepository();
      final service = RewardService(repository: repo);

      expect(await service.getCoinsBalance(), 0);

      // Level 1 complete with 3 stars -> +20 base, +30 bonus = 50 coins
      final coinsGained1 = await service.grantLevelRewards(levelNumber: 1, stars: 3);
      expect(coinsGained1, 50);
      expect(await service.getCoinsBalance(), 50);

      // Replay Level 1 -> 0 new coins claimed
      final coinsGainedReplay = await service.grantLevelRewards(levelNumber: 1, stars: 3);
      expect(coinsGainedReplay, 0);
      expect(await service.getCoinsBalance(), 50);
    });

    test('grants daily challenge reward (+100 coins) only once per date', () async {
      final repo = LocalGameRepository();
      final service = RewardService(repository: repo);

      final coins1 = await service.grantDailyChallengeReward('2026-09-10');
      expect(coins1, 100);
      expect(await service.getCoinsBalance(), 100);

      // Replay daily challenge
      final coinsReplay = await service.grantDailyChallengeReward('2026-09-10');
      expect(coinsReplay, 0);
      expect(await service.getCoinsBalance(), 100);
    });

    test('grants streak milestone reward (+150 coins for every 7 days)', () async {
      final repo = LocalGameRepository();
      final service = RewardService(repository: repo);

      expect(await service.grantStreakMilestoneReward(5), 0);

      final streak7Reward = await service.grantStreakMilestoneReward(7);
      expect(streak7Reward, 150);
      expect(await service.getCoinsBalance(), 150);

      // Duplicate claim
      expect(await service.grantStreakMilestoneReward(7), 0);
    });
  });
}
