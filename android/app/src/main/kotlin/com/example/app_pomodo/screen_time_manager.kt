package com.example.app_pomodo

import android.content.Context
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class ScreenTimeManager : FlutterPlugin {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var monitor: FocusMonitor? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        setupChannel(binding.binaryMessenger)
    }

    private fun setupChannel(messenger: BinaryMessenger) {
        channel = MethodChannel(messenger, "pomodo/screen_time")
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                // Abre las pantallas de permisos (Usage Access y Overlay)
                "requestAuthorization" -> {
                    openUsageAccessSettings()
                    openOverlaySettings()
                    result.success(true)
                }

                // ✅ NUEVO: Verifica si los permisos siguen activos
                "checkAuthorizationStatus" -> {
                    val usageGranted = isUsageAccessGranted()
                    val overlayGranted = Settings.canDrawOverlays(context)
                    result.success(usageGranted && overlayGranted)
                }

                // Inicia la sesión de foco (monitoreo + overlay en apps no permitidas)
                "startFocusSession" -> {
                    val args = call.arguments as? Map<*, *>
                    val minutes = (args?.get("minutes") as? Int) ?: 25
                    if (monitor == null)
                        monitor = FocusMonitor(context, allowedPackages = setOf(context.packageName))
                    monitor?.start(minutes)
                    result.success(null)
                }

                // Finaliza la sesión (detiene monitor y oculta overlay)
                "endFocusSession" -> {
                    monitor?.stop()
                    monitor = null
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun openUsageAccessSettings() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }

    private fun openOverlaySettings() {
        if (!Settings.canDrawOverlays(context)) {
            val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
        }
    }

    // ✅ NUEVO: Comprueba si el permiso de "Uso de apps" está activo
    private fun isUsageAccessGranted(): Boolean {
        return try {
            val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as android.app.AppOpsManager
            val mode = appOps.checkOpNoThrow(
                android.app.AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                context.packageName
            )
            mode == android.app.AppOpsManager.MODE_ALLOWED
        } catch (e: Exception) {
            false
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        monitor?.stop()
        monitor = null
    }
}
