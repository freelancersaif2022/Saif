package com.saif.browser.downloads

import android.app.DownloadManager
import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.webkit.CookieManager

/**
 * Thin wrapper over the system [DownloadManager]. The OS performs the
 * transfer, shows its notification and keeps going when the app is in the
 * background; the app only polls status while its UI is visible.
 */
class DownloadHelper(private val context: Context) {
    private val manager: DownloadManager =
        context.getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager

    fun enqueue(
        url: String,
        fileName: String,
        mimeType: String?,
        userAgent: String?,
        referer: String?,
        cookies: CookieManager?,
    ): Long {
        val uri = Uri.parse(url)
        val scheme = uri.scheme?.lowercase()
        require(scheme == "http" || scheme == "https") { "Only HTTP(S) downloads are supported" }
        val request = DownloadManager.Request(uri).apply {
            if (!mimeType.isNullOrBlank()) setMimeType(mimeType)
            cookies?.getCookie(url)?.let { addRequestHeader("Cookie", it) }
            if (!userAgent.isNullOrBlank()) addRequestHeader("User-Agent", userAgent)
            if (!referer.isNullOrBlank()) addRequestHeader("Referer", referer)
            setTitle(fileName)
            setDescription(uri.host ?: "")
            setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
            setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, fileName)
            setAllowedOverMetered(true)
            setAllowedOverRoaming(true)
        }
        return manager.enqueue(request)
    }

    fun query(ids: LongArray): List<Map<String, Any?>> {
        if (ids.isEmpty()) return emptyList()
        val results = ArrayList<Map<String, Any?>>()
        manager.query(DownloadManager.Query().setFilterById(*ids))?.use { cursor ->
            val idCol = cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_ID)
            val statusCol = cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_STATUS)
            val bytesCol = cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_BYTES_DOWNLOADED_SO_FAR)
            val totalCol = cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_TOTAL_SIZE_BYTES)
            val reasonCol = cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_REASON)
            val localUriCol = cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_LOCAL_URI)
            while (cursor.moveToNext()) {
                val status = when (cursor.getInt(statusCol)) {
                    DownloadManager.STATUS_PENDING -> "pending"
                    DownloadManager.STATUS_RUNNING -> "running"
                    DownloadManager.STATUS_PAUSED -> "paused"
                    DownloadManager.STATUS_SUCCESSFUL -> "completed"
                    else -> "failed"
                }
                results.add(
                    mapOf(
                        "id" to cursor.getLong(idCol),
                        "status" to status,
                        "received" to cursor.getLong(bytesCol),
                        "total" to cursor.getLong(totalCol),
                        "reason" to cursor.getInt(reasonCol),
                        "localUri" to cursor.getString(localUriCol),
                    ),
                )
            }
        }
        val found = results.map { it["id"] as Long }.toSet()
        // Entries removed from the system (e.g. cleared by the user) are reported as missing.
        ids.filterNot(found::contains).forEach {
            results.add(mapOf("id" to it, "status" to "missing"))
        }
        return results
    }

    fun remove(id: Long): Int = manager.remove(id)

    fun contentUri(id: Long): Uri? = manager.getUriForDownloadedFile(id)

    fun mimeType(id: Long): String? = manager.getMimeTypeForDownloadedFile(id)

    companion object {
        /** Public-storage writes need WRITE_EXTERNAL_STORAGE only up to Android 9. */
        fun needsLegacyStoragePermission(): Boolean = Build.VERSION.SDK_INT <= Build.VERSION_CODES.P
    }
}
