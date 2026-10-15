package com.beam.share.transfer

import android.content.ContentValues
import android.content.Context
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.content.FileProvider
import com.google.android.gms.nearby.connection.Payload
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileInputStream
import java.io.InputStream

/** Moves a received Nearby file into Download/Beam and returns a Uri that other apps can open. */
class FileSaver(private val context: Context) {

    private val resolver get() = context.contentResolver

    suspend fun save(file: Payload.File, name: String, mime: String): Uri? = withContext(Dispatchers.IO) {
        runCatching {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val src = file.asUri() ?: return@runCatching null
                val dest = resolver.openInputStream(src)?.use { input -> saveToMediaStore(input, name, mime) }
                    ?: fallbackCopy(resolver.openInputStream(src), name)
                runCatching { resolver.delete(src, null, null) }
                dest
            } else {
                @Suppress("DEPRECATION")
                val src = file.asJavaFile() ?: return@runCatching null
                saveLegacy(src, name, mime)
            }
        }.getOrNull()
    }

    /** Deletes the temporary file Nearby created for a payload that was cancelled or failed. */
    fun discard(file: Payload.File?) {
        file ?: return
        runCatching {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                file.asUri()?.let { resolver.delete(it, null, null) }
            } else {
                @Suppress("DEPRECATION")
                file.asJavaFile()?.delete()
            }
        }
    }

    private fun saveToMediaStore(input: InputStream, name: String, mime: String): Uri? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return null
        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, name)
            put(MediaStore.MediaColumns.MIME_TYPE, mime)
            put(MediaStore.MediaColumns.RELATIVE_PATH, "${Environment.DIRECTORY_DOWNLOADS}/$FOLDER")
            put(MediaStore.MediaColumns.IS_PENDING, 1)
        }
        val collection = MediaStore.Downloads.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        val dest = runCatching { resolver.insert(collection, values) }.getOrNull() ?: return null
        return try {
            resolver.openOutputStream(dest)?.use { out -> input.copyTo(out, BUFFER) } ?: error("No output stream")
            values.clear()
            values.put(MediaStore.MediaColumns.IS_PENDING, 0)
            resolver.update(dest, values, null, null)
            dest
        } catch (e: Exception) {
            runCatching { resolver.delete(dest, null, null) }
            null
        }
    }

    /** Last resort: the app's own external folder, shared through FileProvider. */
    private fun fallbackCopy(input: InputStream?, name: String): Uri? {
        input ?: return null
        val dir = File(context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS) ?: context.filesDir, FOLDER).apply { mkdirs() }
        val dest = uniqueFile(dir, name)
        input.use { i -> dest.outputStream().use { o -> i.copyTo(o, BUFFER) } }
        return providerUri(dest)
    }

    private fun saveLegacy(src: File, name: String, mime: String): Uri? {
        @Suppress("DEPRECATION")
        val publicDir = File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS), FOLDER)
        val dir = if ((publicDir.exists() || publicDir.mkdirs()) && publicDir.canWrite()) publicDir
        else File(context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS) ?: context.filesDir, FOLDER).apply { mkdirs() }
        val dest = uniqueFile(dir, name)
        val moved = src.renameTo(dest) || run {
            FileInputStream(src).use { i -> dest.outputStream().use { o -> i.copyTo(o, BUFFER) } }
            src.delete()
            true
        }
        if (!moved) return null
        MediaScannerConnection.scanFile(context, arrayOf(dest.absolutePath), arrayOf(mime), null)
        return providerUri(dest)
    }

    private fun providerUri(file: File): Uri =
        FileProvider.getUriForFile(context, "${context.packageName}.files", file)

    private fun uniqueFile(dir: File, name: String): File {
        var candidate = File(dir, name)
        if (!candidate.exists()) return candidate
        val base = name.substringBeforeLast('.', name)
        val ext = name.substringAfterLast('.', "").let { if (it.isEmpty() || it == name) "" else ".$it" }
        var i = 1
        while (candidate.exists()) {
            candidate = File(dir, "$base ($i)$ext")
            i++
        }
        return candidate
    }

    companion object {
        const val FOLDER = "Beam"
        private const val BUFFER = 256 * 1024
    }
}
