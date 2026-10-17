import 'package:flutter/material.dart';

import '../../config/monetization_config.dart';
import '../../screens/simulated_ad_screen.dart';
import '../../widgets/feedback.dart';
import '../game_store.dart';
import 'ad_backend.dart';
import 'ad_backend_stub.dart' if (dart.library.io) 'ad_backend_admob.dart' as backend;

/// App-level ad rules: frequency caps, Remove Ads, offline handling.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  final AdBackend _backend = backend.createAdBackend();
  late GameStore _store;
  DateTime _lastInterstitial = DateTime.fromMillisecondsSinceEpoch(0);
  int _battlesSinceAd = 0;
  bool _showing = false;

  Future<void> init(GameStore store) async {
    _store = store;
    await _backend.init();
  }

  /// Rewarded ad. Returns true when the player earned the reward.
  Future<bool> showRewarded({required String rewardLabel}) async {
    if (_showing) return false;
    _showing = true;
    try {
      if (_backend.rewardedReady) {
        final earned = await _backend.showRewarded();
        if (!earned) AppToast.show('Watch the full video to get $rewardLabel.', type: ToastType.info, title: 'No reward');
        return earned;
      }
      if (MonetizationConfig.testMode) {
        final earned = await SimulatedAdScreen.open(rewarded: true, rewardLabel: rewardLabel);
        if (!earned) AppToast.show('Watch the full video to get $rewardLabel.', type: ToastType.info, title: 'No reward');
        return earned;
      }
      AppToast.show('No video available right now. Check your internet and try again.', type: ToastType.error, title: 'Ad not ready');
      return false;
    } finally {
      _showing = false;
    }
  }

  /// Call when a battle finishes. Shows an interstitial only when the
  /// frequency rules allow it. Never blocks on network.
  Future<void> onBattleFinished() async {
    if (_store.removeAds || _showing) return;
    _battlesSinceAd++;
    if (_store.totalBattles <= MonetizationConfig.graceBattles) return;
    if (_battlesSinceAd < MonetizationConfig.battlesPerInterstitial) return;
    if (DateTime.now().difference(_lastInterstitial) < MonetizationConfig.interstitialCooldown) return;

    _showing = true;
    try {
      var shown = false;
      if (_backend.interstitialReady) {
        shown = await _backend.showInterstitial();
      } else if (MonetizationConfig.testMode) {
        shown = await SimulatedAdScreen.open(rewarded: false);
      }
      if (shown) {
        _battlesSinceAd = 0;
        _lastInterstitial = DateTime.now();
      }
    } finally {
      _showing = false;
    }
  }

  static Widget adIcon({double size = 18}) => Icon(Icons.play_circle_fill_rounded, size: size, color: Colors.white);
}
