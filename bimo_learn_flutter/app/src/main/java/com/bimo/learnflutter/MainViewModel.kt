package com.bimo.learnflutter

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.bimo.learnflutter.core.domain.StartDestination
import com.bimo.learnflutter.core.domain.StartDestinationResolver
import com.bimo.learnflutter.data.prefs.AppSettings
import com.bimo.learnflutter.data.prefs.SettingsDataStore
import com.bimo.learnflutter.data.repository.PremiumRepository
import com.bimo.learnflutter.data.repository.ProfileRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class MainViewModel @Inject constructor(
    settingsStore: SettingsDataStore,
    profileRepository: ProfileRepository,
    premiumRepository: PremiumRepository,
) : ViewModel() {

    /** Resolved once at launch; the splash screen stays visible until it is known. */
    private val _startDestination = MutableStateFlow<StartDestination?>(null)
    val startDestination: StateFlow<StartDestination?> = _startDestination.asStateFlow()

    val settings: StateFlow<AppSettings?> =
        settingsStore.settings.stateIn(viewModelScope, SharingStarted.Eagerly, null)

    val isPremium: StateFlow<Boolean> =
        premiumRepository.isPremium.stateIn(viewModelScope, SharingStarted.Eagerly, false)

    init {
        viewModelScope.launch {
            val prefs = settingsStore.settings.first()
            val profile = profileRepository.get()
            _startDestination.value = StartDestinationResolver.resolve(prefs.onboardingCompleted, profile != null)
        }
    }
}
