package com.bimo.learnflutter.ui.screens.premium

import android.app.Activity
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.scaleIn
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Block
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Extension
import androidx.compose.material.icons.filled.Face
import androidx.compose.material.icons.filled.Insights
import androidx.compose.material.icons.automirrored.filled.LibraryBooks
import androidx.compose.material.icons.filled.OndemandVideo
import androidx.compose.material.icons.filled.Palette
import androidx.compose.material.icons.filled.WorkspacePremium
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewModelScope
import com.bimo.learnflutter.BuildConfig
import com.bimo.learnflutter.ads.AdsManager
import com.bimo.learnflutter.billing.PlanOffer
import com.bimo.learnflutter.billing.PurchaseResult
import com.bimo.learnflutter.core.domain.EntitlementSource
import com.bimo.learnflutter.core.domain.PremiumPlan
import com.bimo.learnflutter.data.repository.PremiumRepository
import com.bimo.learnflutter.data.repository.PremiumStatus
import com.bimo.learnflutter.ui.components.ConfettiOverlay
import com.bimo.learnflutter.ui.components.findActivity
import com.bimo.learnflutter.ui.components.formatDate
import com.bimo.learnflutter.ui.navigation.BimoNavigator
import com.bimo.learnflutter.ui.theme.BimoColors
import com.bimo.learnflutter.ui.theme.BimoGradients
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

data class PremiumUiState(
    val status: PremiumStatus = PremiumStatus.FREE,
    val offers: List<PlanOffer> = emptyList(),
    val selected: PremiumPlan = PremiumPlan.YEARLY,
    val busy: Boolean = false,
    val message: String? = null,
    val celebrate: Int = 0,
    val isMockBilling: Boolean = true,
    val rewardedReady: Boolean = false,
)

@HiltViewModel
class PremiumViewModel @Inject constructor(
    private val premium: PremiumRepository,
    private val ads: AdsManager,
) : ViewModel() {
    private val local = MutableStateFlow(PremiumUiState(isMockBilling = premium.isMockBilling))

    val state: StateFlow<PremiumUiState> = combine(local, premium.status, ads.rewardedReady) { l, status, rewarded ->
        l.copy(status = status, rewardedReady = rewarded)
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), PremiumUiState())

    init {
        viewModelScope.launch {
            val offers = premium.offers()
            local.update { it.copy(offers = offers, message = if (offers.isEmpty()) "Plans are unavailable right now. Check your connection and try again." else null) }
        }
    }

    fun select(plan: PremiumPlan) = local.update { it.copy(selected = plan) }

    fun purchase(activity: Activity?) {
        activity ?: return
        val plan = local.value.selected
        local.update { it.copy(busy = true) }
        viewModelScope.launch {
            val msg = when (val r = premium.purchase(activity, plan)) {
                is PurchaseResult.Success -> {
                    local.update { it.copy(celebrate = it.celebrate + 1) }
                    if (premium.isMockBilling) "Demo ${plan.title} Premium activated. No money was charged." else "Welcome to Bimo Premium!"
                }
                PurchaseResult.Cancelled -> null
                PurchaseResult.Pending -> "Your purchase is pending. Premium activates once Google Play confirms it."
                is PurchaseResult.Error -> r.message
            }
            local.update { it.copy(busy = false, message = msg) }
        }
    }

    fun restore() {
        local.update { it.copy(busy = true) }
        viewModelScope.launch {
            val count = premium.restore()
            local.update {
                it.copy(
                    busy = false,
                    message = when {
                        count > 0 -> "Restored $count purchase(s)."
                        premium.isMockBilling -> "Demo mode: mock subscriptions are stored on this device and are already active if purchased."
                        else -> "No purchases found for this Google account."
                    },
                )
            }
        }
    }

    fun cancelMock() = viewModelScope.launch {
        premium.cancelMockSubscription()
        local.update { it.copy(message = "Auto-renew turned off. Premium stays active until the end of the current period.") }
    }

    /**
     * Seven-day promotional trial via a rewarded ad. The entitlement is granted only from the SDK's
     * onUserEarnedReward callback. If no ad can be loaded, debug/demo builds may use the clearly
     * labelled simulated reward flow (BuildConfig.ALLOW_SIMULATED_REWARDS, false in release).
     */
    fun claimTrialWithAd(activity: Activity?) {
        activity ?: return
        ads.showRewarded(
            activity,
            onReward = { grantTrial() },
            onClosed = { earned ->
                if (!earned) local.update { it.copy(message = "The trial is granted only after the ad finishes.") }
            },
        )
    }

    fun claimTrialSimulated() {
        if (!BuildConfig.ALLOW_SIMULATED_REWARDS) return
        grantTrial()
    }

    private fun grantTrial() {
        viewModelScope.launch {
            val ok = premium.claimPromoTrial()
            local.update {
                it.copy(
                    message = if (ok) "Your 7-day promotional premium trial is active." else "The promotional trial has already been claimed.",
                    celebrate = if (ok) it.celebrate + 1 else it.celebrate,
                )
            }
        }
    }

    fun dismissMessage() = local.update { it.copy(message = null) }
}

