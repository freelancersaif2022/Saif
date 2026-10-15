package com.beam.share.data

import android.content.Context
import android.os.Build
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.emptyPreferences
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.map
import java.io.IOException

enum class ThemeMode { SYSTEM, LIGHT, DARK }

data class Settings(
    val deviceName: String,
    val visible: Boolean,
    val themeMode: ThemeMode,
    val keepScreenOn: Boolean,
    val vibrate: Boolean,
    val onboarded: Boolean,
)

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "beam_settings")

class SettingsRepository(private val context: Context) {

    private object Keys {
        val NAME = stringPreferencesKey("device_name")
        val VISIBLE = booleanPreferencesKey("visible")
        val THEME = stringPreferencesKey("theme")
        val KEEP_SCREEN_ON = booleanPreferencesKey("keep_screen_on")
        val VIBRATE = booleanPreferencesKey("vibrate")
        val ONBOARDED = booleanPreferencesKey("onboarded")
    }

    val settings: Flow<Settings> = context.dataStore.data
        .catch { e -> if (e is IOException) emit(emptyPreferences()) else throw e }
        .map { p ->
            Settings(
                deviceName = p[Keys.NAME]?.takeIf { it.isNotBlank() } ?: defaultDeviceName(),
                visible = p[Keys.VISIBLE] ?: true,
                themeMode = p[Keys.THEME]?.let { runCatching { ThemeMode.valueOf(it) }.getOrNull() } ?: ThemeMode.SYSTEM,
                keepScreenOn = p[Keys.KEEP_SCREEN_ON] ?: true,
                vibrate = p[Keys.VIBRATE] ?: true,
                onboarded = p[Keys.ONBOARDED] ?: false,
            )
        }

    suspend fun setDeviceName(name: String) {
        context.dataStore.edit { it[Keys.NAME] = name.trim().take(MAX_NAME) }
    }

    suspend fun setVisible(visible: Boolean) {
        context.dataStore.edit { it[Keys.VISIBLE] = visible }
    }

    suspend fun setTheme(mode: ThemeMode) {
        context.dataStore.edit { it[Keys.THEME] = mode.name }
    }

    suspend fun setKeepScreenOn(value: Boolean) {
        context.dataStore.edit { it[Keys.KEEP_SCREEN_ON] = value }
    }

    suspend fun setVibrate(value: Boolean) {
        context.dataStore.edit { it[Keys.VIBRATE] = value }
    }

    suspend fun setOnboarded() {
        context.dataStore.edit { it[Keys.ONBOARDED] = true }
    }

    fun defaultDeviceName(): String {
        val system = runCatching {
            android.provider.Settings.Global.getString(context.contentResolver, android.provider.Settings.Global.DEVICE_NAME)
        }.getOrNull()
        if (!system.isNullOrBlank()) return system.take(MAX_NAME)
        val model = Build.MODEL.orEmpty()
        val maker = Build.MANUFACTURER.orEmpty().replaceFirstChar { it.uppercase() }
        val name = if (model.startsWith(maker, ignoreCase = true)) model else "$maker $model"
        return name.trim().ifBlank { "Android phone" }.take(MAX_NAME)
    }

    companion object {
        const val MAX_NAME = 40
    }
}
