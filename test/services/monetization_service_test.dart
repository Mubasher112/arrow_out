import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_path/data/repositories/local_game_repository.dart';
import 'package:arrow_path/domain/models/ad_placement.dart';
import 'package:arrow_path/services/ad_frequency_manager.dart';
import 'package:arrow_path/services/monetization_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('MonetizationService', () {
    test('rewarded ad executes callback on completion', () async {
      final repo = LocalGameRepository();
      final monetizationService = MonetizationService(repository: repo);

      bool rewardGranted = false;

      final success = await monetizationService.showRewardedAd(
        placement: AdPlacement.rewardedHint,
        onRewardEarned: () async {
          rewardGranted = true;
        },
      );

      expect(success, isTrue);
      expect(rewardGranted, isTrue);
    });

    test('frequency manager integration blocks early interstitials', () async {
      final repo = LocalGameRepository();
      final frequencyManager = AdFrequencyManager(
        minLevelsBetweenInterstitials: 3,
        firstTimeProtectionLevels: 5,
      );

      final monetizationService = MonetizationService(
        repository: repo,
        adFrequencyManager: frequencyManager,
      );

      final shown = await monetizationService.maybeShowInterstitial(
        AdPlacement.interstitialLevelComplete,
      );

      expect(shown, isFalse);
    });
  });
}