private data class Benefit(val icon: ImageVector, val title: String, val text: String)

private val benefits = listOf(
    Benefit(Icons.Filled.Block, "Ad-free learning", "No interstitial or rewarded ads anywhere in the app."),
    Benefit(Icons.Filled.Palette, "Premium themes", "Ocean, Sunset, Forest and Midnight Gold colour themes."),
    Benefit(Icons.Filled.Extension, "Extra practice challenges", "Every advanced coding challenge, unlocked."),
    Benefit(Icons.Filled.Insights, "Advanced learning insights", "Accuracy per module, focus areas and activity trends."),
    Benefit(Icons.Filled.Face, "Exclusive cosmetics", "Gold, Aurora and Fire avatar frames."),
    Benefit(Icons.AutoMirrored.Filled.LibraryBooks, "Premium resources", "Curated reading lists inside advanced challenges."),
)

@Composable
fun PremiumScreen(navigator: BimoNavigator, viewModel: PremiumViewModel = hiltViewModel()) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    val activity = LocalContext.current.findActivity()
    var confirmPlan by remember { mutableStateOf(false) }
    val active = state.status.active
    val now = System.currentTimeMillis()

    Box(Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background)) {
        Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState())) {
            Box(
                Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(bottomStart = 36.dp, bottomEnd = 36.dp))
                    .background(BimoGradients.Premium),
            ) {
                Column(Modifier.statusBarsPadding().padding(start = 8.dp, end = 20.dp, bottom = 24.dp)) {
                    IconButton(onClick = navigator::back) { Icon(Icons.AutoMirrored.Filled.ArrowBack, "Back", tint = Color.White) }
                    Column(Modifier.padding(start = 12.dp)) {
                        Icon(Icons.Filled.WorkspacePremium, null, tint = BimoColors.Gold, modifier = Modifier.size(48.dp))
                        Spacer(Modifier.height(8.dp))
                        Text("Bimo Premium", style = MaterialTheme.typography.headlineMedium, color = Color.White)
                        Text(
                            "Support Bimo and learn without distractions. The full Dart & Flutter curriculum always stays free.",
                            style = MaterialTheme.typography.bodyMedium,
                            color = Color.White.copy(alpha = 0.9f),
                        )
                    }
                }
            }

            Column(Modifier.padding(20.dp).navigationBarsPadding(), verticalArrangement = Arrangement.spacedBy(14.dp)) {
                if (active != null) {
                    Surface(shape = RoundedCornerShape(20.dp), color = BimoColors.Success.copy(alpha = 0.12f), border = BorderStroke(1.dp, BimoColors.Success)) {
                        Column(Modifier.fillMaxWidth().padding(16.dp)) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(Icons.Filled.CheckCircle, null, tint = BimoColors.Success)
                                Spacer(Modifier.width(8.dp))
                                Text("Premium is active", style = MaterialTheme.typography.titleMedium)
                            }
                            Text(
                                when (active.source) {
                                    EntitlementSource.PROMO_TRIAL -> "7-day promotional trial"
                                    EntitlementSource.MOCK_SUBSCRIPTION -> "${active.plan?.title} plan (demo subscription)"
                                    EntitlementSource.PLAY_SUBSCRIPTION -> "${active.plan?.title} plan"
                                },
                                style = MaterialTheme.typography.bodyMedium,
                            )
                            Text(
                                (if (active.autoRenewing) "Renews on " else "Expires on ") + formatDate(active.expiryMillis) +
                                    " • ${active.remainingDays(now)} days left",
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                            )
                            if (active.source == EntitlementSource.MOCK_SUBSCRIPTION && active.autoRenewing) {
                                TextButton(onClick = { viewModel.cancelMock() }) { Text("Cancel auto-renew (demo)") }
                            }
                        }
                    }
                }

                Text("What you get", style = MaterialTheme.typography.titleLarge)
                benefits.forEach { b ->
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(Modifier.size(40.dp).clip(RoundedCornerShape(12.dp)).background(MaterialTheme.colorScheme.primaryContainer), contentAlignment = Alignment.Center) {
                            Icon(b.icon, null, tint = MaterialTheme.colorScheme.primary)
                        }
                        Spacer(Modifier.width(12.dp))
                        Column {
                            Text(b.title, style = MaterialTheme.typography.titleSmall)
                            Text(b.text, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                        }
                    }
                }

                ComparisonTable()

                Text("Choose a plan", style = MaterialTheme.typography.titleLarge)
                if (state.isMockBilling) {
                    Surface(shape = RoundedCornerShape(14.dp), color = BimoColors.Warning.copy(alpha = 0.15f)) {
                        Text(
                            "DEMONSTRATION MODE — prices below are example values. Purchases are simulated on this device and no money is charged.",
                            Modifier.padding(12.dp),
                            style = MaterialTheme.typography.bodySmall,
                            fontWeight = FontWeight.SemiBold,
                        )
                    }
                }
                state.offers.forEach { offer ->
                    PlanCard(offer, selected = offer.plan == state.selected) { viewModel.select(offer.plan) }
                }
                Button(
                    onClick = { confirmPlan = true },
                    enabled = !state.busy && state.offers.isNotEmpty(),
                    modifier = Modifier.fillMaxWidth().height(56.dp),
                ) {
                    if (state.busy) CircularProgressIndicator(Modifier.size(22.dp), color = MaterialTheme.colorScheme.onPrimary, strokeWidth = 2.dp)
                    else Text(if (active != null) "Change plan" else "Continue with ${state.selected.title}", style = MaterialTheme.typography.titleMedium)
                }
                TextButton(onClick = viewModel::restore, enabled = !state.busy, modifier = Modifier.align(Alignment.CenterHorizontally)) {
                    Text("Restore purchases")
                }

                // Seven-day promotional trial
                Surface(shape = RoundedCornerShape(20.dp), color = MaterialTheme.colorScheme.tertiaryContainer) {
                    Column(Modifier.fillMaxWidth().padding(16.dp)) {
                        Text("7-day promotional trial", style = MaterialTheme.typography.titleMedium, color = MaterialTheme.colorScheme.onTertiaryContainer)
                        Text(
                            "Demonstration feature: watch one rewarded ad to try Premium for 7 days. Can be claimed once per install.",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onTertiaryContainer,
                        )
                        Spacer(Modifier.height(10.dp))
                        when {
                            state.status.promoTrialClaimed -> Text("Already claimed on this device.", style = MaterialTheme.typography.labelLarge)
                            !state.status.canClaimPromoTrial -> Text("Available when Premium is not active.", style = MaterialTheme.typography.labelLarge)
                            else -> {
                                OutlinedButton(onClick = { viewModel.claimTrialWithAd(activity) }, enabled = state.rewardedReady, modifier = Modifier.fillMaxWidth()) {
                                    Icon(Icons.Filled.OndemandVideo, null)
                                    Spacer(Modifier.width(6.dp))
                                    Text(if (state.rewardedReady) "Watch ad to start trial" else "No ad available right now")
                                }
                                if (BuildConfig.ALLOW_SIMULATED_REWARDS && !state.rewardedReady) {
                                    TextButton(onClick = viewModel::claimTrialSimulated, modifier = Modifier.fillMaxWidth()) {
                                        Text("Simulate reward (demo builds only)")
                                    }
                                }
                            }
                        }
                    }
                }

                Text(
                    if (state.isMockBilling) "Demo subscriptions renew automatically on this device until you cancel them here."
                    else "Subscriptions renew automatically until cancelled. Manage or cancel anytime in Google Play ▸ Payments & subscriptions.",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.fillMaxWidth(),
                )
            }
        }
        ConfettiOverlay(if (state.celebrate > 0) state.celebrate else null)
    }

    if (confirmPlan) {
        val offer = state.offers.firstOrNull { it.plan == state.selected }
        AlertDialog(
            onDismissRequest = { confirmPlan = false },
            icon = { Icon(Icons.Filled.WorkspacePremium, null) },
            title = { Text(if (state.isMockBilling) "Confirm demo purchase" else "Confirm subscription") },
            text = {
                Text(
                    if (state.isMockBilling) "Activate the ${state.selected.title} plan (${offer?.price}) in demonstration mode? This is a simulation: no payment is made and nothing is charged."
                    else "You'll be taken to Google Play to subscribe to the ${state.selected.title} plan.",
                )
            },
            confirmButton = { TextButton(onClick = { confirmPlan = false; viewModel.purchase(activity) }) { Text("Confirm") } },
            dismissButton = { TextButton(onClick = { confirmPlan = false }) { Text("Cancel") } },
        )
    }
    state.message?.let { msg ->
        AlertDialog(
            onDismissRequest = viewModel::dismissMessage,
            text = { Text(msg) },
            confirmButton = { TextButton(onClick = viewModel::dismissMessage) { Text("OK") } },
        )
    }
}

