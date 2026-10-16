package com.bimo.learnflutter.ui.components

import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.graphics.drawscope.translate
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import com.bimo.learnflutter.ui.theme.LocalReduceMotion

private val Violet = Color(0xFF6750F5)
private val Cyan = Color(0xFF03B6D4)
private val Lime = Color(0xFFB9F34C)
private val Gold = Color(0xFFE0B84A)
private val Coral = Color(0xFFFF7A7A)
private val Ink = Color(0xFF1D1B2E)

/**
 * Vector illustrations for the four onboarding pages, drawn with Canvas so they stay crisp on
 * every screen density and add nothing to the APK size. They float gently unless reduced motion is on.
 */
@Composable
fun OnboardingIllustration(page: Int, modifier: Modifier = Modifier) {
    val reduceMotion = LocalReduceMotion.current
    val transition = rememberInfiniteTransition(label = "float")
    val floatAnim by transition.animateFloat(
        initialValue = 0f, targetValue = 1f,
        animationSpec = infiniteRepeatable(tween(2400), RepeatMode.Reverse), label = "floatValue",
    )
    val float = if (reduceMotion) 0.5f else floatAnim
    val description = when (page) {
        0 -> "Illustration of a phone showing Dart and Flutter code"
        1 -> "Illustration of an open book with code examples"
        2 -> "Illustration of a quiz card with correct answers"
        else -> "Illustration of a certificate with a gold seal"
    }
    Canvas(modifier.semantics { contentDescription = description }) {
        drawBackdrop(float)
        when (page) {
            0 -> drawPhone(float)
            1 -> drawBook(float)
            2 -> drawQuiz(float)
            else -> drawCertificate(float)
        }
    }
}

private fun DrawScope.drawBackdrop(f: Float) {
    val c = center
    val r = size.minDimension * 0.42f
    drawCircle(Brush.radialGradient(listOf(Violet.copy(alpha = 0.22f), Color.Transparent), c, r * 1.3f), r * 1.3f, c)
    drawCircle(Cyan.copy(alpha = 0.18f), r * 0.16f, Offset(c.x - r * 0.95f, c.y - r * 0.7f + f * 10f))
    drawCircle(Lime.copy(alpha = 0.5f), r * 0.07f, Offset(c.x + r * 0.95f, c.y - r * 0.85f - f * 8f))
    drawCircle(Violet.copy(alpha = 0.25f), r * 0.1f, Offset(c.x + r * 0.9f, c.y + r * 0.85f + f * 6f))
}

private fun DrawScope.drawPhone(f: Float) {
    val w = size.minDimension * 0.42f
    val h = w * 1.85f
    val left = center.x - w / 2
    val top = center.y - h / 2 + (f - 0.5f) * 12f
    drawRoundRect(Ink, Offset(left, top), Size(w, h), CornerRadius(w * 0.16f))
    val pad = w * 0.06f
    drawRoundRect(
        Brush.verticalGradient(listOf(Color(0xFF232742), Color(0xFF151827)), startY = top, endY = top + h),
        Offset(left + pad, top + pad), Size(w - 2 * pad, h - 2 * pad), CornerRadius(w * 0.11f),
    )
    // code lines
    val colors = listOf(Violet, Cyan, Lime, Gold, Cyan, Violet, Coral, Lime)
    val widths = listOf(0.55f, 0.75f, 0.4f, 0.65f, 0.5f, 0.7f, 0.35f, 0.6f)
    for (i in colors.indices) {
        val y = top + pad * 3 + i * h * 0.075f
        val indent = if (i in 2..5) w * 0.1f else 0f
        drawRoundRect(colors[i], Offset(left + pad * 2.2f + indent, y), Size((w - pad * 5) * widths[i], h * 0.03f), CornerRadius(20f))
    }
    // Floating Dart-like diamond + Flutter-like chevron
    translate(center.x + w * 0.62f, top + h * 0.22f - f * 10f) {
        rotate(45f, Offset.Zero) {
            drawRoundRect(Brush.linearGradient(listOf(Cyan, Violet)), Offset(-w * 0.13f, -w * 0.13f), Size(w * 0.26f, w * 0.26f), CornerRadius(14f))
        }
    }
    val chevron = Path().apply {
        val x = center.x - w * 0.72f
        val y = top + h * 0.72f + f * 8f
        moveTo(x, y); lineTo(x + w * 0.22f, y - w * 0.22f); lineTo(x + w * 0.34f, y - w * 0.22f); lineTo(x + w * 0.12f, y); close()
        moveTo(x + w * 0.12f, y); lineTo(x + w * 0.34f, y + w * 0.22f); lineTo(x + w * 0.22f, y + w * 0.22f); lineTo(x, y); close()
    }
    drawPath(chevron, Violet)
}

