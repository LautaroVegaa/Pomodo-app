// lib/services/pomodoro_data_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // Necesario para DateFormat

// Clase dedicada a interactuar con Supabase para los datos de Pomodoro
class PomodoroDataService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtiene el ID del usuario actual o null si no está logueado
  String? get _userId => _supabase.auth.currentUser?.id;

  // Guarda una sesión completada en Supabase
  Future<void> savePomodoroSession(int durationMinutes, String type) async {
    final userId = _userId;
    if (userId == null) {
      print("⚠️ Usuario no logueado. No se guardó la sesión.");
      return;
    }

    try {
      await _supabase.from('pomodoro_sessions').insert({
        'user_id': userId,
        'duration_minutes': durationMinutes,
        'type': type, // 'work', 'shortBreak', 'longBreak'
        'completed_at': DateTime.now().toIso8601String(),
      });
      print("✅ Sesión guardada en Supabase ($type - $durationMinutes min)");
    } catch (e) {
      print("❌ Error al guardar sesión: $e");
      // Considera re-lanzar el error o manejarlo de otra forma si es necesario
      // throw Exception('Error al guardar sesión: $e');
    }
  }

  // Carga TODAS las estadísticas necesarias (hoy, semana, mes, gráfico semanal)
  Future<Map<String, dynamic>> loadAggregatedStats() async {
    final userId = _userId;
    final defaultStats = {
      'today_sessions': 0, 'today_minutes': 0,
      'week_sessions': 0, 'week_minutes': 0,
      'month_sessions': 0, 'month_minutes': 0,
      'weekly_data': <String, int>{'Mon': 0, 'Tue': 0, 'Wed': 0, 'Thu': 0, 'Fri': 0, 'Sat': 0, 'Sun': 0},
    };

    if (userId == null) {
      print("⚠️ Usuario no logueado. No se cargaron estadísticas.");
      return defaultStats;
    }

    try {
      // Pedir todas las sesiones de trabajo del último mes (aprox) para calcular todo
      final nowLocal = DateTime.now().toLocal();
      final oneMonthAgo = nowLocal.subtract(const Duration(days: 31));

      final data = await _supabase
          .from('pomodoro_sessions')
          .select('duration_minutes, completed_at')
          .eq('user_id', userId)
          .eq('type', 'work') // Solo sesiones de trabajo
          .gte('completed_at', oneMonthAgo.toIso8601String()) // Optimización: Traer solo el último mes
          .order('completed_at', ascending: false);

      final todayStart = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
      final tomorrowStart = todayStart.add(const Duration(days: 1));
      final localNowDateOnly = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);

      Map<String, int> weekMap = Map.from(defaultStats['weekly_data'] as Map<String, int>); // Copia para modificarla

      int todaySessions = 0;
      int todayMinutes = 0;
      int weekSessions = 0;
      int weekMinutes = 0;
      int monthSessions = 0;
      int monthMinutes = 0;

      for (var row in data) {
        DateTime completedAtLocal = DateTime.parse(row['completed_at']).toLocal();
        int minutes = (row['duration_minutes'] as num?)?.toInt() ?? 0;
        final localSessionDateOnly = DateTime(completedAtLocal.year, completedAtLocal.month, completedAtLocal.day);

        // Hoy
        if (!completedAtLocal.isBefore(todayStart) && completedAtLocal.isBefore(tomorrowStart)) {
          todaySessions++;
          todayMinutes += minutes;
        }

        // Semana (Hoy y los 6 días anteriores)
        final dayDifference = localNowDateOnly.difference(localSessionDateOnly).inDays;
        if (dayDifference >= 0 && dayDifference < 7) {
            weekSessions++;
            weekMinutes += minutes;
            try {
                String dayKey = DateFormat('E', 'en_US').format(completedAtLocal); // 'Mon', 'Tue', etc.
                weekMap[dayKey] = (weekMap[dayKey] ?? 0) + minutes;
            } catch (e) {
                print("Error formateando día para weekMap: $e");
            }
        }

        // Mes
        if (completedAtLocal.month == nowLocal.month && completedAtLocal.year == nowLocal.year) {
          monthSessions++;
          monthMinutes += minutes;
        }
      }

      print("📊 Estadísticas agregadas cargadas.");
      return {
        'today_sessions': todaySessions, 'today_minutes': todayMinutes,
        'week_sessions': weekSessions, 'week_minutes': weekMinutes,
        'month_sessions': monthSessions, 'month_minutes': monthMinutes,
        'weekly_data': weekMap,
      };

    } catch (e) {
      print("❌ Error al cargar estadísticas agregadas: $e");
      return defaultStats; // Retorna valores por defecto en caso de error
    }
  }


  // Calcula la racha (esta función se mantiene separada porque su lógica es distinta)
  Future<int> calculateStreak() async {
    final userId = _userId;
    if (userId == null) {
      print("⚠️ Usuario no logueado. No se calculó la racha.");
      return 0;
    }

    try {
      final data = await _supabase
          .from('pomodoro_sessions')
          .select('completed_at')
          .eq('user_id', userId)
          .order('completed_at', ascending: false)
          .limit(60); // Limitar razonablemente

      if (data.isEmpty) return 0;

       final uniqueDays = data
          .map<DateTime>((row) => DateTime.parse(row['completed_at']).toLocal())
          .map((d) => DateTime(d.year, d.month, d.day))
          .toSet();

      final now = DateTime.now().toLocal();
      final todayStart = DateTime(now.year, now.month, now.day);
      int streak = 0;
      DateTime checkDay = todayStart;

       if (uniqueDays.contains(todayStart)) {
          streak = 1;
          checkDay = todayStart.subtract(const Duration(days: 1));
      } else {
           checkDay = todayStart.subtract(const Duration(days: 1));
           if (uniqueDays.contains(checkDay)) {
               streak = 1;
               checkDay = checkDay.subtract(const Duration(days: 1));
           } else {
               return 0;
           }
      }

      while (uniqueDays.contains(checkDay)) {
        streak++;
        checkDay = checkDay.subtract(const Duration(days: 1));
      }

      print("🔥 Racha calculada: $streak días.");
      return streak;
    } catch (e) {
      print("❌ Error al calcular racha: $e");
      return 0;
    }
  }
}