@Composable
private fun PlanCard(offer: PlanOffer, selected: Boolean, onSelect: () -> Unit) {
    Surface(
        shape = RoundedCornerShape(20.dp),
        color = if (selected) MaterialTheme.colorScheme.primaryContainer else MaterialTheme.colorScheme.surface,
        border = BorderStroke(if (selected) 2.dp else 1.dp, if (selected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.outlineVariant),
        modifier = Modifier.fillMaxWidth().selectable(selected, role = Role.RadioButton, onClick = onSelect),
    ) {
        Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
            Box(
                Modifier.size(24.dp).clip(CircleShape)
                    .background(if (selected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.surfaceVariant),
                contentAlignment = Alignment.Center,
            ) { if (selected) Icon(Icons.Filled.Check, null, tint = Color.White, modifier = Modifier.size(16.dp)) }
            Spacer(Modifier.width(12.dp))
            Column(Modifier.weight(1f)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(offer.plan.title, style = MaterialTheme.typography.titleMedium)
                    offer.plan.badge?.let {
                        Spacer(Modifier.width(8.dp))
                        Surface(shape = CircleShape, color = BimoColors.Accent) {
                            Text(it, Modifier.padding(horizontal = 8.dp, vertical = 2.dp), style = MaterialTheme.typography.labelSmall, color = Color(0xFF1F2E00))
                        }
                    }
                }
                Text(offer.perWeek + if (offer.isDemoPrice) " (demo)" else "", style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
            Text(offer.price, style = MaterialTheme.typography.titleLarge)
        }
    }
}

@Composable
private fun ComparisonTable() {
    val rows = listOf(
        "Full Dart & Flutter curriculum" to (true to true),
        "Quizzes, XP, streaks & certificate" to (true to true),
        "Real-world projects" to (true to true),
        "Ad-free" to (false to true),
        "Premium themes & avatar frames" to (false to true),
        "All extra coding challenges" to (false to true),
        "Advanced learning insights" to (false to true),
    )
    Surface(shape = RoundedCornerShape(20.dp), color = MaterialTheme.colorScheme.surface, shadowElevation = 1.dp) {
        Column(Modifier.fillMaxWidth().padding(16.dp)) {
            Row {
                Text("Feature", style = MaterialTheme.typography.labelLarge, modifier = Modifier.weight(1f))
                Text("Free", style = MaterialTheme.typography.labelLarge, modifier = Modifier.width(56.dp), textAlign = TextAlign.Center)
                Text("Premium", style = MaterialTheme.typography.labelLarge, modifier = Modifier.width(70.dp), textAlign = TextAlign.Center)
            }
            rows.forEach { (label, avail) ->
                Row(Modifier.padding(vertical = 6.dp), verticalAlignment = Alignment.CenterVertically) {
                    Text(label, style = MaterialTheme.typography.bodyMedium, modifier = Modifier.weight(1f))
                    Box(Modifier.width(56.dp), contentAlignment = Alignment.Center) { Mark(avail.first) }
                    Box(Modifier.width(70.dp), contentAlignment = Alignment.Center) { Mark(avail.second) }
                }
            }
        }
    }
}

@Composable
private fun Mark(yes: Boolean) {
    AnimatedVisibility(true, enter = scaleIn() + fadeIn()) {
        Icon(
            if (yes) Icons.Filled.CheckCircle else Icons.Filled.Close,
            contentDescription = if (yes) "Included" else "Not included",
            tint = if (yes) BimoColors.Success else MaterialTheme.colorScheme.outline,
            modifier = Modifier.size(20.dp),
        )
    }
}
