package com.beam.share.util

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager

object Haptics {
    private fun vibrator(context: Context): Vibrator? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            (context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager)?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        }

    fun tick(context: Context) = play(context, longArrayOf(0, 30), intArrayOf(0, 120))

    fun success(context: Context) = play(context, longArrayOf(0, 40, 80, 60), intArrayOf(0, 160, 0, 255))

    fun alert(context: Context) = play(context, longArrayOf(0, 60, 90, 60), intArrayOf(0, 200, 0, 200))

    private fun play(context: Context, timings: LongArray, amplitudes: IntArray) {
        runCatching {
            val v = vibrator(context) ?: return
            if (!v.hasVibrator()) return
            val effect = if (v.hasAmplitudeControl()) VibrationEffect.createWaveform(timings, amplitudes, -1)
            else VibrationEffect.createWaveform(timings, -1)
            v.vibrate(effect)
        }
    }
}
