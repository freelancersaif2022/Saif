package com.bimo.learnflutter.notifications

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import androidx.hilt.work.HiltWorker
import androidx.work.CoroutineWorker
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import com.bimo.learnflutter.MainActivity
import com.bimo.learnflutter.R
import com.bimo.learnflutter.data.prefs.SettingsDataStore
import com.bimo.learnflutter.data.repository.LearningRepository
import com.bimo.learnflutter.data.repository.ProfileRepository
import dagger.assisted.Assisted
import dagger.assisted.AssistedInject
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.first
import java.time.Duration
import java.time.LocalDateTime
import java.util.concurrent.TimeUnit
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Runs once a day near the learner's chosen time. It posts at most one notification and only if
 * the learner hasn't studied yet today, so it never nags people who are already on track.
 */
@HiltWorker
class ReminderWorker @AssistedInject constructor(
    @Assisted appContext: Context,
    @Assisted params: WorkerParameters,
    private val settings: SettingsDataStore,
    private val learning: LearningRepository,
    private val profiles: ProfileRepository,
) : CoroutineWorker(appContext, params) {

    override suspend fun doWork(): Result {
        val prefs = settings.current()
        if (!prefs.remindersEnabled) return Result.success()
        if (!NotificationHelper.canPost(applicationContext)) return Result.success()

        val streak = learning.streak.first()
        if (streak.studiedToday) return Result.success()
        val name = profiles.get()?.name?.substringBefore(' ') ?: "there"
        val goal = profiles.get()?.dailyGoalLessons ?: 1

        val (title, body) = when {
            prefs.streakReminders && streak.atRisk ->
                "Keep your ${streak.current}-day streak alive 🔥" to
                    "One short lesson today keeps your streak going, $name."
            prefs.goalNotifications ->
                "Your daily goal is waiting" to
                    "Complete $goal ${if (goal == 1) "lesson" else "lessons"} today to hit your goal, $name."
            else -> "Time to learn Flutter" to "Pick up where you left off – your next lesson is ready."
        }
        NotificationHelper.post(applicationContext, title, body)
        return Result.success()
    }
}

object NotificationHelper {
    const val CHANNEL_ID = "learning_reminders"
    private const val NOTIFICATION_ID = 1001

    fun createChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                context.getString(R.string.notification_channel_name),
                NotificationManager.IMPORTANCE_DEFAULT,
            ).apply { description = context.getString(R.string.notification_channel_description) }
            context.getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    fun canPost(context: Context): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
        ) return false
        return NotificationManagerCompat.from(context).areNotificationsEnabled()
    }

    fun post(context: Context, title: String, body: String) {
        if (!canPost(context)) return
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pending = PendingIntent.getActivity(
            context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setContentIntent(pending)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .build()
        try {
            NotificationManagerCompat.from(context).notify(NOTIFICATION_ID, notification)
        } catch (_: SecurityException) {
            // Permission revoked between the check and the call – nothing to do.
        }
    }
}

@Singleton
class ReminderScheduler @Inject constructor(
    @ApplicationContext private val context: Context,
) {
    private val workName = "bimo_daily_reminder"

    /** Schedules (or reschedules) the daily check at [hour]:[minute] local time. */
    fun schedule(hour: Int, minute: Int) {
        val now = LocalDateTime.now()
        var next = now.withHour(hour).withMinute(minute).withSecond(0).withNano(0)
        if (!next.isAfter(now)) next = next.plusDays(1)
        val delay = Duration.between(now, next).toMillis()
        val request = PeriodicWorkRequestBuilder<ReminderWorker>(1, TimeUnit.DAYS)
            .setInitialDelay(delay, TimeUnit.MILLISECONDS)
            .build()
        WorkManager.getInstance(context)
            .enqueueUniquePeriodicWork(workName, ExistingPeriodicWorkPolicy.UPDATE, request)
    }

    fun cancel() {
        WorkManager.getInstance(context).cancelUniqueWork(workName)
    }
}
