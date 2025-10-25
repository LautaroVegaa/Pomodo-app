// lib/providers/timer_provider.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Se eliminan imports de notification y audio player
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:audioplayers/audioplayers.dart';
import '../services/pomodoro_data_service.dart';
// ✅ Nuevos imports para los servicios
import '../services/notification_service.dart';
import '../services/audio_service.dart';

// Enum PomodoroPhase sin cambios
enum PomodoroPhase { work, shortBreak, longBreak }

class TimerProvider extends ChangeNotifier {
  final PomodoroDataService _dataService = PomodoroDataService();
  // ✅ Instancias de los nuevos servicios
  final NotificationService _notificationService = NotificationService();
  final AudioService _audioService = AudioService();


  // --- CONFIGURACIÓN DE DURACIÓN --- (Sin cambios)
  int _workDurationMinutes = 25;
  int _shortBreakDurationMinutes = 5;
  int _longBreakDurationMinutes = 15;

  // --- CONFIGURACIÓN AVANZADA --- (Sin cambios)
  bool _autoStartBreaks = false;
  bool _autoStartPomodoros = false;
  int _longBreakInterval = 4;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;

  // --- ESTADO DEL TEMPORIZADOR --- (Sin cambios)
  int _remainingTimeSeconds = 25 * 60;
  Timer? _timer;
  bool _isRunning = false;
  PomodoroPhase _currentPhase = PomodoroPhase.work;
  int _currentCycle = 1;

  // --- DATOS Y CONCIENTIZACIÓN --- (Sin cambios)
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
  void _updateMotivationalPhrase() { // Sin cambios
    final random = Random();
    if (_currentPhase == PomodoroPhase.work) {
      _currentPhrase = focusPhrases.isNotEmpty ? focusPhrases[random.nextInt(focusPhrases.length)] : '';
    } else {
      _currentPhrase = breakPhrases.isNotEmpty ? breakPhrases[random.nextInt(breakPhrases.length)] : '';
    }
     // No notificamos aquí directamente
  }

  // === ELIMINADO ===
  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = ...;
  // final AudioPlayer _audioPlayer = ...;

  // === ESTADO CENTRALIZADO DE ESTADÍSTICAS === (Sin cambios)
  int _todaySessions = 0;
  int _todayMinutes = 0;
  int _weekSessions = 0;
  int _weekMinutes = 0;
  int _monthSessions = 0;
  int _monthMinutes = 0;
  Map<String, int> _weeklyDataMap = {'Mon': 0, 'Tue': 0, 'Wed': 0, 'Thu': 0, 'Fri': 0, 'Sat': 0, 'Sun': 0};
  int _currentStreak = 0;
  String _bestDay = '';
  int _bestDayMinutes = 0;
  double _weeklyAverage = 0.0;
  double _dailyAverage = 0.0;
  DateTime _lastUpdatedDate = DateTime(2000);

