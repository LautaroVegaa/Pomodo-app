import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScreenTimeService {
  static const _ch = MethodChannel('pomodo/screen_time');

  /// Pide autorización al sistema (iOS: Screen Time; Android: abrirá las pantallas de permisos)
  static Future<bool> requestAuthorization() async {
    try {
      final ok = await _ch.invokeMethod<bool>('requestAuthorization');
      return ok == true;
    } on PlatformException catch (e) {
      print('❌ Error en requestAuthorization: $e');
      return false;
    }
  }

  /// ✅ NUEVO: verifica si los permisos siguen activos actualmente
  static Future<bool> checkAuthorizationStatus() async {
    try {
      final ok = await _ch.invokeMethod<bool>('checkAuthorizationStatus');
      return ok == true;
    } on PlatformException catch (e) {
      print('❌ Error en checkAuthorizationStatus: $e');
      return false;
    }
  }

  /// iOS: activa el shield de Screen Time X minutos (bloqueo real del SO)
  /// Android: inicia el monitor + overlay tipo Focus Plant
  static Future<void> startFocusSession({required int minutes}) async {
    try {
      await _ch.invokeMethod('startFocusSession', {'minutes': minutes});
    } on PlatformException catch (e) {
      print('❌ Error al iniciar FocusSession: $e');
    }
  }

  /// Detiene el bloqueo o el modo foco (iOS/Android)
  static Future<void> endFocusSession() async {
    try {
      await _ch.invokeMethod('endFocusSession');
    } on PlatformException catch (e) {
      print('❌ Error al detener FocusSession: $e');
    }
  }

  /// iOS: muestra el selector para elegir apps/categorías a bloquear
  /// Android: (no implementado aún, se ignora)
  static Future<void> presentPicker() async {
    try {
      await _ch.invokeMethod('presentPicker');
    } on PlatformException catch (e) {
      print('⚠️ Método no soportado en Android: $e');
    }
  }

  // ✅ NUEVO: Popup amigable al estilo Focus Plant (solo Android)
  static Future<bool> requestWithDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Row(
              children: [
                Icon(Icons.spa, color: Theme.of(context).primaryColor, size: 28),
                const SizedBox(width: 8),
                const Text(
                  "Permiso necesario",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: const Text(
              "Pomodō necesita permiso para acceder al tiempo de uso y "
              "bloquear otras apps durante tus sesiones de enfoque.\n\n"
              "Esto te ayudará a mantener la concentración sin distracciones, "
              "igual que Focus Plant 🌱",
              style: TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                child: const Text("Cancelar"),
                onPressed: () => Navigator.pop(context, false),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context, true);
                  await requestAuthorization(); // 🔹 abre la pantalla del sistema
                },
                child: const Text("Conceder permiso"),
              ),
            ],
          ),
        ) ??
        false;
  }
}
