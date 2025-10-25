// lib/screens/stopwatch_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/stopwatch_provider.dart';
import '../widgets/contextual_tip_card.dart'; // Importar el widget de tips

class StopwatchScreen extends StatelessWidget {
  const StopwatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stopwatchProvider = Provider.of<StopwatchProvider>(context);
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isDarkMode = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Card Principal con tiempo y botones
          Card(
            color: theme.cardColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
              child: Column(
                children: [
                  // Display principal (MM:SS)
                  Text(
                    stopwatchProvider.formattedTime,
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Controles Start/Stop/Reset
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botón Start / Stop (Izquierda)
                      GestureDetector(
                        onTap: stopwatchProvider.startStopwatch,
                        child: Container(
                          width: 58, height: 58,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade100, border: Border.all(color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade300, width: 1.2)),
                          child: Icon(stopwatchProvider.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, color: stopwatchProvider.isRunning ? (isDarkMode ? Colors.white.withOpacity(0.9) : textColor.withOpacity(0.9)) : primaryColor, size: 22),
                        ),
                      ),
                      const SizedBox(width: 22),

                      // Botón Reset (Derecha)
                      GestureDetector(
                        onTap: (!stopwatchProvider.isRunning && stopwatchProvider.currentDuration > Duration.zero)
                            ? stopwatchProvider.resetStopwatch
                            : null,
                        child: Opacity(
                          opacity: (!stopwatchProvider.isRunning && stopwatchProvider.currentDuration > Duration.zero) ? 1.0 : 0.5,
                          child: Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade100, border: Border.all(color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade300, width: 1.2)),
                            child: Icon(Icons.refresh_rounded, color: isDarkMode ? Colors.white70 : Colors.grey.shade600, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32), // Espacio después de la card principal

          // 2. Card de Tips Contextuales
          ContextualTipCard(
            text: stopwatchProvider.currentTip,
            icon: Icons.tips_and_updates_outlined, // Icono diferente
          ),
          const SizedBox(height: 16), // Espacio opcional al final

        ],
      ),
    );
  }
}