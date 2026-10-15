package com.beam.share.ui.components

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.Intent
import android.location.LocationManager
import android.net.wifi.WifiManager
import android.os.Build
import android.provider.Settings
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.BluetoothDisabled
import androidx.compose.material.icons.rounded.ErrorOutline
import androidx.compose.material.icons.rounded.LocationOff
import androidx.compose.material.icons.rounded.WifiOff
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.produceState
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.core.location.LocationManagerCompat
import com.beam.share.util.Permissions
import kotlinx.coroutines.delay

data class RadioStatus(
    val bluetoothOn: Boolean,
    val wifiOn: Boolean,
    val locationOn: Boolean,
)

fun readRadioStatus(context: Context): RadioStatus {
    val bt = runCatching {
        (context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager)?.adapter?.isEnabled ?: true
    }.getOrDefault(true)
    val wifi = runCatching {
        (context.applicationContext.getSystemService(Context.WIFI_SERVICE) as? WifiManager)?.isWifiEnabled ?: true
    }.getOrDefault(true)
    val location = runCatching {
        val lm = context.getSystemService(Context.LOCATION_SERVICE) as? LocationManager
        lm == null || LocationManagerCompat.isLocationEnabled(lm)
    }.getOrDefault(true)
    return RadioStatus(bt, wifi, location)
}

@Composable
fun rememberRadioStatus(): RadioStatus {
    val context = LocalContext.current
    val status by produceState(readRadioStatus(context)) {
        while (true) {
            value = readRadioStatus(context)
            delay(1500)
        }
    }
    return status
}

/** Banners that explain why phones might not show up, each with a one-tap fix. */
@Composable
fun RadioBanners(radioError: String?, modifier: Modifier = Modifier) {
    val context = LocalContext.current
    val status = rememberRadioStatus()
    val enableBt = rememberLauncherForActivityResult(ActivityResultContracts.StartActivityForResult()) { }

    Column(modifier, verticalArrangement = Arrangement.spacedBy(8.dp)) {
        if (!status.bluetoothOn) {
            InfoBanner(
                icon = Icons.Rounded.BluetoothDisabled,
                text = "Bluetooth is off. Turn it on to find nearby phones.",
                actionLabel = "Turn on",
                onAction = {
                    val canAsk = Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
                        Permissions.granted(context, Manifest.permission.BLUETOOTH_CONNECT)
                    runCatching {
                        if (canAsk) enableBt.launch(Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE))
                        else context.startActivity(Intent(Settings.ACTION_BLUETOOTH_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                    }
                },
            )
        }
        if (!status.locationOn && Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            InfoBanner(
                icon = Icons.Rounded.LocationOff,
                text = "Location is off. Android needs it on to find nearby phones.",
                actionLabel = "Turn on",
                onAction = {
                    runCatching {
                        context.startActivity(Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                    }
                },
            )
        }
        if (!status.wifiOn) {
            InfoBanner(
                icon = Icons.Rounded.WifiOff,
                text = "Turn on Wi-Fi for much faster transfers. No network needed.",
                actionLabel = "Wi-Fi",
                onAction = {
                    runCatching {
                        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) Intent(Settings.Panel.ACTION_WIFI)
                        else Intent(Settings.ACTION_WIFI_SETTINGS)
                        context.startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                    }
                },
                container = MaterialTheme.colorScheme.primaryContainer,
                content = MaterialTheme.colorScheme.onPrimaryContainer,
            )
        }
        if (radioError != null && status.bluetoothOn) {
            InfoBanner(
                icon = Icons.Rounded.ErrorOutline,
                text = radioError,
                container = MaterialTheme.colorScheme.errorContainer,
                content = MaterialTheme.colorScheme.onErrorContainer,
            )
        }
    }
}
