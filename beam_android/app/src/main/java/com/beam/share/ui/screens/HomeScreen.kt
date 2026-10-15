@file:OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class)

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
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.ArrowDownward
import androidx.compose.material.icons.rounded.ArrowUpward
import androidx.compose.material.icons.rounded.Inbox
import androidx.compose.material.icons.rounded.Smartphone
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.beam.share.AppContainer
import com.beam.share.data.HistoryEntry
import com.beam.share.transfer.Direction
import com.beam.share.ui.Routes
import com.beam.share.ui.components.BeamBottomBar
import com.beam.share.ui.components.BeamCard
import com.beam.share.ui.components.EmptyState
import com.beam.share.ui.components.IconBadge
import com.beam.share.ui.components.LiveDot
import com.beam.share.ui.components.PageTitle
import com.beam.share.util.Format
import kotlinx.coroutines.launch

@Composable
fun HomeScreen(
    container: AppContainer,
    onSend: () -> Unit,
    onReceive: () -> Unit,
    onOpenTab: (String) -> Unit,
) {
    val scope = rememberCoroutineScope()
    val settings by container.settings.collectAsStateWithLifecycle()
    val advertising by container.engine.advertising.collectAsStateWithLifecycle()
    val history by container.history.entries.collectAsStateWithLifecycle(initialValue = emptyList())
    val visible = settings?.visible ?: true

    Scaffold(
        containerColor = MaterialTheme.colorScheme.background,
        bottomBar = { BeamBottomBar(Routes.HOME, onOpenTab) },
    ) { padding ->
        Column(
            Modifier
                .fillMaxSize()
                .padding(bottom = padding.calculateBottomPadding())
                .verticalScroll(rememberScrollState()),
        ) {
            PageTitle("Beam")
            Column(Modifier.padding(horizontal = 20.dp), verticalArrangement = Arrangement.spacedBy(16.dp)) {
                // Visibility card
                BeamCard(Modifier.fillMaxWidth()) {
                    Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                        IconBadge(
                            icon = Icons.Rounded.Smartphone,
                            container = MaterialTheme.colorScheme.primaryContainer,
                            content = MaterialTheme.colorScheme.primary,
                        )
                        Spacer(Modifier.width(14.dp))
                        Column(Modifier.weight(1f)) {
                            Text(
                                if (visible) "Visible to nearby as" else "Hidden from nearby phones",
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                            )
                            Text(
                                settings?.deviceName.orEmpty(),
                                style = MaterialTheme.typography.titleMedium,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis,
                            )
                        }
                        Switch(
                            checked = visible,
                            onCheckedChange = { v -> scope.launch { container.settingsRepository.setVisible(v) } },
                            colors = SwitchDefaults.colors(checkedTrackColor = MaterialTheme.colorScheme.primary),
                        )
                    }
                    HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant)
                    Row(
                        Modifier.padding(horizontal = 16.dp, vertical = 12.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        if (visible && advertising) {
                            LiveDot(MaterialTheme.colorScheme.tertiary)
                            Spacer(Modifier.width(8.dp))
                            Text(
                                "Ready to receive while Beam is open",
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                            )
                        } else {
                            Box(Modifier.size(8.dp).clip(RoundedCornerShape(4.dp)).background(MaterialTheme.colorScheme.outline))
                            Spacer(Modifier.width(8.dp))
                            Text(
                                if (visible) "Starting…" else "Turn on to receive files",
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                            )
                        }
                    }
                }

                // Send / Receive tiles
                Row(horizontalArrangement = Arrangement.spacedBy(14.dp)) {
                    ActionTile(
                        title = "Send",
                        subtitle = "Photos, videos, apps, files",
                        icon = Icons.Rounded.ArrowUpward,
                        container = MaterialTheme.colorScheme.primary,
                        content = MaterialTheme.colorScheme.onPrimary,
                        badge = Color.White.copy(alpha = 0.16f),
                        badgeContent = MaterialTheme.colorScheme.onPrimary,
                        subtitleColor = MaterialTheme.colorScheme.onPrimary.copy(alpha = 0.82f),
                        onClick = onSend,
                        modifier = Modifier.weight(1f),
                    )
                    ActionTile(
                        title = "Receive",
                        subtitle = "Get files from a nearby phone",
                        icon = Icons.Rounded.ArrowDownward,
                        container = MaterialTheme.colorScheme.surfaceContainerLowest,
                        content = MaterialTheme.colorScheme.onSurface,
                        badge = MaterialTheme.colorScheme.secondaryContainer,
                        badgeContent = MaterialTheme.colorScheme.secondary,
                        subtitleColor = MaterialTheme.colorScheme.onSurfaceVariant,
                        onClick = onReceive,
                        bordered = true,
                        modifier = Modifier.weight(1f),
                    )
                }

                // Recent
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text("Recent", style = MaterialTheme.typography.titleLarge, modifier = Modifier.weight(1f))
                    if (history.isNotEmpty()) {
                        TextButton(onClick = { onOpenTab(Routes.HISTORY) }) { Text("See all") }
                    }
                }
                if (history.isEmpty()) {
                    BeamCard(Modifier.fillMaxWidth()) {
                        EmptyState(
                            icon = Icons.Rounded.Inbox,
                            title = "No transfers yet",
                            message = "Files you send and receive will show up here.",
                        )
                    }
                } else {
                    BeamCard(Modifier.fillMaxWidth()) {
                        history.take(4).forEachIndexed { i, entry ->
                            if (i > 0) HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant, modifier = Modifier.padding(start = 70.dp))
                            HistoryRow(entry, onClick = { onOpenTab(Routes.HISTORY) })
                        }
                    }
                }
                Spacer(Modifier.height(12.dp))
            }
        }
    }
}

