/// Manager controlling interstitial ad frequency rules and first-time player protection.
class AdFrequencyManager {
  final int minLevelsBetweenInterstitials;
  final int minSecondsBetweenInterstitials;
  final int firstTimeProtectionLevels;

  int _completedLevelsSinceLastAd = 0;
  int? _lastInterstitialTimestamp;
  int _totalLevelsCompletedInApp = 0;

  AdFrequencyManager({
    this.minLevelsBetweenInterstitials = 3,
    this.minSecondsBetweenInterstitials = 120,
    this.firstTimeProtectionLevels = 5,
  });

  int get completedLevelsSinceLastAd => _completedLevelsSinceLastAd;

  /// Notify that a level has been completed.
  void notifyLevelCompleted() {
    _completedLevelsSinceLastAd++;
    _totalLevelsCompletedInApp++;
  }

  /// Check if the player is currently eligible to receive an interstitial ad.
  bool shouldShowInterstitial({required bool adsRemoved}) {
    if (adsRemoved) return false;

    // First-time player protection
    if (_totalLevelsCompletedInApp <= firstTimeProtectionLevels) {
      return false;
    }

    // Check min levels threshold
    if (_completedLevelsSinceLastAd < minLevelsBetweenInterstitials) {
      return false;
    }

    // Check min cooldown time threshold
    if (_lastInterstitialTimestamp != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsedSeconds = (now - _lastInterstitialTimestamp!) ~/ 1000;
      if (elapsedSeconds < minSecondsBetweenInterstitials) {
        return false;
      }
    }

    return true;
  }

  /// Reset counter after an interstitial ad is shown.
  void recordInterstitialShown() {
    _completedLevelsSinceLastAd = 0;
    _lastInterstitialTimestamp = DateTime.now().millisecondsSinceEpoch;
  }
}
