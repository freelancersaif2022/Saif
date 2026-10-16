package com.bimo.learnflutter.ui.components

import android.media.AudioManager
import android.media.ToneGenerator
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.rotate
import com.bimo.learnflutter.ui.theme.LocalReduceMotion
import com.bimo.learnflutter.ui.theme.LocalSoundEnabled
import kotlin.math.sin
import kotlin.random.Random

private data class Particle(val x: Float, val speed: Float, val size: Float, val color: Color, val spin: Float, val drift: Float)

/** Lightweight confetti burst used for passed quizzes, achievements and certificates. */
@Composable
fun ConfettiOverlay(trigger: Any?, modifier: Modifier = Modifier) {
    if (LocalReduceMotion.current || trigger == null) return
    val colors = listOf(Color(0xFF6750F5), Color(0xFF03B6D4), Color(0xFFB9F34C), Color(0xFFE0B84A), Color(0xFFFF7A7A))
    val particles = remember(trigger) {
        List(70) {
            Particle(
                x = Random.nextFloat(),
                speed = 0.6f + Random.nextFloat() * 0.8f,
                size = 6f + Random.nextFloat() * 10f,
                color = colors[it % colors.size],
                spin = Random.nextFloat() * 720f,
                drift = Random.nextFloat() * 2f - 1f,
            )
        }
    }
    val progress = remember(trigger) { Animatable(0f) }
    LaunchedEffect(trigger) {
        progress.snapTo(0f)
        progress.animateTo(1f, tween(2600, easing = LinearEasing))
    }
    Canvas(modifier.fillMaxSize()) {
        val t = progress.value
        if (t >= 1f) return@Canvas
        particles.forEach { p ->
            val y = -40f + t * p.speed * size.height * 1.3f
            val x = p.x * size.width + sin((t * 6f + p.drift) * 3f) * 40f * p.drift
            rotate(p.spin * t, Offset(x, y)) {
                drawRect(p.color.copy(alpha = 1f - t * 0.6f), Offset(x - p.size / 2, y - p.size / 4), Size(p.size, p.size / 2))
            }
        }
    }
}

/** Short, unobtrusive feedback tones (no audio assets needed). Respects the Sound effects setting. */
class SoundPlayer {
    private var tone: ToneGenerator? = runCatching { ToneGenerator(AudioManager.STREAM_MUSIC, 45) }.getOrNull()

    fun correct() { tone?.startTone(ToneGenerator.TONE_PROP_ACK, 120) }
    fun wrong() { tone?.startTone(ToneGenerator.TONE_PROP_NACK, 160) }
    fun success() { tone?.startTone(ToneGenerator.TONE_CDMA_CONFIRM, 300) }

    fun release() {
        tone?.release()
        tone = null
    }
}

/** Remembers a [SoundPlayer] that is a no-op when sound effects are disabled. */
@Composable
fun rememberSoundPlayer(): SoundPlayer? {
    val enabled = LocalSoundEnabled.current
    if (!enabled) return null
    val player = remember { SoundPlayer() }
    DisposableEffect(player) { onDispose { player.release() } }
    return player
}
