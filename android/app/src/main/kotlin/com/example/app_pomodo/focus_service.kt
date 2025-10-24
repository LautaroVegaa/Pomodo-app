package com.example.app_pomodo

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.graphics.Color
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper

/**
 * Servicio en primer plano que mantiene activo el overlay solo
 * cuando el usuario abre una app externa (no Pomodō ni el sistema).
 */
class FocusService : Service() {
    private val overlay by lazy { OverlayController(this) }
    private val handler = Handler(Looper.getMainLooper())
    private lateinit var usageStats: UsageStatsManager
    private lateinit var pomodoPackage: String
    private var running = false

    // ✅ Control de estado previo para evitar parpadeos
    private var lastApp: String? = null
    private var isOverlayVisible = false

    override fun onCreate() {
        super.onCreate()
        pomodoPackage = packageName
        usageStats = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        startForegroundServiceNotification()
        running = true
        maintainOverlay()
    }

    private fun startForegroundServiceNotification() {
        val channelId = "pomodo_focus_mode"
        val channelName = "Pomodō Focus Mode"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val chan = NotificationChannel(
                channelId,
                channelName,
                NotificationManager.IMPORTANCE_MIN
            )
            chan.lightColor = Color.BLUE
            chan.lockscreenVisibility = Notification.VISIBILITY_PRIVATE

            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(chan)

            val notification: Notification = Notification.Builder(this, channelId)
                .setContentTitle("Pomodō Focus Mode")
                .setContentText("Bloqueando distracciones durante tu sesión.")
                .setSmallIcon(android.R.drawable.ic_lock_lock)
                .setOngoing(true)
                .build()

            startForeground(1, notification)
        } else {
            val notification: Notification = Notification.Builder(this)
                .setContentTitle("Pomodō Focus Mode")
                .setContentText("Bloqueando distracciones durante tu sesión.")
                .setSmallIcon(android.R.drawable.ic_lock_lock)
                .setOngoing(true)
                .build()
            startForeground(1, notification)
        }
    }

    // ✅ Versión estable sin parpadeos ni flash al volver a Pomodō
    private fun maintainOverlay() {
        handler.postDelayed({
            if (!running) return@postDelayed

            val currentApp = getForegroundApp()

            if (currentApp != null && currentApp != lastApp) {
                lastApp = currentApp

                if (shouldBlockApp(currentApp)) {
                    // Solo muestra si aún no está visible
                    if (!isOverlayVisible) {
                        overlay.show()
                        isOverlayVisible = true
                    }
                } else {
                    // Delay suave para evitar flash al volver a Pomodō
                    handler.postDelayed({
                        if (lastApp == pomodoPackage && isOverlayVisible) {
                            overlay.hide()
                            isOverlayVisible = false
                        }
                    }, 600L)
                }
            }

            maintainOverlay()
        }, 700L) // frecuencia un poco más fluida
    }

    /**
     * Determina si una app debe ser bloqueada:
     * - NO bloquea Pomodō.
     * - NO bloquea launchers, home o settings.
     * - Solo bloquea apps de usuario instaladas.
     */
    private fun shouldBlockApp(pkg: String): Boolean {
        if (pkg == pomodoPackage) return false

        val pm = packageManager
        return try {
            val appInfo = pm.getApplicationInfo(pkg, 0)
            val isUserApp = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) == 0 &&
                    (appInfo.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) == 0
            isUserApp
        } catch (e: Exception) {
            false
        }
    }

    private fun getForegroundApp(): String? {
        val now = System.currentTimeMillis()
        val events = usageStats.queryEvents(now - 2000L, now)
        val event = UsageEvents.Event()
        var lastApp: String? = null

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
                lastApp = event.packageName
            }
        }
        return lastApp
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        running = true
        return START_STICKY
    }

    override fun onDestroy() {
        running = false
        overlay.hide()
        isOverlayVisible = false
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
