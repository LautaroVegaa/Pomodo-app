// lib/services/notification_service.dart
import 'package:flutter/material.dart'; // Importar Material para GlobalKey
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// Asegúrate que la ruta al enum sea correcta según tu estructura
import 'package:pomodo_app/providers/timer_provider.dart';
import '../main.dart'; // ✅ Importar main.dart para acceder a navigatorKey

// ✅ Función estática o de nivel superior para manejar el toque de notificación en background/terminada
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print('Notification tap received in background: ${notificationResponse.payload}');
  // Lógica adicional si es necesaria cuando la app se abre desde terminada
}

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // ✅ Configurar callbacks de toque
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
         print('Notification tapped while app is active/background: ${details.payload}');
         navigatorKey.currentState?.pushNamedAndRemoveUntil('/home', (route) => false);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Solicitar permiso Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Crear canal Android 8+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'pomodoro_channel',
      'Notificaciones Pomodō',
      description: 'Canal de notificaciones para finales de ciclo de Pomodoro.',
      importance: Importance.high,
      playSound: false, // Desactivado aquí, manejado por AudioService
      enableVibration: true,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
    print("✅ NotificationService inicializado con callbacks de toque.");
  }

  // Muestra la notificación de fin de fase Pomodoro (sin cambios)
  Future<void> showPomodoroNotification({
    required PomodoroPhase phase,
    required int currentCycle,
    required int longBreakInterval,
    String? payload = 'navigate_home', // Payload para identificar acción
  }) async {
    if (!_initialized) {
      await initialize();
    }

    String title;
    String body;
    if (phase == PomodoroPhase.work) {
      title = "¡Fin del Enfoque! 🔔";
      body = "Tómate un ${currentCycle % longBreakInterval == 0 ? 'descanso largo' : 'descanso corto'} y recarga energías.";
    } else {
      int nextCycle = (phase == PomodoroPhase.longBreak) ? 1 : currentCycle + 1;
      title = "¡Fin del Descanso! 💪";
      body = "Es hora de volver al enfoque. ¡Ciclo $nextCycle!";
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pomodoro_channel', 'Notificaciones Pomodō',
       channelDescription: 'Canal para notificaciones de fin de ciclo Pomodoro.',
       importance: Importance.max, priority: Priority.high, ticker: 'Pomodō Timer',
       playSound: false, enableVibration: true,
    );
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
       presentAlert: true, presentSound: false, presentBadge: true,
    );
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails, iOS: iOSDetails);

    try {
      await flutterLocalNotificationsPlugin.show(
        0, title, body, platformDetails, // ID 0 para Pomodoro
        payload: payload,
      );
      print("🔔 Mostrando notificación Pomodoro: $title");
    } catch (e) {
      print("❌ Error al mostrar notificación Pomodoro: $e");
    }
  }

  // ✅ NUEVO MÉTODO: Muestra notificación para el Timer Simple
  Future<void> showSimpleTimerNotification({
    required int initialDuration, // Recibe la duración que se configuró
    String? payload = 'navigate_home', // Payload opcional
  }) async {
    if (!_initialized) {
      await initialize();
    }

    // Formatear la duración inicial para mostrarla
    int minutes = initialDuration ~/ 60;
    int seconds = initialDuration % 60;
    String durationString = '';
    if (minutes > 0) durationString += '$minutes min ';
    if (seconds > 0 || minutes == 0) durationString += '$seconds seg';
    durationString = durationString.trim();

    final String title = "¡Tiempo Terminado! ⏰";
    final String body = "Finalizó el temporizador de $durationString.";

    // Reutilizar configuraciones, pero con ID diferente
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pomodoro_channel', // Mismo canal
      'Notificaciones Pomodō',
      channelDescription: 'Canal para notificaciones generales de Pomodō.',
      importance: Importance.max, priority: Priority.high, ticker: 'Timer Alert',
      playSound: false, enableVibration: true,
    );
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true, presentSound: false,
    );
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails, iOS: iOSDetails);

    try {
      await flutterLocalNotificationsPlugin.show(
        1, // 👈 Usar un ID DIFERENTE (ej: 1) para el Timer Simple
        title,
        body,
        platformDetails,
        payload: payload,
      );
      print("🔔 Mostrando notificación de Timer Simple: $title");
    } catch (e) {
      print("❌ Error al mostrar notificación de Timer Simple: $e");
    }
  }
} // Fin de la clase NotificationService