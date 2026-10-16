package com.bimo.learnflutter.data.repository

import android.app.Activity
import com.bimo.learnflutter.billing.PlanOffer
import com.bimo.learnflutter.billing.PurchaseResult
import com.bimo.learnflutter.billing.SubscriptionGateway
import com.bimo.learnflutter.core.domain.Entitlement
import com.bimo.learnflutter.core.domain.EntitlementSource
import com.bimo.learnflutter.core.domain.PremiumPlan
import com.bimo.learnflutter.core.domain.PremiumRules
import com.bimo.learnflutter.data.db.dao.EntitlementDao
import com.bimo.learnflutter.data.db.entity.EntitlementEntity
import com.bimo.learnflutter.data.prefs.SettingsDataStore
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map
import java.util.concurrent.TimeUnit
import javax.inject.Inject
import javax.inject.Singleton

data class PremiumStatus(
    val isPremium: Boolean,
    val active: Entitlement?,
    val promoTrialClaimed: Boolean,
    val canClaimPromoTrial: Boolean,
    val history: List<Entitlement>,
) {
    companion object {
        val FREE = PremiumStatus(false, null, false, true, emptyList())
    }
}

@Singleton
class PremiumRepository @Inject constructor(
    private val dao: EntitlementDao,
    private val gateway: SubscriptionGateway,
    private val settings: SettingsDataStore,
    private val time: TimeProvider,
) {
    val isMockBilling: Boolean get() = gateway.isMock

    /** Re-evaluates expiry once a minute so premium ends on time even while the app is open. */
    private val ticker: Flow<Long> = flow {
        while (true) {
            emit(time.nowMillis())
            delay(TimeUnit.MINUTES.toMillis(1))
        }
    }

    val status: Flow<PremiumStatus> = combine(dao.observeAll(), settings.settings, ticker) { rows, prefs, now ->
        val entitlements = rows.map { it.toDomain() }.map { PremiumRules.renewIfNeeded(it, now) }
        val active = PremiumRules.activeEntitlement(entitlements, now)
        PremiumStatus(
            isPremium = active != null,
            active = active,
            promoTrialClaimed = prefs.promoTrialClaimed,
            canClaimPromoTrial = PremiumRules.canClaimPromoTrial(prefs.promoTrialClaimed, entitlements, now),
            history = entitlements,
        )
    }.distinctUntilChanged()

    val isPremium: Flow<Boolean> = status.map { it.isPremium }.distinctUntilChanged()

    suspend fun currentlyPremium(): Boolean = isPremium.first()

    suspend fun offers(): List<PlanOffer> = gateway.offers()

    suspend fun purchase(activity: Activity, plan: PremiumPlan): PurchaseResult {
        val result = gateway.purchase(activity, plan)
        if (result is PurchaseResult.Success) {
            val e = result.entitlement
            dao.insert(
                EntitlementEntity(
                    source = e.source.name, plan = e.plan?.name, startMillis = e.startMillis,
                    expiryMillis = e.expiryMillis, autoRenewing = e.autoRenewing, purchaseToken = result.purchaseToken,
                ),
            )
        }
        return result
    }

    /** Returns the number of entitlements restored from the store. */
    suspend fun restore(): Int {
        val restored = gateway.restore()
        if (restored.isEmpty()) return 0
        dao.deleteBySource(EntitlementSource.PLAY_SUBSCRIPTION.name)
        restored.forEach { (e, token) ->
            dao.insert(
                EntitlementEntity(
                    source = e.source.name, plan = e.plan?.name, startMillis = e.startMillis,
                    expiryMillis = e.expiryMillis, autoRenewing = e.autoRenewing, purchaseToken = token,
                ),
            )
        }
        return restored.size
    }

    /** Mock subscriptions can be cancelled from the app; they stay active until the period ends. */
    suspend fun cancelMockSubscription() {
        dao.cancelAutoRenew(EntitlementSource.MOCK_SUBSCRIPTION.name)
    }

    /**
     * Grants the 7-day promotional trial. Callers must only invoke this after a rewarded ad's
     * `onUserEarnedReward` callback, or from the clearly labelled simulated flow in debug/demo builds.
     */
    suspend fun claimPromoTrial(): Boolean {
        val prefs = settings.current()
        val entitlements = dao.all().map { it.toDomain() }
        val now = time.nowMillis()
        if (!PremiumRules.canClaimPromoTrial(prefs.promoTrialClaimed, entitlements, now)) return false
        val trial = PremiumRules.promoTrial(now)
        dao.insert(
            EntitlementEntity(
                source = trial.source.name, plan = null, startMillis = trial.startMillis,
                expiryMillis = trial.expiryMillis, autoRenewing = false,
            ),
        )
        settings.setPromoTrialClaimed(true)
        return true
    }

    private fun EntitlementEntity.toDomain() = Entitlement(
        source = runCatching { EntitlementSource.valueOf(source) }.getOrDefault(EntitlementSource.MOCK_SUBSCRIPTION),
        plan = plan?.let { p -> PremiumPlan.entries.firstOrNull { it.name == p } },
        startMillis = startMillis,
        expiryMillis = expiryMillis,
        autoRenewing = autoRenewing,
    )
}
