import 'dart:async';
import '../domain/models/ad_placement.dart';

/// Provider-independent abstraction for optional rewarded video ads.
abstract class RewardedAdsService {
  Future<bool> loadRewardedAd(AdPlacement placement);
  Future<bool> showRewardedAd({
    required AdPlacement placement,
    required Future<void> Function() onRewardEarned,
  });
}

/// Simulated rewarded ad provider for testing.
class MockRewardedAdsService implements RewardedAdsService {
  bool isAdAvailable = true;
  bool isNetworkAvailable = true;

  @override
  Future<bool> loadRewardedAd(AdPlacement placement) async {
    if (!isNetworkAvailable) return false;
    await Future.delayed(const Duration(milliseconds: 50));
    isAdAvailable = true;
    return true;
  }

  @override
  Future<bool> showRewardedAd({
    required AdPlacement placement,
    required Future<void> Function() onRewardEarned,
  }) async {
    if (!isNetworkAvailable || !isAdAvailable) return false;

    // Simulate watching rewarded video ad
    await Future.delayed(const Duration(milliseconds: 150));

    // Execute reward callback ONLY on successful completion
    await onRewardEarned();
    return true;
  }
}
