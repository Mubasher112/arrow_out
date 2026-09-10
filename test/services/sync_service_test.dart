import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_path/data/repositories/cloud_game_repository.dart';
import 'package:arrow_path/data/repositories/local_game_repository.dart';
import 'package:arrow_path/domain/models/sync_status.dart';
import 'package:arrow_path/services/mock_auth_service.dart';
import 'package:arrow_path/services/sync_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('SyncService', () {
    test('local-first background sync uploads progress to cloud when authenticated', () async {
      final localRepo = LocalGameRepository();
      final cloudRepo = InMemoryCloudRepository();
      final auth = MockAuthService();

      await auth.signInWithGoogle();

      await localRepo.setCurrentLevel(42);
      await localRepo.addCoins(150);

      final syncService = SyncService(
        localRepository: localRepo,
        cloudRepository: cloudRepo,
        authService: auth,
      );

      await syncService.sync();

      expect(syncService.status, SyncStatus.synced);

      final cloudData = await cloudRepo.getCloudData(auth.currentAccount!.userId);
      expect(cloudData, isNotNull);
      expect(cloudData!.currentLevel, 42);
      expect(cloudData.coinsBalance, 150);
    });

    test('handles offline network state gracefully without crashing', () async {
      final localRepo = LocalGameRepository();
      final cloudRepo = InMemoryCloudRepository();
      final auth = MockAuthService();

      await auth.signInWithGoogle();
      cloudRepo.isNetworkAvailable = false; // Simulate offline

      final syncService = SyncService(
        localRepository: localRepo,
        cloudRepository: cloudRepo,
        authService: auth,
      );

      await syncService.sync();

      expect(syncService.status, SyncStatus.offline);
      expect(syncService.lastError, isNotNull);
    });
  });
}
