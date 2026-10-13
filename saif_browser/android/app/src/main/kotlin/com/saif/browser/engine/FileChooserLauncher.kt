package com.saif.browser.engine

import android.Manifest
import android.app.Activity
import android.content.ClipData
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.ext.SdkExtensions
import android.provider.MediaStore
import android.webkit.MimeTypeMap
import androidx.core.content.FileProvider
import com.saif.browser.system.ActivityHost
import java.io.File
import java.io.IOException

/**
 * Launches system pickers for `<input type="file">`: the Android Photo
 * Picker, the camera, and the Storage Access Framework. No broad storage
 * permission is needed; returned content URIs are readable by the app.
 */
class FileChooserLauncher(private val context: Context, private val host: ActivityHost) {

    fun launch(source: String, chooser: PendingFileChooser, launched: (Boolean) -> Unit) {
        when (source) {
            "media" -> launchMedia(chooser, launched)
            "camera" -> launchCapture(MediaStore.ACTION_IMAGE_CAPTURE, "jpg", chooser, launched)
            "camcorder" -> launchCapture(MediaStore.ACTION_VIDEO_CAPTURE, "mp4", chooser, launched)
            else -> launchDocuments(chooser, launched)
        }
    }

    private fun mimeTypes(accept: List<String>): List<String> {
        val map = MimeTypeMap.getSingleton()
        return accept.mapNotNull { type ->
            val t = type.lowercase()
            when {
                t.startsWith(".") -> map.getMimeTypeFromExtension(t.removePrefix("."))
                t.contains("/") -> t
                else -> null
            }
        }.distinct()
    }

    private fun isPhotoPickerAvailable(): Boolean = when {
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU -> true
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.R ->
            SdkExtensions.getExtensionVersion(Build.VERSION_CODES.R) >= 2
        else -> false
    }

    private fun launchMedia(chooser: PendingFileChooser, launched: (Boolean) -> Unit) {
        val types = mimeTypes(chooser.acceptTypes)
        val wantsImages = types.isEmpty() || types.any { it.startsWith("image/") }
        val wantsVideos = types.isEmpty() || types.any { it.startsWith("video/") }
        val intent = if (isPhotoPickerAvailable()) {
            Intent(MediaStore.ACTION_PICK_IMAGES).apply {
                when {
                    wantsImages && !wantsVideos -> type = "image/*"
                    wantsVideos && !wantsImages -> type = "video/*"
                }
                if (chooser.multiple) {
                    putExtra(MediaStore.EXTRA_PICK_IMAGES_MAX, MediaStore.getPickImagesMaxLimit())
                }
            }
        } else {
            Intent(Intent.ACTION_GET_CONTENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = when {
                    wantsImages && !wantsVideos -> "image/*"
                    wantsVideos && !wantsImages -> "video/*"
                    else -> "*/*"
                }
                if (wantsImages && wantsVideos) {
                    putExtra(Intent.EXTRA_MIME_TYPES, arrayOf("image/*", "video/*"))
                }
                putExtra(Intent.EXTRA_ALLOW_MULTIPLE, chooser.multiple)
            }
        }
        start(intent, chooser, launched)
    }

    private fun launchDocuments(chooser: PendingFileChooser, launched: (Boolean) -> Unit) {
        val types = mimeTypes(chooser.acceptTypes)
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = if (types.size == 1) types.first() else "*/*"
            if (types.size > 1) putExtra(Intent.EXTRA_MIME_TYPES, types.toTypedArray())
            putExtra(Intent.EXTRA_ALLOW_MULTIPLE, chooser.multiple)
        }
        start(intent, chooser, launched)
    }

    private fun start(intent: Intent, chooser: PendingFileChooser, launched: (Boolean) -> Unit) {
        val ok = host.startForResult(intent) { resultCode, data ->
            chooser.callback.onReceiveValue(
                if (resultCode == Activity.RESULT_OK) urisFrom(data) else null,
            )
        }
        if (!ok) chooser.callback.onReceiveValue(null)
        launched(ok)
    }

    private fun launchCapture(
        action: String,
        extension: String,
        chooser: PendingFileChooser,
        launched: (Boolean) -> Unit,
    ) {
        // CAMERA is declared for WebRTC, so the capture intent requires it to be granted.
        host.requestPermissions(listOf(Manifest.permission.CAMERA)) { granted ->
            if (granted[Manifest.permission.CAMERA] != true) {
                chooser.callback.onReceiveValue(null)
                launched(false)
                return@requestPermissions
            }
            val file = try {
                File(captureDir(context), "capture_${System.currentTimeMillis()}.$extension")
                    .also { it.createNewFile() }
            } catch (e: IOException) {
                chooser.callback.onReceiveValue(null)
                launched(false)
                return@requestPermissions
            }
            val uri = FileProvider.getUriForFile(context, authority(context), file)
            val intent = Intent(action).apply {
                putExtra(MediaStore.EXTRA_OUTPUT, uri)
                clipData = ClipData.newRawUri("output", uri)
                addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION or Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            val ok = host.startForResult(intent) { resultCode, _ ->
                if (resultCode == Activity.RESULT_OK && file.length() > 0) {
                    chooser.callback.onReceiveValue(arrayOf(uri))
                } else {
                    file.delete()
                    chooser.callback.onReceiveValue(null)
                }
            }
            if (!ok) {
                file.delete()
                chooser.callback.onReceiveValue(null)
            }
            launched(ok)
        }
    }

    private fun urisFrom(data: Intent?): Array<Uri>? {
        if (data == null) return null
        val clip = data.clipData
        if (clip != null && clip.itemCount > 0) {
            return Array(clip.itemCount) { clip.getItemAt(it).uri }
        }
        return data.data?.let { arrayOf(it) }
    }

    companion object {
        fun authority(context: Context) = "${context.packageName}.files"

        fun captureDir(context: Context): File =
            File(context.cacheDir, "captures").also { it.mkdirs() }

        /** Removes camera captures from earlier runs. */
        fun cleanupCaptures(context: Context) {
            captureDir(context).listFiles()?.forEach { it.delete() }
        }
    }
}
