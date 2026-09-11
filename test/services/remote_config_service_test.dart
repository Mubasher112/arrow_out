import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_path/data/repositories/local_game_repository.dart';
import 'package:arrow_path/services/remote_config_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('RemoteConfigService', () {
    test('provides built-in safe default feature flags', () async {
      final repo = LocalGameRepository();
      final service = RemoteConfigService(repository: repo);

      await service.init();

      expect(service.isFeatureEnabled('weeklyChallenges'), isTrue);
      expect(service.isFeatureEnabled('liveEvents'), isTrue);
    });
  });
}
