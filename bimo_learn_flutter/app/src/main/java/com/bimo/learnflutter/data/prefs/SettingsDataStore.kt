package com.bimo.learnflutter.data.prefs

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.floatPreferencesKey
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.longPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.core.stringSetPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

val Context.bimoDataStore: DataStore<Preferences> by preferencesDataStore(name = "bimo_settings")

enum class ThemeMode { SYSTEM, LIGHT, DARK }

/** Colour palettes. Everything except [VIOLET] is a premium benefit. */
enum class AccentPalette(val label: String, val premium: Boolean) {
    VIOLET("Bimo Violet", false),
    OCEAN("Ocean", true),
    SUNSET("Sunset", true),
    FOREST("Forest", true),
    MIDNIGHT("Midnight Gold", true),
}

data class AppSettings(
    val onboardingCompleted: Boolean = false,
    val themeMode: ThemeMode = ThemeMode.SYSTEM,
    val palette: AccentPalette = AccentPalette.VIOLET,
    val remindersEnabled: Boolean = false,
    val reminderHour: Int = 19,
    val reminderMinute: Int = 0,
    val streakReminders: Boolean = true,
    val goalNotifications: Boolean = true,
    val soundEffects: Boolean = true,
    val reduceMotion: Boolean = false,
    val textScale: Float = 1f,
    /** BCP-47 tag or "system". Only English ships today; the architecture is ready for more. */
    val languageTag: String = "system",
    val lastOpenedLessonId: String? = null,
    val lastInterstitialMillis: Long = 0L,
    val promoTrialClaimed: Boolean = false,
    val avatarFrame: String = "none",
    /** Premium challenges a free learner unlocked by watching a rewarded ad. */
    val rewardUnlockedChallenges: Set<String> = emptySet(),
)

@Singleton
class SettingsDataStore @Inject constructor(
    private val dataStore: DataStore<Preferences>,
) {
    private object Keys {
        val ONBOARDING = booleanPreferencesKey("onboarding_completed")
        val THEME = stringPreferencesKey("theme_mode")
        val PALETTE = stringPreferencesKey("palette")
        val REMINDERS = booleanPreferencesKey("reminders_enabled")
        val REMINDER_HOUR = intPreferencesKey("reminder_hour")
        val REMINDER_MINUTE = intPreferencesKey("reminder_minute")
        val STREAK_REMINDERS = booleanPreferencesKey("streak_reminders")
        val GOAL_NOTIFICATIONS = booleanPreferencesKey("goal_notifications")
        val SOUND = booleanPreferencesKey("sound_effects")
        val REDUCE_MOTION = booleanPreferencesKey("reduce_motion")
        val TEXT_SCALE = floatPreferencesKey("text_scale")
        val LANGUAGE = stringPreferencesKey("language")
        val LAST_LESSON = stringPreferencesKey("last_opened_lesson")
        val LAST_INTERSTITIAL = longPreferencesKey("last_interstitial_millis")
        val PROMO_CLAIMED = booleanPreferencesKey("promo_trial_claimed")
        val AVATAR_FRAME = stringPreferencesKey("avatar_frame")
        val UNLOCKED_CHALLENGES = stringSetPreferencesKey("reward_unlocked_challenges")
    }

    val settings: Flow<AppSettings> = dataStore.data.map { p ->
        AppSettings(
            onboardingCompleted = p[Keys.ONBOARDING] ?: false,
            themeMode = p[Keys.THEME]?.let { runCatching { ThemeMode.valueOf(it) }.getOrNull() } ?: ThemeMode.SYSTEM,
            palette = p[Keys.PALETTE]?.let { runCatching { AccentPalette.valueOf(it) }.getOrNull() } ?: AccentPalette.VIOLET,
            remindersEnabled = p[Keys.REMINDERS] ?: false,
            reminderHour = p[Keys.REMINDER_HOUR] ?: 19,
            reminderMinute = p[Keys.REMINDER_MINUTE] ?: 0,
            streakReminders = p[Keys.STREAK_REMINDERS] ?: true,
            goalNotifications = p[Keys.GOAL_NOTIFICATIONS] ?: true,
            soundEffects = p[Keys.SOUND] ?: true,
            reduceMotion = p[Keys.REDUCE_MOTION] ?: false,
            textScale = p[Keys.TEXT_SCALE] ?: 1f,
            languageTag = p[Keys.LANGUAGE] ?: "system",
            lastOpenedLessonId = p[Keys.LAST_LESSON],
            lastInterstitialMillis = p[Keys.LAST_INTERSTITIAL] ?: 0L,
            promoTrialClaimed = p[Keys.PROMO_CLAIMED] ?: false,
            avatarFrame = p[Keys.AVATAR_FRAME] ?: "none",
            rewardUnlockedChallenges = p[Keys.UNLOCKED_CHALLENGES] ?: emptySet(),
        )
    }

    suspend fun current(): AppSettings = settings.first()

    suspend fun setOnboardingCompleted(value: Boolean) = dataStore.edit { it[Keys.ONBOARDING] = value }
    suspend fun setThemeMode(mode: ThemeMode) = dataStore.edit { it[Keys.THEME] = mode.name }
    suspend fun setPalette(palette: AccentPalette) = dataStore.edit { it[Keys.PALETTE] = palette.name }
    suspend fun setRemindersEnabled(value: Boolean) = dataStore.edit { it[Keys.REMINDERS] = value }
    suspend fun setReminderTime(hour: Int, minute: Int) = dataStore.edit {
        it[Keys.REMINDER_HOUR] = hour.coerceIn(0, 23)
        it[Keys.REMINDER_MINUTE] = minute.coerceIn(0, 59)
    }
    suspend fun setStreakReminders(value: Boolean) = dataStore.edit { it[Keys.STREAK_REMINDERS] = value }
    suspend fun setGoalNotifications(value: Boolean) = dataStore.edit { it[Keys.GOAL_NOTIFICATIONS] = value }
    suspend fun setSoundEffects(value: Boolean) = dataStore.edit { it[Keys.SOUND] = value }
    suspend fun setReduceMotion(value: Boolean) = dataStore.edit { it[Keys.REDUCE_MOTION] = value }
    suspend fun setTextScale(value: Float) = dataStore.edit { it[Keys.TEXT_SCALE] = value.coerceIn(0.85f, 1.4f) }
    suspend fun setLanguage(tag: String) = dataStore.edit { it[Keys.LANGUAGE] = tag }
    suspend fun setLastOpenedLesson(id: String) = dataStore.edit { it[Keys.LAST_LESSON] = id }
    suspend fun setLastInterstitial(millis: Long) = dataStore.edit { it[Keys.LAST_INTERSTITIAL] = millis }
    suspend fun setPromoTrialClaimed(value: Boolean) = dataStore.edit { it[Keys.PROMO_CLAIMED] = value }
    suspend fun setAvatarFrame(frame: String) = dataStore.edit { it[Keys.AVATAR_FRAME] = frame }
    suspend fun unlockChallenge(id: String) = dataStore.edit {
        it[Keys.UNLOCKED_CHALLENGES] = (it[Keys.UNLOCKED_CHALLENGES] ?: emptySet()) + id
    }

    /** Clears progress-related preferences but keeps onboarding, theme and other preferences. */
    suspend fun resetLearningState() = dataStore.edit {
        it.remove(Keys.LAST_LESSON)
        it.remove(Keys.LAST_INTERSTITIAL)
        it.remove(Keys.UNLOCKED_CHALLENGES)
    }

    /** Full reset: the app behaves like a fresh install (onboarding shows again). */
    suspend fun clearAll() = dataStore.edit { it.clear() }
}
