import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_path/data/repositories/local_game_repository.dart';
import 'package:arrow_path/domain/models/notification_settings.dart';
import 'package:arrow_path/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('NotificationService', () {
    test('schedules notifications according to settings toggles', () async {
      final repo = LocalGameRepository();
      final service = NotificationService(repository: repo);

      await service.init();
      expect(service.scheduledQueue.length, 3);

      await service.updateSettings(const NotificationSettings(
        dailyRewards: true,
        dailyChallenges: false,
        events: false,
      ));

      expect(service.scheduledQueue.length, 1);
      expect(service.scheduledQueue.first.id, 'notif_daily_reward');
    });
  });
}
