import 'dart:async';
import '../domain/models/ad_placement.dart';

/// Provider-independent abstraction for interstitial and banner ads.
abstract class AdsService {
  Future<bool> loadInterstitial(AdPlacement placement);
  Future<bool> showInterstitial(AdPlacement placement);
  bool isBannerVisible(AdPlacement placement, {required bool adsRemoved});
}

/// Simulated ad provider implementation for development and testing.
class MockAdsService implements AdsService {
  bool isAdLoaded = true;
  bool isNetworkAvailable = true;

  @override
  Future<bool> loadInterstitial(AdPlacement placement) async {
    if (!isNetworkAvailable) return false;
    await Future.delayed(const Duration(milliseconds: 50));
    isAdLoaded = true;
    return true;
  }

  @override
  Future<bool> showInterstitial(AdPlacement placement) async {
    if (!isNetworkAvailable || !isAdLoaded) return false;
    await Future.delayed(const Duration(milliseconds: 100));
    isAdLoaded = false;
    return true;
  }

  @override
  bool isBannerVisible(AdPlacement placement, {required bool adsRemoved}) {
    if (adsRemoved || !isNetworkAvailable) return false;
    return placement == AdPlacement.bannerHome || placement == AdPlacement.bannerLevelMap;
  }
}
