import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_path/data/repositories/local_game_repository.dart';
import 'package:arrow_path/domain/models/purchase_status.dart';
import 'package:arrow_path/services/purchase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('PurchaseService', () {
    test('purchase remove_ads updates entitlement status', () async {
      final repo = LocalGameRepository();
      final purchaseService = PurchaseService(repository: repo);

      expect(purchaseService.adsRemoved, isFalse);

      final success = await purchaseService.purchaseRemoveAds();

      expect(success, isTrue);
      expect(purchaseService.status, PurchaseStatus.purchased);
      expect(purchaseService.adsRemoved, isTrue);
    });

    test('restore purchases restores remove_ads entitlement', () async {
      final repo = LocalGameRepository();
      final purchaseService = PurchaseService(repository: repo);

      final success = await purchaseService.restorePurchases();

      expect(success, isTrue);
      expect(purchaseService.status, PurchaseStatus.restored);
      expect(purchaseService.adsRemoved, isTrue);
    });
  });
}