private fun DrawScope.drawBook(f: Float) {
    val w = size.minDimension * 0.78f
    val h = w * 0.55f
    val left = center.x - w / 2
    val top = center.y - h / 2 + (f - 0.5f) * 10f
    // pages
    drawRoundRect(Violet, Offset(left - 8f, top + 10f), Size(w + 16f, h + 6f), CornerRadius(24f))
    drawRoundRect(Color.White, Offset(left, top), Size(w / 2 - 4f, h), CornerRadius(18f))
    drawRoundRect(Color.White, Offset(center.x + 4f, top), Size(w / 2 - 4f, h), CornerRadius(18f))
    for (i in 0 until 6) {
        val y = top + h * 0.15f + i * h * 0.12f
        drawRoundRect(Color(0xFFD9DBE8), Offset(left + w * 0.05f, y), Size(w * (0.3f + (i % 3) * 0.04f), h * 0.04f), CornerRadius(10f))
    }
    // code on right page
    drawRoundRect(Color(0xFF151827), Offset(center.x + w * 0.05f, top + h * 0.12f), Size(w * 0.38f, h * 0.76f), CornerRadius(14f))
    val colors = listOf(Violet, Cyan, Lime, Gold, Cyan)
    colors.forEachIndexed { i, c ->
        drawRoundRect(c, Offset(center.x + w * 0.09f + (if (i in 1..3) w * 0.03f else 0f), top + h * 0.2f + i * h * 0.12f),
            Size(w * (0.14f + (i % 2) * 0.1f), h * 0.045f), CornerRadius(10f))
    }
    // bookmark
    val bm = Path().apply {
        val x = left + w * 0.38f
        moveTo(x, top - 6f); lineTo(x + 28f, top - 6f); lineTo(x + 28f, top + h * 0.35f); lineTo(x + 14f, top + h * 0.28f); lineTo(x, top + h * 0.35f); close()
    }
    drawPath(bm, Lime)
    // spark
    drawSpark(Offset(center.x + w * 0.52f, top - 10f - f * 12f), 26f, Gold)
}

private fun DrawScope.drawQuiz(f: Float) {
    val w = size.minDimension * 0.62f
    val h = w * 1.05f
    val left = center.x - w / 2
    val top = center.y - h / 2 + (f - 0.5f) * 10f
    drawRoundRect(Violet.copy(alpha = 0.25f), Offset(left + 22f, top + 22f), Size(w, h), CornerRadius(36f))
    drawRoundRect(Color.White, Offset(left, top), Size(w, h), CornerRadius(36f))
    drawRoundRect(Brush.linearGradient(listOf(Violet, Cyan)), Offset(left, top), Size(w, h * 0.2f), CornerRadius(36f))
    drawRect(Cyan.copy(alpha = 0f), Offset(left, top + h * 0.12f), Size(w, h * 0.08f))
    val rowH = h * 0.15f
    val states = listOf(true, false, true, true)
    states.forEachIndexed { i, ok ->
        val y = top + h * 0.27f + i * (rowH + h * 0.03f)
        val color = if (i == 2) Color(0xFF22A06B) else Color(0xFFEDEEF6)
        drawRoundRect(color.copy(alpha = if (i == 2) 0.18f else 1f), Offset(left + w * 0.07f, y), Size(w * 0.86f, rowH), CornerRadius(20f))
        drawCircle(if (i == 2) Color(0xFF22A06B) else Color(0xFFC9CCDD), rowH * 0.22f, Offset(left + w * 0.16f, y + rowH / 2))
        drawRoundRect(Color(0xFFB9BDD3), Offset(left + w * 0.27f, y + rowH * 0.4f), Size(w * (if (ok) 0.45f else 0.35f), rowH * 0.2f), CornerRadius(8f))
    }
    // big check badge
    val c = Offset(left + w * 0.95f, top + h * 0.05f - f * 10f)
    drawCircle(Lime, w * 0.14f, c)
    val check = Path().apply {
        moveTo(c.x - w * 0.06f, c.y)
        lineTo(c.x - w * 0.015f, c.y + w * 0.045f)
        lineTo(c.x + w * 0.065f, c.y - w * 0.045f)
    }
    drawPath(check, Ink, style = Stroke(width = w * 0.03f, cap = StrokeCap.Round))
}

