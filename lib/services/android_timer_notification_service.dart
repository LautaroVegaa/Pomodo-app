// lib/services/android_timer_notification_service.dart
import 'package:flutter/foundation.dart'; // Para kIsWeb y defaultTargetPlatform
import 'package:flutter/services.dart';

/// Servicio para controlar la notificación persistente del temporizador en Android.
class AndroidTimerNotificationService {
  // Nombre del canal (debe coincidir exactamente con el de MainActivity.kt)
  static const MethodChannel _channel =
      MethodChannel('com.example.app_pomodo/timer_service');

  // Verifica si estamos en Android y no en la web
  static bool get _isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Inicia el servicio en primer plano y muestra la notificación.
  ///
  /// [time]: El tiempo formateado a mostrar (ej. "24:59").
  /// [type]: El tipo de temporizador ("Pomodoro", "Timer", "Stopwatch").
  /// [isRunning]: Indica si el temporizador está corriendo o pausado.
  static Future<void> start(String time, String type, bool isRunning) async {
    if (!_isAndroid) return; // Solo ejecutar en Android

    try {
      await _channel.invokeMethod('startTimerService', {
        'time': time,
        'type': type,
        'isRunning': isRunning,
      });
      print('AndroidTimerNotificationService: start invoked.');
    } on PlatformException catch (e) {
      print("Error al iniciar el servicio de notificación Android: ${e.message}");
      // Considera manejar el error de forma más robusta si es necesario
    }
  }

  /// Actualiza el contenido de la notificación existente.
  ///
  /// [time]: El nuevo tiempo formateado.
  /// [isRunning]: El nuevo estado (corriendo/pausado).
  /// [type]: (Opcional) El tipo, aunque normalmente no cambia durante una actualización.
  static Future<void> update(String time, bool isRunning, {String? type}) async {
     if (!_isAndroid) return; // Solo ejecutar en Android

    try {
      await _channel.invokeMethod('updateTimerService', {
        'time': time,
        'isRunning': isRunning,
        if (type != null) 'type': type, // Incluir tipo si se proporciona
      });
       // Evita imprimir demasiado seguido en updates
       // print('AndroidTimerNotificationService: update invoked.');
    } on PlatformException catch (e) {
      print("Error al actualizar el servicio de notificación Android: ${e.message}");
    }
  }

  /// Detiene el servicio en primer plano y elimina la notificación.
  static Future<void> stop() async {
    if (!_isAndroid) return; // Solo ejecutar en Android

    try {
      await _channel.invokeMethod('stopTimerService');
      print('AndroidTimerNotificationService: stop invoked.');
    } on PlatformException catch (e) {
      print("Error al detener el servicio de notificación Android: ${e.message}");
    }
  }

  // --- Opcional: Escuchar eventos desde el servicio ---
  // Si necesitaras que Android notifique a Flutter (ej. si el usuario pausa desde
  // la notificación), podrías configurar un EventChannel aquí. Por ahora,
  // la comunicación es unidireccional (Flutter -> Android).
}