package com.example.app_pomodo

// --- Asegúrate de tener estos imports ---
import android.content.Intent
import android.os.Build // Necesario para startForegroundService
import android.provider.Settings
import androidx.annotation.NonNull // Necesario para @NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
// --- Fin de imports necesarios ---

class MainActivity : FlutterActivity() {

    // --- Canal EXISTENTE para Screen Time ---
    private val SCREEN_TIME_CHANNEL = "pomodo/screen_time"
    private var monitor: FocusMonitor? = null // Mantén esto si lo usas para screen time

    // --- NUEVO Canal para TimerService ---
    private val TIMER_SERVICE_CHANNEL = "com.example.app_pomodo/timer_service"


    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // --- Configuración del Canal EXISTENTE para Screen Time ---
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SCREEN_TIME_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // ✅ SOLO abre Ajustes si faltan permisos
                    "requestAuthorization" -> {
                        val usageGranted = isUsageAccessGranted()
                        val overlayGranted = Settings.canDrawOverlays(this)

                        if (!usageGranted) openUsageAccessSettings()
                        if (!overlayGranted) openOverlaySettings()

                        // Si ya estaban dados, NO reabrimos nada
                        result.success(true)
                    }
                    // ✅ chequeo que usa tu Dart antes de pedir permisos
                    "checkAuthorizationStatus" -> {
                        val usageGranted = isUsageAccessGranted()
                        val overlayGranted = Settings.canDrawOverlays(this)
                        result.success(usageGranted && overlayGranted)
                    }
                    // ✅ al iniciar, agregamos además el launcher + systemui como permitidos
                    "startFocusSession" -> {
                        val args = call.arguments as? Map<*, *>
                        val minutes = (args?.get("minutes") as? Int) ?: 25

                        val allowed = mutableSetOf(packageName)
                        getLauncherPackage()?.let { allowed.add(it) }
                        allowed.add("com.android.systemui") // evitar bloquear barra/recientes

                        if (monitor == null) {
                            monitor = FocusMonitor(this, allowedPackages = allowed)
                        } else {
                            monitor?.updateAllowed(allowed)
                        }

                        monitor?.start(minutes)
                        result.success(null)
                    }
                    "endFocusSession" -> {
                        monitor?.stop()
                        monitor = null // Considera si realmente quieres anularlo aquí
                        result.success(null)
                    }
                    "presentPicker" -> result.success(null) // Esto es iOS-specific, no hace nada en Android
                    else -> result.notImplemented()
                }
            } // --- Fin del MethodChannel para Screen Time ---


        // --- NUEVA Configuración del Canal para TimerService ---
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TIMER_SERVICE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startTimerService" -> {
                        val args = call.arguments as? Map<String, Any>
                        val time = args?.get("time") as? String ?: "00:00"
                        val type = args?.get("type") as? String ?: "Timer"
                        val isRunning = args?.get("isRunning") as? Boolean ?: true
                        // Usamos la constante definida en TimerService
                        startOrUpdateTimerService(TimerService.ACTION_START, time, type, isRunning)
                        result.success(null)
                    }
                    "updateTimerService" -> {
                        val args = call.arguments as? Map<String, Any>
                        val time = args?.get("time") as? String ?: "00:00"
                        val type = args?.get("type") as? String ?: "Timer" // Incluir por si acaso
                        val isRunning = args?.get("isRunning") as? Boolean ?: true
                        // Usamos la constante definida en TimerService
                        startOrUpdateTimerService(TimerService.ACTION_UPDATE, time, type, isRunning)
                        result.success(null)
                    }
                    "stopTimerService" -> {
                        stopTimerForegroundService()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            } // --- Fin del MethodChannel para TimerService ---

    } // --- Fin de configureFlutterEngine ---


    // --- Funciones Helper para controlar TimerService (NUEVAS) ---
    private fun startOrUpdateTimerService(action: String, time: String, type: String, isRunning: Boolean) {
        val serviceIntent = Intent(this, TimerService::class.java).apply {
            this.action = action // ACTION_START o ACTION_UPDATE
            putExtra("time", time)
            putExtra("type", type)
            putExtra("isRunning", isRunning)
        }
        // Iniciar como servicio en primer plano si es Android 8+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }
    }

    private fun stopTimerForegroundService() {
        val serviceIntent = Intent(this, TimerService::class.java).apply {
            // Usamos la constante definida en TimerService
            action = TimerService.ACTION_STOP
        }
        // Enviamos el intent con la acción STOP al servicio
        startService(serviceIntent)
    }
    // --- Fin Funciones Helper para TimerService ---


    // --- Funciones Helper EXISTENTES para Screen Time ---
    private fun openUsageAccessSettings() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(intent)
    }

    private fun openOverlaySettings() {
        if (!Settings.canDrawOverlays(this)) {
            val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
        }
    }

    private fun isUsageAccessGranted(): Boolean {
        return try {
            val appOps = getSystemService(APP_OPS_SERVICE) as android.app.AppOpsManager
            val mode = appOps.checkOpNoThrow(
                android.app.AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
            mode == android.app.AppOpsManager.MODE_ALLOWED
        } catch (_: Exception) {
            false
        }
    }

    private fun getLauncherPackage(): String? {
        return try {
            val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
            val res = packageManager.resolveActivity(intent, 0)
            res?.activityInfo?.packageName
        } catch (_: Exception) {
            null
        }
    }
    // --- Fin Funciones Helper para Screen Time ---

    // *** IMPORTANTE: Asegúrate de que NO haya una definición de 'class TimerService ...' aquí abajo ***

} // --- Fin de MainActivity ---