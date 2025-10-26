// lib/providers/stopwatch_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math'; // Para Random
import '../services/android_timer_notification_service.dart'; // <-- *** NUEVA LÍNEA ***

// Asegúrate de que use 'ChangeNotifier' o 'with ChangeNotifier'
class StopwatchProvider with ChangeNotifier {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  // --- Tips Contextuales --- (Sin cambios)
  final List<String> stopwatchTips = [
    "Mide cuánto tiempo te lleva completar tareas específicas.",
    "Usa el cronómetro para mejorar tu velocidad en ejercicios o prácticas.",
    "Ideal para registrar el tiempo dedicado a actividades sin un límite fijo.",
    "Puedes usarlo para rastrear interrupciones durante tu trabajo.",
    "Compara tiempos entre diferentes intentos de la misma tarea.",
  ];
  String _currentTip = "";
  // -----------------------------

  // --- Getters --- (Sin cambios)
  bool get isRunning => _stopwatch.isRunning;
  Duration get currentDuration => _stopwatch.elapsed;
  String get currentTip => _currentTip; // Getter para el Tip
  // ---------------------------------

  // Constructor para inicializar el primer tip (Sin cambios)
  StopwatchProvider() {
    _updateTip();
  }

   // Método para actualizar el tip aleatoriamente (Sin cambios)
  void _updateTip() {
    final random = Random();
    _currentTip = stopwatchTips[random.nextInt(stopwatchTips.length)];
    // No se notifica aquí
  }

  // Formatear tiempo transcurrido (MM:SS) (Sin cambios)
  String get formattedTime {
    final elapsedSeconds = _stopwatch.elapsed.inSeconds;
    final minutes = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // --- Métodos de Control ---
  void startStopwatch() {
    if (_stopwatch.isRunning) { // --- DETENIENDO ---
      _stopwatch.stop();
      _timer?.cancel();
      _updateTip(); // Actualizar tip al parar
      // *** NUEVO: Detener notificación Android ***
      AndroidTimerNotificationService.stop();
      // *** FIN NUEVO ***
    } else { // --- INICIANDO ---
      _stopwatch.start();
      _updateTip(); // Actualizar tip al iniciar
      // *** NUEVO: Iniciar notificación Android ***
      AndroidTimerNotificationService.start(formattedTime, "Cronómetro", true);
      // *** FIN NUEVO ***

      // Timer para actualizar la UI cada segundo
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) { // Mantenido en 1 segundo para reducir updates
        if (_stopwatch.isRunning) {
          // *** NUEVO: Actualizar notificación Android cada segundo ***
           AndroidTimerNotificationService.update(formattedTime, true);
          // *** FIN NUEVO ***
          notifyListeners(); // Notifica UI Flutter
        } else {
          _timer?.cancel(); // Detener el timer si el stopwatch se paró
        }
      });
    }
    notifyListeners(); // Notificar cambio a isRunning
  }

  void resetStopwatch() {
    _stopwatch.stop();
    _stopwatch.reset();
    _timer?.cancel();
     // *** NUEVO: Detener notificación Android ***
    AndroidTimerNotificationService.stop();
    // *** FIN NUEVO ***
    _updateTip(); // Actualizar tip al resetear
    notifyListeners();
  }

  // *** NUEVO: dispose modificado para incluir stop ***
  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop(); // Asegura detener el stopwatch interno
    // *** NUEVO: Detener notificación Android ***
    AndroidTimerNotificationService.stop();
    // *** FIN NUEVO ***
    super.dispose();
  }
  // *** FIN NUEVO ***
}