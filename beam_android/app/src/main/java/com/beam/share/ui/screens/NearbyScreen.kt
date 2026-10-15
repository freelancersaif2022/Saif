@file:OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class)

package com.beam.share.ui.screens

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.spring
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.expandVertically
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Smartphone
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.beam.share.AppContainer
import com.beam.share.transfer.NearbyDevice
import com.beam.share.ui.components.BeamTopBar
import com.beam.share.ui.components.DeviceAvatar
import com.beam.share.ui.components.EmptyState
import com.beam.share.ui.components.LiveDot
import com.beam.share.ui.components.PrimaryButton
import com.beam.share.ui.components.RadarPulse
import com.beam.share.ui.components.RadioBanners
import com.beam.share.util.Format
import com.beam.share.util.Haptics
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.sin

@Composable
fun NearbyScreen(
    container: AppContainer,
    onBack: () -> Unit,
    onChooseFiles: () -> Unit,
    onSending: () -> Unit,
) {
    val context = LocalContext.current
    val engine = container.engine
    val selection by container.selection.items.collectAsStateWithLifecycle()
    val devices by engine.devices.collectAsStateWithLifecycle()
    val discovering by engine.discovering.collectAsStateWithLifecycle()
    val radioError by engine.radioError.collectAsStateWithLifecycle()
    val settings by container.settings.collectAsStateWithLifecycle()

    DisposableEffect(engine) {
        engine.setDiscoveryWanted(true)
        onDispose { engine.setDiscoveryWanted(false) }
    }

    fun sendTo(device: NearbyDevice) {
        if (selection.isEmpty()) return
        if (settings?.vibrate != false) Haptics.tick(context)
        engine.send(device, selection)
        onSending()
    }

    Column(Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background)) {
        BeamTopBar(
            title = "Send to",
            subtitle = if (selection.isEmpty()) "No files selected"
            else "${selection.size} ${if (selection.size == 1) "file" else "files"} · ${Format.bytes(selection.sumOf { it.size })}",
            onBack = onBack,
        )

        if (selection.isEmpty()) {
            Box(Modifier.weight(1f), contentAlignment = Alignment.Center) {
                EmptyState(
                    icon = Icons.Rounded.Smartphone,
                    title = "Pick something to send",
                    message = "Choose photos, videos, apps or files first.",
                    action = { PrimaryButton("Choose files", onClick = onChooseFiles) },
                )
            }
            return@Column
        }

        LazyColumn(
            modifier = Modifier.weight(1f),
            contentPadding = PaddingValues(start = 16.dp, end = 16.dp, bottom = 24.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            item {
                RadioBanners(radioError, Modifier.padding(bottom = 4.dp))
            }
            item {
                RadarWithDevices(
                    myName = settings?.deviceName.orEmpty(),
                    devices = devices,
                    onPick = ::sendTo,
                )
            }
            item {
                Row(
                    Modifier.fillMaxWidth().padding(horizontal = 6.dp, vertical = 6.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    if (discovering) LiveDot(MaterialTheme.colorScheme.primary)
                    Spacer(Modifier.width(10.dp))
                    Text(
                        when {
                            !discovering -> "Starting search…"
                            devices.isEmpty() -> "Looking for nearby phones…"
                            else -> "${devices.size} nearby · tap one to send"
                        },
                        style = MaterialTheme.typography.titleSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }
            items(devices, key = { it.endpointId }) { device ->
                DeviceRow(device, onSend = { sendTo(device) }, modifier = Modifier.animateItem())
            }
            item {
                AnimatedVisibility(
                    visible = devices.isEmpty(),
                    enter = fadeIn() + expandVertically(),
                    exit = fadeOut() + shrinkVertically(),
                ) {
                    Text(
                        "Not seeing a phone? Open Beam on it, tap Receive and keep it close by.",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.fillMaxWidth().padding(horizontal = 24.dp, vertical = 12.dp).navigationBarsPadding(),
                    )
                }
            }
        }
    }
}

@Composable
private fun RadarWithDevices(myName: String, devices: List<NearbyDevice>, onPick: (NearbyDevice) -> Unit) {
    BoxWithConstraints(
        Modifier.fillMaxWidth().height(320.dp),
        contentAlignment = Alignment.Center,
    ) {
        val side = minOf(maxWidth, 320.dp)
        RadarPulse(Modifier.size(side))
        // Me in the middle
        Box(
            Modifier.size(76.dp).clip(CircleShape).background(MaterialTheme.colorScheme.primary),
            contentAlignment = Alignment.Center,
        ) {
            Icon(Icons.Rounded.Smartphone, contentDescription = "This phone ($myName)", tint = MaterialTheme.colorScheme.onPrimary, modifier = Modifier.size(32.dp))
        }
        // Found phones around
        val radius = side / 2 * 0.72f
        devices.take(6).forEach { device ->
            key(device.endpointId) {
                val angle = Math.toRadians(((abs(device.endpointId.hashCode()) % 360)).toDouble())
                val appear = remember { Animatable(0f) }
                LaunchedEffect(Unit) { appear.animateTo(1f, spring(dampingRatio = Spring.DampingRatioMediumBouncy)) }
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier
                        .offset(x = radius * cos(angle).toFloat(), y = radius * sin(angle).toFloat())
                        .graphicsLayer {
                            scaleX = appear.value
                            scaleY = appear.value
                            alpha = appear.value.coerceIn(0f, 1f)
                        },
                ) {
                    Surface(onClick = { onPick(device) }, shape = CircleShape, color = MaterialTheme.colorScheme.background) {
                        DeviceAvatar(device.name, size = 56.dp, ring = MaterialTheme.colorScheme.background)
                    }
                    Text(
                        device.name,
                        style = MaterialTheme.typography.labelMedium,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.width(88.dp),
                        textAlign = TextAlign.Center,
                    )
                }
            }
        }
    }
}

@Composable
private fun DeviceRow(device: NearbyDevice, onSend: () -> Unit, modifier: Modifier = Modifier) {
    Surface(
        onClick = onSend,
        shape = RoundedCornerShape(20.dp),
        color = MaterialTheme.colorScheme.surfaceContainerLowest,
        border = androidx.compose.foundation.BorderStroke(1.dp, MaterialTheme.colorScheme.outlineVariant),
        modifier = modifier.fillMaxWidth(),
    ) {
        Row(Modifier.padding(14.dp), verticalAlignment = Alignment.CenterVertically) {
            DeviceAvatar(device.name, size = 46.dp)
            Spacer(Modifier.width(14.dp))
            Column(Modifier.weight(1f)) {
                Text(device.name, style = MaterialTheme.typography.titleMedium, maxLines = 1, overflow = TextOverflow.Ellipsis)
                Text("Nearby · ready to receive", style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
            Box(
                Modifier
                    .clip(RoundedCornerShape(50))
                    .background(MaterialTheme.colorScheme.primary)
                    .padding(horizontal = 18.dp, vertical = 10.dp),
            ) {
                Text("Send", style = MaterialTheme.typography.labelLarge, color = MaterialTheme.colorScheme.onPrimary)
            }
        }
    }
}
