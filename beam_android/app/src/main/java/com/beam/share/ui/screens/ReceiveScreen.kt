package com.beam.share.ui.screens

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
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.FolderOpen
import androidx.compose.material.icons.rounded.Lock
import androidx.compose.material.icons.rounded.Visibility
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.runtime.DisposableEffect
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.beam.share.AppContainer
import com.beam.share.ui.components.BeamCard
import com.beam.share.ui.components.BeamTopBar
import com.beam.share.ui.components.DeviceAvatar
import com.beam.share.ui.components.LiveDot
import com.beam.share.ui.components.PrimaryButton
import com.beam.share.ui.components.RadarPulse
import com.beam.share.ui.components.RadioBanners
import com.beam.share.util.Files
import kotlinx.coroutines.launch

@Composable
fun ReceiveScreen(container: AppContainer, onBack: () -> Unit) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val settings by container.settings.collectAsStateWithLifecycle()
    val advertising by container.engine.advertising.collectAsStateWithLifecycle()
    val radioError by container.engine.radioError.collectAsStateWithLifecycle()
    val visible = settings?.visible ?: true
    val name = settings?.deviceName.orEmpty()

    // Keep the screen awake while waiting for a sender.
    val view = LocalView.current
    DisposableEffect(view) {
        view.keepScreenOn = true
        onDispose { view.keepScreenOn = false }
    }

    Column(Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background)) {
        BeamTopBar(title = "Receive", onBack = onBack)
        Column(
            Modifier
                .weight(1f)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 20.dp)
                .navigationBarsPadding(),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            RadioBanners(radioError)
            Spacer(Modifier.height(8.dp))
            Box(Modifier.size(300.dp), contentAlignment = Alignment.Center) {
                RadarPulse(
                    Modifier.fillMaxSize(),
                    color = if (visible) MaterialTheme.colorScheme.secondary else MaterialTheme.colorScheme.outline,
                    active = visible && advertising,
                )
                DeviceAvatar(name, size = 96.dp, ring = MaterialTheme.colorScheme.background)
            }
            Spacer(Modifier.height(12.dp))
            if (visible) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    if (advertising) {
                        LiveDot(MaterialTheme.colorScheme.tertiary)
                        Spacer(Modifier.width(8.dp))
                    }
                    Text(
                        if (advertising) "Ready to receive" else "Getting ready…",
                        style = MaterialTheme.typography.headlineMedium,
                    )
                }
                Spacer(Modifier.height(6.dp))
                Text(
                    "Nearby phones see you as",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
                Text(name, style = MaterialTheme.typography.titleLarge, textAlign = TextAlign.Center)
            } else {
                Text("You're hidden", style = MaterialTheme.typography.headlineMedium)
                Spacer(Modifier.height(6.dp))
                Text(
                    "Nearby phones can't see you, so nobody can send you files.",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    textAlign = TextAlign.Center,
                )
                Spacer(Modifier.height(16.dp))
                PrimaryButton(
                    text = "Become visible",
                    icon = Icons.Rounded.Visibility,
                    onClick = { scope.launch { container.settingsRepository.setVisible(true) } },
                )
            }
            Spacer(Modifier.height(28.dp))
            BeamCard(Modifier.fillMaxWidth()) {
                Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(14.dp)) {
                    Tip(Icons.Rounded.Lock, "You'll be asked to accept before anything is saved. Check the 4-digit code matches on both phones.")
                    Tip(Icons.Rounded.FolderOpen, "Received files are saved in Download › Beam.")
                }
            }
            Spacer(Modifier.height(12.dp))
            androidx.compose.material3.TextButton(onClick = { Files.openDownloads(context) }) {
                Text("Open received files")
            }
            Spacer(Modifier.height(16.dp))
        }
    }
}

@Composable
private fun Tip(icon: ImageVector, text: String) {
    Row(verticalAlignment = Alignment.Top) {
        Icon(icon, null, tint = MaterialTheme.colorScheme.primary, modifier = Modifier.size(20.dp))
        Spacer(Modifier.width(12.dp))
        Text(text, style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
    }
}
