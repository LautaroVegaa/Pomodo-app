package com.example.app_pomodo

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.IBinder
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat

class TimerService : Service() {

    companion object {
        const val CHANNEL_ID = "PomodoFocusChannel"

        // 🔹 Acciones reconocidas por el servicio
        const val ACTION_START = "ACTION_START"
        const val ACTION_UPDATE = "ACTION_UPDATE"
        const val ACTION_TOGGLE_PAUSE = "ACTION_TOGGLE_PAUSE"
        const val ACTION_STOP = "ACTION_STOP"
    }

    private var currentFormattedTime: String = "25:00"
    private var timerType: String = "Work"
    private var isRunning: Boolean = true

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // 🟡 Actualiza datos recibidos desde Flutter
        intent?.let {
            currentFormattedTime = it.getStringExtra("time") ?: currentFormattedTime
            timerType = it.getStringExtra("type") ?: timerType
            isRunning = it.getBooleanExtra("isRunning", isRunning)
        }

        when (intent?.action) {
            ACTION_START -> {
                // Crear y mostrar notificación persistente
                startForeground(1, createNotification())
            }

            ACTION_UPDATE -> {
                // Actualizar contenido de la notificación sin reiniciar servicio
                val notification = createNotification()
                val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                manager.notify(1, notification)
            }

            ACTION_TOGGLE_PAUSE -> {
                isRunning = !isRunning
                val notification = createNotification()
                val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                manager.notify(1, notification)
            }

            ACTION_STOP -> {
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
            }

            else -> startForeground(1, createNotification())
        }

        return START_STICKY
    }

    private fun createNotification(): Notification {
        val notificationLayout = RemoteViews(packageName, R.layout.timer_notification_layout)

        // 🕒 Texto dinámico
        notificationLayout.setTextViewText(R.id.notification_time, currentFormattedTime)
        val titleText = timerType + if (isRunning) "" else " (Paused)"
        notificationLayout.setTextViewText(R.id.notification_title, titleText)
        notificationLayout.setTextViewText(R.id.tag_text, timerType)

        // 🎨 Color del tag según tipo
        val tagColor = when (timerType.lowercase()) {
            "work", "pomodoro" -> "#B8F397"
            "break", "short break", "long break" -> "#9FD8FF"
            else -> "#FFFFFF"
        }
        notificationLayout.setTextColor(R.id.tag_text, Color.parseColor(tagColor))

        // ▶️ / ⏸ Icono dinámico
        val pausePlayIconRes =
            if (isRunning) R.drawable.ic_media_pause else R.drawable.ic_media_play_arrow
        notificationLayout.setImageViewResource(
            R.id.notification_button_pause_play,
            pausePlayIconRes
        )

        // 🔗 Pending intents
        val openAppIntent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pendingOpenAppIntent = openAppIntent?.let {
            PendingIntent.getActivity(
                this, 0, it,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        val toggleIntent = Intent(this, TimerService::class.java).apply {
            action = ACTION_TOGGLE_PAUSE
            putExtra("time", currentFormattedTime)
            putExtra("type", timerType)
            putExtra("isRunning", isRunning)
        }
        val togglePendingIntent = PendingIntent.getService(
            this, 1, toggleIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        notificationLayout.setOnClickPendingIntent(
            R.id.notification_button_pause_play,
            togglePendingIntent
        )

        val stopIntent = Intent(this, TimerService::class.java).apply {
            action = ACTION_STOP
        }
        val stopPendingIntent = PendingIntent.getService(
            this, 2, stopIntent,
            PendingIntent.FLAG_CANCEL_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        notificationLayout.setOnClickPendingIntent(
            R.id.notification_button_stop,
            stopPendingIntent
        )

        // 🧱 Construcción de la notificación (ajustada para layout personalizado)
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_hourglass) // 👈 usa tu icono personalizado
            .setCustomContentView(notificationLayout)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomBigContentView(null) // 👈 evita MediaStyle expandido
            .setCategory(Notification.CATEGORY_SERVICE)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .setSilent(true)
            .setOnlyAlertOnce(true)
            .setAutoCancel(false)
            .setContentIntent(pendingOpenAppIntent)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .build()
    }

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Pomodō Focus Mode",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "Bloquea distracciones durante tu sesión."
            setSound(null, null)
            enableVibration(false)
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
        }

        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.createNotificationChannel(channel)
    }
}
