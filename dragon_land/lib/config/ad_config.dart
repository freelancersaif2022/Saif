import 'package:flutter/foundation.dart';

/// AdMob configuration. Debug/profile builds always use Google's public test
/// ad units. Release builds use the production IDs below once they are filled
/// in; until then they fall back to the test units, so a release build never
/// requests real ads with placeholder IDs.
class AdConfig {
  AdConfig._();

  // Google's official test ad unit IDs (Android).
  static const String testBanner = 'ca-app-pub-3940256099942544/9214589741';
  static const String testInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const String testRewarded = 'ca-app-pub-3940256099942544/5224354917';

  // Production ad unit IDs. Replace the placeholders with the IDs from your
  // AdMob account (Apps > Dragon Land > Ad units).
  static const String prodBanner = 'REPLACE_WITH_BANNER_AD_UNIT_ID';
  static const String prodInterstitial = 'REPLACE_WITH_INTERSTITIAL_AD_UNIT_ID';
  static const String prodRewarded = 'REPLACE_WITH_REWARDED_AD_UNIT_ID';

  static bool get _useProduction => kReleaseMode && !prodBanner.startsWith('REPLACE');

  static String get bannerId => _useProduction ? prodBanner : testBanner;
  static String get interstitialId => _useProduction ? prodInterstitial : testInterstitial;
  static String get rewardedId => _useProduction ? prodRewarded : testRewarded;

  /// An interstitial is offered at most once every [interstitialEveryRuns]
  /// finished runs, and never more often than [interstitialMinInterval].
  static const int interstitialEveryRuns = 3;
  static const Duration interstitialMinInterval = Duration(minutes: 3);

  /// Test device IDs (from logcat "Use RequestConfiguration...setTestDeviceIds").
  static const List<String> testDeviceIds = [];
}
