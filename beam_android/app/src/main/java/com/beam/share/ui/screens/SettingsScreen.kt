@file:OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class)

package com.beam.share.ui.screens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
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
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.KeyboardArrowRight
import androidx.compose.material.icons.rounded.Check
import androidx.compose.material.icons.rounded.Folder
import androidx.compose.material.icons.rounded.Info
import androidx.compose.material.icons.rounded.LightMode
import androidx.compose.material.icons.rounded.Shield
import androidx.compose.material.icons.rounded.Smartphone
import androidx.compose.material.icons.rounded.StayCurrentPortrait
import androidx.compose.material.icons.rounded.Vibration
import androidx.compose.material.icons.rounded.Visibility
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.beam.share.AppContainer
import com.beam.share.BuildConfig
import com.beam.share.data.SettingsRepository
import com.beam.share.data.ThemeMode
import com.beam.share.ui.Routes
import com.beam.share.ui.components.BeamBottomBar
import com.beam.share.ui.components.BeamCard
import com.beam.share.ui.components.IconBadge
import com.beam.share.ui.components.PageTitle
import com.beam.share.ui.components.SectionLabel
import com.beam.share.ui.components.Segmented
import com.beam.share.util.Files
import com.beam.share.util.Permissions
import kotlinx.coroutines.launch

@Composable
fun SettingsScreen(container: AppContainer, onOpenTab: (String) -> Unit) {
    val context = LocalContext.current
    val focus = LocalFocusManager.current
    val scope = rememberCoroutineScope()
    val settings by container.settings.collectAsStateWithLifecycle()
    val repo = container.settingsRepository
    val s = settings ?: return

    var name by rememberSaveable { mutableStateOf(s.deviceName) }
    LaunchedEffect(s.deviceName) { if (name.isBlank()) name = s.deviceName }
    val nameChanged = name.trim() != s.deviceName && name.isNotBlank()
    fun saveName() {
        if (name.isBlank()) name = s.deviceName
        else scope.launch { repo.setDeviceName(name) }
        focus.clearFocus()
    }

    Scaffold(
        containerColor = MaterialTheme.colorScheme.background,
        bottomBar = { BeamBottomBar(Routes.SETTINGS, onOpenTab) },
    ) { padding ->
        Column(
            Modifier
                .fillMaxSize()
                .padding(bottom = padding.calculateBottomPadding())
                .verticalScroll(rememberScrollState()),
        ) {
            PageTitle("Settings")
            Column(Modifier.padding(horizontal = 20.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                SectionLabel("Your device", Modifier.padding(start = 4.dp, top = 8.dp))
                OutlinedTextField(
                    value = name,
                    onValueChange = { if (it.length <= SettingsRepository.MAX_NAME) name = it },
                    label = { Text("Device name") },
                    supportingText = { Text("This is how nearby phones see you") },
                    singleLine = true,
                    leadingIcon = { Icon(Icons.Rounded.Smartphone, null) },
                    trailingIcon = {
                        if (nameChanged) {
                            IconButton(onClick = ::saveName) { Icon(Icons.Rounded.Check, contentDescription = "Save name", tint = MaterialTheme.colorScheme.primary) }
                        }
                    },
                    keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Words, imeAction = ImeAction.Done),
                    keyboardActions = KeyboardActions(onDone = { saveName() }),
                    shape = RoundedCornerShape(16.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedContainerColor = MaterialTheme.colorScheme.surfaceContainerLowest,
                        unfocusedContainerColor = MaterialTheme.colorScheme.surfaceContainerLowest,
                        unfocusedBorderColor = MaterialTheme.colorScheme.outline,
                    ),
                    modifier = Modifier.fillMaxWidth(),
                )

                BeamCard(Modifier.fillMaxWidth()) {
                    ToggleRow(
                        icon = Icons.Rounded.Visibility,
                        title = "Visible to nearby phones",
                        subtitle = "Others can send you files while Beam is open",
                        checked = s.visible,
                        onChange = { v -> scope.launch { repo.setVisible(v) } },
                    )
                }

                SectionLabel("Appearance", Modifier.padding(start = 4.dp, top = 12.dp))
                BeamCard(Modifier.fillMaxWidth()) {
                    Column(Modifier.padding(16.dp)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            RowIcon(Icons.Rounded.LightMode)
                            Spacer(Modifier.width(14.dp))
                            Text("Theme", style = MaterialTheme.typography.titleSmall)
                        }
                        Spacer(Modifier.height(12.dp))
                        Segmented(
                            options = listOf(ThemeMode.SYSTEM to "System", ThemeMode.LIGHT to "Light", ThemeMode.DARK to "Dark"),
                            selected = s.themeMode,
                            onSelect = { m -> scope.launch { repo.setTheme(m) } },
                        )
                    }
                }

                SectionLabel("Transfers", Modifier.padding(start = 4.dp, top = 12.dp))
                BeamCard(Modifier.fillMaxWidth()) {
                    ToggleRow(
                        icon = Icons.Rounded.StayCurrentPortrait,
                        title = "Keep screen on",
                        subtitle = "While a transfer is running",
                        checked = s.keepScreenOn,
                        onChange = { v -> scope.launch { repo.setKeepScreenOn(v) } },
                    )
                    Divider()
                    ToggleRow(
                        icon = Icons.Rounded.Vibration,
                        title = "Vibrate",
                        subtitle = "For new requests and finished transfers",
                        checked = s.vibrate,
                        onChange = { v -> scope.launch { repo.setVibrate(v) } },
                    )
                    Divider()
                    LinkRow(
                        icon = Icons.Rounded.Folder,
                        title = "Saved to",
                        subtitle = "Download › Beam",
                        onClick = { Files.openDownloads(context) },
                    )
                }

                SectionLabel("About", Modifier.padding(start = 4.dp, top = 12.dp))
                BeamCard(Modifier.fillMaxWidth()) {
                    LinkRow(
                        icon = Icons.Rounded.Shield,
                        title = "App permissions",
                        subtitle = "Nearby devices, location, photos, notifications",
                        onClick = { context.startActivity(Permissions.appSettingsIntent(context)) },
                    )
                    Divider()
                    LinkRow(
                        icon = Icons.Rounded.Info,
                        title = "Beam ${BuildConfig.VERSION_NAME}",
                        subtitle = "Peer-to-peer over Bluetooth and Wi-Fi Direct. Files never touch the internet.",
                        onClick = null,
                    )
                }
                Spacer(Modifier.height(24.dp))
            }
        }
    }
}

