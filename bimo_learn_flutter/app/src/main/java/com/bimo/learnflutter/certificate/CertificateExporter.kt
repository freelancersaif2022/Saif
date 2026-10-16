package com.bimo.learnflutter.certificate

import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.pdf.PdfDocument
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.content.FileProvider
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.io.OutputStream
import javax.inject.Inject
import javax.inject.Singleton

sealed interface ExportResult {
    data class Saved(val location: String, val uri: Uri) : ExportResult
    data class Failed(val message: String) : ExportResult
}

/**
 * Writes certificates as PDF (A4 landscape) or PNG and prepares share intents. No storage
 * permission is needed: API 29+ uses MediaStore, older versions use app-specific external storage.
 */
@Singleton
class CertificateExporter @Inject constructor(
    @ApplicationContext private val context: Context,
) {
    private val authority = "${context.packageName}.fileprovider"

    /** A4 landscape in PostScript points. */
    private val pdfWidth = 842
    private val pdfHeight = 595

    fun writePdf(data: CertificateData, out: OutputStream) {
        val document = PdfDocument()
        try {
            val page = document.startPage(PdfDocument.PageInfo.Builder(pdfWidth, pdfHeight, 1).create())
            val canvas = page.canvas
            canvas.scale(pdfWidth / CertificateRenderer.WIDTH.toFloat(), pdfHeight / CertificateRenderer.HEIGHT.toFloat())
            CertificateRenderer.draw(canvas, data)
            document.finishPage(page)
            document.writeTo(out)
        } finally {
            document.close()
        }
    }

    fun writePng(data: CertificateData, out: OutputStream) {
        val bitmap = CertificateRenderer.renderBitmap(data)
        try {
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
        } finally {
            bitmap.recycle()
        }
    }

    private fun fileName(data: CertificateData, ext: String) = "Bimo-Certificate-${data.certificateId}.$ext"

    suspend fun savePdf(data: CertificateData): ExportResult = save(
        data, "pdf", "application/pdf",
        collection = { if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) MediaStore.Downloads.EXTERNAL_CONTENT_URI else null },
        relativeDir = "${Environment.DIRECTORY_DOWNLOADS}/Bimo",
        legacyDir = Environment.DIRECTORY_DOCUMENTS,
    ) { writePdf(data, it) }

    suspend fun saveImage(data: CertificateData): ExportResult = save(
        data, "png", "image/png",
        collection = { if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) MediaStore.Images.Media.EXTERNAL_CONTENT_URI else null },
        relativeDir = "${Environment.DIRECTORY_PICTURES}/Bimo",
        legacyDir = Environment.DIRECTORY_PICTURES,
    ) { writePng(data, it) }

    private suspend fun save(
        data: CertificateData,
        ext: String,
        mime: String,
        collection: () -> Uri?,
        relativeDir: String,
        legacyDir: String,
        writer: (OutputStream) -> Unit,
    ): ExportResult = withContext(Dispatchers.IO) {
        try {
            val target = collection()
            if (target != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val values = ContentValues().apply {
                    put(MediaStore.MediaColumns.DISPLAY_NAME, fileName(data, ext))
                    put(MediaStore.MediaColumns.MIME_TYPE, mime)
                    put(MediaStore.MediaColumns.RELATIVE_PATH, relativeDir)
                    put(MediaStore.MediaColumns.IS_PENDING, 1)
                }
                val resolver = context.contentResolver
                val uri = resolver.insert(target, values) ?: return@withContext ExportResult.Failed("Could not create the file.")
                resolver.openOutputStream(uri)?.use(writer) ?: return@withContext ExportResult.Failed("Could not open the file.")
                values.clear()
                values.put(MediaStore.MediaColumns.IS_PENDING, 0)
                resolver.update(uri, values, null, null)
                ExportResult.Saved("$relativeDir/${fileName(data, ext)}", uri)
            } else {
                val dir = context.getExternalFilesDir(legacyDir) ?: context.filesDir
                val file = File(dir, fileName(data, ext))
                file.outputStream().use(writer)
                ExportResult.Saved(file.absolutePath, FileProvider.getUriForFile(context, authority, file))
            }
        } catch (e: Exception) {
            ExportResult.Failed(e.message ?: "Export failed.")
        }
    }

    /** Writes a temporary copy to the cache and returns a share intent for it. */
    suspend fun shareIntent(data: CertificateData, asPdf: Boolean): Intent = withContext(Dispatchers.IO) {
        val dir = File(context.cacheDir, "shared").apply { mkdirs() }
        val ext = if (asPdf) "pdf" else "png"
        val file = File(dir, fileName(data, ext))
        file.outputStream().use { if (asPdf) writePdf(data, it) else writePng(data, it) }
        val uri = FileProvider.getUriForFile(context, authority, file)
        val send = Intent(Intent.ACTION_SEND).apply {
            type = if (asPdf) "application/pdf" else "image/png"
            putExtra(Intent.EXTRA_STREAM, uri)
            putExtra(
                Intent.EXTRA_TEXT,
                "I completed “${data.courseTitle}” on Bimo – Learn Flutter! Certificate ID: ${data.certificateId}",
            )
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        Intent.createChooser(send, "Share certificate").addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
    }
}
