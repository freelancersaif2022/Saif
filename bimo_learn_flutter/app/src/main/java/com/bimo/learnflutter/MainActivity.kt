package com.bimo.learnflutter

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.runtime.getValue
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.lifecycleScope
import com.bimo.learnflutter.ads.AdsManager
import com.bimo.learnflutter.data.prefs.AppSettings
import com.bimo.learnflutter.data.repository.PremiumRepository
import com.bimo.learnflutter.ui.navigation.BimoNavHost
import com.bimo.learnflutter.ui.theme.BimoTheme
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.launch
import javax.inject.Inject

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    private val viewModel: MainViewModel by viewModels()

    @Inject lateinit var adsManager: AdsManager
    @Inject lateinit var premiumRepository: PremiumRepository

    override fun onCreate(savedInstanceState: Bundle?) {
        val splash = installSplashScreen()
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        splash.setKeepOnScreenCondition {
            viewModel.startDestination.value == null || viewModel.settings.value == null
        }

        setContent {
            val start by viewModel.startDestination.collectAsStateWithLifecycle()
            val settings by viewModel.settings.collectAsStateWithLifecycle()
            val prefs = settings ?: AppSettings()
            BimoTheme(
                themeMode = prefs.themeMode,
                palette = prefs.palette,
                textScale = prefs.textScale,
                reduceMotion = prefs.reduceMotion,
                soundEnabled = prefs.soundEffects,
            ) {
                start?.let { BimoNavHost(startDestination = it) }
            }
        }

        // Ads: gather consent, initialise the SDK and preload. Premium users never get interstitials.
        lifecycleScope.launch {
            premiumRepository.isPremium.distinctUntilChanged().collect { premium ->
                if (premium) adsManager.releaseInterstitial()
                adsManager.gatherConsentAndInitialize(this@MainActivity, preloadInterstitial = !premium)
            }
        }
    }
}
