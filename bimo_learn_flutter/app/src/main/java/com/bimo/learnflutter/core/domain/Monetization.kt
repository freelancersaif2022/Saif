package com.bimo.learnflutter.core.domain

import java.util.concurrent.TimeUnit

enum class PremiumPlan(
    val productId: String,
    val title: String,
    val durationDays: Int,
    /** Demonstration price only. Real prices come from Google Play at runtime. */
    val demoPrice: String,
    val demoPerWeek: String,
    val badge: String?,
) {
    WEEKLY("bimo_premium_weekly", "Weekly", 7, "$2.99", "$2.99 / week", null),
    MONTHLY("bimo_premium_monthly", "Monthly", 30, "$7.99", "$1.86 / week", "Popular"),
    YEARLY("bimo_premium_yearly", "Yearly", 365, "$49.99", "$0.96 / week", "Best value"),
}

enum class EntitlementSource { MOCK_SUBSCRIPTION, PLAY_SUBSCRIPTION, PROMO_TRIAL }

private val DAY_MS = TimeUnit.DAYS.toMillis(1)

data class Entitlement(
    val source: EntitlementSource,
    val plan: PremiumPlan?,
    val startMillis: Long,
    val expiryMillis: Long,
    val autoRenewing: Boolean,
) {
    fun isActive(nowMillis: Long): Boolean = nowMillis in startMillis until expiryMillis
    fun remainingDays(nowMillis: Long): Int =
        if (!isActive(nowMillis)) 0 else ((expiryMillis - nowMillis + DAY_MS - 1) / DAY_MS).toInt()
}

object PremiumRules {
    const val PROMO_TRIAL_DAYS = 7
    private val DAY_MS = TimeUnit.DAYS.toMillis(1)

    /** The entitlement that currently grants premium, preferring the one that lasts longest. */
    fun activeEntitlement(entitlements: List<Entitlement>, nowMillis: Long): Entitlement? =
        entitlements.filter { it.isActive(nowMillis) }.maxByOrNull { it.expiryMillis }

    fun isPremium(entitlements: List<Entitlement>, nowMillis: Long): Boolean =
        activeEntitlement(entitlements, nowMillis) != null

    fun mockSubscription(plan: PremiumPlan, nowMillis: Long): Entitlement =
        Entitlement(EntitlementSource.MOCK_SUBSCRIPTION, plan, nowMillis, nowMillis + plan.durationDays * DAY_MS, true)

    /**
     * Renews a mock auto-renewing subscription period by period until it covers [nowMillis].
     * Cancelled subscriptions (autoRenewing = false) simply expire.
     */
    fun renewIfNeeded(entitlement: Entitlement, nowMillis: Long): Entitlement {
        if (!entitlement.autoRenewing || entitlement.plan == null || entitlement.isActive(nowMillis)) return entitlement
        val period = entitlement.plan.durationDays * DAY_MS
        var expiry = entitlement.expiryMillis
        while (expiry <= nowMillis) expiry += period
        return entitlement.copy(expiryMillis = expiry)
    }

    fun promoTrial(nowMillis: Long): Entitlement =
        Entitlement(EntitlementSource.PROMO_TRIAL, null, nowMillis, nowMillis + PROMO_TRIAL_DAYS * DAY_MS, false)

    /** The 7-day promotional trial can be claimed once per install and not while premium is active. */
    fun canClaimPromoTrial(alreadyClaimed: Boolean, entitlements: List<Entitlement>, nowMillis: Long): Boolean =
        !alreadyClaimed && !isPremium(entitlements, nowMillis)
}

data class AdDecision(val show: Boolean, val reason: String)

/**
 * Interstitial rules (kept pure so they can be unit tested):
 *  - never for premium users,
 *  - only after the completion and its rewards have been persisted,
 *  - only on the *first* completion of a lesson (re-taking a finished lesson never shows an ad),
 *  - only if an ad is actually loaded (progress is never blocked waiting for one),
 *  - at most once per [MIN_INTERVAL_MS] to respect users and AdMob frequency guidance.
 */
object AdPolicy {
    val MIN_INTERVAL_MS: Long = TimeUnit.SECONDS.toMillis(90)

    fun interstitialAfterLesson(
        isPremium: Boolean,
        adLoaded: Boolean,
        completionSaved: Boolean,
        rewardsFinished: Boolean,
        firstCompletion: Boolean,
        lastInterstitialMillis: Long,
        nowMillis: Long,
    ): AdDecision = when {
        isPremium -> AdDecision(false, "premium")
        !completionSaved || !rewardsFinished -> AdDecision(false, "completion not finalised")
        !firstCompletion -> AdDecision(false, "lesson was already completed before")
        !adLoaded -> AdDecision(false, "no ad loaded")
        nowMillis - lastInterstitialMillis < MIN_INTERVAL_MS -> AdDecision(false, "frequency cap")
        else -> AdDecision(true, "eligible")
    }

    fun rewardedAvailable(isPremium: Boolean, adLoaded: Boolean, rewardSlotFree: Boolean): Boolean =
        adLoaded && rewardSlotFree && !isPremium
}
