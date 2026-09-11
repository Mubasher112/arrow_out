import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_path/data/repositories/local_game_repository.dart';
import 'package:arrow_path/services/daily_login_service.dart';
import 'package:arrow_path/services/date_provider.dart';
import 'package:arrow_path/services/reward_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('DailyLoginService', () {
    test('claims day 1 reward and prevents duplicate claim on same date ISO', () async {
      final repo = LocalGameRepository();
      final dateProvider = TestDateProvider(DateTime(2026, 9, 11));
      final rewardService = RewardService(repository: repo);
      final loginService = DailyLoginService(
        repository: repo,
        rewardService: rewardService,
        dateProvider: dateProvider,
      );

      expect(await loginService.isTodayClaimed(), isFalse);
      expect(await loginService.getCurrentLoginDay(), 1);

      final coinsClaimed = await loginService.claimTodayReward();
      expect(coinsClaimed, 50); // Day 1 reward = 50 coins
      expect(await loginService.isTodayClaimed(), isTrue);

      // Same date claim attempt returns 0 coins
      final duplicateClaim = await loginService.claimTodayReward();
      expect(duplicateClaim, 0);

      // Next day, login day is 2
      dateProvider.advanceDays(1);
      expect(await loginService.isTodayClaimed(), isFalse);
      expect(await loginService.getCurrentLoginDay(), 2);
    });
  });
}
