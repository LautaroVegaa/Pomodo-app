// lib/screens/more_stats_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importar Provider
import 'package:intl/intl.dart'; // Para formatear
import '../providers/timer_provider.dart'; // Importar el TimerProvider

// Convertido a StatelessWidget porque el estado ahora vive en TimerProvider
class MoreStatsScreen extends StatelessWidget {
  const MoreStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios en TimerProvider
    final timerProvider = context.watch<TimerProvider>();

    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color cardColor = isDarkMode ? const Color(0xFF1F2937) : Colors.white;
    Color subTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

    // Formatear promedios para mostrar solo un decimal
    String weeklyAvgFormatted = timerProvider.weeklyAverage.toStringAsFixed(1);
    String dailyAvgFormatted = timerProvider.dailyAverage.toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Más Estadísticas", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      // No necesitamos el indicador de carga aquí, TimerProvider maneja la carga inicial
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Historial y Promedios",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // --- GRÁFICO SEMANAL (lee datos de timerProvider) ---
            Container(
              height: 230,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                 color: cardColor,
                 borderRadius: BorderRadius.circular(12),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
                     blurRadius: 8, offset: const Offset(0, 4),
                   ),
                 ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Progreso de Concentración Semanal',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: timerProvider.bestDay.isNotEmpty
                              ? 'Tu mejor día fue el ${_translateDay(timerProvider.bestDay)} (${timerProvider.bestDayMinutes} min).'
                              : 'Aún no hay datos suficientes.',
                          style: TextStyle(color: subTextColor, fontSize: 12),
                        ),
                        const TextSpan(text: '\n'),
                        TextSpan(
                          text: 'Promedio semanal: $weeklyAvgFormatted min.',
                          style: TextStyle(color: subTextColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Row( // Gráfico de barras
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: timerProvider.weeklyDataMap.entries.map<Widget>((entry) {
                       final double maxMinutes = timerProvider.bestDayMinutes > 0
                           ? timerProvider.bestDayMinutes.toDouble()
                           : 1.0;
                       final double heightRatio = (entry.value / maxMinutes).clamp(0.0, 1.0);
                       return _buildChartBar(context, heightRatio, _translateDayShort(entry.key));
                    }).toList(),
                  ),
                ],
              ),
            ),
            // --- FIN GRÁFICO ---

            const SizedBox(height: 24),

            // --- TARJETAS DE ESTADÍSTICAS (leen datos de timerProvider) ---
            _buildStatCard(context, 'Hoy', timerProvider.todaySessions.toString(), 'Sesiones',
                value2: '${timerProvider.todayMinutes}', label2: 'Minutos'),
            _buildStatCard(context, 'Esta semana', timerProvider.weekSessions.toString(), 'Sesiones',
                value2: '${timerProvider.weekMinutes}', label2: 'Minutos'),
            _buildStatCard(context, 'Este mes', timerProvider.monthSessions.toString(), 'Sesiones',
                value2: '${timerProvider.monthMinutes}', label2: 'Minutos'),
            _buildStatCard(context, 'Promedio diario', dailyAvgFormatted, 'Min',
                icon: Icons.show_chart_outlined,
                iconColor: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }

  // --- Widgets auxiliares (_buildStatCard, _buildChartBar) ---
  // (Sin cambios respecto a la versión anterior, los puedes copiar y pegar)
   Widget _buildStatCard(BuildContext context, String title, String value1, String label1,
      {String? value2, String? label2, IconData? icon, Color? iconColor}) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color cardBgColor = isDarkMode ? const Color(0xFF1F2937) : Colors.white;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: cardBgColor,
      elevation: 0, // Quitar elevación por defecto
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Redondear bordes
       // Añadir sombra sutil similar al gráfico
       shadowColor: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
       // Aumentar un poco el blur y el offset vertical
       // elevation: 4, // Puedes usar elevation directamente si prefieres

      child: Padding(
        padding: const EdgeInsets.all(20.0), // Padding uniforme
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: iconColor ?? Theme.of(context).primaryColor), // Icono más pequeño
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600), // Título un poco más fuerte
                ),
              ],
            ),
            const SizedBox(height: 16), // Espacio consistente
            Row( // Primera línea de valor
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value1,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: iconColor ?? Theme.of(context).primaryColor // Color principal
                  )
                ),
                const SizedBox(width: 8),
                Text(
                  label1,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500) // Etiqueta gris
                ),
              ],
            ),
            if (label2 != null && value2 != null) ...[ // Segunda línea si existe
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value2,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith( // Un poco más pequeño que el valor 1
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981) // Verde para minutos (o elige otro color)
                    )
                  ),
                  const SizedBox(width: 4), // Menos espacio para etiqueta corta
                  Text(
                    label2,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500) // Etiqueta gris
                  ),
                ],
              ),
            ]
          ]
        ),
      ),
    );
  }

  Widget _buildChartBar(BuildContext context, double heightRatio, String label) {
    final safeHeightRatio = heightRatio.isNaN || heightRatio < 0 ? 0.0 : heightRatio;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: safeHeightRatio * 80,
          constraints: const BoxConstraints(minHeight: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(safeHeightRatio > 0 ? 0.8 : 0.3),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500)),
      ],
    );
  }

  // --- Funciones de traducción ---
   String _translateDay(String shortDay) { /* ... sin cambios ... */
      const Map<String, String> days = {
        'Mon': 'lunes', 'Tue': 'martes', 'Wed': 'miércoles',
        'Thu': 'jueves', 'Fri': 'viernes', 'Sat': 'sábado', 'Sun': 'domingo'
      };
      return days[shortDay] ?? '';
   }
   String _translateDayShort(String shortDay) { /* ... sin cambios ... */
      const Map<String, String> daysShort = {
        'Mon': 'Lun', 'Tue': 'Mar', 'Wed': 'Mié',
        'Thu': 'Jue', 'Fri': 'Vie', 'Sat': 'Sáb', 'Sun': 'Dom'
      };
      return daysShort[shortDay] ?? '';
   }

} // Fin de MoreStatsScreen