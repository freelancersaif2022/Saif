package com.saif.browser.system

import android.Manifest
import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import androidx.core.content.FileProvider
import com.saif.browser.downloads.DownloadHelper
import com.saif.browser.engine.BrowserEngine
import com.saif.browser.engine.FileChooserLauncher
import com.saif.browser.security.KeystoreCipher
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException
import java.security.GeneralSecurityException
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * `saif/system` channel: Keystore encryption, system downloads, file
 * open/share/save, external app links, secure window and incoming intents.
 */
class SystemChannel(
    private val context: Context,
    messenger: BinaryMessenger,
    private val host: ActivityHost,
    private val engine: BrowserEngine,
) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, CHANNEL)
    private val io: ExecutorService = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private val downloads = DownloadHelper(context)

    init {
        channel.setMethodCallHandler(this)
        host.intentListener = { intent ->
            intentPayload(intent)?.let { channel.invokeMethod("onIntent", it) }
        }
        io.execute { FileChooserLauncher.cleanupCaptures(context) }
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        io.shutdown()
    }

    private fun background(result: MethodChannel.Result, block: () -> Any?) {
        io.execute {
            val outcome = try {
                Result.success(block())
            } catch (e: Exception) {
                Result.failure(e)
            }
            main.post {
                outcome.fold(
                    onSuccess = { result.success(it) },
                    onFailure = { result.error(errorCode(it), it.javaClass.simpleName, null) },
                )
            }
        }
    }

    private fun errorCode(e: Throwable) = when (e) {
        is GeneralSecurityException -> "crypto_failed"
        is IOException -> "io_failed"
        is IllegalArgumentException -> "bad_args"
        else -> "failed"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "consumeInitialIntent" -> result.success(host.consumeInitialIntent()?.let(::intentPayload))
            "encrypt" -> {
                val data = call.argument<ByteArray>("data") ?: return result.error("bad_args", null, null)
                val aad = (call.argument<String>("aad") ?: "").toByteArray()
                background(result) { KeystoreCipher.encrypt(data, aad) }
            }
            "decrypt" -> {
                val data = call.argument<ByteArray>("data") ?: return result.error("bad_args", null, null)
                val aad = (call.argument<String>("aad") ?: "").toByteArray()
                background(result) { KeystoreCipher.decrypt(data, aad) }
            }
            "setSecure" -> {
                host.setSecure(call.argument<Boolean>("secure") == true)
                result.success(null)
            }
            "moveToBack" -> result.success(host.context.moveTaskToBack(true))
            "openExternal" -> result.success(openExternal(call.argument<String>("url") ?: ""))
            "shareText" -> {
                val intent = Intent(Intent.ACTION_SEND).apply {
                    type = "text/plain"
                    putExtra(Intent.EXTRA_TEXT, call.argument<String>("text"))
                    call.argument<String>("subject")?.let { putExtra(Intent.EXTRA_SUBJECT, it) }
                }
                result.success(startChooser(intent, null))
            }
            "openAppSettings" -> {
                val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                    .setData(Uri.fromParts("package", context.packageName, null))
                result.success(start(intent))
            }
            "appDownloadsDir" -> {
                val dir = context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS)
                    ?: File(context.filesDir, "downloads")
                dir.mkdirs()
                result.success(dir.absolutePath)
            }
            "enqueueDownload" -> enqueueDownload(call, result)
            "queryDownloads" -> {
                val ids = (call.argument<List<Number>>("ids") ?: emptyList()).map { it.toLong() }
                background(result) { downloads.query(ids.toLongArray()) }
            }
            "removeDownload" -> {
                val id = call.argument<Number>("id")?.toLong() ?: -1
                background(result) { downloads.remove(id) }
            }
            "openFile" -> {
                val uri = fileUri(call) ?: return result.success(false)
                val intent = Intent(Intent.ACTION_VIEW).apply {
                    setDataAndType(uri, call.argument<String>("mimeType") ?: "*/*")
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                }
                result.success(start(intent))
            }
            "shareFile" -> {
                val uri = fileUri(call) ?: return result.success(false)
                val intent = Intent(Intent.ACTION_SEND).apply {
                    type = call.argument<String>("mimeType") ?: "*/*"
                    putExtra(Intent.EXTRA_STREAM, uri)
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                }
                result.success(startChooser(intent, uri))
            }
            "saveCopy" -> saveCopy(call, result)
            else -> result.notImplemented()
        }
    }

    private fun intentPayload(intent: Intent): Map<String, Any?>? = when (intent.action) {
        Intent.ACTION_VIEW -> intent.data?.takeIf {
            it.scheme.equals("http", true) || it.scheme.equals("https", true)
        }?.let { mapOf("url" to it.toString()) }
        Intent.ACTION_SEND -> intent.getStringExtra(Intent.EXTRA_TEXT)?.let { mapOf("text" to it) }
        Intent.ACTION_WEB_SEARCH -> intent.getStringExtra("query")?.let { mapOf("text" to it) }
        else -> null
    }

    private fun start(intent: Intent): Boolean = try {
        host.context.startActivity(intent)
        true
    } catch (e: ActivityNotFoundException) {
        false
    } catch (e: SecurityException) {
        false
    }

    private fun startChooser(intent: Intent, uri: Uri?): Boolean {
        val chooser = Intent.createChooser(intent, null)
        if (uri != null) chooser.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        return start(chooser)
    }

    /**
     * Opens a non-web link (intent:, tel:, mailto:, market:, app schemes) in
     * another app after the user confirmed it. `intent:` URIs are sanitised so
     * a page cannot target non-exported or internal components.
     */
    private fun openExternal(url: String): Boolean {
        val intent = try {
            if (url.startsWith("intent:", ignoreCase = true)) {
                Intent.parseUri(url, Intent.URI_INTENT_SCHEME).apply {
                    addCategory(Intent.CATEGORY_BROWSABLE)
                    component = null
                    selector = null
                    `package`?.let { pkg -> if (pkg == context.packageName) return false }
                }
            } else {
                Intent(Intent.ACTION_VIEW, Uri.parse(url)).addCategory(Intent.CATEGORY_BROWSABLE)
            }
        } catch (e: Exception) {
            return false
        }
        if (intent.data?.scheme.equals("file", true) || intent.data?.scheme.equals("content", true)) {
            return false
        }
        if (start(intent)) return true
        // App not installed: open its store listing when the link names a package.
        val pkg = intent.`package` ?: return false
        return start(
            Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=$pkg"))
                .addCategory(Intent.CATEGORY_BROWSABLE),
        )
    }

    private fun fileUri(call: MethodCall): Uri? {
        call.argument<Number>("systemId")?.toLong()?.let { return downloads.contentUri(it) }
        val path = call.argument<String>("path") ?: return null
        val file = File(path)
        if (!file.exists()) return null
        return try {
            FileProvider.getUriForFile(context, FileChooserLauncher.authority(context), file)
        } catch (e: IllegalArgumentException) {
            null
        }
    }

    private fun enqueueDownload(call: MethodCall, result: MethodChannel.Result) {
        val perform = {
            try {
                val incognito = call.argument<Boolean>("incognito") == true
                val id = downloads.enqueue(
                    url = call.argument<String>("url") ?: "",
                    fileName = call.argument<String>("fileName") ?: "download",
                    mimeType = call.argument<String>("mimeType"),
                    userAgent = call.argument<String>("userAgent"),
                    referer = if (incognito) null else call.argument<String>("referer"),
                    cookies = engine.profiles.cookieManagerForSession(incognito),
                )
                result.success(id)
            } catch (e: IllegalArgumentException) {
                result.error("bad_args", e.message, null)
            } catch (e: SecurityException) {
                result.error("permission", e.message, null)
            }
        }
        if (DownloadHelper.needsLegacyStoragePermission()) {
            host.requestPermissions(listOf(Manifest.permission.WRITE_EXTERNAL_STORAGE)) { granted ->
                if (granted.values.all { it }) perform() else result.error("permission", "Storage permission denied", null)
            }
        } else {
            perform()
        }
    }

    /** Lets the user pick a destination with the Storage Access Framework and copies the file there. */
    private fun saveCopy(call: MethodCall, result: MethodChannel.Result) {
        val source = fileUri(call) ?: return result.success(false)
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = call.argument<String>("mimeType") ?: "application/octet-stream"
            putExtra(Intent.EXTRA_TITLE, call.argument<String>("fileName") ?: "download")
        }
        val launched = host.startForResult(intent) { code, data ->
            val target = data?.data
            if (code != Activity.RESULT_OK || target == null) {
                result.success(false)
                return@startForResult
            }
            background(result) {
                val resolver = context.contentResolver
                val input = resolver.openInputStream(source) ?: throw IOException("source")
                input.use { inp ->
                    val output = resolver.openOutputStream(target, "w") ?: throw IOException("target")
                    output.use { inp.copyTo(it, 64 * 1024) }
                }
                true
            }
        }
        if (!launched) result.success(false)
    }

    companion object {
        const val CHANNEL = "saif/system"
    }
}
