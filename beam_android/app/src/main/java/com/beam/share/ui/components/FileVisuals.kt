package com.beam.share.ui.components

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Android
import androidx.compose.material.icons.rounded.Archive
import androidx.compose.material.icons.rounded.Description
import androidx.compose.material.icons.rounded.Image
import androidx.compose.material.icons.rounded.MusicNote
import androidx.compose.material.icons.rounded.Folder
import androidx.compose.material.icons.rounded.Videocam
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.produceState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.core.graphics.drawable.toBitmap
import android.net.Uri
import coil.compose.SubcomposeAsyncImage
import coil.request.ImageRequest
import com.beam.share.model.FileKind
import com.beam.share.ui.theme.BeamTheme
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

fun FileKind.icon(): ImageVector = when (this) {
    FileKind.IMAGE -> Icons.Rounded.Image
    FileKind.VIDEO -> Icons.Rounded.Videocam
    FileKind.AUDIO -> Icons.Rounded.MusicNote
    FileKind.APP -> Icons.Rounded.Android
    FileKind.DOCUMENT -> Icons.Rounded.Description
    FileKind.ARCHIVE -> Icons.Rounded.Archive
    FileKind.OTHER -> Icons.Rounded.Folder
}

@Composable
fun FileKind.colors(): Pair<Color, Color> {
    val s = MaterialTheme.colorScheme
    val e = BeamTheme.extra
    return when (this) {
        FileKind.IMAGE -> s.primaryContainer to s.primary
        FileKind.VIDEO -> s.secondaryContainer to s.secondary
        FileKind.AUDIO -> e.purpleContainer to e.onPurpleContainer
        FileKind.APP -> s.tertiaryContainer to s.tertiary
        FileKind.DOCUMENT -> e.tealContainer to e.onTealContainer
        FileKind.ARCHIVE -> e.amberContainer to e.onAmberContainer
        FileKind.OTHER -> s.surfaceContainerHighest to s.onSurfaceVariant
    }
}

@Composable
fun FileTypeIcon(kind: FileKind, modifier: Modifier = Modifier, size: Dp = 40.dp) {
    val (bg, fg) = kind.colors()
    IconBadge(
        icon = kind.icon(),
        container = bg,
        content = fg,
        modifier = modifier,
        size = size,
        iconSize = size * 0.5f,
        shape = RoundedCornerShape(size * 0.3f),
    )
}

/** Real preview for photos / videos / apps, typed icon for everything else. */
@Composable
fun FileThumb(
    kind: FileKind,
    uri: Uri?,
    modifier: Modifier = Modifier,
    size: Dp = 40.dp,
    packageName: String? = null,
) {
    val shape = RoundedCornerShape(size * 0.3f)
    when {
        kind == FileKind.APP && packageName != null -> {
            val icon = rememberAppIcon(packageName)
            if (icon != null) {
                Image(icon, contentDescription = null, modifier = modifier.size(size))
            } else {
                FileTypeIcon(kind, modifier, size)
            }
        }
        (kind == FileKind.IMAGE || kind == FileKind.VIDEO) && uri != null -> {
            val context = LocalContext.current
            SubcomposeAsyncImage(
                model = ImageRequest.Builder(context).data(uri).size(256).build(),
                contentDescription = null,
                contentScale = ContentScale.Crop,
                modifier = modifier.size(size).clip(shape).background(MaterialTheme.colorScheme.surfaceContainerHighest),
                loading = { Box(Modifier.fillMaxSize().background(MaterialTheme.colorScheme.surfaceContainerHighest)) },
                error = { FileTypeIcon(kind, Modifier.fillMaxSize(), size) },
            )
        }
        else -> FileTypeIcon(kind, modifier, size)
    }
}

@Composable
fun rememberAppIcon(packageName: String): ImageBitmap? {
    val context = LocalContext.current
    val icon by produceState<ImageBitmap?>(initialValue = null, packageName) {
        value = withContext(Dispatchers.IO) {
            runCatching {
                context.packageManager.getApplicationIcon(packageName).toBitmap(144, 144).asImageBitmap()
            }.getOrNull()
        }
    }
    return icon
}

/** Grid tile for the photo / video picker. */
@Composable
fun MediaTile(uri: Uri, modifier: Modifier = Modifier) {
    val context = LocalContext.current
    SubcomposeAsyncImage(
        model = ImageRequest.Builder(context).data(uri).size(360).build(),
        contentDescription = null,
        contentScale = ContentScale.Crop,
        modifier = modifier.background(MaterialTheme.colorScheme.surfaceContainerHighest),
        loading = { Box(Modifier.fillMaxSize().background(MaterialTheme.colorScheme.surfaceContainerHighest)) },
        error = {
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                FileTypeIcon(FileKind.IMAGE, size = 36.dp)
            }
        },
    )
}
