@file:OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class)

package com.beam.share.ui.screens

import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.ArrowForward
import androidx.compose.material.icons.rounded.Check
import androidx.compose.material.icons.rounded.Close
import androidx.compose.material.icons.rounded.FolderOpen
import androidx.compose.material.icons.rounded.PhotoLibrary
import androidx.compose.material.icons.rounded.PlayArrow
import androidx.compose.material3.Checkbox
import androidx.compose.material3.CheckboxDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.compose.LifecycleEventEffect
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.beam.share.AppContainer
import com.beam.share.media.MediaEntry
import com.beam.share.model.FileKind
import com.beam.share.model.ShareItem
import com.beam.share.ui.components.BeamCard
import com.beam.share.ui.components.BeamTopBar
import com.beam.share.ui.components.EmptyState
import com.beam.share.ui.components.FileThumb
import com.beam.share.ui.components.icon
import com.beam.share.ui.components.InfoBanner
import com.beam.share.ui.components.MediaTile
import com.beam.share.ui.components.PrimaryButton
import com.beam.share.ui.components.SecondaryButton
import com.beam.share.ui.components.Spinner
import com.beam.share.util.Format
import com.beam.share.util.Permissions
import kotlinx.coroutines.launch

@Composable
fun PickerScreen(container: AppContainer, onBack: () -> Unit, onNext: () -> Unit) {
    val vm: PickerViewModel = viewModel()
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val tab by vm.tab.collectAsStateWithLifecycle()
    val selection by container.selection.items.collectAsStateWithLifecycle()
    val selectedKeys = remember(selection) { selection.map { it.key }.toHashSet() }
    var hasMedia by remember { mutableStateOf(Permissions.hasMediaAccess(context)) }
    var partialMedia by remember { mutableStateOf(Permissions.hasPartialMediaAccess(context)) }

    val mediaPermission = rememberLauncherForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) {
        hasMedia = Permissions.hasMediaAccess(context)
        partialMedia = Permissions.hasPartialMediaAccess(context)
        vm.reloadMedia()
    }
    val systemPhotoPicker = rememberLauncherForActivityResult(ActivityResultContracts.PickMultipleVisualMedia(100)) { uris ->
        addUris(container, scope, uris)
    }
    val documentPicker = rememberLauncherForActivityResult(ActivityResultContracts.OpenMultipleDocuments()) { uris ->
        addUris(container, scope, uris)
    }

    LaunchedEffect(tab) { vm.ensureLoaded(tab) }
    LifecycleEventEffect(Lifecycle.Event.ON_RESUME) {
        val now = Permissions.hasMediaAccess(context)
        if (now != hasMedia) {
            hasMedia = now
            vm.reloadMedia()
        }
        partialMedia = Permissions.hasPartialMediaAccess(context)
    }

    Box(Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background)) {
        Column(Modifier.fillMaxSize()) {
            BeamTopBar(
                title = "Choose files",
                onBack = onBack,
                actions = {
                    if (selection.isNotEmpty()) {
                        TextButton(onClick = { container.selection.clear() }) { Text("Clear") }
                    }
                },
            )
            LazyRow(
                contentPadding = PaddingValues(horizontal = 16.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                modifier = Modifier.padding(bottom = 12.dp),
            ) {
                items(PickerTab.entries.toList()) { t ->
                    val count = selection.count { it.matches(t) }
                    TabChip(
                        label = if (count > 0) "${t.label} · $count" else t.label,
                        selected = t == tab,
                        onClick = { vm.select(t) },
                    )
                }
            }

            Box(Modifier.weight(1f)) {
                when (tab) {
                    PickerTab.PHOTOS, PickerTab.VIDEOS -> {
                        if (!hasMedia) {
                            MediaPermissionPrompt(
                                onAllow = { mediaPermission.launch(Permissions.media) },
                                onSystemPicker = {
                                    systemPhotoPicker.launch(
                                        PickVisualMediaRequest(
                                            if (tab == PickerTab.PHOTOS) ActivityResultContracts.PickVisualMedia.ImageOnly
                                            else ActivityResultContracts.PickVisualMedia.VideoOnly
                                        )
                                    )
                                },
                            )
                        } else {
                            val state by (if (tab == PickerTab.PHOTOS) vm.photos else vm.videos).collectAsStateWithLifecycle()
                            Column {
                                if (partialMedia) {
                                    InfoBanner(
                                        icon = Icons.Rounded.PhotoLibrary,
                                        text = "You've allowed access to some photos only.",
                                        actionLabel = "Manage",
                                        onAction = { mediaPermission.launch(Permissions.media) },
                                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 4.dp),
                                        container = MaterialTheme.colorScheme.primaryContainer,
                                        content = MaterialTheme.colorScheme.onPrimaryContainer,
                                    )
                                }
                                MediaGrid(
                                    state = state,
                                    selectedKeys = selectedKeys,
                                    emptyTitle = if (tab == PickerTab.PHOTOS) "No photos" else "No videos",
                                    onToggle = { container.selection.toggle(it) },
                                    bottomPadding = if (selection.isEmpty()) 24.dp else 120.dp,
                                )
                            }
                        }
                    }
                    PickerTab.APPS -> {
                        val state by vm.apps.collectAsStateWithLifecycle()
                        if (state.loading || !state.loaded) {
                            Loading()
                        } else if (state.items.isEmpty()) {
                            EmptyState(
                                icon = FileKind.APP.icon(),
                                title = "No apps to share",
                                message = "Apps you installed yourself appear here.",
                            )
                        } else {
                            LazyColumn(
                                contentPadding = PaddingValues(start = 16.dp, end = 16.dp, bottom = if (selection.isEmpty()) 24.dp else 120.dp),
                            ) {
                                item {
                                    BeamCard(Modifier.fillMaxWidth()) {
                                        state.items.forEachIndexed { i, app ->
                                            if (i > 0) HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant, modifier = Modifier.padding(start = 72.dp))
                                            SelectableRow(
                                                item = app.item,
                                                title = app.label,
                                                subtitle = Format.bytes(app.item.size),
                                                selected = app.item.key in selectedKeys,
                                                onToggle = { container.selection.toggle(app.item) },
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    PickerTab.FILES -> {
                        val files = selection.filter { it.matches(PickerTab.FILES) }
                        LazyColumn(
                            contentPadding = PaddingValues(start = 16.dp, end = 16.dp, bottom = if (selection.isEmpty()) 24.dp else 120.dp),
                            verticalArrangement = Arrangement.spacedBy(12.dp),
                        ) {
                            item {
                                Surface(
                                    onClick = { documentPicker.launch(arrayOf("*/*")) },
                                    shape = RoundedCornerShape(22.dp),
                                    color = MaterialTheme.colorScheme.primaryContainer,
                                    modifier = Modifier.fillMaxWidth(),
                                ) {
                                    Row(Modifier.padding(20.dp), verticalAlignment = Alignment.CenterVertically) {
                                        Box(
                                            Modifier.size(52.dp).clip(RoundedCornerShape(16.dp)).background(MaterialTheme.colorScheme.primary),
                                            contentAlignment = Alignment.Center,
                                        ) {
                                            Icon(Icons.Rounded.FolderOpen, null, tint = MaterialTheme.colorScheme.onPrimary)
                                        }
                                        Spacer(Modifier.width(16.dp))
                                        Column(Modifier.weight(1f)) {
                                            Text("Browse files", style = MaterialTheme.typography.titleMedium, color = MaterialTheme.colorScheme.onPrimaryContainer)
                                            Text(
                                                "Documents, music, ZIPs, APKs and more",
                                                style = MaterialTheme.typography.bodySmall,
                                                color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.8f),
                                            )
                                        }
                                    }
                                }
                            }
                            if (files.isNotEmpty()) {
                                item {
                                    BeamCard(Modifier.fillMaxWidth()) {
                                        files.forEachIndexed { i, f ->
                                            if (i > 0) HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant, modifier = Modifier.padding(start = 72.dp))
                                            Row(
                                                Modifier.fillMaxWidth().padding(start = 16.dp, end = 4.dp, top = 10.dp, bottom = 10.dp),
                                                verticalAlignment = Alignment.CenterVertically,
                                            ) {
                                                FileThumb(f.kind, f.uri, size = 42.dp, packageName = f.packageName)
                                                Spacer(Modifier.width(14.dp))
                                                Column(Modifier.weight(1f)) {
                                                    Text(f.name, style = MaterialTheme.typography.titleSmall, maxLines = 1, overflow = TextOverflow.Ellipsis)
                                                    Text(Format.bytes(f.size), style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                                                }
                                                IconButton(onClick = { container.selection.remove(f.key) }) {
                                                    Icon(Icons.Rounded.Close, contentDescription = "Remove ${f.name}")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        AnimatedVisibility(
            visible = selection.isNotEmpty(),
            enter = slideInVertically { it },
            exit = slideOutVertically { it },
            modifier = Modifier.align(Alignment.BottomCenter),
        ) {
            SelectionBar(selection = selection, onNext = onNext)
        }
    }
}

private fun ShareItem.matches(tab: PickerTab): Boolean = when (tab) {
    PickerTab.PHOTOS -> kind == FileKind.IMAGE && uri.scheme == "content" && uri.authority == "media"
    PickerTab.VIDEOS -> kind == FileKind.VIDEO && uri.scheme == "content" && uri.authority == "media"
    PickerTab.APPS -> packageName != null
    PickerTab.FILES -> !(uri.authority == "media" && (kind == FileKind.IMAGE || kind == FileKind.VIDEO)) && packageName == null
}

private fun addUris(container: AppContainer, scope: kotlinx.coroutines.CoroutineScope, uris: List<Uri>) {
    if (uris.isEmpty()) return
    scope.launch {
        val items = uris.mapNotNull { container.media.resolve(it) }
        container.selection.add(items)
    }
}

@Composable
private fun TabChip(label: String, selected: Boolean, onClick: () -> Unit) {
    Surface(
        onClick = onClick,
        shape = RoundedCornerShape(50),
        color = if (selected) MaterialTheme.colorScheme.onSurface else MaterialTheme.colorScheme.surfaceContainerLowest,
        contentColor = if (selected) MaterialTheme.colorScheme.surface else MaterialTheme.colorScheme.onSurface,
        border = if (selected) null else BorderStroke(1.dp, MaterialTheme.colorScheme.outline),
        modifier = Modifier.height(40.dp),
    ) {
        Box(Modifier.padding(horizontal = 18.dp), contentAlignment = Alignment.Center) {
            Text(label, style = MaterialTheme.typography.titleSmall)
        }
    }
}

@Composable
private fun Loading() {
    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Spinner(Modifier.size(40.dp), strokeWidth = 4.dp)
    }
}

@Composable
private fun MediaGrid(
    state: LoadState<MediaEntry>,
    selectedKeys: Set<String>,
    emptyTitle: String,
    onToggle: (ShareItem) -> Unit,
    bottomPadding: androidx.compose.ui.unit.Dp,
) {
    when {
        state.loading || !state.loaded -> Loading()
        state.items.isEmpty() -> EmptyState(
            icon = Icons.Rounded.PhotoLibrary,
            title = emptyTitle,
            message = "Nothing to show here yet.",
        )
        else -> LazyVerticalGrid(
            columns = GridCells.Adaptive(112.dp),
            contentPadding = PaddingValues(start = 16.dp, end = 16.dp, top = 4.dp, bottom = bottomPadding),
            horizontalArrangement = Arrangement.spacedBy(6.dp),
            verticalArrangement = Arrangement.spacedBy(6.dp),
            modifier = Modifier.fillMaxSize(),
        ) {
            items(state.items, key = { it.item.key }) { entry ->
                MediaCell(entry, selected = entry.item.key in selectedKeys, onClick = { onToggle(entry.item) })
            }
        }
    }
}

@Composable
private fun MediaCell(entry: MediaEntry, selected: Boolean, onClick: () -> Unit) {
    val scale by animateFloatAsState(if (selected) 0.9f else 1f, label = "cellScale")
    val primary = MaterialTheme.colorScheme.primary
    Box(
        Modifier
            .aspectRatio(1f)
            .clip(RoundedCornerShape(12.dp))
            .background(if (selected) MaterialTheme.colorScheme.primaryContainer else Color.Transparent)
            .clickable(onClick = onClick),
    ) {
        MediaTile(
            uri = entry.item.uri,
            modifier = Modifier
                .fillMaxSize()
                .scale(scale)
                .clip(RoundedCornerShape(if (selected) 10.dp else 12.dp)),
        )
        if (entry.item.kind == FileKind.VIDEO) {
            Row(
                Modifier
                    .align(Alignment.BottomStart)
                    .padding(8.dp)
                    .clip(RoundedCornerShape(6.dp))
                    .background(Color.Black.copy(alpha = 0.62f))
                    .padding(horizontal = 6.dp, vertical = 2.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Icon(Icons.Rounded.PlayArrow, null, tint = Color.White, modifier = Modifier.size(12.dp))
                Spacer(Modifier.width(2.dp))
                Text(Format.videoLength(entry.durationMs), color = Color.White, style = MaterialTheme.typography.labelSmall)
            }
        }
        Box(
            Modifier
                .align(Alignment.TopEnd)
                .padding(8.dp)
                .size(24.dp)
                .clip(CircleShape)
                .then(
                    if (selected) Modifier.background(primary)
                    else Modifier.background(Color.Black.copy(alpha = 0.22f)).border(2.dp, Color.White, CircleShape)
                ),
            contentAlignment = Alignment.Center,
        ) {
            if (selected) Icon(Icons.Rounded.Check, contentDescription = "Selected", tint = MaterialTheme.colorScheme.onPrimary, modifier = Modifier.size(16.dp))
        }
    }
}

@Composable
private fun SelectableRow(item: ShareItem, title: String, subtitle: String, selected: Boolean, onToggle: () -> Unit) {
    Row(
        Modifier
            .fillMaxWidth()
            .clickable(onClick = onToggle)
            .padding(start = 16.dp, end = 8.dp, top = 10.dp, bottom = 10.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        FileThumb(item.kind, item.uri, size = 44.dp, packageName = item.packageName)
        Spacer(Modifier.width(14.dp))
        Column(Modifier.weight(1f)) {
            Text(title, style = MaterialTheme.typography.titleSmall, maxLines = 1, overflow = TextOverflow.Ellipsis)
            Text(subtitle, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
        }
        Checkbox(
            checked = selected,
            onCheckedChange = { onToggle() },
            colors = CheckboxDefaults.colors(checkedColor = MaterialTheme.colorScheme.primary),
        )
    }
}

@Composable
private fun MediaPermissionPrompt(onAllow: () -> Unit, onSystemPicker: () -> Unit) {
    Column(Modifier.fillMaxSize().padding(24.dp), verticalArrangement = Arrangement.Center) {
        EmptyState(
            icon = Icons.Rounded.PhotoLibrary,
            title = "See your photos and videos",
            message = "Allow access to pick from your gallery right here, or use Android's photo picker instead.",
        )
        PrimaryButton("Allow access", onClick = onAllow, modifier = Modifier.fillMaxWidth())
        Spacer(Modifier.height(10.dp))
        SecondaryButton("Use photo picker", onClick = onSystemPicker, modifier = Modifier.fillMaxWidth())
    }
}

@Composable
private fun SelectionBar(selection: List<ShareItem>, onNext: () -> Unit) {
    Surface(
        color = MaterialTheme.colorScheme.surfaceContainerLowest,
        shadowElevation = 16.dp,
        shape = RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp),
        modifier = Modifier.fillMaxWidth(),
    ) {
        Row(
            Modifier
                .navigationBarsPadding()
                .padding(start = 20.dp, end = 16.dp, top = 16.dp, bottom = 16.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            // Stacked thumbnails
            Box(Modifier.width((36 + 16 * (minOf(selection.size, 3) - 1)).dp).height(44.dp)) {
                selection.take(3).forEachIndexed { i, item ->
                    Box(
                        Modifier
                            .offset(x = (16 * i).dp)
                            .align(Alignment.CenterStart)
                            .size(40.dp)
                            .clip(RoundedCornerShape(12.dp))
                            .border(2.dp, MaterialTheme.colorScheme.surfaceContainerLowest, RoundedCornerShape(12.dp)),
                    ) {
                        FileThumb(item.kind, item.uri, size = 40.dp, packageName = item.packageName)
                    }
                }
            }
            Spacer(Modifier.width(14.dp))
            Column(Modifier.weight(1f)) {
                Text("${selection.size} selected", style = MaterialTheme.typography.titleMedium)
                Text(Format.bytes(selection.sumOf { it.size }) + " total", style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
            PrimaryButton(
                text = "Next",
                onClick = onNext,
                trailingIcon = Icons.AutoMirrored.Rounded.ArrowForward,
            )
        }
    }
}