@Composable
private fun Divider() {
    HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant, modifier = Modifier.padding(start = 70.dp))
}

@Composable
private fun RowIcon(icon: ImageVector) {
    IconBadge(
        icon = icon,
        container = MaterialTheme.colorScheme.primaryContainer,
        content = MaterialTheme.colorScheme.primary,
        size = 40.dp,
        iconSize = 20.dp,
        shape = RoundedCornerShape(12.dp),
    )
}

@Composable
private fun ToggleRow(icon: ImageVector, title: String, subtitle: String, checked: Boolean, onChange: (Boolean) -> Unit) {
    Row(
        Modifier
            .fillMaxWidth()
            .clickable { onChange(!checked) }
            .padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        RowIcon(icon)
        Spacer(Modifier.width(14.dp))
        Column(Modifier.weight(1f)) {
            Text(title, style = MaterialTheme.typography.titleSmall)
            Text(subtitle, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
        }
        Spacer(Modifier.width(8.dp))
        Switch(checked = checked, onCheckedChange = onChange)
    }
}

@Composable
private fun LinkRow(icon: ImageVector, title: String, subtitle: String, onClick: (() -> Unit)?) {
    Row(
        Modifier
            .fillMaxWidth()
            .then(if (onClick != null) Modifier.clickable(onClick = onClick) else Modifier)
            .padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        RowIcon(icon)
        Spacer(Modifier.width(14.dp))
        Column(Modifier.weight(1f)) {
            Text(title, style = MaterialTheme.typography.titleSmall)
            Text(subtitle, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
        }
        if (onClick != null) {
            Icon(
                Icons.AutoMirrored.Rounded.KeyboardArrowRight,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.size(22.dp),
            )
        }
    }
}
