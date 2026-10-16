package com.bimo.learnflutter.certificate

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RadialGradient
import android.graphics.RectF
import android.graphics.Shader
import android.graphics.Typeface
import com.bimo.learnflutter.core.domain.CertificateRules
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Locale

data class CertificateData(
    val certificateId: String,
    val learnerName: String,
    val courseTitle: String,
    val issuedAtMillis: Long,
    val finalScore: Int,
)

/**
 * Draws the certificate onto any [Canvas] in a 2000 × 1414 coordinate space (A-series landscape
 * ratio). The same drawing code is used for the on-screen preview, PNG export and PDF export, so
 * all three are pixel-identical.
 */
object CertificateRenderer {
    const val WIDTH = 2000
    const val HEIGHT = 1414

    private val VIOLET = Color.parseColor("#6750F5")
    private val CYAN = Color.parseColor("#03B6D4")
    private val LIME = Color.parseColor("#B9F34C")
    private val GOLD = Color.parseColor("#C9A227")
    private val GOLD_DARK = Color.parseColor("#9C7A12")
    private val INK = Color.parseColor("#1D1B2E")
    private val MUTED = Color.parseColor("#5D5A72")

    fun formattedDate(millis: Long): String =
        DateTimeFormatter.ofPattern("d MMMM yyyy", Locale.ENGLISH)
            .format(Instant.ofEpochMilli(millis).atZone(ZoneId.systemDefault()))

