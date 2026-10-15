package com.beam.share

import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.core.content.IntentCompat
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.lifecycleScope
import com.beam.share.data.ThemeMode
import com.beam.share.ui.BeamRoot
import com.beam.share.ui.theme.BeamTheme
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {

    private val container by lazy { (application as BeamApp).container }

    override fun onCreate(savedInstanceState: Bundle?) {
        val splash = installSplashScreen()
        super.onCreate(savedInstanceState)
        splash.setKeepOnScreenCondition { container.settings.value == null }

        if (savedInstanceState == null) handleShareIntent(intent)

        lifecycle.addObserver(LifecycleEventObserver { _, event ->
            when (event) {
                Lifecycle.Event.ON_START -> container.engine.onAppForeground(true)
                Lifecycle.Event.ON_STOP -> container.engine.onAppForeground(false)
                else -> Unit
            }
        })

        setContent {
            val settings by container.settings.collectAsStateWithLifecycle()
            val systemDark = isSystemInDarkTheme()
            val dark = when (settings?.themeMode) {
                ThemeMode.LIGHT -> false
                ThemeMode.DARK -> true
                else -> systemDark
            }
            DisposableEffect(dark) {
                enableEdgeToEdge(
                    statusBarStyle = SystemBarStyle.auto(Color.TRANSPARENT, Color.TRANSPARENT) { dark },
                    navigationBarStyle = SystemBarStyle.auto(Color.TRANSPARENT, Color.TRANSPARENT) { dark },
                )
                onDispose { }
            }
            BeamTheme(darkTheme = dark) {
                val s = settings
                if (s != null) {
                    BeamRoot(container = container, settings = s)
                } else {
                    Box(Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background))
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleShareIntent(intent)
    }

    private fun handleShareIntent(intent: Intent?) {
        intent ?: return
        val uris: List<Uri> = when (intent.action) {
            Intent.ACTION_SEND -> listOfNotNull(IntentCompat.getParcelableExtra(intent, Intent.EXTRA_STREAM, Uri::class.java))
            Intent.ACTION_SEND_MULTIPLE ->
                IntentCompat.getParcelableArrayListExtra(intent, Intent.EXTRA_STREAM, Uri::class.java).orEmpty()
            else -> return
        }.ifEmpty {
            // Some apps only put the files in ClipData.
            val clip = intent.clipData
            if (clip == null) emptyList() else (0 until clip.itemCount).mapNotNull { clip.getItemAt(it).uri }
        }
        if (uris.isEmpty()) {
            Toast.makeText(this, "Beam can only send files", Toast.LENGTH_SHORT).show()
            return
        }
        lifecycleScope.launch {
            val items = uris.mapNotNull { container.media.resolve(it) }
            if (items.isEmpty()) {
                Toast.makeText(this@MainActivity, "Couldn't open the shared files", Toast.LENGTH_SHORT).show()
                return@launch
            }
            container.selection.add(items)
            container.pendingShare.value = true
        }
    }
}