  // === GETTERS === (Sin cambios)
  int get todaySessions => _todaySessions;
  int get todayMinutes => _todayMinutes;
  int get weekSessions => _weekSessions;
  int get weekMinutes => _weekMinutes;
  int get monthSessions => _monthSessions;
  int get monthMinutes => _monthMinutes;
  Map<String, int> get weeklyDataMap => Map.unmodifiable(_weeklyDataMap);
  int get currentStreak => _currentStreak;
  String get bestDay => _bestDay;
  int get bestDayMinutes => _bestDayMinutes;
  double get weeklyAverage => _weeklyAverage;
  double get dailyAverage => _dailyAverage;
  int get completedCycles => _todaySessions;
  String get formattedTimeStudied { /* ... sin cambios ... */
    int hours = _todayMinutes ~/ 60;
    int minutes = _todayMinutes % 60;
    return '${hours}h ${minutes}m';
  }
  int get workDurationMinutes => _workDurationMinutes;
  int get shortBreakDurationMinutes => _shortBreakDurationMinutes;
  int get longBreakDurationMinutes => _longBreakDurationMinutes;
  int get remainingTimeSeconds => _remainingTimeSeconds;
  bool get isRunning => _isRunning;
  PomodoroPhase get currentPhase => _currentPhase;
  int get currentCycle => _currentCycle;
  String get userName => "Usuario";
  bool get autoStartBreaks => _autoStartBreaks;
  bool get autoStartPomodoros => _autoStartPomodoros;
  int get longBreakInterval => _longBreakInterval;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  String get formattedTime { /* ... sin cambios ... */
    int minutes = _remainingTimeSeconds ~/ 60;
    int seconds = _remainingTimeSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  String get currentPhrase => _currentPhrase;


  // --- SETTERS de configuración --- (Sin cambios)
  Future<void> setWorkDuration(int minutes) async { /* ... sin cambios ... */
     _workDurationMinutes = minutes;
     final prefs = await SharedPreferences.getInstance();
     await prefs.setInt('work_duration', minutes);
     if (!_isRunning && _currentPhase == PomodoroPhase.work) {
       _remainingTimeSeconds = minutes * 60;
     }
     notifyListeners();
  }
  Future<void> setShortBreakDuration(int minutes) async { /* ... sin cambios ... */
    _shortBreakDurationMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('short_break_duration', minutes);
    if (!_isRunning && _currentPhase == PomodoroPhase.shortBreak) {
      _remainingTimeSeconds = minutes * 60;
    }
    notifyListeners();
  }
  Future<void> setLongBreakDuration(int minutes) async { /* ... sin cambios ... */
     _longBreakDurationMinutes = minutes < 1 ? 1 : minutes;
     final prefs = await SharedPreferences.getInstance();
     await prefs.setInt('long_break_duration', _longBreakDurationMinutes);
     if (!_isRunning && _currentPhase == PomodoroPhase.longBreak) {
       _remainingTimeSeconds = _longBreakDurationMinutes * 60;
     }
     notifyListeners();
  }
  Future<void> setAutoStartBreaks(bool value) async { /* ... sin cambios ... */
    _autoStartBreaks = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_start_breaks', value);
    notifyListeners();
  }
  Future<void> setAutoStartPomodoros(bool value) async { /* ... sin cambios ... */
    _autoStartPomodoros = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_start_pomodoros', value);
    notifyListeners();
  }
  Future<void> setLongBreakInterval(int value) async { /* ... sin cambios ... */
    _longBreakInterval = value < 1 ? 1 : value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('long_break_interval', _longBreakInterval);
    notifyListeners();
  }
  Future<void> setNotificationsEnabled(bool value) async { /* ... sin cambios ... */
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    notifyListeners();
  }
  Future<void> setSoundEnabled(bool value) async { /* ... sin cambios ... */
    _soundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', value);
    notifyListeners();
  }
  Future<void> _loadDurationsFromPrefs() async { /* ... sin cambios ... */
     final prefs = await SharedPreferences.getInstance();
     _workDurationMinutes = prefs.getInt('work_duration') ?? 25;
     _shortBreakDurationMinutes = prefs.getInt('short_break_duration') ?? 5;
     _longBreakDurationMinutes = prefs.getInt('long_break_duration') ?? 15;
     _autoStartBreaks = prefs.getBool('auto_start_breaks') ?? false;
     _autoStartPomodoros = prefs.getBool('auto_start_pomodoros') ?? false;
     _longBreakInterval = prefs.getInt('long_break_interval') ?? 4;
     _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
     _soundEnabled = prefs.getBool('sound_enabled') ?? true;

     if (!_isRunning) {
         switch (_currentPhase) {
           case PomodoroPhase.work: _remainingTimeSeconds = _workDurationMinutes * 60; break;
           case PomodoroPhase.shortBreak: _remainingTimeSeconds = _shortBreakDurationMinutes * 60; break;
           case PomodoroPhase.longBreak: _remainingTimeSeconds = _longBreakDurationMinutes * 60; break;
         }
     }
  }


  // === ELIMINADO ===
  // Future<void> _initializeNotifications() async { ... }
  // Future<void> _showNotificationAndPlaySound(PomodoroPhase phase) async { ... }

  // === Métodos de Estadísticas === (Sin cambios)
  Future<void> _updateAggregatedStatsAndStreak() async { /* ... sin cambios ... */
    final aggregatedStats = await _dataService.loadAggregatedStats();
    final streak = await _dataService.calculateStreak();
    _todaySessions = aggregatedStats['today_sessions'] ?? 0;
    _todayMinutes = aggregatedStats['today_minutes'] ?? 0;
    _weekSessions = aggregatedStats['week_sessions'] ?? 0;
    _weekMinutes = aggregatedStats['week_minutes'] ?? 0;
    _monthSessions = aggregatedStats['month_sessions'] ?? 0;
    _monthMinutes = aggregatedStats['month_minutes'] ?? 0;
    _weeklyDataMap = Map<String, int>.from(aggregatedStats['weekly_data'] ?? {});
    _currentStreak = streak;
    _calculateDerivedStats();
    _currentCycle = _todaySessions + 1;
    final now = DateTime.now().toLocal();
    _lastUpdatedDate = DateTime(now.year, now.month, now.day);
    notifyListeners();
  }
  void _calculateDerivedStats() { /* ... sin cambios ... */
    int bestMins = 0; String bestD = ''; int totalWeekMins = 0;
    _weeklyDataMap.forEach((dayKey, minutes) {
      totalWeekMins += minutes;
      if (minutes > bestMins) { bestMins = minutes; bestD = dayKey; }
    });
    _bestDayMinutes = bestMins; _bestDay = bestD;
    _weeklyAverage = totalWeekMins / 7.0; _dailyAverage = _weeklyAverage;
  }

  // --- Lógica del temporizador --- (Modificada la parte del fin de ciclo)
  void startStopTimer() {
    final now = DateTime.now().toLocal();
    final today = DateTime(now.year, now.month, now.day);
    if (_lastUpdatedDate.year == 2000 || today.isAfter(_lastUpdatedDate)) {
       print("☀️ Nuevo día detectado o primera carga, recargando...");
       _updateAggregatedStatsAndStreak();
    }

    if (_isRunning) {
      _timer?.cancel();
      _isRunning = false;
      _updateMotivationalPhrase();
    } else {
      _isRunning = true;
      _updateMotivationalPhrase();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingTimeSeconds > 0) {
          _remainingTimeSeconds--;
           if (_isRunning) notifyListeners();
        } else { // Tiempo llegó a 0
           _timer?.cancel();
           _isRunning = false;

           // ✅ LLAMADAS A LOS SERVICIOS DE NOTIFICACIÓN Y AUDIO
           if (_notificationsEnabled) {
             _notificationService.showPomodoroNotification(
               phase: _currentPhase,
               currentCycle: _currentCycle, // Usa el ciclo actual calculado por stats
               longBreakInterval: _longBreakInterval,
             );
           }
           if (_soundEnabled) {
             _audioService.playPomodoroSound();
           }
           // ✅ FIN LLAMADAS A SERVICIOS

          bool shouldUpdateStats = false;
          if (_currentPhase == PomodoroPhase.work) {
             shouldUpdateStats = true;
             _dataService.savePomodoroSession(_workDurationMinutes, "work").then((_) {
                 _updateAggregatedStatsAndStreak().then((_){
                    _handleNextPhase(); // Manejar fase DESPUÉS de actualizar stats
                 });
             }).catchError((e) {
                 print("Error guardando sesión: $e. Pasando a siguiente fase.");
                 _handleNextPhase(); // Manejar fase aunque falle el guardado
             });
          }

          // Si no era fase de trabajo (era descanso), manejar la siguiente fase directamente
          if (!shouldUpdateStats) {
             _handleNextPhase();
          }
          // Si era fase de trabajo, _handleNextPhase se llamará en el .then()
        }
      });
    }
    notifyListeners();
  }


  void skipPhase() { // Añadido stopSound
    _timer?.cancel();
    _isRunning = false;
    _audioService.stopSound(); // Detener sonido al saltar
    _handleNextPhase();
  }


  void _handleNextPhase() { // Sin cambios en sí mismo
    _isRunning = false;
    _timer?.cancel();
    PomodoroPhase phaseBeforeChange = _currentPhase;

    if (phaseBeforeChange == PomodoroPhase.work) {
      if (_currentCycle % _longBreakInterval == 0) {
        _currentPhase = PomodoroPhase.longBreak;
        _remainingTimeSeconds = _longBreakDurationMinutes * 60;
      } else {
        _currentPhase = PomodoroPhase.shortBreak;
        _remainingTimeSeconds = _shortBreakDurationMinutes * 60;
      }
    } else {
      _currentPhase = PomodoroPhase.work;
      _remainingTimeSeconds = _workDurationMinutes * 60;
    }
    _updateMotivationalPhrase();

    bool shouldAutoStart = (phaseBeforeChange == PomodoroPhase.work && _autoStartBreaks) ||
                           (phaseBeforeChange != PomodoroPhase.work && _autoStartPomodoros);

    if (shouldAutoStart) {
      startStopTimer();
    } else {
      notifyListeners();
    }
  }


  void resetTimer() { // Añadido stopSound
    _timer?.cancel();
    _isRunning = false;
    _currentPhase = PomodoroPhase.work;
    _remainingTimeSeconds = _workDurationMinutes * 60;
    _updateMotivationalPhrase();
    _audioService.stopSound(); // Detener sonido al resetear
    notifyListeners();
   }


  // --- Inicialización --- (Modificada para inicializar NotificationService)
  TimerProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    await _loadDurationsFromPrefs();
    // ✅ Inicializar servicio de notificaciones
    await _notificationService.initialize();
    await _updateAggregatedStatsAndStreak();
    _updateMotivationalPhrase();
    // notifyListeners() ya está en _updateAggregatedStatsAndStreak
  }

  // refreshStats() sin cambios
  void refreshStats() {
     _updateAggregatedStatsAndStreak();
  }

  // dispose() modificado para incluir audioService.dispose()
  @override
  void dispose() {
    _timer?.cancel();
    _audioService.dispose(); // ✅ Liberar recursos del AudioService
    super.dispose();
   }
}