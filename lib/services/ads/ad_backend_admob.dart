import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../config/monetization_config.dart';
import 'ad_backend.dart';

AdBackend createAdBackend() => _AdMobBackend();

class _AdMobBackend implements AdBackend {
  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  bool _loadingInterstitial = false;
  bool _loadingRewarded = false;
  int _interstitialFails = 0;
  int _rewardedFails = 0;
  bool _ready = false;

  @override
  Future<void> init() async {
    try {
      await MobileAds.instance.initialize().timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('AdMob init: $e');
    }
    _ready = true;
    _loadInterstitial();
    _loadRewarded();
  }

  // Retry with backoff so an offline phone does not hammer the SDK.
  Duration _backoff(int fails) => Duration(seconds: (15 * (1 << fails.clamp(0, 5))).clamp(15, 480));

  void _loadInterstitial() {
    if (!_ready || _loadingInterstitial || _interstitial != null) return;
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: MonetizationConfig.interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _loadingInterstitial = false;
          _interstitialFails = 0;
        },
        onAdFailedToLoad: (err) {
          _loadingInterstitial = false;
          Timer(_backoff(_interstitialFails++), _loadInterstitial);
        },
      ),
    );
  }

  void _loadRewarded() {
    if (!_ready || _loadingRewarded || _rewarded != null) return;
    _loadingRewarded = true;
    RewardedAd.load(
      adUnitId: MonetizationConfig.rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          _loadingRewarded = false;
          _rewardedFails = 0;
        },
        onAdFailedToLoad: (err) {
          _loadingRewarded = false;
          Timer(_backoff(_rewardedFails++), _loadRewarded);
        },
      ),
    );
  }

  @override
  bool get interstitialReady {
    if (_interstitial == null) _loadInterstitial();
    return _interstitial != null;
  }

  @override
  bool get rewardedReady {
    if (_rewarded == null) _loadRewarded();
    return _rewarded != null;
  }

  @override
  Future<bool> showInterstitial() {
    final ad = _interstitial;
    if (ad == null) return Future.value(false);
    _interstitial = null;
    final done = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!done.isCompleted) done.complete(true);
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        if (!done.isCompleted) done.complete(false);
        _loadInterstitial();
      },
    );
    ad.show();
    return done.future;
  }

  @override
  Future<bool> showRewarded() {
    final ad = _rewarded;
    if (ad == null) return Future.value(false);
    _rewarded = null;
    var earned = false;
    final done = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!done.isCompleted) done.complete(earned);
        _loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        if (!done.isCompleted) done.complete(false);
        _loadRewarded();
      },
    );
    ad.show(onUserEarnedReward: (_, _) => earned = true);
    return done.future;
  }
}
