package com.beam.share.media

import android.content.ContentUris
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.provider.OpenableColumns
import com.beam.share.model.FileKind
import com.beam.share.model.ShareItem
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File

data class MediaEntry(
    val item: ShareItem,
    val dateAdded: Long,
    val durationMs: Long,
)

data class AppEntry(
    val item: ShareItem,
    val label: String,
    val packageName: String,
)

class MediaRepository(private val context: Context) {

    private val resolver get() = context.contentResolver

    suspend fun loadImages(limit: Int = 3000): List<MediaEntry> = withContext(Dispatchers.IO) {
        val collection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
        } else {
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        }
        queryMedia(collection, video = false, limit = limit)
    }

    suspend fun loadVideos(limit: Int = 3000): List<MediaEntry> = withContext(Dispatchers.IO) {
        val collection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
        } else {
            MediaStore.Video.Media.EXTERNAL_CONTENT_URI
        }
        queryMedia(collection, video = true, limit = limit)
    }

    private fun queryMedia(collection: Uri, video: Boolean, limit: Int): List<MediaEntry> {
        val projection = buildList {
            add(MediaStore.MediaColumns._ID)
            add(MediaStore.MediaColumns.DISPLAY_NAME)
            add(MediaStore.MediaColumns.SIZE)
            add(MediaStore.MediaColumns.MIME_TYPE)
            add(MediaStore.MediaColumns.DATE_ADDED)
            if (video) add(MediaStore.Video.VideoColumns.DURATION)
        }.toTypedArray()
        val out = ArrayList<MediaEntry>()
        runCatching {
            resolver.query(
                collection, projection, null, null,
                "${MediaStore.MediaColumns.DATE_ADDED} DESC"
            )?.use { c ->
                val idCol = c.getColumnIndexOrThrow(MediaStore.MediaColumns._ID)
                val nameCol = c.getColumnIndexOrThrow(MediaStore.MediaColumns.DISPLAY_NAME)
                val sizeCol = c.getColumnIndexOrThrow(MediaStore.MediaColumns.SIZE)
                val mimeCol = c.getColumnIndexOrThrow(MediaStore.MediaColumns.MIME_TYPE)
                val dateCol = c.getColumnIndexOrThrow(MediaStore.MediaColumns.DATE_ADDED)
                val durCol = if (video) c.getColumnIndex(MediaStore.Video.VideoColumns.DURATION) else -1
                while (c.moveToNext() && out.size < limit) {
                    val id = c.getLong(idCol)
                    val size = c.getLong(sizeCol)
                    if (size <= 0) continue
                    val name = c.getString(nameCol) ?: "file_$id"
                    val mime = c.getString(mimeCol) ?: FileKind.mimeFromName(name)
                    val uri = ContentUris.withAppendedId(collection, id)
                    out += MediaEntry(
                        item = ShareItem(
                            uri = uri,
                            name = name,
                            size = size,
                            mime = mime,
                            kind = if (video) FileKind.VIDEO else FileKind.IMAGE,
                        ),
                        dateAdded = c.getLong(dateCol) * 1000,
                        durationMs = if (durCol >= 0) c.getLong(durCol) else 0L,
                    )
                }
            }
        }
        return out
    }

    /** User-installed (or updated system) apps that ship as a single APK, so the receiver can install them. */
    suspend fun loadApps(): List<AppEntry> = withContext(Dispatchers.IO) {
        val pm = context.packageManager
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        @Suppress("DEPRECATION")
        val activities = runCatching { pm.queryIntentActivities(intent, 0) }.getOrDefault(emptyList())
        activities.asSequence()
            .mapNotNull { it.activityInfo?.applicationInfo }
            .distinctBy { it.packageName }
            .filter { it.packageName != context.packageName }
            .filter { info ->
                val system = info.flags and ApplicationInfo.FLAG_SYSTEM != 0
                val updated = info.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP != 0
                (!system || updated) && info.splitSourceDirs.isNullOrEmpty()
            }
            .mapNotNull { info ->
                val apk = File(info.sourceDir ?: return@mapNotNull null)
                if (!apk.canRead()) return@mapNotNull null
                val label = runCatching { pm.getApplicationLabel(info).toString() }.getOrDefault(info.packageName)
                val safeLabel = label.replace(Regex("[\\\\/:*?\"<>|]"), "_").trim().ifBlank { info.packageName }
                AppEntry(
                    item = ShareItem(
                        uri = Uri.fromFile(apk),
                        name = "$safeLabel.apk",
                        size = apk.length(),
                        mime = FileKind.APK_MIME,
                        kind = FileKind.APP,
                        packageName = info.packageName,
                    ),
                    label = label,
                    packageName = info.packageName,
                )
            }
            .sortedBy { it.label.lowercase() }
            .toList()
    }

    /** Turns a content:// (or file://) Uri from a picker or share intent into a [ShareItem]. */
    suspend fun resolve(uri: Uri): ShareItem? = withContext(Dispatchers.IO) {
        runCatching {
            if (uri.scheme == "file") {
                val f = File(uri.path ?: return@runCatching null)
                if (!f.exists()) return@runCatching null
                val mime = FileKind.mimeFromName(f.name)
                return@runCatching ShareItem(uri, f.name, f.length(), mime, FileKind.from(mime, f.name))
            }
            var name: String? = null
            var size = -1L
            resolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE), null, null, null)?.use { c ->
                if (c.moveToFirst()) {
                    val n = c.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                    val s = c.getColumnIndex(OpenableColumns.SIZE)
                    if (n >= 0 && !c.isNull(n)) name = c.getString(n)
                    if (s >= 0 && !c.isNull(s)) size = c.getLong(s)
                }
            }
            if (size < 0) {
                size = resolver.openFileDescriptor(uri, "r")?.use { it.statSize } ?: 0L
            }
            val finalName = name ?: uri.lastPathSegment?.substringAfterLast('/') ?: "file"
            val mime = resolver.getType(uri) ?: FileKind.mimeFromName(finalName)
            ShareItem(uri, finalName, size.coerceAtLeast(0), mime, FileKind.from(mime, finalName))
        }.getOrNull()
    }
}