    fun renderBitmap(data: CertificateData, scale: Float = 1f): Bitmap {
        val bitmap = Bitmap.createBitmap((WIDTH * scale).toInt(), (HEIGHT * scale).toInt(), Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        canvas.scale(scale, scale)
        draw(canvas, data)
        return bitmap
    }

    fun draw(canvas: Canvas, data: CertificateData) {
        val w = WIDTH.toFloat()
        val h = HEIGHT.toFloat()
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)

        // Paper
        paint.shader = LinearGradient(0f, 0f, w, h, Color.parseColor("#FFFDF7"), Color.parseColor("#F4EEDC"), Shader.TileMode.CLAMP)
        canvas.drawRect(0f, 0f, w, h, paint)
        paint.shader = null

        // Subtle guilloche-like background rings
        paint.style = Paint.Style.STROKE
        paint.strokeWidth = 1.5f
        paint.color = Color.argb(18, 103, 80, 245)
        for (i in 0 until 26) canvas.drawCircle(w / 2, h / 2 + 40, 160f + i * 26f, paint)

        // Borders
        paint.strokeWidth = 26f
        paint.shader = LinearGradient(0f, 0f, w, h, VIOLET, CYAN, Shader.TileMode.CLAMP)
        canvas.drawRoundRect(RectF(40f, 40f, w - 40f, h - 40f), 28f, 28f, paint)
        paint.shader = null
        paint.strokeWidth = 4f
        paint.color = GOLD
        canvas.drawRoundRect(RectF(84f, 84f, w - 84f, h - 84f), 18f, 18f, paint)
        paint.strokeWidth = 1.5f
        canvas.drawRoundRect(RectF(100f, 100f, w - 100f, h - 100f), 14f, 14f, paint)

        // Corner ornaments
        paint.style = Paint.Style.FILL
        listOf(84f to 84f, w - 84f to 84f, 84f to h - 84f, w - 84f to h - 84f).forEach { (x, y) ->
            val d = Path().apply {
                moveTo(x, y - 22f); lineTo(x + 22f, y); lineTo(x, y + 22f); lineTo(x - 22f, y); close()
            }
            paint.color = GOLD
            canvas.drawPath(d, paint)
            paint.color = Color.WHITE
            canvas.drawCircle(x, y, 6f, paint)
        }

        drawLogo(canvas, w / 2 - 70f, 150f, 140f)

        val text = Paint(Paint.ANTI_ALIAS_FLAG).apply { textAlign = Paint.Align.CENTER; color = INK }
        val serif = Typeface.create(Typeface.SERIF, Typeface.NORMAL)
        val serifBold = Typeface.create(Typeface.SERIF, Typeface.BOLD)
        val serifItalic = Typeface.create(Typeface.SERIF, Typeface.ITALIC)
        val serifBoldItalic = Typeface.create(Typeface.SERIF, Typeface.BOLD_ITALIC)
        val sans = Typeface.create(Typeface.SANS_SERIF, Typeface.NORMAL)
        val sansBold = Typeface.create(Typeface.SANS_SERIF, Typeface.BOLD)

        text.typeface = serifBold
        text.textSize = 70f
        text.letterSpacing = 0.12f
        text.color = INK
        canvas.drawText("BIMO — CERTIFICATE OF COMPLETION", w / 2, 380f, text)
        text.letterSpacing = 0f

        // Gold divider with diamond
        paint.color = GOLD
        canvas.drawRect(w / 2 - 360f, 420f, w / 2 - 24f, 424f, paint)
        canvas.drawRect(w / 2 + 24f, 420f, w / 2 + 360f, 424f, paint)
        canvas.drawPath(Path().apply {
            moveTo(w / 2, 408f); lineTo(w / 2 + 14f, 422f); lineTo(w / 2, 436f); lineTo(w / 2 - 14f, 422f); close()
        }, paint)

        text.typeface = serifItalic
        text.textSize = 40f
        text.color = MUTED
        canvas.drawText("This is to certify that", w / 2, 510f, text)

        text.typeface = serifBoldItalic
        text.color = VIOLET
        text.textSize = fitTextSize(text, data.learnerName, 112f, 1300f)
        canvas.drawText(data.learnerName, w / 2, 650f, text)
        paint.color = INK
        canvas.drawRect(w / 2 - 520f, 680f, w / 2 + 520f, 683f, paint)

        text.typeface = serifItalic
        text.textSize = 40f
        text.color = MUTED
        canvas.drawText("has successfully completed the Bimo course", w / 2, 760f, text)

        text.typeface = serifBold
        text.textSize = 66f
        text.color = INK
        canvas.drawText(data.courseTitle, w / 2, 850f, text)

        text.typeface = sans
        text.textSize = 30f
        text.color = MUTED
        canvas.drawText(
            "Dart programming • Flutter development • 15 real-world projects • Final assessment",
            w / 2, 905f, text,
        )

        // Details row
        val columns = listOf(
            "COMPLETION DATE" to formattedDate(data.issuedAtMillis),
            "FINAL SCORE" to "${data.finalScore}%",
            "CERTIFICATE ID" to data.certificateId,
        )
        val colWidth = 520f
        val startX = w / 2 - colWidth
        columns.forEachIndexed { index, (label, value) ->
            val cx = startX + index * colWidth
            text.typeface = sansBold
            text.textSize = 24f
            text.letterSpacing = 0.15f
            text.color = GOLD_DARK
            canvas.drawText(label, cx, 1000f, text)
            text.letterSpacing = 0f
            text.typeface = serifBold
            text.textSize = if (index == 2) 32f else 40f
            text.color = INK
            canvas.drawText(value, cx, 1050f, text)
        }

        // Signature (left) and seal (right)
        val sigX = 470f
        text.typeface = serifBoldItalic
        text.textSize = 76f
        text.color = Color.parseColor("#26206B")
        canvas.drawText(CertificateRules.SIGNATORY, sigX, 1190f, text)
        paint.color = INK
        canvas.drawRect(sigX - 220f, 1212f, sigX + 220f, 1215f, paint)
        text.typeface = sansBold
        text.textSize = 26f
        text.color = INK
        canvas.drawText("Authorized Signature", sigX, 1252f, text)
        text.typeface = sans
        text.textSize = 24f
        text.color = MUTED
        canvas.drawText("Saif A, Founder — Bimo", sigX, 1286f, text)

        drawSeal(canvas, w - 470f, 1180f, 120f)

        // Verification + disclaimer
        text.typeface = sans
        text.textSize = 22f
        text.color = MUTED
        canvas.drawText(
            "Verify: open Bimo ▸ Profile ▸ Certificates ▸ Verify and enter ${data.certificateId}",
            w / 2, 1310f, text,
        )
        text.textSize = 19f
        canvas.drawText(CertificateRules.DISCLAIMER, w / 2, 1344f, text)
    }

