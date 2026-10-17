/// All ad + in-app purchase settings live here.
///
/// BEFORE PUBLISHING:
///  1. Set [testMode] to false.
///  2. Replace the AdMob IDs below (and the APPLICATION_ID meta-data in
///     android/app/src/main/AndroidManifest.xml) with your real IDs.
///  3. Create the products listed in [ProductIds] in Google Play Console
///     with exactly the same IDs.
class MonetizationConfig {
  MonetizationConfig._();

  /// While true:
  ///  * Google's official TEST ad units are used.
  ///  * If no real ad / store is reachable (offline, emulator, app not yet
  ///    on Play), a built-in simulated ad / test checkout is shown instead,
  ///    so every reward and purchase flow can be tested with no internet.
  static const bool testMode = true;

  // Google's public test unit IDs (safe to click, never earn money).
  static const String _testInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewarded = 'ca-app-pub-3940256099942544/5224354917';

  // TODO: paste your real ad unit IDs here before release.
  static const String _liveInterstitial = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _liveRewarded = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  static String get interstitialUnitId => testMode ? _testInterstitial : _liveInterstitial;
  static String get rewardedUnitId => testMode ? _testRewarded : _liveRewarded;

  /// Minimum time between two interstitials (AdMob-policy friendly).
  static const Duration interstitialCooldown = Duration(seconds: 90);

  /// Interstitial shows after every Nth finished battle.
  static const int battlesPerInterstitial = 2;

  /// No interstitial during a player's first N battles ever (better retention).
  static const int graceBattles = 3;

  /// Max "free gems" rewarded ads per day.
  static const int dailyFreeGemAds = 5;
}

class ProductIds {
  ProductIds._();
  static const String removeAds = 'remove_ads';
  static const String starterPack = 'starter_pack';
  static const String gemsSmall = 'gems_small';
  static const String gemsMedium = 'gems_medium';
  static const String gemsLarge = 'gems_large';

  static const Set<String> nonConsumables = {removeAds, starterPack};
  static const Set<String> consumables = {gemsSmall, gemsMedium, gemsLarge};
  static Set<String> get all => {...nonConsumables, ...consumables};
}
