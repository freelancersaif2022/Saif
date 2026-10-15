package com.beam.share.ui.screens

import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Bolt
import androidx.compose.material.icons.rounded.Lock
import androidx.compose.material.icons.rounded.NearMe
import androidx.compose.material.icons.rounded.WifiOff
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.beam.share.AppContainer
import com.beam.share.R
import com.beam.share.ui.components.IconBadge
import com.beam.share.ui.components.InfoBanner
import com.beam.share.ui.components.PrimaryButton
import com.beam.share.ui.components.RadarPulse
import com.beam.share.ui.components.SecondaryButton
import com.beam.share.util.Permissions
import kotlinx.coroutines.launch

@Composable
fun OnboardingScreen(container: AppContainer, onDone: () -> Unit) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    var denied by remember { mutableStateOf(false) }

    val launcher = rememberLauncherForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) {
        if (Permissions.hasNearby(context)) {
            denied = false
            container.engine.refresh()
            scope.launch {
                container.settingsRepository.setOnboarded()
                onDone()
            }
        } else {
            denied = true
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .statusBarsPadding()
            .navigationBarsPadding()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Spacer(Modifier.height(24.dp))
        Box(Modifier.size(260.dp), contentAlignment = Alignment.Center) {
            RadarPulse(Modifier.fillMaxSize())
            Box(
                Modifier
                    .size(96.dp)
                    .clip(CircleShape)
                    .background(MaterialTheme.colorScheme.primary),
                contentAlignment = Alignment.Center,
            ) {
                Icon(
                    painterResource(R.drawable.ic_launcher_foreground),
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onPrimary,
                    modifier = Modifier.size(96.dp),
                )
            }
        }
        Spacer(Modifier.height(12.dp))
        Text("Beam", style = MaterialTheme.typography.displayMedium)
        Spacer(Modifier.height(8.dp))
        Text(
            "Send photos, videos, apps and files to phones next to you. No internet, no cables.",
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center,
        )
        Spacer(Modifier.height(28.dp))

        Column(verticalArrangement = Arrangement.spacedBy(16.dp), modifier = Modifier.fillMaxWidth()) {
            Feature(Icons.Rounded.Bolt, "Very fast", "Uses Wi-Fi Direct, up to 10× faster than Bluetooth.")
            Feature(Icons.Rounded.WifiOff, "Works offline", "No mobile data or Wi-Fi network needed.")
            Feature(Icons.Rounded.Lock, "You stay in control", "Nothing is saved until you tap Accept.")
        }

        Spacer(Modifier.height(28.dp))

        if (denied) {
            InfoBanner(
                icon = Icons.Rounded.NearMe,
                text = "Beam can't find nearby phones without the Nearby devices and Location permissions.",
                actionLabel = "Settings",
                onAction = { context.startActivity(Permissions.appSettingsIntent(context)) },
            )
            Spacer(Modifier.height(12.dp))
        }

        PrimaryButton(
            text = if (denied) "Try again" else "Get started",
            onClick = { launcher.launch(Permissions.nearby + Permissions.extras) },
            modifier = Modifier.fillMaxWidth(),
        )
        if (denied) {
            Spacer(Modifier.height(10.dp))
            SecondaryButton(
                text = "Open app settings",
                onClick = { context.startActivity(Permissions.appSettingsIntent(context)) },
                modifier = Modifier.fillMaxWidth(),
            )
        }
        Spacer(Modifier.height(12.dp))
        Text(
            "Android asks for Location because nearby phones are found with Bluetooth. Beam never tracks where you are.",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center,
        )
        Spacer(Modifier.height(16.dp))
    }
}

@Composable
private fun Feature(icon: ImageVector, title: String, text: String) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        IconBadge(
            icon = icon,
            container = MaterialTheme.colorScheme.primaryContainer,
            content = MaterialTheme.colorScheme.primary,
        )
        Spacer(Modifier.width(14.dp))
        Column(Modifier.weight(1f)) {
            Text(title, style = MaterialTheme.typography.titleMedium)
            Text(text, style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
        }
    }
}
