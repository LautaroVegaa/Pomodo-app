// lib/providers/simple_timer_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math'; // Para Random

class SimpleTimerProvider extends ChangeNotifier {
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
  }

  // Método para actualizar el tip aleatoriamente
  void _updateTip() {
    final random = Random();
    // Evitar seleccionar el mismo tip dos veces seguidas (opcional)
    String newTip = _currentTip;
    if (timerTips.length > 1) {
      while (newTip == _currentTip) {
        newTip = timerTips[random.nextInt(timerTips.length)];
      }
    } else if (timerTips.isNotEmpty) {
      newTip = timerTips[0];
    }
    _currentTip = newTip;
    // No notificamos aquí directamente, se hará a través de los métodos de control
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
      // _updateTip(); // ❗️❗️ CORRECCIÓN: NO actualizar el tip aquí ❗️❗️
      notifyListeners(); // Notificar solo cambio de duración/tiempo restante
    }
  }

  void startTimer() {
    if (_isRunning || _remainingTimeSeconds == 0) return;
    _isRunning = true;
    _updateTip(); // Actualizar tip al iniciar
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTimeSeconds > 0) {
        _remainingTimeSeconds--;
      } else {
        _timer?.cancel();
        _isRunning = false;
        _updateTip(); // Actualizar tip al finalizar
      }
      notifyListeners(); // Notificar cambio de tiempo restante (y estado si finalizó)
    });
    notifyListeners(); // Notificar cambio a _isRunning
  }

  void pauseTimer() {
    if (!_isRunning) return;
    _timer?.cancel();
    _isRunning = false;
    _updateTip(); // Actualizar tip al pausar
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _remainingTimeSeconds = _initialDurationSeconds;
    _updateTip(); // Actualizar tip al resetear
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}