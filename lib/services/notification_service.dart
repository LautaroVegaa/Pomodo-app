// lib/services/notification_service.dart
import 'package:flutter/material.dart'; // Importar Material para GlobalKey
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pomodo_app/providers/timer_provider.dart'; // Necesario para PomodoroPhase
import '../main.dart'; // ✅ Importar main.dart para acceder a navigatorKey

// ✅ Función estática o de nivel superior para manejar el toque de notificación en background/terminada
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print('Notification tap received in background: ${notificationResponse.payload}');
  // Aquí podríamos guardar el payload si necesitamos actuar sobre él
  // cuando la app se inicie completamente. Por ahora, no es necesario.
}

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Icono de la app

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true, // Solicitar permiso de sonido en iOS
      requestBadgePermission: true, // Solicitar permiso de badge en iOS
      requestAlertPermission: true, // Solicitar permiso de alerta en iOS
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // ✅ Modificar la llamada a initialize para incluir los callbacks
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // Se llama cuando se toca la notificación y la app está en primer plano o background
      onDidReceiveNotificationResponse: (NotificationResponse details) {
         print('Notification tapped while app is active/background: ${details.payload}');
         // Usa la navigatorKey global para navegar a la pantalla principal ('/home')
         // y elimina todas las rutas anteriores para asegurar que no haya pantallas encima.
         navigatorKey.currentState?.pushNamedAndRemoveUntil('/home', (route) => false);
      },
      // Se llama cuando se toca la notificación y la app estaba terminada
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Solicitar permiso explícitamente en Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Crear canal de notificación para Android 8+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'pomodoro_channel',             // ID único del canal
      'Notificaciones Pomodō',        // Nombre visible para el usuario
      description: 'Canal de notificaciones para finales de ciclo de Pomodoro.', // Descripción
      importance: Importance.high,    // Prioridad
      playSound: false,               // Desactivar sonido por defecto del canal (lo manejamos aparte)
      enableVibration: true,          // Habilitar vibración por defecto del canal
      // Puedes ajustar el patrón de vibración si quieres
      // vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
    print("✅ NotificationService inicializado con callbacks de toque.");
  }

  // Muestra la notificación de fin de fase
  Future<void> showPomodoroNotification({
    required PomodoroPhase phase,
    required int currentCycle,
    required int longBreakInterval,
    String? payload = 'navigate_home', // Payload opcional para identificar la acción
  }) async {
    // Intenta inicializar si aún no lo está (importante si se llama muy temprano)
    if (!_initialized) {
      print("⚠️ NotificationService no inicializado. Llamando a initialize()...");
      await initialize();
    }

    String title;
    String body;

    // Determinar título y cuerpo según la fase que terminó
    if (phase == PomodoroPhase.work) {
      title = "¡Fin del Enfoque! 🔔";
      body =
          "Tómate un ${currentCycle % longBreakInterval == 0 ? 'descanso largo' : 'descanso corto'} y recarga energías.";
    } else {
      int nextCycle = (phase == PomodoroPhase.longBreak) ? 1 : currentCycle + 1;
      title = "¡Fin del Descanso! 💪";
      body = "Es hora de volver al enfoque. ¡Ciclo $nextCycle!";
    }

    // Configuración específica de Android
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pomodoro_channel', // Debe coincidir con el ID del canal creado
      'Notificaciones Pomodō',
      channelDescription: 'Canal para notificaciones de fin de ciclo Pomodoro.',
      importance: Importance.max, // Máxima importancia para que aparezca como pop-up
      priority: Priority.high, // Alta prioridad
      ticker: 'Pomodō Timer', // Texto corto en la barra de estado
      playSound: false, // Sonido manejado por AudioService
      enableVibration: true, // Usar la vibración definida en el canal (o definir un patrón aquí)
      // styleInformation: DefaultStyleInformation(true, true), // Estilo por defecto
      // Podrías usar BigTextStyleInformation(body) si el 'body' fuera muy largo
    );

    // Configuración específica de iOS
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true, // Mostrar alerta
      presentSound: false, // Sonido manejado por AudioService
      presentBadge: true, // Opcional: Actualizar el número en el ícono de la app
      // badgeNumber: 1, // Podrías poner un número si lo gestionas
    );

    // Combinar configuraciones de plataforma
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails, iOS: iOSDetails);

    // Mostrar la notificación
    try {
      await flutterLocalNotificationsPlugin.show(
        0, // ID de la notificación (0 reemplaza la anterior si existe)
        title,
        body,
        platformDetails,
        payload: payload, // Adjuntar el payload definido
      );
      print("🔔 Mostrando notificación: $title");
    } catch (e) {
      print("❌ Error al mostrar notificación: $e");
    }
  }
}