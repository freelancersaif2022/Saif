package com.beam.share.ui.components

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/** Expanding rings plus a slow sweep, used while looking for / waiting for phones. */
@Composable
fun RadarPulse(
    modifier: Modifier = Modifier,
    color: Color = MaterialTheme.colorScheme.primary,
    active: Boolean = true,
) {
    val transition = rememberInfiniteTransition(label = "radar")
    val pulse by transition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(tween(2600, easing = LinearEasing)),
        label = "pulse",
    )
    val sweep by transition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(tween(4200, easing = LinearEasing)),
        label = "sweep",
    )
    Canvas(modifier) {
        val maxR = size.minDimension / 2f
        val center = Offset(size.width / 2f, size.height / 2f)
        // Static guide rings
        listOf(0.36f, 0.68f, 1f).forEachIndexed { i, f ->
            drawCircle(color.copy(alpha = 0.05f + 0.03f * (2 - i)), radius = maxR * f, center = center)
            drawCircle(color.copy(alpha = 0.16f), radius = maxR * f, center = center, style = Stroke(1.dp.toPx()))
        }
        if (!active) return@Canvas
        // Sweep
        rotate(sweep, center) {
            drawArc(
                brush = Brush.sweepGradient(
                    0f to Color.Transparent,
                    0.85f to Color.Transparent,
                    1f to color.copy(alpha = 0.22f),
                    center = center,
                ),
                startAngle = 0f,
                sweepAngle = 360f,
                useCenter = true,
                topLeft = Offset(center.x - maxR, center.y - maxR),
                size = Size(maxR * 2, maxR * 2),
            )
        }
        // Expanding pulses
        repeat(3) { i ->
            val p = (pulse + i / 3f) % 1f
            drawCircle(
                color = color.copy(alpha = (1f - p) * 0.45f),
                radius = maxR * (0.28f + 0.72f * p),
                center = center,
                style = Stroke(width = (2.5f * (1f - p) + 0.5f).dp.toPx()),
            )
        }
    }
}

/** Circular progress with a rounded cap. */
@Composable
fun ProgressRing(
    progress: Float,
    modifier: Modifier = Modifier,
    strokeWidth: Dp = 14.dp,
    color: Color = MaterialTheme.colorScheme.primary,
    trackColor: Color = MaterialTheme.colorScheme.surfaceContainerHighest,
) {
    val animated by animateFloatAsState(progress.coerceIn(0f, 1f), tween(450), label = "ring")
    Canvas(modifier) {
        val sw = strokeWidth.toPx()
        val arcSize = Size(size.width - sw, size.height - sw)
        val topLeft = Offset(sw / 2, sw / 2)
        drawArc(trackColor, 0f, 360f, false, topLeft = topLeft, size = arcSize, style = Stroke(sw))
        if (animated > 0f) {
            drawArc(
                color, -90f, 360f * animated, false,
                topLeft = topLeft, size = arcSize, style = Stroke(sw, cap = StrokeCap.Round),
            )
        }
    }
}

/** Small spinning arc for "connecting" states. */
@Composable
fun Spinner(modifier: Modifier = Modifier, color: Color = MaterialTheme.colorScheme.primary, strokeWidth: Dp = 6.dp) {
    val transition = rememberInfiniteTransition(label = "spin")
    val angle by transition.animateFloat(0f, 360f, infiniteRepeatable(tween(1100, easing = LinearEasing)), label = "a")
    val sweep by transition.animateFloat(
        40f, 200f,
        infiniteRepeatable(tween(900), repeatMode = RepeatMode.Reverse),
        label = "s",
    )
    Canvas(modifier.graphicsLayer { rotationZ = angle }) {
        val sw = strokeWidth.toPx()
        drawArc(
            color, 0f, sweep, false,
            topLeft = Offset(sw / 2, sw / 2), size = Size(size.width - sw, size.height - sw),
            style = Stroke(sw, cap = StrokeCap.Round),
        )
    }
}

/** Blinking "live" dot. */
@Composable
fun LiveDot(color: Color, modifier: Modifier = Modifier, size: Dp = 8.dp) {
    val transition = rememberInfiniteTransition(label = "dot")
    val alpha by transition.animateFloat(1f, 0.25f, infiniteRepeatable(tween(900), RepeatMode.Reverse), label = "al")
    Box(modifier.size(size).graphicsLayer { this.alpha = alpha }.clip(CircleShape).background(color))
}
