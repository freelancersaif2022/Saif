@file:OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class)

package com.beam.share.ui.screens

import android.net.Uri
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.OpenInNew
import androidx.compose.material.icons.rounded.DeleteOutline
import androidx.compose.material.icons.rounded.History
import androidx.compose.material.icons.rounded.MoreVert
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
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
import com.beam.share.ui.components.FileThumb
import com.beam.share.ui.components.PageTitle
import com.beam.share.ui.components.SecondaryButton
import com.beam.share.ui.components.SectionLabel
import com.beam.share.ui.components.Segmented
import com.beam.share.util.Files
import com.beam.share.util.Format
import kotlinx.coroutines.launch

private enum class HistoryFilter { ALL, SENT, RECEIVED }

@Composable
fun HistoryScreen(container: AppContainer, onOpenTab: (String) -> Unit) {
    val scope = rememberCoroutineScope()
    val entries by container.history.entries.collectAsStateWithLifecycle(initialValue = null)
    var filter by rememberSaveable { mutableStateOf(HistoryFilter.ALL) }
    var menuOpen by remember { mutableStateOf(false) }
    var confirmClear by remember { mutableStateOf(false) }
    var detail by remember { mutableStateOf<HistoryEntry?>(null) }

    val list = entries.orEmpty().filter {
        when (filter) {
            HistoryFilter.ALL -> true
            HistoryFilter.SENT -> it.direction == Direction.SEND
            HistoryFilter.RECEIVED -> it.direction == Direction.RECEIVE
        }
    }
    val groups = list.groupBy { Format.dayLabel(it.timestamp) }

    Scaffold(
        containerColor = MaterialTheme.colorScheme.background,
        bottomBar = { BeamBottomBar(Routes.HISTORY, onOpenTab) },
    ) { padding ->
        Column(Modifier.fillMaxSize().padding(bottom = padding.calculateBottomPadding())) {
            PageTitle("History") {
                if (!entries.isNullOrEmpty()) {
                    Box {
                        IconButton(onClick = { menuOpen = true }) {
                            Icon(Icons.Rounded.MoreVert, contentDescription = "More options")
                        }
                        DropdownMenu(expanded = menuOpen, onDismissRequest = { menuOpen = false }) {
                            DropdownMenuItem(
                                text = { Text("Clear history") },
                                leadingIcon = { Icon(Icons.Rounded.DeleteOutline, null) },
                                onClick = {
                                    menuOpen = false
                                    confirmClear = true
                                },
                            )
                        }
                    }
                }
            }
            Segmented(
                options = listOf(HistoryFilter.ALL to "All", HistoryFilter.SENT to "Sent", HistoryFilter.RECEIVED to "Received"),
                selected = filter,
                onSelect = { filter = it },
                modifier = Modifier.padding(horizontal = 20.dp, vertical = 8.dp),
            )
            when {
                entries == null -> Unit
                list.isEmpty() -> Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    EmptyState(
                        icon = Icons.Rounded.History,
                        title = if (filter == HistoryFilter.ALL) "No history yet" else "Nothing here",
                        message = when (filter) {
                            HistoryFilter.ALL -> "Every file you send or receive is listed here."
                            HistoryFilter.SENT -> "Files you send will show up here."
                            HistoryFilter.RECEIVED -> "Files you receive will show up here."
                        },
                    )
                }
                else -> LazyColumn(
                    contentPadding = PaddingValues(start = 20.dp, end = 20.dp, top = 8.dp, bottom = 24.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp),
                ) {
                    groups.forEach { (day, items) ->
                        item(key = "h_$day") { SectionLabel(day, Modifier.padding(top = 8.dp, start = 4.dp)) }
                        item(key = "g_$day") {
                            BeamCard(Modifier.fillMaxWidth()) {
                                items.forEachIndexed { i, entry ->
                                    if (i > 0) HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant, modifier = Modifier.padding(start = 70.dp))
                                    HistoryRow(entry, onClick = { detail = entry })
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    if (confirmClear) {
        AlertDialog(
            onDismissRequest = { confirmClear = false },
            title = { Text("Clear history?") },
            text = { Text("This only clears the list. Received files stay in Download › Beam.") },
            confirmButton = {
                TextButton(onClick = {
                    confirmClear = false
                    scope.launch { container.history.clear() }
                }) { Text("Clear", color = MaterialTheme.colorScheme.error) }
            },
            dismissButton = { TextButton(onClick = { confirmClear = false }) { Text("Cancel") } },
            containerColor = MaterialTheme.colorScheme.surfaceContainerLowest,
        )
    }

    detail?.let { entry ->
        HistoryDetailSheet(
            entry = entry,
            onDismiss = { detail = null },
            onDelete = {
                detail = null
                scope.launch { container.history.delete(entry.id) }
            },
        )
    }
}

@Composable
private fun HistoryDetailSheet(entry: HistoryEntry, onDismiss: () -> Unit, onDelete: () -> Unit) {
    val context = LocalContext.current
    val sent = entry.direction == Direction.SEND
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
        containerColor = MaterialTheme.colorScheme.surfaceContainerLowest,
    ) {
        Column(Modifier.padding(horizontal = 24.dp).padding(bottom = 24.dp)) {
            Text(entry.title, style = MaterialTheme.typography.headlineSmall, maxLines = 2, overflow = TextOverflow.Ellipsis)
            Spacer(Modifier.height(4.dp))
            Text(
                "${if (sent) "Sent to" else "Received from"} ${entry.deviceName}",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            Text(
                "${Format.dayLabel(entry.timestamp)}, ${Format.time(entry.timestamp)} · ${Format.bytes(entry.totalBytes)}" +
                    if (entry.durationMs > 0) " · ${Format.duration(entry.durationMs)}" else "",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            Spacer(Modifier.height(16.dp))
            Column(
                Modifier.fillMaxWidth().heightIn(max = 360.dp).verticalScroll(rememberScrollState()),
            ) {
                entry.files.forEach { f ->
                    val uri = f.uri?.let { Uri.parse(it) }
                    Row(
                        Modifier.fillMaxWidth().padding(vertical = 8.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        FileThumb(f.kind, uri, size = 40.dp)
                        Spacer(Modifier.width(12.dp))
                        Column(Modifier.weight(1f)) {
                            Text(f.name, style = MaterialTheme.typography.titleSmall, maxLines = 1, overflow = TextOverflow.Ellipsis)
                            Text(
                                if (f.ok) Format.bytes(f.size) else "Not transferred",
                                style = MaterialTheme.typography.bodySmall,
                                color = if (f.ok) MaterialTheme.colorScheme.onSurfaceVariant else MaterialTheme.colorScheme.error,
                            )
                        }
                        if (uri != null && f.ok && !sent) {
                            IconButton(onClick = { Files.open(context, uri, f.mime) }) {
                                Icon(Icons.AutoMirrored.Rounded.OpenInNew, contentDescription = "Open ${f.name}", tint = MaterialTheme.colorScheme.primary)
                            }
                        }
                    }
                }
            }
            Spacer(Modifier.height(16.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                if (!sent) {
                    SecondaryButton("Open folder", onClick = { Files.openDownloads(context) }, modifier = Modifier.weight(1f))
                }
                SecondaryButton(
                    "Remove",
                    onClick = onDelete,
                    icon = Icons.Rounded.DeleteOutline,
                    contentColor = MaterialTheme.colorScheme.error,
                    modifier = Modifier.weight(1f),
                )
            }
        }
    }
}
