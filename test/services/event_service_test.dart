import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_path/data/repositories/local_game_repository.dart';
import 'package:arrow_path/domain/models/event_status.dart';
import 'package:arrow_path/services/date_provider.dart';
import 'package:arrow_path/services/event_service.dart';
import 'package:arrow_path/services/reward_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('EventService', () {
    test('returns active event and detects expiration when date passes endAtIso', () async {
      final repo = LocalGameRepository();
      final dateProvider = TestDateProvider(DateTime(2026, 9, 11));
      final rewardService = RewardService(repository: repo);
      final eventService = EventService(
        repository: repo,
        rewardService: rewardService,
        dateProvider: dateProvider,
      );

      var event = await eventService.getActiveEvent();
      expect(event.status, EventStatus.active);

      // Advance date past event end date
      dateProvider.advanceDays(10);
      event = await eventService.getActiveEvent();
      expect(event.status, EventStatus.expired);
    });
  });
}
