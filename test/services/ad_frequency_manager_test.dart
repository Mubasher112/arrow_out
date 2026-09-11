import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_path/services/ad_frequency_manager.dart';

void main() {
  group('AdFrequencyManager', () {
    test('first-time player protection disables ads during initial 5 levels', () {
      final manager = AdFrequencyManager(
        minLevelsBetweenInterstitials: 3,
        firstTimeProtectionLevels: 5,
      );

      for (int i = 0; i < 5; i++) {
        manager.notifyLevelCompleted();
        expect(manager.shouldShowInterstitial(adsRemoved: false), isFalse);
      }

      // Level 6 completed
      manager.notifyLevelCompleted();
      expect(manager.shouldShowInterstitial(adsRemoved: false), isTrue);
    });

    test('adsRemoved entitlement permanently disables interstitials', () {
      final manager = AdFrequencyManager(
        minLevelsBetweenInterstitials: 1,
        firstTimeProtectionLevels: 0,
      );

      manager.notifyLevelCompleted();
      expect(manager.shouldShowInterstitial(adsRemoved: true), isFalse);
    });

    test('min level threshold reset after showing interstitial', () {
      final manager = AdFrequencyManager(
        minLevelsBetweenInterstitials: 3,
        minSecondsBetweenInterstitials: 0,
        firstTimeProtectionLevels: 0,
      );

      manager.notifyLevelCompleted();
      manager.notifyLevelCompleted();
      expect(manager.shouldShowInterstitial(adsRemoved: false), isFalse);

      manager.notifyLevelCompleted();
      expect(manager.shouldShowInterstitial(adsRemoved: false), isTrue);

      manager.recordInterstitialShown();
      expect(manager.completedLevelsSinceLastAd, 0);
      expect(manager.shouldShowInterstitial(adsRemoved: false), isFalse);
    });
  });
}
