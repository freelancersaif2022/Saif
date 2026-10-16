package com.bimo.learnflutter.billing

import android.app.Activity
import com.bimo.learnflutter.core.domain.Entitlement
import com.bimo.learnflutter.core.domain.PremiumPlan
import com.bimo.learnflutter.core.domain.PremiumRules
import kotlinx.coroutines.delay
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Local simulation of subscriptions for development and demos. It never contacts Google Play and
 * never charges anything; the UI labels every price as a demonstration value.
 */
@Singleton
class MockSubscriptionGateway @Inject constructor() : SubscriptionGateway {
    override val isMock: Boolean = true

    override suspend fun offers(): List<PlanOffer> =
        PremiumPlan.entries.map { PlanOffer(it, it.demoPrice, it.demoPerWeek, isDemoPrice = true) }

    override suspend fun purchase(activity: Activity, plan: PremiumPlan): PurchaseResult {
        delay(700) // Simulates the store round-trip so the loading state is visible.
        val entitlement: Entitlement = PremiumRules.mockSubscription(plan, System.currentTimeMillis())
        return PurchaseResult.Success(entitlement, purchaseToken = "mock-${plan.productId}-${System.currentTimeMillis()}")
    }

    /** The mock store has no server-side record; locally stored mock entitlements are already restored. */
    override suspend fun restore(): List<Pair<Entitlement, String?>> {
        delay(500)
        return emptyList()
    }
}
