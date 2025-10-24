import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';

enum PomodoroPhase { work, shortBreak, longBreak }

class TimerProvider extends ChangeNotifier {
  // --- CONFIGURACIÓN DE DURACIÓN (en minutos) ---
  int _workDurationMinutes = 25;
  int _shortBreakDurationMinutes = 5;
  int _longBreakDurationMinutes = 15; // ✅ ahora editable

  // --- CONFIGURACIÓN AVANZADA ---
  bool _autoStartBreaks = false;
  bool _autoStartPomodoros = false;
  int _longBreakInterval = 4;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;

  // --- ESTADO DEL TEMPORIZADOR ---
  int _remainingTimeSeconds = 25 * 60;
  Timer? _timer;
  bool _isRunning = false;
  PomodoroPhase _currentPhase = PomodoroPhase.work;
  int _currentCycle = 1;

  String _userName = "Usuario";
  DateTime _lastUpdatedDate = DateTime.now();

  // --- NUEVO: Racha diaria ---
  int _currentStreak = 0;
  int get currentStreak => _currentStreak;

 // --- DATOS Y CONCIENTIZACIÓN (basados en Franco Pisso) ---

final List<String> focusPhrases = [
  "Tu cerebro tarda más de 20 minutos en recuperar el foco después de una distracción.",
  "Cambiar de estímulo cada 10 segundos entrena la dispersión mental.",
  "La dopamina se libera antes del placer, no cuando lo disfrutás.",
  "El exceso de estímulos debilita tu tolerancia al aburrimiento.",
  "Cada video corto enseña a tu mente a buscar recompensa inmediata.",
  "Las emociones rápidas agotan tu capacidad de pensar lento.",
  "El foco es un músculo: si no lo usás, se atrofia.",
  "Tu atención no se perdió, se entrenó para cambiar de tema cada segundo.",
  "La dopamina fácil secuestra tu curiosidad natural.",
  "La sobreestimulación te impide sostener atención profunda.",
  "El cerebro cansado evita tareas que requieren esfuerzo.",
  "El scroll constante entrena la procrastinación.",
  "Cada notificación compite con tu pensamiento más importante.",
  "La mente dispersa busca escape, no aprendizaje.",
  "Cuanto más emoción instantánea consumís, menos foco retenés.",
];

final List<String> breakPhrases = [
  "Después de horas de redes no estás descansado: estás sobrecargado.",
  "La 'resaca emocional' es real: tu mente se agota por exceso de emociones.",
  "Sentirte vacío después del scroll es un signo de sobreestimulación.",
  "No estás cansado de trabajar: estás cansado de sentir sin parar.",
  "Dormir no cura el agotamiento emocional del scroll nocturno.",
  "Una pausa sin pantalla es descanso real.",
  "El aburrimiento activa la creatividad y restaura el foco.",
  "Tu mente se repara cuando no recibe estímulos nuevos.",
  "Cada minuto sin dopamina fácil es un entrenamiento de calma.",
  "Ver contenido emocionalmente intenso genera agotamiento invisible.",
  "La calma activa tu corteza prefrontal, la parte que decide bien.",
  "La mente necesita silencio tanto como sueño.",
  "Evitar pantallas antes de dormir mejora tu energía al día siguiente.",
  "El descanso consciente reequilibra tu sistema nervioso.",
  "La dopamina baja cuando frenás, y ahí empieza la claridad.",
];

  String _currentPhrase = "";
  String get currentPhrase => _currentPhrase;

  void _updateMotivationalPhrase() {
    final random = Random();
    if (_currentPhase == PomodoroPhase.work) {
      _currentPhrase = focusPhrases[random.nextInt(focusPhrases.length)];
    } else {
      _currentPhrase = breakPhrases[random.nextInt(breakPhrases.length)];
    }
    notifyListeners();
  }

  // --- Notificaciones y Audio ---
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer()..setVolume(1.0);

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

  bool get autoStartBreaks => _autoStartBreaks;
  bool get autoStartPomodoros => _autoStartPomodoros;
  int get longBreakInterval => _longBreakInterval;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;

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

  Future<void> setLongBreakDuration(int minutes) async {
    _longBreakDurationMinutes = minutes < 1 ? 1 : minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('long_break_duration', _longBreakDurationMinutes);
    notifyListeners();
  }

  Future<void> setAutoStartBreaks(bool value) async {
    _autoStartBreaks = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_start_breaks', value);
    notifyListeners();
  }

  Future<void> setAutoStartPomodoros(bool value) async {
    _autoStartPomodoros = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_start_pomodoros', value);
    notifyListeners();
  }

  Future<void> setLongBreakInterval(int value) async {
    _longBreakInterval = value < 1 ? 1 : value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('long_break_interval', _longBreakInterval);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', value);
    notifyListeners();
  }

