package com.beam.share.model

import android.net.Uri
import android.webkit.MimeTypeMap

enum class FileKind {
    IMAGE, VIDEO, AUDIO, APP, DOCUMENT, ARCHIVE, OTHER;

    companion object {
        const val APK_MIME = "application/vnd.android.package-archive"

        private val archiveExt = setOf("zip", "rar", "7z", "tar", "gz", "tgz", "bz2", "xz")
        private val docExt = setOf(
            "pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "txt", "csv", "rtf",
            "odt", "ods", "odp", "md", "json", "xml", "html", "epub"
        )

        fun from(mime: String?, name: String): FileKind {
            val m = mime?.lowercase().orEmpty()
            val ext = name.substringAfterLast('.', "").lowercase()
            return when {
                m.startsWith("image/") -> IMAGE
                m.startsWith("video/") -> VIDEO
                m.startsWith("audio/") -> AUDIO
                m == APK_MIME || ext == "apk" -> APP
                ext in archiveExt || m.contains("zip") || m.contains("compressed") -> ARCHIVE
                m.startsWith("text/") || m == "application/pdf" || ext in docExt ||
                    m.contains("document") || m.contains("msword") ||
                    m.contains("sheet") || m.contains("presentation") -> DOCUMENT
                else -> OTHER
            }
        }

        fun mimeFromName(name: String): String {
            val ext = name.substringAfterLast('.', "").lowercase()
            if (ext == "apk") return APK_MIME
            return MimeTypeMap.getSingleton().getMimeTypeFromExtension(ext)
                ?: "application/octet-stream"
        }
    }
}

/** A file the user picked to send. */
data class ShareItem(
    val uri: Uri,
    val name: String,
    val size: Long,
    val mime: String,
    val kind: FileKind,
    /** Set for installed apps so the picker / lists can show the app icon. */
    val packageName: String? = null,
) {
    val key: String get() = uri.toString()
}
