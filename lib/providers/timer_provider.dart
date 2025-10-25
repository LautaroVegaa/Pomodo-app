// lib/providers/timer_provider.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/pomodoro_data_service.dart'; // Importar el servicio

enum PomodoroPhase { work, shortBreak, longBreak }

class TimerProvider extends ChangeNotifier {
  final PomodoroDataService _dataService = PomodoroDataService();

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
  int _currentCycle = 1; // Ciclo actual DENTRO DE LA SESIÓN DE HOY

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
  ]; // Asegúrate de tener tus frases aquí
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
  ]; // Asegúrate de tener tus frases aquí
  String _currentPhrase = "";
  // _updateMotivationalPhrase() sin cambios
  void _updateMotivationalPhrase() {
    final random = Random();
    if (_currentPhase == PomodoroPhase.work) {
      _currentPhrase = focusPhrases.isNotEmpty ? focusPhrases[random.nextInt(focusPhrases.length)] : '';
    } else {
      _currentPhrase = breakPhrases.isNotEmpty ? breakPhrases[random.nextInt(breakPhrases.length)] : '';
    }
     // No notificamos aquí directamente para evitar reconstrucciones innecesarias
     // Se notificará cuando cambie el estado principal (ej: al cambiar de fase)
  }


  // --- Notificaciones y Audio --- (Sin cambios)
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer()..setVolume(1.0);
  // _initializeNotifications() sin cambios
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true, requestBadgePermission: true, requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'pomodoro_channel', 'Notificaciones Pomodō',
      description: 'Canal de notificaciones para finales de ciclo de Pomodoro.',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // _showNotificationAndPlaySound() sin cambios
  Future<void> _showNotificationAndPlaySound(PomodoroPhase phase) async {
    if (_notificationsEnabled) {
      String title; String body;
      if (phase == PomodoroPhase.work) {
        title = "¡Fin del Enfoque! 🔔";
        body = "Tómate un ${_currentCycle % _longBreakInterval == 0 ? 'descanso largo' : 'descanso corto'} y recarga energías.";
      } else {
        int nextCycle = (_currentPhase == PomodoroPhase.longBreak) ? 1 : _currentCycle + 1;
        title = "¡Fin del Descanso! 💪"; body = "Es hora de volver al enfoque. ¡Ciclo $nextCycle!";
      }
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'pomodoro_channel', 'Notificaciones Pomodō', channelDescription: 'Canal para notificaciones de fin de ciclo Pomodoro.',
        importance: Importance.max, priority: Priority.high, ticker: 'timer-alert', playSound: false,
      );
      const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(presentAlert: true, presentSound: false);
      const NotificationDetails platformDetails = NotificationDetails(android: androidDetails, iOS: iOSDetails);
      await flutterLocalNotificationsPlugin.show(0, title, body, platformDetails);
    }
    if (_soundEnabled) {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource('audio/pomodoro_ring.wav'));
      } catch (e) { print('❌ Error al reproducir sonido: $e'); }
    }
  }


  // === NUEVO: Estado centralizado para TODAS las estadísticas ===
  int _todaySessions = 0;
  int _todayMinutes = 0;
  int _weekSessions = 0;
  int _weekMinutes = 0;
  int _monthSessions = 0;
  int _monthMinutes = 0;
  Map<String, int> _weeklyDataMap = {'Mon': 0, 'Tue': 0, 'Wed': 0, 'Thu': 0, 'Fri': 0, 'Sat': 0, 'Sun': 0};
  int _currentStreak = 0;
  String _bestDay = ''; // Clave en inglés ('Mon', 'Tue', etc.)
  int _bestDayMinutes = 0;
  double _weeklyAverage = 0.0;
  double _dailyAverage = 0.0; // Usamos weekly por simplicidad
  DateTime _lastUpdatedDate = DateTime(2000); // Fecha inicial lejana para forzar carga

  // === GETTERS para las nuevas estadísticas ===
  int get todaySessions => _todaySessions;
  int get todayMinutes => _todayMinutes;
  int get weekSessions => _weekSessions;
  int get weekMinutes => _weekMinutes;
  int get monthSessions => _monthSessions;
  int get monthMinutes => _monthMinutes;
  Map<String, int> get weeklyDataMap => Map.unmodifiable(_weeklyDataMap); // Devuelve copia inmutable
  int get currentStreak => _currentStreak;
  String get bestDay => _bestDay;
  int get bestDayMinutes => _bestDayMinutes;
  double get weeklyAverage => _weeklyAverage;
  double get dailyAverage => _dailyAverage;

  // Getters existentes que ahora usan los nuevos datos
  int get completedCycles => _todaySessions; // Ahora 'completedCycles' es lo mismo que todaySessions
  String get formattedTimeStudied { // Usa todayMinutes
    int hours = _todayMinutes ~/ 60;
    int minutes = _todayMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  // Getters de configuración (sin cambios)
  int get workDurationMinutes => _workDurationMinutes;
  int get shortBreakDurationMinutes => _shortBreakDurationMinutes;
  int get longBreakDurationMinutes => _longBreakDurationMinutes;
  int get remainingTimeSeconds => _remainingTimeSeconds;
  bool get isRunning => _isRunning;
  PomodoroPhase get currentPhase => _currentPhase;
  int get currentCycle => _currentCycle; // Mantenemos el ciclo actual de la sesión
  String get userName => "Usuario"; // Simplificado por ahora
  bool get autoStartBreaks => _autoStartBreaks;
  bool get autoStartPomodoros => _autoStartPomodoros;
  int get longBreakInterval => _longBreakInterval;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  String get formattedTime { // Sin cambios
    int minutes = _remainingTimeSeconds ~/ 60;
    int seconds = _remainingTimeSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
   }
  String get currentPhrase => _currentPhrase;

  // --- SETTERS de configuración --- (Sin cambios)
  // setWorkDuration, setShortBreakDuration, etc. sin cambios
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
     if (!_isRunning && _currentPhase == PomodoroPhase.longBreak) { // Actualizar tiempo si estamos en long break y no corriendo
       _remainingTimeSeconds = _longBreakDurationMinutes * 60;
     }
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
  // _loadDurationsFromPrefs() sin cambios
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

    // Actualizar tiempo restante SOLO si el timer no está corriendo
    if (!_isRunning) {
        switch (_currentPhase) {
          case PomodoroPhase.work: _remainingTimeSeconds = _workDurationMinutes * 60; break;
          case PomodoroPhase.shortBreak: _remainingTimeSeconds = _shortBreakDurationMinutes * 60; break;
          case PomodoroPhase.longBreak: _remainingTimeSeconds = _longBreakDurationMinutes * 60; break;
        }
    }
  }


  // === Método REVISADO para cargar y procesar TODAS las estadísticas ===
  Future<void> _updateAggregatedStatsAndStreak() async {
    final aggregatedStats = await _dataService.loadAggregatedStats();
    final streak = await _dataService.calculateStreak();

    // Actualizar estado interno
    _todaySessions = aggregatedStats['today_sessions'] ?? 0;
    _todayMinutes = aggregatedStats['today_minutes'] ?? 0;
    _weekSessions = aggregatedStats['week_sessions'] ?? 0;
    _weekMinutes = aggregatedStats['week_minutes'] ?? 0;
    _monthSessions = aggregatedStats['month_sessions'] ?? 0;
    _monthMinutes = aggregatedStats['month_minutes'] ?? 0;
    _weeklyDataMap = Map<String, int>.from(aggregatedStats['weekly_data'] ?? {}); // Asegurar tipo
    _currentStreak = streak;

    // Calcular derivados (mejor día, promedios) AQUI
    _calculateDerivedStats();

     // Actualizar ciclo actual basado en sesiones de hoy
    _currentCycle = _todaySessions + 1;

    final now = DateTime.now().toLocal();
    _lastUpdatedDate = DateTime(now.year, now.month, now.day);

    notifyListeners(); // Notificar a la UI
  }

  // === NUEVO: Método auxiliar para calcular estadísticas derivadas ===
  void _calculateDerivedStats() {
    int bestMins = 0;
    String bestD = '';
    int totalWeekMins = 0;

    _weeklyDataMap.forEach((dayKey, minutes) {
      totalWeekMins += minutes;
      if (minutes > bestMins) {
        bestMins = minutes;
        bestD = dayKey;
      }
    });

    _bestDayMinutes = bestMins;
    _bestDay = bestD; // Clave en inglés
    // Corrección: el promedio semanal debe ser sobre 7 días, no sobre sesiones semanales
    _weeklyAverage = totalWeekMins / 7.0;
    _dailyAverage = _weeklyAverage; // Simplificado
  }


  // --- Lógica del temporizador --- (Modificada para usar _updateAggregatedStatsAndStreak)
  void startStopTimer() {
    final now = DateTime.now().toLocal();
    final today = DateTime(now.year, now.month, now.day);
    // Verificar si _lastUpdatedDate tiene valor inicial o si el día cambió
    if (_lastUpdatedDate.year == 2000 || today.isAfter(_lastUpdatedDate)) {
       print("☀️ Nuevo día detectado o primera carga, recargando estadísticas y reiniciando ciclo.");
       _updateAggregatedStatsAndStreak(); // Recarga TODO al detectar nuevo día
    }

    if (_isRunning) {
      _timer?.cancel();
      _isRunning = false;
      _updateMotivationalPhrase(); // Actualizar frase al pausar
    } else {
      _isRunning = true;
      _updateMotivationalPhrase(); // Actualizar frase al iniciar/reanudar
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingTimeSeconds > 0) {
          _remainingTimeSeconds--;
           if (_isRunning) notifyListeners(); // Notificar cambio de tiempo solo si sigue corriendo
        } else { // Tiempo llegó a 0
           _timer?.cancel(); // Detener el timer actual
           _isRunning = false; // Marcar como no corriendo
          _showNotificationAndPlaySound(_currentPhase); // Notificar fin de fase

          if (_currentPhase == PomodoroPhase.work) {
             // Guardar sesión y LUEGO actualizar stats y manejar fase
             _dataService.savePomodoroSession(_workDurationMinutes, "work").then((_) {
                 print("Sesión guardada, actualizando stats...");
                 _updateAggregatedStatsAndStreak().then((_){
                    // Una vez actualizadas las stats, preparamos la siguiente fase (descanso)
                    print("Stats actualizadas, preparando siguiente fase...");
                    _handleNextPhase(); // Decide si auto-inicia o solo notifica
                 });
             }).catchError((e) {
                 print("Error guardando sesión: $e. Pasando a siguiente fase sin actualizar stats.");
                 // Si falla el guardado, igual pasamos a la siguiente fase
                 _handleNextPhase();
             });
             // No hacemos nada más aquí, esperamos al .then()
          } else {
             // Si terminó un descanso, simplemente pasamos a la siguiente fase
             _handleNextPhase();
          }
        }
      });
    }
    notifyListeners(); // Notificar cambio inicial/pausa de isRunning
  }


   // Helper to just set up variables for the next phase without starting timer
   // Ya no es necesario, _handleNextPhase hace la preparación
   /*
   void _prepareNextPhase() {
     // ... Lógica movida a _handleNextPhase ...
   }
   */

  void skipPhase() {
    _timer?.cancel();
    _isRunning = false;
    _handleNextPhase(); // Saltar a la siguiente fase
  }

  // Maneja el cambio de fase y decide si auto-iniciar
  void _handleNextPhase() {
    _isRunning = false; // Asegurar que está detenido
    _timer?.cancel();

    PomodoroPhase phaseBeforeChange = _currentPhase;

    // --- Preparar la siguiente fase ---
    if (phaseBeforeChange == PomodoroPhase.work) {
      // El ciclo actual (_currentCycle) se actualiza en _updateAggregatedStatsAndStreak
      if (_currentCycle % _longBreakInterval == 0) {
        _currentPhase = PomodoroPhase.longBreak;
        _remainingTimeSeconds = _longBreakDurationMinutes * 60;
      } else {
        _currentPhase = PomodoroPhase.shortBreak;
        _remainingTimeSeconds = _shortBreakDurationMinutes * 60;
      }
    } else { // Si estábamos en descanso
      // El ciclo (_currentCycle) se actualiza en _updateAggregatedStatsAndStreak
      _currentPhase = PomodoroPhase.work;
      _remainingTimeSeconds = _workDurationMinutes * 60;
    }
    _updateMotivationalPhrase(); // Actualizar frase para la nueva fase
    // --- Fin de preparación ---


    // Decidir si auto-iniciar basado en la configuración Y la fase ANTERIOR
    bool shouldAutoStart = (phaseBeforeChange == PomodoroPhase.work && _autoStartBreaks) ||
                           (phaseBeforeChange != PomodoroPhase.work && _autoStartPomodoros);

    if (shouldAutoStart) {
      print("🚀 Auto-iniciando siguiente fase: $_currentPhase");
      startStopTimer(); // Inicia el nuevo ciclo/descanso
    } else {
       print("⏸️ Siguiente fase preparada: $_currentPhase. Esperando inicio manual.");
      notifyListeners(); // Solo notificar el cambio de estado si no se auto-inició
    }
  }


  void resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _currentPhase = PomodoroPhase.work;
    // _currentCycle = 1; // El ciclo se basa en todaySessions, se actualizará si es necesario
    _remainingTimeSeconds = _workDurationMinutes * 60;
    _updateMotivationalPhrase();
     // Forzar recarga de stats al resetear? Podría ser útil si el día cambió.
     // Opcional: _updateAggregatedStatsAndStreak();
    notifyListeners();
  }

  // --- Inicialización ---
  TimerProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    await _loadDurationsFromPrefs(); // Cargar config primero
    await _initializeNotifications(); // Configurar notifs
    await _updateAggregatedStatsAndStreak(); // Cargar TODAS las stats iniciales
    _updateMotivationalPhrase(); // Frase inicial
    // El notifyListeners está dentro de _updateAggregatedStatsAndStreak
  }

  // Método explícito para recargar si es necesario
  void refreshStats() {
     _updateAggregatedStatsAndStreak();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose(); // Liberar recursos del reproductor de audio
    super.dispose();
   }
}