// lib/providers/simple_timer_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math'; // Para Random
// ✅ 1. Importar los servicios
import '../services/notification_service.dart';
import '../services/audio_service.dart';
import '../services/android_timer_notification_service.dart'; // <-- *** NUEVA LÍNEA ***

class SimpleTimerProvider extends ChangeNotifier {
  // ✅ 2. Añadir instancias de los servicios
  final NotificationService _notificationService = NotificationService();
  final AudioService _audioService = AudioService();

  int _initialDurationSeconds = 10 * 60; // 10 minutos por defecto
  int _remainingTimeSeconds = 10 * 60;
  Timer? _timer;
  bool _isRunning = false;

  // --- Tips Contextuales ---
  final List<String> timerTips = [
    "Usa un temporizador para tareas con límite de tiempo definido.",
    "Programa alarmas cortas para recordarte tomar descansos rápidos.",
    "Establecer un tiempo te ayuda a enfocarte en finalizar la tarea.",
    "Ideal para técnicas como 'Timeboxing' donde asignas bloques fijos.",
    "Un temporizador visible puede aumentar tu sentido de urgencia.",
    "Divide tareas grandes en bloques de tiempo manejables.",
  ];
  String _currentTip = "";
  // -----------------------------

  // --- Getters ---
  int get remainingTimeSeconds => _remainingTimeSeconds;
  bool get isRunning => _isRunning;
  int get initialDurationSeconds => _initialDurationSeconds;
  String get currentTip => _currentTip;
  // ---------------------------------

  // Constructor
  SimpleTimerProvider() {
    _updateTip(); // Establecer el primer tip al crear el provider
     // No es necesario inicializar servicios aquí, NotificationService se auto-inicializa
  }

  // Método para actualizar el tip aleatoriamente
  void _updateTip() {
    final random = Random();
    String newTip = _currentTip;
    if (timerTips.length > 1) {
      while (newTip == _currentTip) {
        newTip = timerTips[random.nextInt(timerTips.length)];
      }
    } else if (timerTips.isNotEmpty) {
      newTip = timerTips[0];
    }
    _currentTip = newTip;
    // No notificamos aquí directamente
  }

  // Formatear tiempo restante (MM:SS)
  String get formattedTime {
    int minutes = _remainingTimeSeconds ~/ 60;
    int seconds = _remainingTimeSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // --- Métodos de Control ---
  void setInitialDuration(int seconds) {
    if (!_isRunning) {
      _initialDurationSeconds = seconds >= 0 ? seconds : 0;
      _remainingTimeSeconds = _initialDurationSeconds;
      notifyListeners();
    }
  }

  void startTimer() {
    if (_isRunning || _remainingTimeSeconds == 0) return;
    _isRunning = true;
    _updateTip(); // Actualizar tip al iniciar
    // *** NUEVO: Iniciar notificación Android ***
    AndroidTimerNotificationService.start(formattedTime, "Timer", _isRunning);
    // *** FIN NUEVO ***
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTimeSeconds > 0) {
        _remainingTimeSeconds--;
        // *** NUEVO: Actualizar notificación Android en cada tick ***
        if (_isRunning) { // Solo si sigue corriendo
          AndroidTimerNotificationService.update(formattedTime, _isRunning);
        }
        // *** FIN NUEVO ***
      } else {
        _timer?.cancel();
        _isRunning = false;
        // *** NUEVO: Detener notificación Android ***
        AndroidTimerNotificationService.stop();
        // *** FIN NUEVO ***

        // ✅ 3. LLAMAR A LOS SERVICIOS AL TERMINAR
        _notificationService.showSimpleTimerNotification(
            initialDuration: _initialDurationSeconds // Pasa la duración inicial
        );
        _audioService.playPomodoroSound(); // Reutilizamos el mismo sonido

        _updateTip(); // Actualizar tip al finalizar
      }
      // Notificar cambio de tiempo restante (y estado si finalizó)
      // Asegurarse de que el widget todavía exista antes de notificar
      // Esto es una buena práctica general, aunque Provider ya maneja esto.
      // if (mounted) { // Esta comprobación no es válida en ChangeNotifier
           notifyListeners();
      // } else {
      //     _timer?.cancel(); // Si el widget ya no existe, cancelar el timer
      // }
    });
    notifyListeners(); // Notificar cambio a _isRunning
  }

  void pauseTimer() {
    if (!_isRunning) return;
    _timer?.cancel();
    _isRunning = false;
    _audioService.stopSound(); // ✅ 4. Detener sonido al pausar
    // *** NUEVO: Actualizar notificación Android a pausado ***
    AndroidTimerNotificationService.update(formattedTime, _isRunning, type: "Timer");
    // *** FIN NUEVO ***
    _updateTip();
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _remainingTimeSeconds = _initialDurationSeconds;
    _audioService.stopSound(); // ✅ 4. Detener sonido al resetear
    // *** NUEVO: Detener notificación Android ***
    AndroidTimerNotificationService.stop();
    // *** FIN NUEVO ***
    _updateTip();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioService.dispose(); // ✅ 5. Liberar recursos de audio
    // *** NUEVO: Detener notificación Android ***
    AndroidTimerNotificationService.stop();
    // *** FIN NUEVO ***
    super.dispose();
  }

  // Variables placeholder para compatibilidad con la lógica de notificación/sonido existente
  // (Si ya tenías control global para esto, úsalo, si no, puedes añadirlas)
  bool get _notificationsEnabled => true; // Asume habilitado
  bool get _soundEnabled => true; // Asume habilitado
}