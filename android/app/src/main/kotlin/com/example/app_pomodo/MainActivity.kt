package com.example.app_pomodo

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "pomodo/screen_time"
    private var monitor: FocusMonitor? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
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
                        monitor = null
                        result.success(null)
                    }

                    "presentPicker" -> result.success(null)

                    else -> result.notImplemented()
                }
            }
    }

    // ---------- helpers ----------

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

    // ✅ paquete del launcher actual (Samsung, Pixel, etc.)
    private fun getLauncherPackage(): String? {
        return try {
            val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
            val res = packageManager.resolveActivity(intent, 0)
            res?.activityInfo?.packageName
        } catch (_: Exception) {
            null
        }
    }
}
