import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider; // AÑADIR PREFIJO 'provider'
import '../providers/timer_provider.dart';
import '../services/screen_time_service.dart'; // ✅ acceso al bloqueo nativo

class PomodoroTimerCard extends StatelessWidget {
  const PomodoroTimerCard({super.key});

  // Función para obtener el texto del estado actual
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

    return Card(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.all(20),
                  ),
                  icon: Icon(
                    timerProvider.isRunning ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 36,
                  ),
                  onPressed: () async {
                    // 🔹 Mantiene tu lógica original
                    timerProvider.startStopTimer();

                    // ✅ Bloquea solo en modo de trabajo
                    if (timerProvider.isRunning &&
                        timerProvider.currentPhase == PomodoroPhase.work) {
                      final hasPermission =
                          await ScreenTimeService.checkAuthorizationStatus();
                      if (!hasPermission) {
                        await ScreenTimeService.requestAuthorization();
                      }

                      // Inicia bloqueo solo durante el trabajo
                      await ScreenTimeService.startFocusSession(
                        minutes: timerProvider.workDurationMinutes,
                      );
                    } else {
                      // 🧠 Si pausó, terminó o no es fase de trabajo → desbloquea
                      await ScreenTimeService.endFocusSession();
                    }
                  },
                ),
                const SizedBox(width: 20),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    padding: const EdgeInsets.all(16),
                  ),
                  icon: const Icon(Icons.refresh, size: 28),
                  onPressed: () async {
                    if (timerProvider.isRunning) {
                      timerProvider.skipPhase();
                    } else {
                      timerProvider.resetTimer();
                    }

                    // ✅ Siempre libera bloqueo al cambiar de fase o resetear
                    await ScreenTimeService.endFocusSession();
                  },
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
