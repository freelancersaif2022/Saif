package com.bimo.learnflutter.ui.screens.settings

import android.Manifest
import android.app.TimePickerDialog
import android.content.Intent
import android.os.Build
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.PaddingValues
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
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.selection.toggleable
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.Animation
import androidx.compose.material.icons.filled.DarkMode
import androidx.compose.material.icons.filled.DeleteForever
import androidx.compose.material.icons.filled.Description
import androidx.compose.material.icons.filled.FileDownload
import androidx.compose.material.icons.filled.FormatSize
import androidx.compose.material.icons.filled.Gavel
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Language
import androidx.compose.material.icons.filled.LocalFireDepartment
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Palette
import androidx.compose.material.icons.filled.PrivacyTip
import androidx.compose.material.icons.filled.RestartAlt
import androidx.compose.material.icons.filled.Schedule
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material.icons.filled.TrackChanges
import androidx.compose.material.icons.automirrored.filled.VolumeUp
import androidx.compose.material.icons.filled.WorkspacePremium
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.SegmentedButton
import androidx.compose.material3.SegmentedButtonDefaults
import androidx.compose.material3.SingleChoiceSegmentedButtonRow
import androidx.compose.material3.Slider
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewModelScope
import com.bimo.learnflutter.BuildConfig
import com.bimo.learnflutter.ads.AdsManager
import com.bimo.learnflutter.data.prefs.AccentPalette
import com.bimo.learnflutter.data.prefs.AppSettings
import com.bimo.learnflutter.data.prefs.SettingsDataStore
import com.bimo.learnflutter.data.prefs.ThemeMode
import com.bimo.learnflutter.data.repository.DataManagementRepository
import com.bimo.learnflutter.data.repository.PremiumRepository
import com.bimo.learnflutter.notifications.NotificationHelper
import com.bimo.learnflutter.notifications.ReminderScheduler
import com.bimo.learnflutter.ui.components.findActivity
import com.bimo.learnflutter.ui.navigation.BimoNavigator
import com.bimo.learnflutter.ui.navigation.Routes
import com.bimo.learnflutter.ui.screens.practice.TopBar
import com.bimo.learnflutter.ui.theme.BimoColors
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

data class SettingsUiState(val settings: AppSettings? = null, val isPremium: Boolean = false)

@HiltViewModel
class SettingsViewModel @Inject constructor(
    private val store: SettingsDataStore,
    premium: PremiumRepository,
    private val scheduler: ReminderScheduler,
    private val data: DataManagementRepository,
    val ads: AdsManager,
) : ViewModel() {
    val state: StateFlow<SettingsUiState> = combine(store.settings, premium.isPremium) { s, p -> SettingsUiState(s, p) }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), SettingsUiState())

    fun setTheme(mode: ThemeMode) = viewModelScope.launch { store.setThemeMode(mode) }
    fun setPalette(p: AccentPalette) = viewModelScope.launch { store.setPalette(p) }
    fun setSound(v: Boolean) = viewModelScope.launch { store.setSoundEffects(v) }
    fun setReduceMotion(v: Boolean) = viewModelScope.launch { store.setReduceMotion(v) }
    fun setTextScale(v: Float) = viewModelScope.launch { store.setTextScale(v) }
    fun setLanguage(tag: String) = viewModelScope.launch { store.setLanguage(tag) }
    fun setStreakReminders(v: Boolean) = viewModelScope.launch { store.setStreakReminders(v) }
    fun setGoalNotifications(v: Boolean) = viewModelScope.launch { store.setGoalNotifications(v) }

    fun setReminders(enabled: Boolean) = viewModelScope.launch {
        store.setRemindersEnabled(enabled)
        val s = store.current()
        if (enabled) scheduler.schedule(s.reminderHour, s.reminderMinute) else scheduler.cancel()
    }

    fun setReminderTime(hour: Int, minute: Int) = viewModelScope.launch {
        store.setReminderTime(hour, minute)
        if (store.current().remindersEnabled) scheduler.schedule(hour, minute)
    }

    suspend fun exportIntent(): Intent = data.exportShareIntent()
    fun resetProgress(onDone: () -> Unit) = viewModelScope.launch { data.resetLearningProgress(); onDone() }
    fun resetAll(onDone: () -> Unit) = viewModelScope.launch {
        scheduler.cancel()
        data.resetAllData()
        onDone()
    }
}

