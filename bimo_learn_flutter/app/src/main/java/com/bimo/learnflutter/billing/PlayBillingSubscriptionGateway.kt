package com.bimo.learnflutter.billing

import android.app.Activity
import android.content.Context
import com.android.billingclient.api.AcknowledgePurchaseParams
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClientStateListener
import com.android.billingclient.api.BillingFlowParams
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.PendingPurchasesParams
import com.android.billingclient.api.ProductDetails
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import com.android.billingclient.api.QueryProductDetailsParams
import com.android.billingclient.api.QueryPurchasesParams
import com.android.billingclient.api.acknowledgePurchase
import com.android.billingclient.api.queryProductDetails
import com.android.billingclient.api.queryPurchasesAsync
import com.bimo.learnflutter.core.domain.Entitlement
import com.bimo.learnflutter.core.domain.EntitlementSource
import com.bimo.learnflutter.core.domain.PremiumPlan
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.suspendCancellableCoroutine
import java.util.concurrent.TimeUnit
import javax.inject.Inject
import javax.inject.Singleton
import kotlin.coroutines.resume

/**
 * Google Play Billing implementation (Billing Library 7). To activate it:
 *  1. Create subscriptions with the product ids from [PremiumPlan] in Play Console.
 *  2. Set `USE_MOCK_BILLING` to false in app/build.gradle.kts.
 *  3. Verify purchases on your own backend before trusting them in production.
 */
@Singleton
class PlayBillingSubscriptionGateway @Inject constructor(
    @ApplicationContext private val context: Context,
) : SubscriptionGateway, PurchasesUpdatedListener {

    override val isMock: Boolean = false

    private var pendingPurchase: CompletableDeferred<PurchaseResult>? = null
    private var pendingPlan: PremiumPlan? = null
    private val details = mutableMapOf<String, ProductDetails>()

    private val client: BillingClient = BillingClient.newBuilder(context)
        .setListener(this)
        .enablePendingPurchases(PendingPurchasesParams.newBuilder().enableOneTimeProducts().build())
        .build()

    private suspend fun ensureConnected(): Boolean {
        if (client.isReady) return true
        return suspendCancellableCoroutine { cont ->
            client.startConnection(object : BillingClientStateListener {
                override fun onBillingSetupFinished(result: BillingResult) {
                    if (cont.isActive) cont.resume(result.responseCode == BillingClient.BillingResponseCode.OK)
                }

                override fun onBillingServiceDisconnected() {
                    if (cont.isActive) cont.resume(false)
                }
            })
        }
    }

    override suspend fun offers(): List<PlanOffer> {
        if (!ensureConnected()) return emptyList()
        val products = PremiumPlan.entries.map {
            QueryProductDetailsParams.Product.newBuilder()
                .setProductId(it.productId)
                .setProductType(BillingClient.ProductType.SUBS)
                .build()
        }
        val result = client.queryProductDetails(
            QueryProductDetailsParams.newBuilder().setProductList(products).build(),
        )
        result.productDetailsList.orEmpty().forEach { details[it.productId] = it }
        return PremiumPlan.entries.mapNotNull { plan ->
            val product = details[plan.productId] ?: return@mapNotNull null
            val phase = product.subscriptionOfferDetails?.firstOrNull()
                ?.pricingPhases?.pricingPhaseList?.lastOrNull() ?: return@mapNotNull null
            PlanOffer(plan, phase.formattedPrice, phase.billingPeriod, isDemoPrice = false)
        }
    }

    override suspend fun purchase(activity: Activity, plan: PremiumPlan): PurchaseResult {
        if (!ensureConnected()) return PurchaseResult.Error("Google Play is not available right now.")
        if (details[plan.productId] == null) offers()
        val product = details[plan.productId] ?: return PurchaseResult.Error("This plan is not available.")
        val offerToken = product.subscriptionOfferDetails?.firstOrNull()?.offerToken
            ?: return PurchaseResult.Error("This plan has no active offer.")
        val params = BillingFlowParams.newBuilder()
            .setProductDetailsParamsList(
                listOf(
                    BillingFlowParams.ProductDetailsParams.newBuilder()
                        .setProductDetails(product)
                        .setOfferToken(offerToken)
                        .build(),
                ),
            )
            .build()
        val deferred = CompletableDeferred<PurchaseResult>()
        pendingPurchase = deferred
        pendingPlan = plan
        val launch = client.launchBillingFlow(activity, params)
        if (launch.responseCode != BillingClient.BillingResponseCode.OK) {
            pendingPurchase = null
            return PurchaseResult.Error(launch.debugMessage.ifBlank { "Could not start the purchase." })
        }
        return deferred.await()
    }

    override fun onPurchasesUpdated(result: BillingResult, purchases: MutableList<Purchase>?) {
        val deferred = pendingPurchase ?: return
        val plan = pendingPlan
        pendingPurchase = null
        when (result.responseCode) {
            BillingClient.BillingResponseCode.OK -> {
                val purchase = purchases?.firstOrNull()
                if (purchase == null || plan == null) {
                    deferred.complete(PurchaseResult.Error("No purchase was returned."))
                } else if (purchase.purchaseState == Purchase.PurchaseState.PENDING) {
                    deferred.complete(PurchaseResult.Pending)
                } else {
                    deferred.complete(PurchaseResult.Success(toEntitlement(purchase, plan), purchase.purchaseToken))
                }
            }
            BillingClient.BillingResponseCode.USER_CANCELED -> deferred.complete(PurchaseResult.Cancelled)
            else -> deferred.complete(PurchaseResult.Error(result.debugMessage.ifBlank { "Purchase failed." }))
        }
    }

    override suspend fun restore(): List<Pair<Entitlement, String?>> {
        if (!ensureConnected()) return emptyList()
        val result = client.queryPurchasesAsync(
            QueryPurchasesParams.newBuilder().setProductType(BillingClient.ProductType.SUBS).build(),
        )
        return result.purchasesList
            .filter { it.purchaseState == Purchase.PurchaseState.PURCHASED }
            .mapNotNull { purchase ->
                val plan = PremiumPlan.entries.firstOrNull { it.productId in purchase.products } ?: return@mapNotNull null
                acknowledge(purchase)
                toEntitlement(purchase, plan) to purchase.purchaseToken
            }
    }

    suspend fun acknowledge(purchase: Purchase) {
        if (purchase.isAcknowledged || !ensureConnected()) return
        client.acknowledgePurchase(
            AcknowledgePurchaseParams.newBuilder().setPurchaseToken(purchase.purchaseToken).build(),
        )
    }

    /**
     * Play does not expose the expiry on the client; we approximate it from the purchase time and
     * the plan period and refresh it via [restore] on every app start. A backend using the Google
     * Play Developer API should be the source of truth in production.
     */
    private fun toEntitlement(purchase: Purchase, plan: PremiumPlan): Entitlement {
        val period = TimeUnit.DAYS.toMillis(plan.durationDays.toLong())
        var expiry = purchase.purchaseTime + period
        val now = System.currentTimeMillis()
        if (purchase.isAutoRenewing) while (expiry <= now) expiry += period
        return Entitlement(EntitlementSource.PLAY_SUBSCRIPTION, plan, purchase.purchaseTime, expiry, purchase.isAutoRenewing)
    }
}
