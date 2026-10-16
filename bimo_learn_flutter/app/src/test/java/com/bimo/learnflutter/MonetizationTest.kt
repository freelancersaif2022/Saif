package com.bimo.learnflutter

import com.bimo.learnflutter.core.domain.AdPolicy
import com.bimo.learnflutter.core.domain.EntitlementSource
import com.bimo.learnflutter.core.domain.PremiumPlan
import com.bimo.learnflutter.core.domain.PremiumRules
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import java.util.concurrent.TimeUnit

class MonetizationTest {
    private val day = TimeUnit.DAYS.toMillis(1)
    private val now = 1_000L * day

    @Test
    fun mockActivationAndExpiry() {
        val e = PremiumRules.mockSubscription(PremiumPlan.MONTHLY, now)
        assertEquals(EntitlementSource.MOCK_SUBSCRIPTION, e.source)
        assertTrue(e.isActive(now))
        assertTrue(e.isActive(now + 29 * day))
        assertFalse(e.isActive(now + 30 * day))
        assertEquals(30, e.remainingDays(now))
        assertTrue(PremiumRules.isPremium(listOf(e), now + day))
        assertFalse(PremiumRules.isPremium(listOf(e), now + 31 * day))
    }

    @Test
    fun cancelledSubscriptionExpiresAndRenewingOneRenews() {
        val e = PremiumRules.mockSubscription(PremiumPlan.WEEKLY, now)
        val later = now + 20 * day
        val renewed = PremiumRules.renewIfNeeded(e, later)
        assertTrue(renewed.isActive(later))
        assertEquals(now + 21 * day, renewed.expiryMillis)
        val cancelled = e.copy(autoRenewing = false)
        assertFalse(PremiumRules.renewIfNeeded(cancelled, later).isActive(later))
    }

    @Test
    fun promoTrialIsSevenDaysAndClaimableOnce() {
        val trial = PremiumRules.promoTrial(now)
        assertEquals(7 * day, trial.expiryMillis - trial.startMillis)
        assertTrue(PremiumRules.canClaimPromoTrial(false, emptyList(), now))
        assertFalse(PremiumRules.canClaimPromoTrial(true, emptyList(), now))
        assertFalse(PremiumRules.canClaimPromoTrial(false, listOf(trial), now + day))
    }

    @Test
    fun activeEntitlementPrefersLongest() {
        val trial = PremiumRules.promoTrial(now)
        val yearly = PremiumRules.mockSubscription(PremiumPlan.YEARLY, now)
        assertEquals(yearly, PremiumRules.activeEntitlement(listOf(trial, yearly), now))
        assertNull(PremiumRules.activeEntitlement(listOf(trial), now + 8 * day))
    }

    private fun decide(
        premium: Boolean = false, loaded: Boolean = true, saved: Boolean = true,
        rewards: Boolean = true, first: Boolean = true, last: Long = 0L,
    ) = AdPolicy.interstitialAfterLesson(premium, loaded, saved, rewards, first, last, now)

    @Test
    fun interstitialEligibility() {
        assertTrue(decide().show)
        assertFalse(decide(premium = true).show)
        assertFalse(decide(loaded = false).show)
        assertFalse(decide(saved = false).show)
        assertFalse(decide(rewards = false).show)
        assertFalse(decide(first = false).show)
        assertFalse(decide(last = now - 10_000).show)
        assertTrue(decide(last = now - AdPolicy.MIN_INTERVAL_MS).show)
    }

    @Test
    fun rewardedAvailability() {
        assertTrue(AdPolicy.rewardedAvailable(false, true, true))
        assertFalse(AdPolicy.rewardedAvailable(true, true, true))
        assertFalse(AdPolicy.rewardedAvailable(false, false, true))
        assertFalse(AdPolicy.rewardedAvailable(false, true, false))
    }
}
