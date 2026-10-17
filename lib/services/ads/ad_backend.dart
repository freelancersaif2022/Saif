/// Platform-neutral contract implemented by the AdMob backend (mobile)
/// and a no-op backend (web preview / tests).
abstract class AdBackend {
  Future<void> init();
  bool get interstitialReady;
  bool get rewardedReady;

  /// Resolves when the ad is closed. Returns false if it could not be shown.
  Future<bool> showInterstitial();

  /// Resolves when the ad is closed. Returns true only if the reward was earned.
  Future<bool> showRewarded();
}
