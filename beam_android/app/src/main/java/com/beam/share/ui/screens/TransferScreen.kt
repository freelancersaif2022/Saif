@file:OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class)

package com.beam.share.ui.screens

import androidx.activity.compose.BackHandler
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
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
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.OpenInNew
import androidx.compose.material.icons.rounded.Block
import androidx.compose.material.icons.rounded.Check
import androidx.compose.material.icons.rounded.Close
import androidx.compose.material.icons.rounded.ErrorOutline
import androidx.compose.material.icons.rounded.FolderOpen
import androidx.compose.material.icons.rounded.Refresh
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.SideEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.runtime.DisposableEffect
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.beam.share.AppContainer
import com.beam.share.model.FileKind
import com.beam.share.transfer.Direction
import com.beam.share.transfer.FileProgress
import com.beam.share.transfer.FileState
import com.beam.share.transfer.Phase
import com.beam.share.transfer.TransferSession
import com.beam.share.ui.components.BeamCard
import com.beam.share.ui.components.DeviceAvatar
import com.beam.share.ui.components.FileThumb
import com.beam.share.ui.components.PrimaryButton
import com.beam.share.ui.components.ProgressRing
import com.beam.share.ui.components.RadarPulse
import com.beam.share.ui.components.SecondaryButton
import com.beam.share.ui.components.Spinner
import com.beam.share.ui.theme.BeamTheme
import com.beam.share.util.Files
import com.beam.share.util.Format

