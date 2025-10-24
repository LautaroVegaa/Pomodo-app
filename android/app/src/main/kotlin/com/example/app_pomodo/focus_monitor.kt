package com.example.app_pomodo

import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper

/**
 * Lee el app en foreground usando UsageStats y muestra/oculta el overlay
 * si NO está en la allowlist (por defecto, solo Pomodō).
 */
class FocusMonitor(
    private val context: Context,
    private var allowedPackages: Set<String> // ⚠️ ahora es var (para actualizar)
) {
    private val usageStats = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
    private val handler = Handler(Looper.getMainLooper())
    private val overlay = OverlayController(context)

    @Volatile private var running = false
    private var endAtMs: Long = 0L

    private val tick = object : Runnable {
        override fun run() {
            if (!running) return

            val now = System.currentTimeMillis()
            if (endAtMs > 0 && now >= endAtMs) {
                stop() // terminó el bloque
                return
            }

            val pkg = currentForegroundPackage(now)

            // ✅ NUEVO BLOQUE: respetar allowlist actualizada
            if (pkg == null) {
                overlay.hide()
            } else if (allowedPackages.contains(pkg)) {
                overlay.hide()
            } else {
                overlay.show()
            }

            handler.postDelayed(this, 500L)
        }
    }

    fun start(minutes: Int) {
    if (running) return
    running = true
    endAtMs = if (minutes > 0) System.currentTimeMillis() + minutes * 60_000L else 0L

    // 🔹 Inicia el servicio en primer plano para mantener el overlay persistente
    val serviceIntent = Intent(context, FocusService::class.java)
    context.startForegroundService(serviceIntent)

    handler.post(tick)
}

fun stop() {
    running = false
    handler.removeCallbacks(tick)

    // 🔹 Detiene el servicio de bloqueo
    val serviceIntent = Intent(context, FocusService::class.java)
    context.stopService(serviceIntent)
}

    // ✅ NUEVO: permite actualizar dinámicamente la lista de apps permitidas
    fun updateAllowed(newAllowed: Set<String>) {
        allowedPackages = newAllowed
    }

    private fun currentForegroundPackage(now: Long): String? {
        val events = usageStats.queryEvents(now - 2000L, now)
        val event = UsageEvents.Event()
        var lastPkg: String? = null

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED ||
                event.eventType == UsageEvents.Event.ACTIVITY_PAUSED ||
                event.eventType == UsageEvents.Event.ACTIVITY_STOPPED
            ) {
                lastPkg = event.packageName
            }
        }
        return lastPkg
    }
}