@OptIn(ExperimentalLayoutApi::class, androidx.compose.material3.ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(navigator: BimoNavigator, viewModel: SettingsViewModel = hiltViewModel()) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    val s = state.settings ?: return
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    var confirmReset by remember { mutableStateOf(false) }
    var confirmResetAll by remember { mutableStateOf(false) }
    var message by remember { mutableStateOf<String?>(null) }
    var textScale by remember(s.textScale) { mutableFloatStateOf(s.textScale) }

    val notificationPermission = rememberLauncherForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
        if (granted) viewModel.setReminders(true)
        else message = "Notifications are blocked. You can allow them in system settings to receive reminders."
    }

    fun enableReminders(enable: Boolean) {
        if (enable && Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU && !NotificationHelper.canPost(context)) {
            notificationPermission.launch(Manifest.permission.POST_NOTIFICATIONS)
        } else {
            viewModel.setReminders(enable)
        }
    }

    Column(Modifier.fillMaxSize().statusBarsPadding()) {
        TopBar("Settings", navigator)
        LazyColumn(
            contentPadding = PaddingValues(start = 16.dp, end = 16.dp, bottom = 32.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
            modifier = Modifier.navigationBarsPadding(),
        ) {
            item { GroupTitle("Appearance") }
            item {
                SettingsCard {
                    RowHeader(Icons.Filled.DarkMode, "Theme")
                    Spacer(Modifier.height(8.dp))
                    SingleChoiceSegmentedButtonRow(Modifier.fillMaxWidth()) {
                        val options = listOf(ThemeMode.SYSTEM to "System", ThemeMode.LIGHT to "Light", ThemeMode.DARK to "Dark")
                        options.forEachIndexed { i, (mode, label) ->
                            SegmentedButton(
                                selected = s.themeMode == mode,
                                onClick = { viewModel.setTheme(mode) },
                                shape = SegmentedButtonDefaults.itemShape(i, options.size),
                            ) { Text(label) }
                        }
                    }
                    Spacer(Modifier.height(16.dp))
                    RowHeader(Icons.Filled.Palette, "Colour theme", if (state.isPremium) "Premium themes unlocked" else "Premium themes require Premium")
                    Spacer(Modifier.height(10.dp))
                    FlowRow(horizontalArrangement = Arrangement.spacedBy(12.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        AccentPalette.entries.forEach { p ->
                            val locked = p.premium && !state.isPremium
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Box(
                                    Modifier
                                        .size(44.dp)
                                        .clip(CircleShape)
                                        .background(paletteSwatch(p))
                                        .border(if (s.palette == p) 3.dp else 0.dp, MaterialTheme.colorScheme.onSurface, CircleShape)
                                        .clickable(role = Role.RadioButton) {
                                            if (locked) navigator.to(Routes.PREMIUM) else viewModel.setPalette(p)
                                        }
                                        .semantics { contentDescription = p.label + if (locked) ", premium" else "" },
                                    contentAlignment = Alignment.Center,
                                ) { if (locked) Icon(Icons.Filled.Lock, null, tint = Color.White, modifier = Modifier.size(16.dp)) }
                                Text(p.label, style = MaterialTheme.typography.labelSmall)
                            }
                        }
                    }
                    Spacer(Modifier.height(16.dp))
                    RowHeader(Icons.Filled.FormatSize, "Text size", "${(textScale * 100).toInt()}%")
                    Slider(
                        value = textScale,
                        onValueChange = { textScale = it },
                        onValueChangeFinished = { viewModel.setTextScale(textScale) },
                        valueRange = 0.85f..1.4f,
                        steps = 10,
                    )
                    Text("Preview: Flutter makes beautiful apps.", style = MaterialTheme.typography.bodyMedium)
                    Spacer(Modifier.height(8.dp))
                    ToggleRow(Icons.Filled.Animation, "Reduce animations", "Also follows the system “Remove animations” setting", s.reduceMotion, viewModel::setReduceMotion)
                }
            }

            item { GroupTitle("Learning & notifications") }
            item {
                SettingsCard {
                    ToggleRow(Icons.Filled.Notifications, "Daily learning reminder", "One gentle nudge if you haven't studied yet", s.remindersEnabled, ::enableReminders)
                    if (s.remindersEnabled) {
                        LinkRow(Icons.Filled.Schedule, "Reminder time", "%02d:%02d".format(s.reminderHour, s.reminderMinute)) {
                            TimePickerDialog(context, { _, h, m -> viewModel.setReminderTime(h, m) }, s.reminderHour, s.reminderMinute, true).show()
                        }
                        ToggleRow(Icons.Filled.LocalFireDepartment, "Streak reminders", "Warn me when my streak is at risk", s.streakReminders, viewModel::setStreakReminders)
                        ToggleRow(Icons.Filled.TrackChanges, "Daily goal notifications", "Remind me about my daily lesson goal", s.goalNotifications, viewModel::setGoalNotifications)
                    }
                    ToggleRow(Icons.AutoMirrored.Filled.VolumeUp, "Sound effects", "Short tones for quiz answers", s.soundEffects, viewModel::setSound)
                    LinkRow(Icons.Filled.Language, "Language", if (s.languageTag == "system") "System default (English)" else "English") {
                        viewModel.setLanguage(if (s.languageTag == "system") "en" else "system")
                    }
                }
            }

            item { GroupTitle("Premium") }
            item {
                SettingsCard {
                    LinkRow(Icons.Filled.WorkspacePremium, "Manage premium", if (state.isPremium) "Active" else "Free plan") { navigator.to(Routes.PREMIUM) }
                }
            }

            item { GroupTitle("Privacy & data") }
            item {
                SettingsCard {
                    LinkRow(Icons.Filled.FileDownload, "Export learning information", "Share your progress as a JSON file") {
                        scope.launch { context.startActivity(viewModel.exportIntent()) }
                    }
                    if (viewModel.ads.privacyOptionsRequired) {
                        LinkRow(Icons.Filled.Shield, "Ad privacy choices", "Review your consent for ads") {
                            context.findActivity()?.let { a -> viewModel.ads.showPrivacyOptions(a) { err -> err?.let { message = it } } }
                        }
                    }
                    LinkRow(Icons.Filled.PrivacyTip, "Privacy policy", null) { navigator.to(Routes.legal("privacy")) }
                    LinkRow(Icons.Filled.Gavel, "Terms and conditions", null) { navigator.to(Routes.legal("terms")) }
                    LinkRow(Icons.Filled.RestartAlt, "Reset learning progress", "Clears lessons, quizzes, XP and achievements", danger = true) { confirmReset = true }
                    LinkRow(Icons.Filled.DeleteForever, "Delete all app data", "Also removes your profile and settings", danger = true) { confirmResetAll = true }
                }
            }

            item { GroupTitle("About") }
            item {
                SettingsCard {
                    LinkRow(Icons.Filled.Info, "About Bimo", null) { navigator.to(Routes.legal("about")) }
                    LinkRow(Icons.Filled.Description, "App version", "${BuildConfig.VERSION_NAME} (${BuildConfig.VERSION_CODE})") {}
                }
            }
        }
    }

    message?.let {
        AlertDialog(
            onDismissRequest = { message = null },
            text = { Text(it) },
            confirmButton = { TextButton(onClick = { message = null }) { Text("OK") } },
        )
    }
    if (confirmReset) {
        AlertDialog(
            onDismissRequest = { confirmReset = false },
            icon = { Icon(Icons.Filled.RestartAlt, null) },
            title = { Text("Reset learning progress?") },
            text = { Text("All completed lessons, quiz history, XP, streaks, achievements and certificates will be permanently deleted. Your profile, settings and premium status stay. This cannot be undone.") },
            confirmButton = {
                TextButton(onClick = {
                    confirmReset = false
                    viewModel.resetProgress { message = "Your learning progress has been reset." }
                }) { Text("Reset", color = BimoColors.Error) }
            },
            dismissButton = { TextButton(onClick = { confirmReset = false }) { Text("Cancel") } },
        )
    }
    if (confirmResetAll) {
        AlertDialog(
            onDismissRequest = { confirmResetAll = false },
            icon = { Icon(Icons.Filled.DeleteForever, null) },
            title = { Text("Delete all app data?") },
            text = { Text("This removes your profile, progress, certificates, settings and local premium records, and returns Bimo to the first-launch onboarding. This cannot be undone.") },
            confirmButton = {
                TextButton(onClick = {
                    confirmResetAll = false
                    viewModel.resetAll { navigator.resetTo(Routes.ONBOARDING) }
                }) { Text("Delete everything", color = BimoColors.Error) }
            },
            dismissButton = { TextButton(onClick = { confirmResetAll = false }) { Text("Cancel") } },
        )
    }
}

