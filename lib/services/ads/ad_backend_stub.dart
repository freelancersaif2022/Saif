import 'ad_backend.dart';

AdBackend createAdBackend() => _NoAds();

class _NoAds implements AdBackend {
  @override
  Future<void> init() async {}
  @override
  bool get interstitialReady => false;
  @override
  bool get rewardedReady => false;
  @override
  Future<bool> showInterstitial() async => false;
  @override
  Future<bool> showRewarded() async => false;
}
