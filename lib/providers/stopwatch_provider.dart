// lib/providers/stopwatch_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math'; // Para Random

class StopwatchProvider with ChangeNotifier {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  // --- Tips Contextuales ---
  final List<String> stopwatchTips = [
    "Mide cuánto tiempo te lleva completar tareas específicas.",
    "Usa el cronómetro para mejorar tu velocidad en ejercicios o prácticas.",
    "Ideal para registrar el tiempo dedicado a actividades sin un límite fijo.",
    "Puedes usarlo para rastrear interrupciones durante tu trabajo.",
    "Compara tiempos entre diferentes intentos de la misma tarea.",
  ];
  String _currentTip = "";
  // -----------------------------

  // --- Getters ---
  bool get isRunning => _stopwatch.isRunning;
  Duration get currentDuration => _stopwatch.elapsed;
  String get currentTip => _currentTip; // Getter para el Tip
  // ---------------------------------

  // Constructor para inicializar el primer tip
  StopwatchProvider() {
    _updateTip();
  }

   // Método para actualizar el tip aleatoriamente
  void _updateTip() {
    final random = Random();
    _currentTip = stopwatchTips[random.nextInt(stopwatchTips.length)];
    // No se notifica aquí
  }

  // Formatear tiempo transcurrido (MM:SS)
  String get formattedTime {
    final elapsedSeconds = _stopwatch.elapsed.inSeconds;
    final minutes = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // --- Métodos de Control ---
  void startStopwatch() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer?.cancel();
      _updateTip(); // Actualizar tip al parar
    } else {
      _stopwatch.start();
      _updateTip(); // Actualizar tip al iniciar
      // Timer para actualizar la UI cada segundo
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_stopwatch.isRunning) {
          notifyListeners();
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
    _updateTip(); // Actualizar tip al resetear
    notifyListeners();
  }

  // dispose no necesita override explícito para mixins simples
}