@Composable
fun TransferScreen(
    container: AppContainer,
    onClose: () -> Unit,
    onSendMore: () -> Unit,
    onRetry: () -> Unit,
) {
    val session by container.engine.session.collectAsStateWithLifecycle()
    val settings by container.settings.collectAsStateWithLifecycle()
    var confirmCancel by remember { mutableStateOf(false) }

    // Keep showing the last state while the screen animates away after Done / Send more.
    val lastSeen = remember { mutableStateOf<TransferSession?>(null) }
    val current = session
    SideEffect { if (current != null) lastSeen.value = current }
    LaunchedEffect(Unit) { if (container.engine.session.value == null) onClose() }
    val s = current ?: lastSeen.value
    if (s == null) {
        Box(Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background))
        return
    }

    // Keep screen on during an active transfer if the user wants that.
    val view = LocalView.current
    val keepOn = s.isActive && settings?.keepScreenOn != false
    DisposableEffect(keepOn) {
        view.keepScreenOn = keepOn
        onDispose { view.keepScreenOn = false }
    }

    BackHandler {
        if (s.isActive) confirmCancel = true else onClose()
    }

    Column(
        Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .statusBarsPadding()
            .navigationBarsPadding(),
    ) {
        // Header
        Row(
            Modifier.fillMaxWidth().padding(start = 8.dp, end = 20.dp, top = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            IconButton(onClick = { if (s.isActive) confirmCancel = true else onClose() }, modifier = Modifier.size(48.dp)) {
                Icon(Icons.Rounded.Close, contentDescription = "Close")
            }
            Spacer(Modifier.weight(1f))
            DeviceAvatar(s.deviceName, size = 36.dp)
            Spacer(Modifier.width(10.dp))
            Column(horizontalAlignment = Alignment.End) {
                Text(
                    if (s.direction == Direction.SEND) "Sending to" else "Receiving from",
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
                Text(s.deviceName, style = MaterialTheme.typography.titleSmall, maxLines = 1, overflow = TextOverflow.Ellipsis)
            }
        }

        AnimatedContent(
            targetState = s.phase.stage(),
            transitionSpec = { fadeIn(tween(260)) togetherWith fadeOut(tween(160)) },
            label = "stage",
            modifier = Modifier.weight(1f),
        ) { stage ->
            when (stage) {
                Stage.WAITING -> WaitingContent(s)
                Stage.PROGRESS -> ProgressContent(s)
                Stage.DONE -> DoneContent(s)
                Stage.PROBLEM -> ProblemContent(s)
            }
        }

        // Bottom actions
        Column(Modifier.padding(horizontal = 20.dp, vertical = 16.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
            val context = LocalContext.current
            when (s.phase.stage()) {
                Stage.WAITING, Stage.PROGRESS -> SecondaryButton(
                    text = "Cancel",
                    onClick = { confirmCancel = true },
                    modifier = Modifier.fillMaxWidth(),
                    contentColor = MaterialTheme.colorScheme.error,
                )
                Stage.DONE -> if (s.direction == Direction.SEND) {
                    PrimaryButton("Send more", onClick = onSendMore, modifier = Modifier.fillMaxWidth())
                    SecondaryButton("Done", onClick = onClose, modifier = Modifier.fillMaxWidth())
                } else {
                    PrimaryButton("Open Download folder", icon = Icons.Rounded.FolderOpen, onClick = { Files.openDownloads(context) }, modifier = Modifier.fillMaxWidth())
                    SecondaryButton("Done", onClick = onClose, modifier = Modifier.fillMaxWidth())
                }
                Stage.PROBLEM -> if (s.direction == Direction.SEND) {
                    PrimaryButton("Try again", icon = Icons.Rounded.Refresh, onClick = onRetry, modifier = Modifier.fillMaxWidth())
                    SecondaryButton("Done", onClick = onClose, modifier = Modifier.fillMaxWidth())
                } else {
                    PrimaryButton("Done", onClick = onClose, modifier = Modifier.fillMaxWidth())
                }
            }
        }
    }

    if (confirmCancel) {
        AlertDialog(
            onDismissRequest = { confirmCancel = false },
            title = { Text("Stop this transfer?") },
            text = {
                Text(
                    if (s.direction == Direction.SEND) "Files that haven't arrived yet won't be sent."
                    else "Files that haven't finished won't be saved."
                )
            },
            confirmButton = {
                TextButton(onClick = {
                    confirmCancel = false
                    container.engine.cancel()
                }) { Text("Stop", color = MaterialTheme.colorScheme.error) }
            },
            dismissButton = {
                TextButton(onClick = { confirmCancel = false }) { Text("Keep going") }
            },
            containerColor = MaterialTheme.colorScheme.surfaceContainerLowest,
        )
    }
}

private enum class Stage { WAITING, PROGRESS, DONE, PROBLEM }

private fun Phase.stage(): Stage = when (this) {
    Phase.CONNECTING, Phase.AWAITING_ACCEPT, Phase.INCOMING_REQUEST -> Stage.WAITING
    Phase.TRANSFERRING -> Stage.PROGRESS
    Phase.COMPLETED -> Stage.DONE
    Phase.FAILED, Phase.DECLINED, Phase.CANCELLED -> Stage.PROBLEM
}

@Composable
private fun WaitingContent(s: TransferSession) {
    Column(
        Modifier.fillMaxSize().padding(horizontal = 24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Box(Modifier.size(260.dp), contentAlignment = Alignment.Center) {
            RadarPulse(Modifier.fillMaxSize())
            DeviceAvatar(s.deviceName, size = 88.dp, ring = MaterialTheme.colorScheme.background)
        }
        Spacer(Modifier.height(20.dp))
        val waitingForAccept = s.phase == Phase.AWAITING_ACCEPT
        Text(
            if (waitingForAccept) "Waiting for ${s.deviceName}" else "Connecting…",
            style = MaterialTheme.typography.headlineMedium,
            textAlign = TextAlign.Center,
        )
        Spacer(Modifier.height(8.dp))
        Text(
            if (waitingForAccept) "Ask them to tap Accept on their phone."
            else "Setting up a secure connection with ${s.deviceName}.",
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center,
        )
        s.authCode?.let { code ->
            Spacer(Modifier.height(24.dp))
            Column(
                Modifier
                    .clip(RoundedCornerShape(20.dp))
                    .background(MaterialTheme.colorScheme.surfaceContainerLowest)
                    .padding(horizontal = 28.dp, vertical = 14.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Text("Code", style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                Text(
                    code,
                    style = MaterialTheme.typography.displaySmall.copy(letterSpacing = MaterialTheme.typography.displaySmall.fontSize * 0.2f),
                )
                Text("should match on both phones", style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
        }
        Spacer(Modifier.height(20.dp))
        Text(
            "${s.files.size} ${if (s.files.size == 1) "file" else "files"} · ${Format.bytes(s.totalBytes)}",
            style = MaterialTheme.typography.titleSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
    }
}

@Composable
private fun ProgressContent(s: TransferSession) {
    LazyColumn(
        Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        item {
            Box(Modifier.padding(top = 16.dp, bottom = 12.dp).size(232.dp), contentAlignment = Alignment.Center) {
                ProgressRing(
                    progress = s.progress,
                    modifier = Modifier.fillMaxSize(),
                    strokeWidth = 16.dp,
                    color = if (s.direction == Direction.SEND) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.secondary,
                )
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("${(s.progress * 100).toInt()}%", style = MaterialTheme.typography.displayMedium)
                    Text(
                        "${Format.bytes(s.transferredBytes)} of ${Format.bytes(s.totalBytes)}",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }
        }
        item {
            Row(
                Modifier.fillMaxWidth().padding(horizontal = 16.dp),
                horizontalArrangement = Arrangement.spacedBy(10.dp),
            ) {
                Stat("Speed", Format.speed(s.speedBytesPerSec), Modifier.weight(1f))
                Stat("Time left", s.etaSeconds?.let { Format.clock(it) } ?: "—", Modifier.weight(1f))
                Stat("Files", "${s.doneCount} of ${s.files.size}", Modifier.weight(1f))
            }
            Spacer(Modifier.height(16.dp))
        }
        item {
            BeamCard(Modifier.fillMaxWidth().padding(horizontal = 16.dp)) {
                s.files.forEach { f -> FileProgressRow(f, s.direction) }
            }
            Spacer(Modifier.height(12.dp))
            Text(
                "Keep both phones close until it finishes",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}

@Composable
private fun Stat(label: String, value: String, modifier: Modifier = Modifier) {
    BeamCard(modifier) {
        Column(Modifier.padding(horizontal = 12.dp, vertical = 12.dp)) {
            Text(label, style = MaterialTheme.typography.labelMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
            Spacer(Modifier.height(2.dp))
            Text(value, style = MaterialTheme.typography.titleMedium, maxLines = 1, overflow = TextOverflow.Ellipsis)
        }
    }
}

@Composable
private fun FileProgressRow(f: FileProgress, direction: Direction) {
    Row(
        Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        FileThumb(f.kind, if (direction == Direction.SEND) f.sourceUri else f.savedUri, size = 40.dp, packageName = f.packageName)
        Spacer(Modifier.width(12.dp))
        Column(Modifier.weight(1f)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(f.name, style = MaterialTheme.typography.titleSmall, maxLines = 1, overflow = TextOverflow.Ellipsis, modifier = Modifier.weight(1f))
                Spacer(Modifier.width(8.dp))
                val (label, color) = when (f.state) {
                    FileState.WAITING -> "Waiting" to MaterialTheme.colorScheme.onSurfaceVariant
                    FileState.IN_PROGRESS -> "${(f.fraction * 100).toInt()}%" to MaterialTheme.colorScheme.onSurface
                    FileState.SAVING -> "Saving" to MaterialTheme.colorScheme.onSurfaceVariant
                    FileState.DONE -> (if (direction == Direction.SEND) "Sent" else "Saved") to BeamTheme.extra.success
                    FileState.FAILED -> "Failed" to MaterialTheme.colorScheme.error
                }
                Text(label, style = MaterialTheme.typography.labelMedium, color = color)
            }
            Spacer(Modifier.height(6.dp))
            val barColor = when (f.state) {
                FileState.DONE -> BeamTheme.extra.success
                FileState.FAILED -> MaterialTheme.colorScheme.error
                else -> if (direction == Direction.SEND) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.secondary
            }
            val animated by animateFloatAsState(f.fraction, tween(300), label = "bar")
            LinearProgressIndicator(
                progress = { animated },
                modifier = Modifier.fillMaxWidth().height(6.dp).clip(RoundedCornerShape(3.dp)),
                color = barColor,
                trackColor = MaterialTheme.colorScheme.surfaceContainerHighest,
                strokeCap = StrokeCap.Round,
                gapSize = 0.dp,
                drawStopIndicator = {},
            )
        }
    }
}

@Composable
private fun DoneContent(s: TransferSession) {
    val context = LocalContext.current
    val pop = remember { androidx.compose.animation.core.Animatable(0.4f) }
    LaunchedEffect(Unit) { pop.animateTo(1f, spring(dampingRatio = Spring.DampingRatioMediumBouncy, stiffness = Spring.StiffnessLow)) }
    LazyColumn(
        Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        item {
            Spacer(Modifier.height(28.dp))
            Box(
                Modifier
                    .size(156.dp)
                    .graphicsLayer { scaleX = pop.value; scaleY = pop.value }
                    .clip(CircleShape)
                    .background(MaterialTheme.colorScheme.tertiaryContainer),
                contentAlignment = Alignment.Center,
            ) {
                Box(
                    Modifier.size(104.dp).clip(CircleShape).background(BeamTheme.extra.success),
                    contentAlignment = Alignment.Center,
                ) {
                    Icon(Icons.Rounded.Check, contentDescription = null, tint = BeamTheme.extra.onSuccess, modifier = Modifier.size(56.dp))
                }
            }
            Spacer(Modifier.height(24.dp))
            val n = s.doneCount
            val noun = if (n == 1) "file" else "files"
            Text(
                if (s.direction == Direction.SEND) "$n $noun sent" else "$n $noun received",
                style = MaterialTheme.typography.headlineLarge,
            )
            Spacer(Modifier.height(6.dp))
            val bytes = s.files.filter { it.state == FileState.DONE }.sumOf { it.size }
            Text(
                "${Format.bytes(bytes)} in ${Format.duration(s.elapsedMs)}",
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            if (s.failedCount > 0) {
                Spacer(Modifier.height(4.dp))
                Text(
                    "${s.failedCount} couldn't be transferred",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.error,
                )
            }
            if (s.direction == Direction.RECEIVE) {
                Spacer(Modifier.height(4.dp))
                Text("Saved in Download › Beam", style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
            Spacer(Modifier.height(24.dp))
        }
        item {
            BeamCard(Modifier.fillMaxWidth().padding(horizontal = 16.dp)) {
                s.files.forEach { f ->
                    val openUri = if (s.direction == Direction.RECEIVE) f.savedUri else null
                    Row(
                        Modifier.fillMaxWidth().padding(start = 16.dp, end = 4.dp, top = 8.dp, bottom = 8.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        FileThumb(f.kind, f.savedUri ?: f.sourceUri, size = 40.dp, packageName = f.packageName)
                        Spacer(Modifier.width(12.dp))
                        Column(Modifier.weight(1f)) {
                            Text(f.name, style = MaterialTheme.typography.titleSmall, maxLines = 1, overflow = TextOverflow.Ellipsis)
                            Text(
                                if (f.state == FileState.DONE) Format.bytes(f.size) else "Failed",
                                style = MaterialTheme.typography.bodySmall,
                                color = if (f.state == FileState.DONE) MaterialTheme.colorScheme.onSurfaceVariant else MaterialTheme.colorScheme.error,
                            )
                        }
                        if (openUri != null) {
                            IconButton(onClick = { Files.open(context, openUri, f.mime) }) {
                                Icon(
                                    Icons.AutoMirrored.Rounded.OpenInNew,
                                    contentDescription = if (f.kind == FileKind.APP) "Install ${f.name}" else "Open ${f.name}",
                                    tint = MaterialTheme.colorScheme.primary,
                                )
                            }
                        } else {
                            Spacer(Modifier.width(12.dp))
                        }
                    }
                }
            }
            Spacer(Modifier.height(8.dp))
        }
    }
}

@Composable
private fun ProblemContent(s: TransferSession) {
    Column(
        Modifier.fillMaxSize().padding(horizontal = 28.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        val declined = s.phase == Phase.DECLINED
        val cancelled = s.phase == Phase.CANCELLED
        Box(
            Modifier
                .size(132.dp)
                .clip(CircleShape)
                .background(if (declined || cancelled) MaterialTheme.colorScheme.surfaceContainerHighest else MaterialTheme.colorScheme.errorContainer),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                if (declined || cancelled) Icons.Rounded.Block else Icons.Rounded.ErrorOutline,
                contentDescription = null,
                tint = if (declined || cancelled) MaterialTheme.colorScheme.onSurfaceVariant else MaterialTheme.colorScheme.error,
                modifier = Modifier.size(56.dp),
            )
        }
        Spacer(Modifier.height(24.dp))
        Text(
            when {
                declined -> "Not accepted"
                cancelled -> "Transfer stopped"
                else -> "Transfer failed"
            },
            style = MaterialTheme.typography.headlineLarge,
            textAlign = TextAlign.Center,
        )
        Spacer(Modifier.height(8.dp))
        Text(
            s.error ?: when {
                declined -> "${s.deviceName} declined the files."
                cancelled -> "The transfer was cancelled."
                else -> "Something went wrong. Try again with the phones closer together."
            },
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center,
        )
        if (s.doneCount > 0) {
            Spacer(Modifier.height(12.dp))
            Text(
                "${s.doneCount} of ${s.files.size} files ${if (s.direction == Direction.SEND) "were sent" else "were saved"} before it stopped.",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                textAlign = TextAlign.Center,
            )
        }
    }
}
