// lib/screens/simple_timer_screen.dart

import 'package:flutter/material.dart';
// ✅ CORRECCIÓN: Import correcto para el paquete provider
import 'package:provider/provider.dart';
// ---------------------------------------------------
import '../providers/simple_timer_provider.dart';
import 'dart:math'; // Para usar max()
import '../widgets/contextual_tip_card.dart';

class SimpleTimerScreen extends StatelessWidget {
  const SimpleTimerScreen({super.key});

  // Función para formatear el tiempo (HH:MM:SS)
  String _formatDisplayTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // ✅ CORRECCIÓN: Ahora 'Provider' es reconocido
    final timerProvider = Provider.of<SimpleTimerProvider>(context);
    // ------------------------------------------
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isDarkMode = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    // Valor del Slider basado en el provider
    final double sliderValue = max(0.1, (timerProvider.initialDurationSeconds / 60.0)).clamp(0.1, 180.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Card principal que muestra el tiempo restante
          Card(
            color: theme.cardColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0), // Ajuste de padding
              child: Column(
                children: [
                  Text(
                    timerProvider.formattedTime, // Muestra MM:SS del tiempo restante
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.displayLarge?.color, // Color blanco/negro
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: timerProvider.initialDurationSeconds > 0
                        ? timerProvider.remainingTimeSeconds / timerProvider.initialDurationSeconds
                        : 0.0,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade300.withOpacity(0.5),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                  const SizedBox(height: 24), // Espacio antes de los botones

                  // Controles Start/Pause/Reset (Dentro de la Card)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botón Start / Pause (Izquierda)
                      GestureDetector(
                        onTap: () {
                          timerProvider.isRunning
                              ? timerProvider.pauseTimer()
                              : timerProvider.startTimer();
                        },
                        child: Container(
                           width: 58, height: 58,
                           decoration: BoxDecoration(shape: BoxShape.circle, color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade100, border: Border.all(color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade300, width: 1.2)),
                           child: Icon(timerProvider.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, color: timerProvider.isRunning ? (isDarkMode ? Colors.white.withOpacity(0.9) : textColor.withOpacity(0.9)) : primaryColor, size: 22),
                        ),
                      ),
                      const SizedBox(width: 22),

                      // Botón Reset (Derecha)
                      GestureDetector(
                        onTap: timerProvider.resetTimer,
                        child: Opacity(
                          opacity: (timerProvider.remainingTimeSeconds != timerProvider.initialDurationSeconds) ? 1.0 : 0.5,
                          child: Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade100, border: Border.all(color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade300, width: 1.2)),
                            child: Icon(Icons.refresh_rounded, color: isDarkMode ? Colors.white70 : Colors.grey.shade600, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ), // Fin Row Controles
                ],
              ), // Fin Column Card
            ), // Fin Padding Card
          ), // Fin Card
          const SizedBox(height: 32), // Espacio después de la card principal

          // 2. Control de Duración con Slider
          Column(
            children: [
              Text(
                "Ajustar Duración",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: timerProvider.isRunning ? theme.textTheme.bodySmall?.color : theme.textTheme.titleMedium?.color,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                _formatDisplayTime(timerProvider.initialDurationSeconds),
                style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: timerProvider.isRunning ? primaryColor.withOpacity(0.4) : primaryColor.withOpacity(0.9),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
              Slider(
                value: sliderValue,
                min: 0.1,
                max: 180,
                divisions: (180 - 0.1) ~/ 0.5,
                activeColor: timerProvider.isRunning ? primaryColor.withOpacity(0.4) : primaryColor,
                inactiveColor: timerProvider.isRunning ? primaryColor.withOpacity(0.1) : primaryColor.withOpacity(0.3),
                label: _formatDisplayTime((sliderValue * 60).round()),
                onChanged: timerProvider.isRunning ? null : (double value) {
                  timerProvider.setInitialDuration((value * 60).round());
                },
              ),
              const SizedBox(height: 32), // Espacio después del slider
            ],
          ), // Fin Column Slider

          // 3. Card de Tips Contextuales
          ContextualTipCard(
            text: timerProvider.currentTip,
            icon: Icons.lightbulb_outline,
          ),
          const SizedBox(height: 16), // Espacio opcional al final

        ], // Fin Children Column Principal
      ), // Fin Column Principal
    ); // Fin SingleChildScrollView
  } // Fin build
} // Fin SimpleTimerScreen