private fun paletteSwatch(p: AccentPalette): androidx.compose.ui.graphics.Brush = androidx.compose.ui.graphics.Brush.linearGradient(
    when (p) {
        AccentPalette.VIOLET -> listOf(Color(0xFF6750F5), Color(0xFF03B6D4))
        AccentPalette.OCEAN -> listOf(Color(0xFF0B63BE), Color(0xFF00A6A6))
        AccentPalette.SUNSET -> listOf(Color(0xFFE2475B), Color(0xFFFFB347))
        AccentPalette.FOREST -> listOf(Color(0xFF2E7D4F), Color(0xFF9BD23C))
        AccentPalette.MIDNIGHT -> listOf(Color(0xFF2B2D6E), Color(0xFFC9A227))
    },
)

@Composable
private fun GroupTitle(text: String) {
    Text(text, style = MaterialTheme.typography.titleSmall, color = MaterialTheme.colorScheme.primary, modifier = Modifier.padding(start = 4.dp, top = 8.dp))
}

@Composable
private fun SettingsCard(content: @Composable () -> Unit) {
    Surface(shape = RoundedCornerShape(22.dp), color = MaterialTheme.colorScheme.surface, shadowElevation = 1.dp, modifier = Modifier.fillMaxWidth()) {
        Column(Modifier.padding(16.dp)) { content() }
    }
}

