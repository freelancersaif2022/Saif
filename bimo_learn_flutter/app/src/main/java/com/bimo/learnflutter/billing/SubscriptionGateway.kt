package com.bimo.learnflutter.billing

import android.app.Activity
import com.bimo.learnflutter.core.domain.Entitlement
import com.bimo.learnflutter.core.domain.PremiumPlan

/** A plan as offered to the user. [price] is a demo value for the mock gateway, a Play price otherwise. */
data class PlanOffer(
    val plan: PremiumPlan,
    val price: String,
    val perWeek: String,
    val isDemoPrice: Boolean,
)

sealed interface PurchaseResult {
    data class Success(val entitlement: Entitlement, val purchaseToken: String?) : PurchaseResult
    data object Cancelled : PurchaseResult
    data object Pending : PurchaseResult
    data class Error(val message: String) : PurchaseResult
}

/**
 * Billing abstraction. [MockSubscriptionGateway] simulates purchases locally (no money moves);
 * [PlayBillingSubscriptionGateway] talks to Google Play Billing. The implementation is chosen in
 * `BillingModule` from `BuildConfig.USE_MOCK_BILLING`.
 */
interface SubscriptionGateway {
    val isMock: Boolean
    suspend fun offers(): List<PlanOffer>
    suspend fun purchase(activity: Activity, plan: PremiumPlan): PurchaseResult
    /** Returns entitlements owned by the user according to the store. */
    suspend fun restore(): List<Pair<Entitlement, String?>>
}