    private fun fitTextSize(paint: Paint, value: String, max: Float, maxWidth: Float): Float {
        var size = max
        paint.textSize = size
        while (paint.measureText(value) > maxWidth && size > 40f) {
            size -= 4f
            paint.textSize = size
        }
        return size
    }

    /** Bimo logo: a rounded gradient tile with the "B" glyph and a lime spark, matching the launcher icon. */
    fun drawLogo(canvas: Canvas, left: Float, top: Float, size: Float) {
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        paint.shader = LinearGradient(left, top, left + size, top + size, VIOLET, CYAN, Shader.TileMode.CLAMP)
        canvas.drawRoundRect(RectF(left, top, left + size, top + size), size * 0.28f, size * 0.28f, paint)
        paint.shader = null
        val s = size / 108f
        canvas.save()
        canvas.translate(left, top)
        canvas.scale(s, s)
        paint.color = Color.WHITE
        canvas.drawPath(glyphPath(), paint)
        paint.color = LIME
        canvas.drawCircle(76f, 34f, 5f, paint)
        canvas.restore()
    }

    /** The "B" glyph in a 108 × 108 viewport (same geometry as ic_launcher_foreground.xml). */
    fun glyphPath(): Path = Path().apply {
        fillType = Path.FillType.EVEN_ODD
        moveTo(36f, 30f); lineTo(60f, 30f)
        arcTo(RectF(49f, 30f, 71f, 52f), -90f, 180f, false)
        lineTo(63f, 52f)
        arcTo(RectF(50f, 52f, 76f, 78f), -90f, 180f, false)
        lineTo(36f, 78f); close()
        moveTo(46f, 38f); lineTo(59f, 38f)
        arcTo(RectF(56f, 38f, 62f, 44f), -90f, 180f, false)
        lineTo(46f, 44f); close()
        moveTo(46f, 60f); lineTo(62f, 60f)
        arcTo(RectF(57f, 60f, 67f, 70f), -90f, 180f, false)
        lineTo(46f, 70f); close()
    }

    private fun drawSeal(canvas: Canvas, cx: Float, cy: Float, r: Float) {
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        // Ribbon tails
        paint.color = VIOLET
        canvas.drawPath(Path().apply {
            moveTo(cx - 60f, cy + 60f); lineTo(cx - 100f, cy + 190f); lineTo(cx - 62f, cy + 165f)
            lineTo(cx - 40f, cy + 200f); lineTo(cx - 10f, cy + 80f); close()
        }, paint)
        paint.color = CYAN
        canvas.drawPath(Path().apply {
            moveTo(cx + 60f, cy + 60f); lineTo(cx + 100f, cy + 190f); lineTo(cx + 62f, cy + 165f)
            lineTo(cx + 40f, cy + 200f); lineTo(cx + 10f, cy + 80f); close()
        }, paint)
        // Scalloped gold disc
        val star = Path()
        val points = 36
        for (i in 0 until points * 2) {
            val radius = if (i % 2 == 0) r else r * 0.9f
            val angle = Math.PI * i / points
            val x = cx + (radius * Math.cos(angle)).toFloat()
            val y = cy + (radius * Math.sin(angle)).toFloat()
            if (i == 0) star.moveTo(x, y) else star.lineTo(x, y)
        }
        star.close()
        paint.shader = RadialGradient(cx - r / 3, cy - r / 3, r * 1.4f, Color.parseColor("#F5D976"), GOLD_DARK, Shader.TileMode.CLAMP)
        canvas.drawPath(star, paint)
        paint.shader = null
        paint.style = Paint.Style.STROKE
        paint.strokeWidth = 3f
        paint.color = Color.parseColor("#FFF4C2")
        canvas.drawCircle(cx, cy, r * 0.72f, paint)
        paint.style = Paint.Style.FILL
        val text = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            textAlign = Paint.Align.CENTER
            color = Color.parseColor("#4A3A05")
            typeface = Typeface.create(Typeface.SERIF, Typeface.BOLD)
        }
        text.textSize = 40f
        canvas.drawText("BIMO", cx, cy + 4f, text)
        text.textSize = 17f
        text.letterSpacing = 0.12f
        canvas.drawText("COURSE COMPLETE", cx, cy + 34f, text)
        text.textSize = 18f
        canvas.drawText("★ ★ ★", cx, cy - 36f, text)
    }
}