@Composable
private fun RowHeader(icon: ImageVector, title: String, subtitle: String? = null) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Icon(icon, null, tint = MaterialTheme.colorScheme.primary)
        Spacer(Modifier.width(12.dp))
        Column {
            Text(title, style = MaterialTheme.typography.titleSmall)
            subtitle?.let { Text(it, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant) }
        }
    }
}

@Composable
private fun ToggleRow(icon: ImageVector, title: String, subtitle: String, checked: Boolean, onChange: (Boolean) -> Unit) {
    Row(
        Modifier
            .fillMaxWidth()
            .toggleable(value = checked, role = Role.Switch, onValueChange = onChange)
            .padding(vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(icon, null, tint = MaterialTheme.colorScheme.primary)
        Spacer(Modifier.width(12.dp))
        Column(Modifier.weight(1f)) {
            Text(title, style = MaterialTheme.typography.titleSmall)
            Text(subtitle, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
        }
        Switch(checked = checked, onCheckedChange = null)
    }
}

@Composable
private fun LinkRow(icon: ImageVector, title: String, subtitle: String?, danger: Boolean = false, onClick: () -> Unit) {
    val color = if (danger) BimoColors.Error else MaterialTheme.colorScheme.primary
    Row(
        Modifier
            .fillMaxWidth()
            .clickable(role = Role.Button, onClick = onClick)
            .padding(vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(icon, null, tint = color)
        Spacer(Modifier.width(12.dp))
        Column(Modifier.weight(1f)) {
            Text(title, style = MaterialTheme.typography.titleSmall, color = if (danger) BimoColors.Error else MaterialTheme.colorScheme.onSurface)
            subtitle?.let { Text(it, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant) }
        }
        Icon(Icons.AutoMirrored.Filled.ArrowForward, null, tint = MaterialTheme.colorScheme.onSurfaceVariant, modifier = Modifier.size(18.dp))
    }
}

// ------------------------------------------------------------------ Legal / About

@HiltViewModel
class LegalViewModel @Inject constructor(savedStateHandle: SavedStateHandle) : ViewModel() {
    val doc: String = savedStateHandle.get<String>("doc") ?: "about"
}

@Composable
fun LegalScreen(navigator: BimoNavigator, viewModel: LegalViewModel = hiltViewModel()) {
    val (title, body) = when (viewModel.doc) {
        "privacy" -> "Privacy policy" to PRIVACY_POLICY
        "terms" -> "Terms and conditions" to TERMS
        else -> "About Bimo" to ABOUT
    }
    Column(Modifier.fillMaxSize().statusBarsPadding()) {
        TopBar(title, navigator)
        Column(
            Modifier
                .verticalScroll(rememberScrollState())
                .navigationBarsPadding()
                .padding(horizontal = 20.dp, vertical = 8.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            body.split("\n\n").forEach { para ->
                if (para.startsWith("# ")) Text(para.removePrefix("# "), style = MaterialTheme.typography.titleMedium)
                else Text(para, style = MaterialTheme.typography.bodyMedium)
            }
            Spacer(Modifier.height(24.dp))
        }
    }
}

private val PRIVACY_POLICY = """
# Summary

Bimo – Learn Flutter is designed to work offline. Your profile, learning progress, quiz history, achievements and certificates are stored only on your device. Bimo has no user accounts and does not upload your learning data to our servers.

# Data stored on your device

Your display name, optional avatar picture, learning goal, lesson progress, quiz attempts and answers, XP, streaks, achievements, certificates, premium status and app settings. Android's backup service may back up this data to your Google account if device backup is enabled.

# Advertising

The free version shows ads served by Google AdMob. Before any ad is requested, Bimo asks for your consent where required using Google's User Messaging Platform. AdMob may collect device identifiers and usage data to show and measure ads, as described in Google's privacy policy (policies.google.com/privacy). Premium users do not see ads.

# Purchases

In this build, subscriptions are simulated locally and no payment information is collected. When real Google Play Billing is enabled, payments are processed by Google Play; Bimo never sees your payment details.

# Notifications

Learning reminders are optional and only sent after you enable them and grant notification permission.

# Your choices

You can export your learning data (Settings ▸ Export learning information), reset your progress, or delete all app data at any time. Uninstalling the app removes all locally stored data.

# Children

Bimo is a general-audience educational app and is not directed at children under 13.

# Contact

Questions about privacy? Contact the Bimo team through the support e-mail listed on the store page.
""".trimIndent()

private val TERMS = """
# Educational use

Bimo provides educational content about Dart and Flutter. Code samples are provided for learning purposes, without warranty of any kind. Always review code before using it in production.

# Certificates

The Bimo certificate of completion is an educational course-completion certificate issued by the Bimo app. It is not an accredited professional licence and is not an official Google or Flutter certification. Flutter and Dart are trademarks of Google LLC; Bimo is not affiliated with or endorsed by Google.

# Premium

Premium features are optional. The core Dart and Flutter curriculum is available to every learner through normal progression. In this build, premium plans are demonstrations: prices are illustrative and no money is charged. Real subscriptions, if enabled, are governed by Google Play's terms and can be managed or cancelled in Google Play.

# Promotional trial

The seven-day promotional premium trial is a demonstration feature, can be claimed once per installation, and may be changed or withdrawn.

# Fair use

Do not attempt to manipulate XP, achievements or certificates. Certificates represent your own learning.

# Changes

These terms may be updated with new versions of the app.
""".trimIndent()

private val ABOUT = """
# Bimo – Learn Flutter

Bimo teaches Dart and Flutter from your very first variable to production-ready apps: two complete courses, fifteen real-world projects, hundreds of quizzes, coding challenges and a final assessment.

# How Bimo works

Lessons unlock one at a time. Read a lesson, pass its quiz with at least 70%, and the next lesson opens. Earn XP, keep your streak alive and collect achievements along the way.

# Built with

Bimo itself is a native Android app written in Kotlin with Jetpack Compose and Material 3. Everything works offline.

# Credits

Created by Saif A and the Bimo team. Flutter and the related logo are trademarks of Google LLC. Dart is a trademark of Google LLC.
""".trimIndent()
