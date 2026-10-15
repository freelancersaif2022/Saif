package com.beam.share.util

import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import kotlin.math.max

object Format {
    fun bytes(value: Long): String {
        val b = max(0L, value).toDouble()
        return when {
            b < 1024 -> "${b.toLong()} B"
            b < 1024 * 1024 -> String.format(Locale.US, "%.1f KB", b / 1024)
            b < 1024.0 * 1024 * 1024 -> String.format(Locale.US, "%.1f MB", b / (1024 * 1024))
            else -> String.format(Locale.US, "%.2f GB", b / (1024.0 * 1024 * 1024))
        }
    }

    fun speed(bytesPerSecond: Long): String = if (bytesPerSecond <= 0) "—" else bytes(bytesPerSecond) + "/s"

    /** 0:05, 1:23, 1:02:03 */
    fun clock(totalSeconds: Long): String {
        val s = max(0L, totalSeconds)
        val h = s / 3600
        val m = (s % 3600) / 60
        val sec = s % 60
        return if (h > 0) String.format(Locale.US, "%d:%02d:%02d", h, m, sec)
        else String.format(Locale.US, "%d:%02d", m, sec)
    }

    /** "9 seconds", "1 min 4 s", "1 h 2 min" */
    fun duration(ms: Long): String {
        val s = max(1L, (ms + 500) / 1000)
        return when {
            s < 60 -> if (s == 1L) "1 second" else "$s seconds"
            s < 3600 -> "${s / 60} min ${s % 60} s"
            else -> "${s / 3600} h ${(s % 3600) / 60} min"
        }
    }

    fun time(timestamp: Long): String =
        SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date(timestamp))

    fun dayLabel(timestamp: Long, now: Long = System.currentTimeMillis()): String {
        val day = Calendar.getInstance().apply { timeInMillis = timestamp }
        val today = Calendar.getInstance().apply { timeInMillis = now }
        fun sameDay(a: Calendar, b: Calendar) =
            a.get(Calendar.YEAR) == b.get(Calendar.YEAR) &&
                a.get(Calendar.DAY_OF_YEAR) == b.get(Calendar.DAY_OF_YEAR)
        if (sameDay(day, today)) return "Today"
        today.add(Calendar.DAY_OF_YEAR, -1)
        if (sameDay(day, today)) return "Yesterday"
        val pattern = if (day.get(Calendar.YEAR) == Calendar.getInstance().get(Calendar.YEAR)) "EEEE, d MMM" else "d MMM yyyy"
        return SimpleDateFormat(pattern, Locale.getDefault()).format(Date(timestamp))
    }

    fun relative(timestamp: Long, now: Long = System.currentTimeMillis()): String {
        val diff = max(0L, now - timestamp) / 1000
        return when {
            diff < 60 -> "Just now"
            diff < 3600 -> "${diff / 60}m ago"
            diff < 86_400 -> "${diff / 3600}h ago"
            diff < 172_800 -> "Yesterday"
            else -> SimpleDateFormat("d MMM", Locale.getDefault()).format(Date(timestamp))
        }
    }

    fun videoLength(ms: Long): String = clock(ms / 1000)
}