private fun DrawScope.drawCertificate(f: Float) {
    val w = size.minDimension * 0.86f
    val h = w * 0.66f
    val left = center.x - w / 2
    val top = center.y - h / 2 + (f - 0.5f) * 8f
    drawRoundRect(Color(0xFFFFFDF7), Offset(left, top), Size(w, h), CornerRadius(20f))
    drawRoundRect(Brush.linearGradient(listOf(Violet, Cyan)), Offset(left, top), Size(w, h), CornerRadius(20f), style = Stroke(10f))
    drawRoundRect(Gold, Offset(left + 22f, top + 22f), Size(w - 44f, h - 44f), CornerRadius(12f), style = Stroke(3f))
    drawRoundRect(Ink.copy(alpha = 0.8f), Offset(center.x - w * 0.28f, top + h * 0.18f), Size(w * 0.56f, h * 0.07f), CornerRadius(10f))
    drawRoundRect(Violet, Offset(center.x - w * 0.22f, top + h * 0.36f), Size(w * 0.44f, h * 0.09f), CornerRadius(10f))
    drawRoundRect(Color(0xFFC9CCDD), Offset(center.x - w * 0.32f, top + h * 0.54f), Size(w * 0.64f, h * 0.04f), CornerRadius(8f))
    drawRoundRect(Color(0xFFC9CCDD), Offset(center.x - w * 0.24f, top + h * 0.63f), Size(w * 0.48f, h * 0.04f), CornerRadius(8f))
    // seal with ribbons
    val sc = Offset(left + w * 0.82f, top + h * 0.82f)
    drawPath(Path().apply {
        moveTo(sc.x - 24f, sc.y); lineTo(sc.x - 44f, sc.y + 80f); lineTo(sc.x - 20f, sc.y + 66f); lineTo(sc.x - 6f, sc.y + 90f); lineTo(sc.x, sc.y); close()
    }, Violet)
    drawPath(Path().apply {
        moveTo(sc.x + 24f, sc.y); lineTo(sc.x + 44f, sc.y + 80f); lineTo(sc.x + 20f, sc.y + 66f); lineTo(sc.x + 6f, sc.y + 90f); lineTo(sc.x, sc.y); close()
    }, Cyan)
    drawCircle(Brush.radialGradient(listOf(Color(0xFFF5D976), Color(0xFF9C7A12)), sc, w * 0.11f), w * 0.1f, sc)
    drawSpark(sc, w * 0.04f, Color(0xFFFFF4C2))
    drawSpark(Offset(left + w * 0.08f, top - 20f - f * 14f), 30f, Lime)
}

private fun DrawScope.drawSpark(c: Offset, r: Float, color: Color) {
    val p = Path().apply {
        moveTo(c.x, c.y - r)
        quadraticBezierTo(c.x, c.y, c.x + r, c.y)
        quadraticBezierTo(c.x, c.y, c.x, c.y + r)
        quadraticBezierTo(c.x, c.y, c.x - r, c.y)
        quadraticBezierTo(c.x, c.y, c.x, c.y - r)
        close()
    }
    drawPath(p, color)
}