  // --- Cargar configuración guardada ---
  Future<void> _loadDurationsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _workDurationMinutes = prefs.getInt('work_duration') ?? 25;
    _shortBreakDurationMinutes = prefs.getInt('short_break_duration') ?? 5;
    _longBreakDurationMinutes = prefs.getInt('long_break_duration') ?? 15;
    _autoStartBreaks = prefs.getBool('auto_start_breaks') ?? false;
    _autoStartPomodoros = prefs.getBool('auto_start_pomodoros') ?? false;
    _longBreakInterval = prefs.getInt('long_break_interval') ?? 4;
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;

    _remainingTimeSeconds = _workDurationMinutes * 60;
  }

  // --- NUEVO: Calcular la racha diaria (CORREGIDO) ---
  Future<void> _loadStreak() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await supabase
          .from('pomodoro_sessions')
          .select('completed_at')
          .eq('user_id', user.id)
          .order('completed_at', ascending: false)
          .limit(30);

      // 1. Obtener un Set de fechas únicas (solo día, ignorando el tiempo) en hora local
      final now = DateTime.now().toLocal();
      final todayStart = DateTime(now.year, now.month, now.day);
      
      final uniqueDays = data
          .map<DateTime>((row) => DateTime.parse(row['completed_at']).toLocal())
          .map((d) => DateTime(d.year, d.month, d.day))
          .toSet();
      
      // 2. Inicializar y verificar la racha
      int streak = 0;
      DateTime checkDay = todayStart;

      // Paso 1: Verificar si hay sesión hoy e inicializar el conteo.
      if (uniqueDays.contains(todayStart)) {
          streak = 1;
          checkDay = todayStart.subtract(const Duration(days: 1)); // El próximo día esperado es ayer
      } else {
          // Si no hay sesión hoy, la racha consecutiva HASTA HOY es 0 por definición.
          _currentStreak = 0;
          notifyListeners();
          return;
      }
      
      // Paso 2: Contar días consecutivos hacia atrás desde ayer.
      while (true) {
          if (uniqueDays.contains(checkDay)) {
              streak++;
              checkDay = checkDay.subtract(const Duration(days: 1));
          } else {
              break; // La racha se rompe.
          }
      }

      _currentStreak = streak;
      notifyListeners();
    } catch (e) {
      print("❌ Error al calcular racha: $e");
    }
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

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'pomodoro_channel',
      'Notificaciones Pomodō',
      description: 'Canal de notificaciones para finales de ciclo de Pomodoro.',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // --- Mostrar notificación + reproducir sonido ---
  Future<void> _showNotificationAndPlaySound(PomodoroPhase phase) async {
    if (_notificationsEnabled) {
      String title;
      String body;

      if (phase == PomodoroPhase.work) {
        title = "¡Fin del Enfoque! 🔔";
        body =
            "Tómate un ${_currentCycle % _longBreakInterval == 0 ? 'descanso largo' : 'descanso corto'} y recarga energías.";
      } else {
        title = "¡Fin del Descanso! 💪";
        body = "Es hora de volver al enfoque. ¡Ciclo ${_currentCycle + 1}!";
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'pomodoro_channel',
        'Notificaciones Pomodō',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'timer-alert',
        playSound: false,
      );

      const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentSound: false,
      );

      const NotificationDetails platformDetails =
          NotificationDetails(android: androidDetails, iOS: iOSDetails);

      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformDetails,
      );
    }

    if (_soundEnabled) {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource('audio/pomodoro_ring.wav'));
      } catch (e) {
        print('❌ Error al reproducir sonido: $e');
      }
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
      await _loadStreak(); // Actualizar racha al guardar sesión (CORREGIDO)
    } catch (e) {
      print("❌ Error al guardar sesión: $e");
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

      await _loadStreak(); // También cargar racha al inicio (CORREGIDO)
      notifyListeners();
    } catch (e) {
      print("❌ Error al cargar sesiones del día: $e");
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
          _handleNextPhase(false);
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
      if (_currentCycle % _longBreakInterval == 0) {
        _currentPhase = PomodoroPhase.longBreak;
        _remainingTimeSeconds = _longBreakDurationMinutes * 60;
      } else {
        _currentPhase = PomodoroPhase.shortBreak;
        _remainingTimeSeconds = _shortBreakDurationMinutes * 60;
      }

      _updateMotivationalPhrase(); // cambia frase al pasar a descanso

      if (_autoStartBreaks) {
        startStopTimer();
        return;
      }
    } else {
      if (_currentPhase == PomodoroPhase.longBreak) {
        _currentCycle = 1;
      } else {
        _currentCycle++;
      }
      _currentPhase = PomodoroPhase.work;
      _remainingTimeSeconds = _workDurationMinutes * 60;

      _updateMotivationalPhrase(); // cambia frase al pasar a enfoque

      if (_autoStartPomodoros) {
        startStopTimer();
        return;
      }
    }

    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _currentPhase = PomodoroPhase.work;
    _currentCycle = 1;
    _remainingTimeSeconds = _workDurationMinutes * 60;
    _updateMotivationalPhrase(); // FIX: refresca frase al resetear
    notifyListeners();
  }

  // --- Inicialización ---
  TimerProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    await _loadDurationsFromPrefs();
    await _loadTodayStats();
    await _initializeNotifications();
    _updateMotivationalPhrase(); // FIX: genera primera frase visible
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