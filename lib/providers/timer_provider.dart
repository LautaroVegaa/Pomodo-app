// lib/providers/timer_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart'; // 🎵 NUEVO: para reproducir sonido local

enum PomodoroPhase { work, shortBreak, longBreak }

class TimerProvider extends ChangeNotifier {
  // --- CONFIGURACIÓN DE DURACIÓN (en minutos) ---
  int _workDurationMinutes = 25;
  int _shortBreakDurationMinutes = 5;
  final int _longBreakDurationMinutes = 15;

  // --- ESTADO DEL TEMPORIZADOR ---
  int _remainingTimeSeconds = 25 * 60;
  Timer? _timer;
  bool _isRunning = false;
  PomodoroPhase _currentPhase = PomodoroPhase.work;
  int _currentCycle = 1;

  String _userName = "Usuario";
  DateTime _lastUpdatedDate = DateTime.now();

  // --- Notificaciones y Audio ---
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer()..setVolume(1.0); // 🎵 NUEVO

  // --- GETTERS ---
  int get workDurationMinutes => _workDurationMinutes;
  int get shortBreakDurationMinutes => _shortBreakDurationMinutes;
  int get longBreakDurationMinutes => _longBreakDurationMinutes;
  int get remainingTimeSeconds => _remainingTimeSeconds;
  bool get isRunning => _isRunning;
  PomodoroPhase get currentPhase => _currentPhase;
  int get currentCycle => _currentCycle;
  int get completedCycles => _currentCycle > 1 ? _currentCycle - 1 : 0;
  int get totalTimeStudiedInMinutes => completedCycles * _workDurationMinutes;
  String get userName => _userName;

  String get formattedTime {
    int minutes = _remainingTimeSeconds ~/ 60;
    int seconds = _remainingTimeSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedTimeStudied {
    int totalMinutes = totalTimeStudiedInMinutes;
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  // --- SETTERS ---
  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  Future<void> setWorkDuration(int minutes) async {
    _workDurationMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('work_duration', minutes);
    if (!_isRunning && _currentPhase == PomodoroPhase.work) {
      _remainingTimeSeconds = minutes * 60;
    }
    notifyListeners();
  }

  Future<void> setShortBreakDuration(int minutes) async {
    _shortBreakDurationMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('short_break_duration', minutes);
    if (!_isRunning && _currentPhase == PomodoroPhase.shortBreak) {
      _remainingTimeSeconds = minutes * 60;
    }
    notifyListeners();
  }

  // --- Cargar configuración guardada ---
  Future<void> _loadDurationsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _workDurationMinutes = prefs.getInt('work_duration') ?? 25;
    _shortBreakDurationMinutes = prefs.getInt('short_break_duration') ?? 5;
    _remainingTimeSeconds = _workDurationMinutes * 60;
  }

  // --- Inicialización de notificaciones ---
  Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Pedir permiso explícito en Android 13+
  await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.requestNotificationsPermission();


  // Crear canal de notificación si no existe (Android)
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'pomodoro_channel', // mismo ID que usás en _showNotificationAndPlaySound
    'Notificaciones Pomodō',
    description:
        'Canal de notificaciones para finales de ciclo de Pomodoro.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}


  // --- Mostrar notificación + reproducir sonido desde assets ---
  Future<void> _showNotificationAndPlaySound(PomodoroPhase phase) async {
    String title;
    String body;

    if (phase == PomodoroPhase.work) {
      title = "¡Fin del Enfoque! 🔔";
      body =
          "Tómate un ${_currentCycle % 4 == 0 ? 'descanso largo' : 'descanso corto'} y recarga energías.";
    } else {
      title = "¡Fin del Descanso! 💪";
      body = "Es hora de volver al enfoque. ¡Ciclo ${_currentCycle + 1}!";
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pomodoro_channel',
      'Notificaciones Pomodō',
      channelDescription:
          'Canal de notificaciones para finales de ciclo de Pomodoro.',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'timer-alert',
      playSound: false, // 🔇 Desactivamos sonido del sistema
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: false, // 🔇 iOS sin sonido interno
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails, iOS: iOSDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
      payload: 'cycle-completed',
    );

    // 🎵 Reproducir sonido desde assets/audio/pomodoro_ring.wav
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/pomodoro_ring.wav'));
    } catch (e) {
      print('❌ Error al reproducir sonido: $e');
    }
  }

  // --- Cargar estadísticas del día desde Supabase ---
  Future<void> _loadTodayStats() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final data = await supabase
          .from('pomodoro_sessions')
          .select('duration_minutes, completed_at, type')
          .eq('user_id', user.id)
          .eq('type', 'work')
          .gte('completed_at', startOfDay.toIso8601String());

      int totalMinutes = 0;
      int totalSessions = 0;

      for (var row in data) {
        totalMinutes += (row['duration_minutes'] as num?)?.toInt() ?? 0;
        totalSessions++;
      }

      _currentCycle = totalSessions + 1;
      _lastUpdatedDate = today;
      notifyListeners();
    } catch (e) {
      print("❌ Error al cargar sesiones del día: $e");
    }
  }

  // --- Guardar sesión en Supabase ---
  Future<void> _savePomodoroSession(int durationMinutes, String type) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;

    try {
      await supabase.from('pomodoro_sessions').insert({
        'user_id': user.id,
        'duration_minutes': durationMinutes,
        'type': type,
        'completed_at': DateTime.now().toIso8601String(),
      });

      print("✅ Sesión guardada en Supabase ($type - $durationMinutes min)");
      await _loadTodayStats();
    } catch (e) {
      print("❌ Error al guardar sesión: $e");
    }
  }

  // --- Lógica del temporizador ---
  void startStopTimer() {
    if (DateTime.now().day != _lastUpdatedDate.day) {
      _currentCycle = 1;
      _lastUpdatedDate = DateTime.now();
      notifyListeners();
    }

    if (_isRunning) {
      _timer?.cancel();
      _isRunning = false;
    } else {
      _isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingTimeSeconds > 0) {
          _remainingTimeSeconds--;
        } else {
          _showNotificationAndPlaySound(_currentPhase);
          if (_currentPhase == PomodoroPhase.work) {
            _savePomodoroSession(_workDurationMinutes, "work");
          }
          _handleNextPhase(true);
        }
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void skipPhase() {
    _handleNextPhase(false);
  }

  void _handleNextPhase(bool autoStartNext) {
    _isRunning = false;
    _timer?.cancel();

    if (_currentPhase == PomodoroPhase.work) {
      if (_currentCycle < 4) {
        _currentPhase = PomodoroPhase.shortBreak;
        _remainingTimeSeconds = _shortBreakDurationMinutes * 60;
      } else {
        _currentPhase = PomodoroPhase.longBreak;
        _remainingTimeSeconds = _longBreakDurationMinutes * 60;
      }
    } else {
      if (_currentPhase == PomodoroPhase.longBreak) {
        _currentCycle = 1;
      } else {
        _currentCycle++;
      }
      _currentPhase = PomodoroPhase.work;
      _remainingTimeSeconds = _workDurationMinutes * 60;
    }

    notifyListeners();

    if (autoStartNext) startStopTimer();
  }

  void resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _currentPhase = PomodoroPhase.work;
    _currentCycle = 1;
    _remainingTimeSeconds = _workDurationMinutes * 60;
    notifyListeners();
  }

  // --- Constructor ---
  TimerProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    await _loadDurationsFromPrefs();
    await _loadTodayStats();
    await _initializeNotifications();
    notifyListeners();
  }

  void loadTodayStatsIfAvailable() {
    _loadTodayStats();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
