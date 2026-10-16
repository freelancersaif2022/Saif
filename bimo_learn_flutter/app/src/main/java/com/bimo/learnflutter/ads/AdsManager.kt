package com.bimo.learnflutter.ads

import android.app.Activity
import android.content.Context
import android.util.Log
import com.bimo.learnflutter.BuildConfig
import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback
import com.google.android.ump.ConsentInformation
import com.google.android.ump.ConsentRequestParameters
import com.google.android.ump.UserMessagingPlatform
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.util.concurrent.atomic.AtomicBoolean
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Wraps the Google Mobile Ads SDK.
 *  - Consent is gathered with Google's User Messaging Platform before any ad request.
 *  - Ads are preloaded so showing one never delays the learner.
 *  - Callers decide *whether* to show an ad with the pure [com.bimo.learnflutter.core.domain.AdPolicy].
 *
 * Unit ids come from BuildConfig and default to Google's official test ids.
 */
@Singleton
class AdsManager @Inject constructor(
    @ApplicationContext private val context: Context,
) {
    private val consentInformation: ConsentInformation = UserMessagingPlatform.getConsentInformation(context)
    private val sdkInitialized = AtomicBoolean(false)

    private var interstitial: InterstitialAd? = null
    private var rewarded: RewardedAd? = null
    private var loadingInterstitial = false
    private var loadingRewarded = false

    private val _interstitialReady = MutableStateFlow(false)
    val interstitialReady: StateFlow<Boolean> = _interstitialReady.asStateFlow()
    private val _rewardedReady = MutableStateFlow(false)
    val rewardedReady: StateFlow<Boolean> = _rewardedReady.asStateFlow()

    /** Whether a privacy-options entry point must be shown in Settings (required in some regions). */
    val privacyOptionsRequired: Boolean
        get() = consentInformation.privacyOptionsRequirementStatus ==
            ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED

    /** Call from the activity on start. Safe to call repeatedly. */
    fun gatherConsentAndInitialize(activity: Activity, preloadInterstitial: Boolean) {
        val params = ConsentRequestParameters.Builder().build()
        consentInformation.requestConsentInfoUpdate(
            activity,
            params,
            {
                UserMessagingPlatform.loadAndShowConsentFormIfRequired(activity) { formError ->
                    formError?.let { Log.w(TAG, "Consent form: ${it.message}") }
                    initializeIfAllowed(preloadInterstitial)
                }
            },
            { requestError ->
                Log.w(TAG, "Consent info update failed: ${requestError.message}")
                initializeIfAllowed(preloadInterstitial)
            },
        )
        // Consent obtained in a previous session allows requests right away.
        initializeIfAllowed(preloadInterstitial)
    }

    fun showPrivacyOptions(activity: Activity, onDone: (String?) -> Unit) {
        UserMessagingPlatform.showPrivacyOptionsForm(activity) { error -> onDone(error?.message) }
    }

    private fun initializeIfAllowed(preloadInterstitial: Boolean) {
        if (!consentInformation.canRequestAds()) return
        if (sdkInitialized.compareAndSet(false, true)) {
            MobileAds.initialize(context) {}
        }
        if (preloadInterstitial) loadInterstitial()
        loadRewarded()
    }

    fun loadInterstitial() {
        if (!sdkInitialized.get() || interstitial != null || loadingInterstitial) return
        loadingInterstitial = true
        InterstitialAd.load(
            context,
            BuildConfig.ADMOB_INTERSTITIAL_ID,
            AdRequest.Builder().build(),
            object : InterstitialAdLoadCallback() {
                override fun onAdLoaded(ad: InterstitialAd) {
                    loadingInterstitial = false
                    interstitial = ad
                    _interstitialReady.value = true
                }

                override fun onAdFailedToLoad(error: LoadAdError) {
                    loadingInterstitial = false
                    interstitial = null
                    _interstitialReady.value = false
                    Log.i(TAG, "Interstitial failed to load: ${error.message}")
                }
            },
        )
    }

    fun loadRewarded() {
        if (!sdkInitialized.get() || rewarded != null || loadingRewarded) return
        loadingRewarded = true
        RewardedAd.load(
            context,
            BuildConfig.ADMOB_REWARDED_ID,
            AdRequest.Builder().build(),
            object : RewardedAdLoadCallback() {
                override fun onAdLoaded(ad: RewardedAd) {
                    loadingRewarded = false
                    rewarded = ad
                    _rewardedReady.value = true
                }

                override fun onAdFailedToLoad(error: LoadAdError) {
                    loadingRewarded = false
                    rewarded = null
                    _rewardedReady.value = false
                    Log.i(TAG, "Rewarded failed to load: ${error.message}")
                }
            },
        )
    }

    /**
     * Shows the preloaded interstitial. [onFinished] is always invoked exactly once, whether the ad
     * was shown, dismissed or failed, so navigation can continue regardless.
     */
    fun showInterstitial(activity: Activity, onFinished: (shown: Boolean) -> Unit) {
        val ad = interstitial
        if (ad == null) {
            onFinished(false)
            loadInterstitial()
            return
        }
        interstitial = null
        _interstitialReady.value = false
        val finished = AtomicBoolean(false)
        ad.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdDismissedFullScreenContent() {
                if (finished.compareAndSet(false, true)) onFinished(true)
                loadInterstitial()
            }

            override fun onAdFailedToShowFullScreenContent(error: AdError) {
                if (finished.compareAndSet(false, true)) onFinished(false)
                loadInterstitial()
            }
        }
        ad.show(activity)
    }

    /**
     * Shows a rewarded ad. [onReward] fires only from the SDK's onUserEarnedReward callback – rewards
     * are never granted before the user has actually earned them. [onClosed] fires when the ad goes away.
     */
    fun showRewarded(activity: Activity, onReward: () -> Unit, onClosed: (rewarded: Boolean) -> Unit) {
        val ad = rewarded
        if (ad == null) {
            onClosed(false)
            loadRewarded()
            return
        }
        rewarded = null
        _rewardedReady.value = false
        val earned = AtomicBoolean(false)
        ad.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdDismissedFullScreenContent() {
                onClosed(earned.get())
                loadRewarded()
            }

            override fun onAdFailedToShowFullScreenContent(error: AdError) {
                onClosed(false)
                loadRewarded()
            }
        }
        ad.show(activity) {
            if (earned.compareAndSet(false, true)) onReward()
        }
    }

    /** Premium users get an ad-free experience: drop anything already loaded. */
    fun releaseInterstitial() {
        interstitial = null
        _interstitialReady.value = false
    }

    private companion object {
        const val TAG = "AdsManager"
    }
}
