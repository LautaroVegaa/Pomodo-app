import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider; // AÑADIR PREFIJO 'provider'
import '../providers/timer_provider.dart';
import '../services/screen_time_service.dart'; // ✅ acceso al bloqueo nativo

class PomodoroTimerCard extends StatelessWidget {
  const PomodoroTimerCard({super.key});

  String _getStatusText(TimerProvider timer) {
    if (!timer.isRunning &&
        timer.remainingTimeSeconds == timer.workDurationMinutes * 60) {
      return "Pausado";
    }

    switch (timer.currentPhase) {
      case PomodoroPhase.work:
        return "Enfoque - Ciclo ${timer.currentCycle}";
      case PomodoroPhase.shortBreak:
        return "Descanso Corto - Ciclo ${timer.currentCycle}";
      case PomodoroPhase.longBreak:
        return "Descanso Largo";
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = provider.Provider.of<TimerProvider>(context);
    // Variables para el manejo de tema en la tarjeta
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      color: Theme.of(context).cardColor, // ✅ usa el color del tema
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getStatusText(timerProvider),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              timerProvider.formattedTime,
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontSize: 72, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: _getProgressValue(timerProvider),
              minHeight: 6,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Botones con estilo minimalista tipo glassmorphism
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ▶️ Start / Pause button
                GestureDetector(
                  onTap: () async {
                    timerProvider.startStopTimer();

                    if (timerProvider.isRunning &&
                        timerProvider.currentPhase == PomodoroPhase.work) {
                      final hasPermission =
                          await ScreenTimeService.checkAuthorizationStatus();
                      if (!hasPermission) {
                        await ScreenTimeService.requestAuthorization();
                      }
                      await ScreenTimeService.startFocusSession(
                        minutes: timerProvider.workDurationMinutes,
                      );
                    } else {
                      await ScreenTimeService.endFocusSession();
                    }
                  },
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // CORRECCIÓN: Estilos condicionales para modo claro
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.05) // Fondo translúcido oscuro
                          : Colors.grey.shade100, // Fondo gris claro
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.1) // Borde sutil oscuro
                            : Colors.grey.shade300, // Borde gris claro
                        width: 1.2,
                      ),
                    ),
                    child: Icon(
                      timerProvider.isRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      // CORRECCIÓN: Color de icono condicional para modo claro
                      color: timerProvider.isRunning
                          ? isDarkMode
                              ? Colors.white.withOpacity(0.9)
                              : textColor.withOpacity(0.9) // Color de texto oscuro para pausa
                          : primaryColor, // Color principal para iniciar
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 22),

                // 🔁 Restart / Skip button
                GestureDetector(
                  onTap: () async {
                    if (timerProvider.isRunning) {
                      timerProvider.skipPhase();
                    } else {
                      timerProvider.resetTimer();
                    }

                    await ScreenTimeService.endFocusSession();
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // CORRECCIÓN: Estilos condicionales para modo claro
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.05) // Fondo translúcido oscuro
                          : Colors.grey.shade100, // Fondo gris claro
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.1) // Borde sutil oscuro
                            : Colors.grey.shade300, // Borde gris claro
                        width: 1.2,
                      ),
                    ),
                    child: Icon(
                      Icons.refresh_rounded,
                      // CORRECCIÓN: Color de icono condicional para modo claro
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade600, // Gris oscuro
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _getProgressValue(TimerProvider timer) {
    switch (timer.currentPhase) {
      case PomodoroPhase.work:
        return timer.remainingTimeSeconds / (timer.workDurationMinutes * 60);
      case PomodoroPhase.shortBreak:
        return timer.remainingTimeSeconds /
            (timer.shortBreakDurationMinutes * 60);
      case PomodoroPhase.longBreak:
        return timer.remainingTimeSeconds /
            (timer.longBreakDurationMinutes * 60);
    }
  }
}