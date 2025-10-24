package com.example.app_pomodo

import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView

/**
 * Controla la ventana flotante que bloquea apps no permitidas.
 * - Idempotente: no re-agrega si ya está visible.
 * - Sin re-inyección periódica (evita parpadeos).
 * - Oculta antes de volver a Pomodō para evitar "flash".
 */
class OverlayController(private val context: Context) {
    private var overlayView: View? = null
    private val windowManager =
        context.getSystemService(Context.WINDOW_SERVICE) as WindowManager

    @Volatile
    private var isShowing = false

    fun show() {
        if (isShowing) return
        if (overlayView != null) return

        val inflater = LayoutInflater.from(context)
        val view = inflater.inflate(R.layout.overlay_block_screen, null)

        val btnBack = view.findViewById<Button>(R.id.btnBack)
        val txtMsg = view.findViewById<TextView>(R.id.txtMessage)

        txtMsg.text =
            "☕ Take a breath.\nThis moment belongs to your focus."

        btnBack.setOnClickListener {
            // 🔒 Evitar flash: ocultar overlay ANTES de ir a Pomodō
            hide()

            val intent =
                context.packageManager.getLaunchIntentForPackage(context.packageName)
            intent?.addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
            )
            if (intent != null) context.startActivity(intent)
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            // Flags estables que no requieren re-inyección:
            // - Mantenerse en pantalla completa
            // - No ajustar tamaño con teclado
            // - No "parpadear" por cambios de foco
            WindowManager.LayoutParams.FLAG_FULLSCREEN or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        )
        params.gravity = Gravity.CENTER

        overlayView = view
        windowManager.addView(view, params)
        isShowing = true
    }

    fun hide() {
        if (!isShowing && overlayView == null) return
        try {
            overlayView?.let { windowManager.removeViewImmediate(it) }
        } catch (_: Exception) {
        } finally {
            overlayView = null
            isShowing = false
        }
    }
}
