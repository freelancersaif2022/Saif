package com.beam.share.transfer

import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat
import com.beam.share.BeamApp
import com.beam.share.MainActivity
import com.beam.share.R
import com.beam.share.util.Format
import com.beam.share.util.Permissions
import kotlinx.coroutines.FlowPreview
import kotlinx.coroutines.Job
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.sample
import kotlinx.coroutines.launch

/** Keeps the app alive while a transfer runs with the screen off, and shows its progress. */
class TransferService : Service() {

    private val scope = MainScope()
    private var job: Job? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createChannel(this)
    }

    @OptIn(FlowPreview::class)
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val engine = (application as BeamApp).container.engine
        val started = runCatching {
            val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) ServiceInfo.FOREGROUND_SERVICE_TYPE_CONNECTED_DEVICE else 0
            ServiceCompat.startForeground(this, NOTIFICATION_ID, buildProgress(engine.session.value), type)
        }
        if (started.isFailure) {
            Log.w(TAG, "startForeground failed", started.exceptionOrNull())
            stopSelf()
            return START_NOT_STICKY
        }
        if (job == null) {
            job = scope.launch {
                engine.session.sample(700).collect { s ->
                    if (s == null || !s.isActive) {
                        if (s != null) postResult(s)
                        ServiceCompat.stopForeground(this@TransferService, ServiceCompat.STOP_FOREGROUND_REMOVE)
                        stopSelf()
                        job?.cancel()
                    } else {
                        notifySafely(NOTIFICATION_ID, buildProgress(s))
                    }
                }
            }
        }
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        scope.cancel()
        super.onDestroy()
    }

    private fun contentIntent(): PendingIntent = PendingIntent.getActivity(
        this, 0,
        Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )

    private fun buildProgress(s: TransferSession?): android.app.Notification {
        val sending = s?.direction == Direction.SEND
        val title = when {
            s == null -> "Preparing transfer"
            s.phase == Phase.CONNECTING -> "Connecting to ${s.deviceName}"
            s.phase == Phase.AWAITING_ACCEPT -> "Waiting for ${s.deviceName}"
            s.phase == Phase.INCOMING_REQUEST -> "${s.deviceName} wants to share files"
            sending -> "Sending to ${s.deviceName}"
            else -> "Receiving from ${s.deviceName}"
        }
        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_beam)
            .setContentTitle(title)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setCategory(NotificationCompat.CATEGORY_PROGRESS)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .setContentIntent(contentIntent())
        if (s != null && s.phase == Phase.TRANSFERRING) {
            val pct = (s.progress * 100).toInt()
            builder.setProgress(100, pct, false)
                .setContentText("$pct% · ${Format.bytes(s.transferredBytes)} of ${Format.bytes(s.totalBytes)} · ${Format.speed(s.speedBytesPerSec)}")
        } else {
            builder.setProgress(0, 0, true)
        }
        return builder.build()
    }

    private fun postResult(s: TransferSession) {
        val (title, text) = when (s.phase) {
            Phase.COMPLETED -> {
                val what = if (s.doneCount == 1) s.files.first { it.state == FileState.DONE }.name else "${s.doneCount} files"
                if (s.direction == Direction.SEND) "Sent to ${s.deviceName}" to what
                else "Received from ${s.deviceName}" to "$what · saved to Download/Beam"
            }
            Phase.DECLINED -> "Not sent" to (s.error ?: "${s.deviceName} declined")
            Phase.CANCELLED -> "Transfer cancelled" to (s.error ?: "The transfer was stopped")
            else -> "Transfer failed" to (s.error ?: "Something went wrong")
        }
        val n = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_beam)
            .setContentTitle(title)
            .setContentText(text)
            .setAutoCancel(true)
            .setContentIntent(contentIntent())
            .build()
        notifySafely(RESULT_NOTIFICATION_ID, n)
    }

    @SuppressLint("MissingPermission")
    private fun notifySafely(id: Int, notification: android.app.Notification) {
        if (!Permissions.canNotify(this)) return
        runCatching { NotificationManagerCompat.from(this).notify(id, notification) }
    }

    companion object {
        private const val TAG = "BeamService"
        private const val CHANNEL_ID = "transfers"
        private const val NOTIFICATION_ID = 41
        private const val RESULT_NOTIFICATION_ID = 42

        fun start(context: Context) {
            runCatching {
                ContextCompat.startForegroundService(context, Intent(context, TransferService::class.java))
            }.onFailure { Log.w(TAG, "Couldn't start service", it) }
        }

        fun createChannel(context: Context) {
            val manager = context.getSystemService(NotificationManager::class.java) ?: return
            val channel = NotificationChannel(
                CHANNEL_ID,
                context.getString(R.string.channel_transfers),
                NotificationManager.IMPORTANCE_LOW,
            ).apply { description = context.getString(R.string.channel_transfers_desc) }
            manager.createNotificationChannel(channel)
        }
    }
}
