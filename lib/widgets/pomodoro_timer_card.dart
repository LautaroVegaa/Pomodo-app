import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider; // AÑADIR PREFIJO 'provider'
import '../providers/timer_provider.dart';

class PomodoroTimerCard extends StatelessWidget {
  const PomodoroTimerCard({super.key});

  // Función para obtener el texto del estado actual
  String _getStatusText(TimerProvider timer) {
    // Si no está corriendo, muestra "Pausado"
    if (!timer.isRunning &&
        timer.remainingTimeSeconds == timer.workDurationMinutes * 60) {
      return "Pausado"; // Estado inicial o reseteado
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
    // Usar el prefijo 'provider'
    final timerProvider = provider.Provider.of<TimerProvider>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // El texto del estado ahora siempre está visible
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
                  onPressed: () => timerProvider.startStopTimer(),
                ),
                const SizedBox(width: 20),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    padding: const EdgeInsets.all(16),
                  ),
                  icon: const Icon(Icons.refresh, size: 28),
                  onPressed: () {
                    // Si el timer está corriendo, salta la fase. Si está pausado, hace reset.
                    if (timerProvider.isRunning) {
                      timerProvider.skipPhase();
                    } else {
                      timerProvider.resetTimer();
                    }
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
        return timer.remainingTimeSeconds /
            (timer.workDurationMinutes * 60);
      case PomodoroPhase.shortBreak:
        return timer.remainingTimeSeconds /
            (timer.shortBreakDurationMinutes * 60);
      case PomodoroPhase.longBreak:
        // ✅ FIX: ahora usa la duración dinámica del descanso largo
        return timer.remainingTimeSeconds /
            (timer.longBreakDurationMinutes * 60);
    }
  }
}
