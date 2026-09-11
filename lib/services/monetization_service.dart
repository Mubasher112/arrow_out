import 'package:flutter/foundation.dart';
import '../domain/models/ad_placement.dart';
import '../domain/repositories/game_repository.dart';
import 'ad_frequency_manager.dart';
import 'ads_service.dart';
import 'consent_service.dart';
import 'purchase_service.dart';
import 'rewarded_ads_service.dart';

/// Unified service facade orchestrating ads, purchases, consent, and frequency limits.
class MonetizationService extends ChangeNotifier {
  final AdsService adsService;
  final RewardedAdsService rewardedAdsService;
  final PurchaseService purchaseService;
  final ConsentService consentService;
  final AdFrequencyManager adFrequencyManager;

  MonetizationService({
    required GameRepository repository,
    AdsService? adsService,
    RewardedAdsService? rewardedAdsService,
    PurchaseService? purchaseService,
    ConsentService? consentService,
    AdFrequencyManager? adFrequencyManager,
  })  : adsService = adsService ?? MockAdsService(),
        rewardedAdsService = rewardedAdsService ?? MockRewardedAdsService(),
        purchaseService = purchaseService ?? PurchaseService(repository: repository),
        consentService = consentService ?? ConsentService(repository: repository),
        adFrequencyManager = adFrequencyManager ?? AdFrequencyManager();

  bool get adsRemoved => purchaseService.adsRemoved;

  /// Notify that a level was completed and show an interstitial if eligible.
  Future<bool> maybeShowInterstitial(AdPlacement placement) async {
    adFrequencyManager.notifyLevelCompleted();

    if (adFrequencyManager.shouldShowInterstitial(adsRemoved: adsRemoved)) {
      final shown = await adsService.showInterstitial(placement);
      if (shown) {
        adFrequencyManager.recordInterstitialShown();
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  /// Show optional rewarded ad to earn a reward.
  Future<bool> showRewardedAd({
    required AdPlacement placement,
    required Future<void> Function() onRewardEarned,
  }) async {
    final success = await rewardedAdsService.showRewardedAd(
      placement: placement,
      onRewardEarned: onRewardEarned,
    );
    if (success) notifyListeners();
    return success;
  }

  /// Purchase remove_ads entitlement.
  Future<bool> purchaseRemoveAds() async {
    final success = await purchaseService.purchaseRemoveAds();
    if (success) notifyListeners();
    return success;
  }

  /// Restore purchases.
  Future<bool> restorePurchases() async {
    final success = await purchaseService.restorePurchases();
    if (success) notifyListeners();
    return success;
  }
}
