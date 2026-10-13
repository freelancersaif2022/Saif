import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/ad_config.dart';
import 'progress_controller.dart';

/// Google Mobile Ads wrapper.
///
/// * Interstitials are only shown at natural breaks (leaving the results
///   screen), with run and time based frequency caps, never during gameplay,
///   and never when the player owns Remove Ads.
/// * Rewarded ads are always player-initiated and the reward callback only
///   fires from the SDK's `onUserEarnedReward`.
class AdService extends ChangeNotifier {
  AdService(this._progress, {this.enabled = true});

  final ProgressController _progress;
  final bool enabled;

  bool _initialized = false;
  bool _canRequestAds = false;
  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  bool _loadingRewarded = false;
  bool _loadingInterstitial = false;
  bool _showingFullScreen = false;
  DateTime? _lastInterstitial;

  bool get supported => enabled && !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  bool get rewardedReady => _rewarded != null;
  bool get showingFullScreen => _showingFullScreen;
  bool get bannersAllowed => supported && _initialized && _canRequestAds && !_progress.adsRemoved;

  Future<void> init() async {
    if (!supported) return;
    try {
      await _gatherConsent();
      await MobileAds.instance.initialize();
      if (AdConfig.testDeviceIds.isNotEmpty) {
        await MobileAds.instance.updateRequestConfiguration(RequestConfiguration(testDeviceIds: AdConfig.testDeviceIds));
      }
      _initialized = true;
      _canRequestAds = await ConsentInformation.instance.canRequestAds();
      notifyListeners();
      _loadRewarded();
      _loadInterstitial();
    } catch (e) {
      debugPrint('AdService: init failed: $e');
    }
  }

  /// Google UMP consent flow (GDPR / US states). Ads are only requested once
  /// the SDK says consent allows it.
  Future<void> _gatherConsent() {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        try {
          await ConsentForm.loadAndShowConsentFormIfRequired((FormError? e) {
            if (e != null) debugPrint('AdService consent form: ${e.message}');
            if (!done.isCompleted) done.complete();
          });
        } catch (e) {
          if (!done.isCompleted) done.complete();
        }
      },
      (FormError e) {
        debugPrint('AdService consent info: ${e.message}');
        if (!done.isCompleted) done.complete();
      },
    );
    return done.future.timeout(const Duration(seconds: 12), onTimeout: () {});
  }

  Future<void> showPrivacyOptions() async {
    if (!supported) return;
    try {
      await ConsentForm.showPrivacyOptionsForm((_) {});
    } catch (e) {
      debugPrint('AdService: privacy options: $e');
    }
  }

  void _loadRewarded() {
    if (!_initialized || !_canRequestAds || _loadingRewarded || _rewarded != null) return;
    _loadingRewarded = true;
    RewardedAd.load(
      adUnitId: AdConfig.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          _loadingRewarded = false;
          notifyListeners();
        },
        onAdFailedToLoad: (err) {
          debugPrint('AdService: rewarded failed to load: ${err.message}');
          _loadingRewarded = false;
          Future.delayed(const Duration(seconds: 30), _loadRewarded);
        },
      ),
    );
  }

  void _loadInterstitial() {
    if (!_initialized || !_canRequestAds || _progress.adsRemoved) return;
    if (_loadingInterstitial || _interstitial != null) return;
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _loadingInterstitial = false;
        },
        onAdFailedToLoad: (err) {
          debugPrint('AdService: interstitial failed to load: ${err.message}');
          _loadingInterstitial = false;
          Future.delayed(const Duration(seconds: 60), _loadInterstitial);
        },
      ),
    );
  }

  /// Shows a rewarded ad. [onReward] runs only if the SDK reports the reward
  /// was earned. The returned future completes after the ad closes, with
  /// whether the reward was earned.
  Future<bool> showRewarded(VoidCallback onReward) {
    final ad = _rewarded;
    if (ad == null || _showingFullScreen) {
      _loadRewarded();
      return Future.value(false);
    }
    _rewarded = null;
    _showingFullScreen = true;
    notifyListeners();
    final result = Completer<bool>();
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _afterFullScreen();
        if (!result.isCompleted) result.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _afterFullScreen();
        if (!result.isCompleted) result.complete(false);
      },
    );
    ad.show(
      onUserEarnedReward: (_, _) {
        if (earned) return;
        earned = true;
        onReward();
      },
    );
    return result.future;
  }

  /// Called when a run ends.
  void registerCompletedRun() {
    _progress.mutate((p) => p.runsSinceInterstitial++);
  }

  /// Shows an interstitial at a natural transition if frequency caps allow.
  /// Completes once the ad is closed (or immediately if none is shown).
  Future<void> maybeShowInterstitial() async {
    if (!supported || _progress.adsRemoved || _showingFullScreen) return;
    if (_progress.data.runsSinceInterstitial < AdConfig.interstitialEveryRuns) return;
    final last = _lastInterstitial;
    if (last != null && DateTime.now().difference(last) < AdConfig.interstitialMinInterval) return;
    final ad = _interstitial;
    if (ad == null) {
      _loadInterstitial();
      return;
    }
    _interstitial = null;
    _showingFullScreen = true;
    final closed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _afterFullScreen();
        if (!closed.isCompleted) closed.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _afterFullScreen();
        if (!closed.isCompleted) closed.complete();
      },
    );
    _lastInterstitial = DateTime.now();
    _progress.mutate((p) => p.runsSinceInterstitial = 0);
    await ad.show();
    await closed.future;
  }

  void _afterFullScreen() {
    _showingFullScreen = false;
    notifyListeners();
    _loadRewarded();
    _loadInterstitial();
  }

  /// Called after Remove Ads is purchased.
  void onRemoveAdsChanged() {
    if (_progress.adsRemoved) {
      _interstitial?.dispose();
      _interstitial = null;
    }
    notifyListeners();
  }

  BannerAd? createBanner(void Function(Ad ad) onLoaded) {
    if (!bannersAllowed) return null;
    return BannerAd(
      adUnitId: AdConfig.bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: (ad, err) {
          debugPrint('AdService: banner failed: ${err.message}');
          ad.dispose();
        },
      ),
    );
  }

  @override
  void dispose() {
    _interstitial?.dispose();
    _rewarded?.dispose();
    super.dispose();
  }
}