@Composable
private fun ActionTile(
    title: String,
    subtitle: String,
    icon: ImageVector,
    container: Color,
    content: Color,
    badge: Color,
    badgeContent: Color,
    subtitleColor: Color,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    bordered: Boolean = false,
) {
    Surface(
        onClick = onClick,
        modifier = modifier.height(184.dp),
        shape = RoundedCornerShape(26.dp),
        color = container,
        contentColor = content,
        border = if (bordered) androidx.compose.foundation.BorderStroke(1.dp, MaterialTheme.colorScheme.outlineVariant) else null,
    ) {
        Column(Modifier.padding(18.dp), verticalArrangement = Arrangement.SpaceBetween) {
            Box(
                Modifier.size(52.dp).clip(RoundedCornerShape(17.dp)).background(badge),
                contentAlignment = Alignment.Center,
            ) {
                Icon(icon, contentDescription = null, tint = badgeContent, modifier = Modifier.size(26.dp))
            }
            Column {
                Text(title, style = MaterialTheme.typography.headlineSmall, color = content)
                Spacer(Modifier.height(2.dp))
                Text(subtitle, style = MaterialTheme.typography.bodySmall, color = subtitleColor, maxLines = 2)
            }
        }
    }
}

@Composable
fun HistoryRow(entry: HistoryEntry, onClick: () -> Unit) {
    Surface(onClick = onClick, color = Color.Transparent) {
        Row(
            Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            val sent = entry.direction == Direction.SEND
            com.beam.share.ui.components.FileThumb(
                kind = entry.files.firstOrNull()?.kind ?: com.beam.share.model.FileKind.OTHER,
                uri = entry.files.firstOrNull { it.ok }?.uri?.let { android.net.Uri.parse(it) },
                size = 42.dp,
            )
            Spacer(Modifier.width(12.dp))
            Column(Modifier.weight(1f)) {
                Text(entry.title, style = MaterialTheme.typography.titleSmall, maxLines = 1, overflow = TextOverflow.Ellipsis)
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        if (sent) Icons.Rounded.ArrowUpward else Icons.Rounded.ArrowDownward,
                        contentDescription = if (sent) "Sent" else "Received",
                        tint = if (sent) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.secondary,
                        modifier = Modifier.size(14.dp),
                    )
                    Spacer(Modifier.width(4.dp))
                    Text(
                        "${if (sent) "To" else "From"} ${entry.deviceName} · ${Format.bytes(entry.totalBytes)}",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                }
            }
            Spacer(Modifier.width(8.dp))
            Column(horizontalAlignment = Alignment.End) {
                Text(Format.relative(entry.timestamp), style = MaterialTheme.typography.labelMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
                StatusChip(entry)
            }
        }
    }
}

@Composable
fun StatusChip(entry: HistoryEntry) {
    val (label, bg, fg) = when (entry.status) {
        com.beam.share.data.HistoryStatus.COMPLETED -> return
        com.beam.share.data.HistoryStatus.FAILED -> Triple("Failed", MaterialTheme.colorScheme.errorContainer, MaterialTheme.colorScheme.onErrorContainer)
        com.beam.share.data.HistoryStatus.CANCELLED -> Triple("Cancelled", MaterialTheme.colorScheme.surfaceContainerHighest, MaterialTheme.colorScheme.onSurfaceVariant)
        com.beam.share.data.HistoryStatus.DECLINED -> Triple("Declined", MaterialTheme.colorScheme.surfaceContainerHighest, MaterialTheme.colorScheme.onSurfaceVariant)
    }
    Spacer(Modifier.height(4.dp))
    Text(
        label,
        style = MaterialTheme.typography.labelSmall,
        color = fg,
        modifier = Modifier.clip(RoundedCornerShape(6.dp)).background(bg).padding(horizontal = 6.dp, vertical = 2.dp),
    )
}
