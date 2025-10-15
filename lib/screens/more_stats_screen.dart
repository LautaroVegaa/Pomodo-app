// lib/screens/more_stats_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class MoreStatsScreen extends StatefulWidget {
  const MoreStatsScreen({super.key});

  @override
  State<MoreStatsScreen> createState() => _MoreStatsScreenState();
}

class _MoreStatsScreenState extends State<MoreStatsScreen> {
  bool loading = true;

  Map<String, dynamic> stats = {
    'today_sessions': 0,
    'today_minutes': 0,
    'week_sessions': 0,
    'week_minutes': 0,
    'month_sessions': 0,
    'month_minutes': 0,
    'streak': 0,
    'daily_avg': 0,
    'best_day': '',
    'best_day_minutes': 0,
    'weekly_avg': 0,
    'weekly_data': {},
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await supabase
          .from('pomodoro_sessions')
          .select('duration_minutes, completed_at')
          .eq('user_id', user.id)
          .order('completed_at', ascending: false);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      Map<String, int> weekMap = {
        'Mon': 0,
        'Tue': 0,
        'Wed': 0,
        'Thu': 0,
        'Fri': 0,
        'Sat': 0,
        'Sun': 0,
      };

      int todaySessions = 0;
      int todayMinutes = 0;
      int weekSessions = 0;
      int weekMinutes = 0;
      int monthSessions = 0;
      int monthMinutes = 0;

      for (var row in data) {
        DateTime date = DateTime.parse(row['completed_at']);
        int minutes = row['duration_minutes'];
        final diff = now.difference(date).inDays;

        if (date.isAfter(today)) {
          todaySessions++;
          todayMinutes += minutes;
        }

        if (diff < 7) {
          weekSessions++;
          weekMinutes += minutes;
          weekMap[DateFormat('E').format(date)] =
              (weekMap[DateFormat('E').format(date)] ?? 0) + minutes;
        }

        if (date.month == now.month && date.year == now.year) {
          monthSessions++;
          monthMinutes += minutes;
        }
      }

      String bestDay = '';
      int bestMinutes = 0;
      int totalWeeklyMinutes = 0;

      weekMap.forEach((day, minutes) {
        totalWeeklyMinutes += minutes;
        if (minutes > bestMinutes) {
          bestMinutes = minutes;
          bestDay = day;
        }
      });

      double weeklyAvg = totalWeeklyMinutes / 7;

      setState(() {
        stats = {
          'today_sessions': todaySessions,
          'today_minutes': todayMinutes,
          'week_sessions': weekSessions,
          'week_minutes': weekMinutes,
          'month_sessions': monthSessions,
          'month_minutes': monthMinutes,
          'streak': 0,
          'daily_avg': (weekMinutes / 7).toStringAsFixed(1),
          'best_day': bestDay,
          'best_day_minutes': bestMinutes,
          'weekly_avg': weeklyAvg.toStringAsFixed(1),
          'weekly_data': weekMap,
        };
        loading = false;
      });
    } catch (e) {
      print("❌ Error al cargar estadísticas: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color cardColor = isDarkMode ? const Color(0xFF1F2937) : Colors.white;
    Color subTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Más Estadísticas",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Historial y Promedios",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

// --- INICIO DEL GRÁFICO MINIMALISTA (Contenedor simulado con datos reales) ---
Container(
  height: 230, // Altura del resumen
  width: double.infinity,
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Progreso de Concentración Semanal',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      const SizedBox(height: 8),

      // --- Resumen dinámico ---
      Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: stats['best_day'] != ''
                  ? 'Tu mejor día fue el ${_translateDay(stats['best_day'])} (${stats['best_day_minutes']} min).'
                  : 'Aún no hay datos suficientes.',
              style: TextStyle(color: subTextColor),
            ),
            const TextSpan(text: '\n'),
            TextSpan(
              text: 'Promedio semanal: ${stats['weekly_avg']} min.',
              style: TextStyle(color: subTextColor),
            ),
          ],
        ),
        style: Theme.of(context).textTheme.bodySmall,
      ),

      const Spacer(),

      // --- Gráfico dinámico ---
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats['weekly_data'].entries.map<Widget>((entry) {
          // Calculamos la altura relativa con respecto al mejor día
          final double heightRatio = (entry.value /
                  (stats['best_day_minutes'] == 0
                      ? 1
                      : stats['best_day_minutes']))
              .clamp(0.0, 1.0);

          return _buildChartBar(
            context,
            heightRatio,
            _translateDayShort(entry.key),
          );
        }).toList(),
      ),
    ],
  ),
),
// --- FIN DEL GRÁFICO MINIMALISTA (Contenedor simulado con datos reales) ---



                  const SizedBox(height: 24),
                  _buildStatCard(context, 'Hoy', stats['today_sessions'].toString(), 'Sesiones',
                      value2: '${stats['today_minutes']}', label2: 'Minutos'),
                  _buildStatCard(context, 'Esta semana', stats['week_sessions'].toString(),
                      'Sesiones', value2: '${stats['week_minutes']}', label2: 'Minutos'),
                  _buildStatCard(context, 'Este mes', stats['month_sessions'].toString(),
                      'Sesiones', value2: '${stats['month_minutes']}', label2: 'Minutos'),
                  _buildStatCard(context, 'Promedio diario', '${stats['daily_avg']}', 'Min',
                      icon: Icons.show_chart_outlined,
                      iconColor: Theme.of(context).primaryColor),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value1, String label1,
      {String? value2, String? label2, IconData? icon, Color? iconColor}) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: iconColor ?? Theme.of(context).primaryColor),
              const SizedBox(width: 8),
            ],
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value1,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: iconColor ?? Theme.of(context).primaryColor)),
              const SizedBox(width: 8),
              Text(label1,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey.shade500)),
            ],
          ),
          if (label2 != null && value2 != null) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value2,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                const SizedBox(width: 4),
                Text(label2,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey.shade500)),
              ],
            ),
          ]
        ]),
      ),
    );
  }

  Widget _buildChartBar(BuildContext context, double heightRatio, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: heightRatio * 100, // Mantiene la proporción original
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  String _translateDay(String shortDay) {
    switch (shortDay) {
      case 'Mon':
        return 'lunes';
      case 'Tue':
        return 'martes';
      case 'Wed':
        return 'miércoles';
      case 'Thu':
        return 'jueves';
      case 'Fri':
        return 'viernes';
      case 'Sat':
        return 'sábado';
      case 'Sun':
        return 'domingo';
      default:
        return '';
    }
  }

  String _translateDayShort(String shortDay) {
    switch (shortDay) {
      case 'Mon':
        return 'Lun';
      case 'Tue':
        return 'Mar';
      case 'Wed':
        return 'Mié';
      case 'Thu':
        return 'Jue';
      case 'Fri':
        return 'Vie';
      case 'Sat':
        return 'Sáb';
      case 'Sun':
        return 'Dom';
      default:
        return '';
    }
  }
}
