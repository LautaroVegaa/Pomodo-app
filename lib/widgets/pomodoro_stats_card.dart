// lib/widgets/pomodoro_stats_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';

class PomodoroStatsCard extends StatelessWidget {
  const PomodoroStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Estadísticas de hoy",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      timerProvider.completedCycles.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const Text("Ciclos"),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      timerProvider.formattedTimeStudied,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const Text("Estudiado"),
                  ],
                ),
                // ✅ Racha diaria conectada al TimerProvider
                Column(
                  children: [
                    Text(
                      timerProvider.currentStreak.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const Text("Racha"),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
