import 'package:flutter/material.dart';

class FocusLockScreen extends StatelessWidget {
  const FocusLockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF111827), const Color(0xFF1F2937)]
                : [const Color(0xFFF9FAFB), const Color(0xFFECEEF1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícono central
                const Text("☕", style: TextStyle(fontSize: 72)),
                const SizedBox(height: 20),

                // Título principal
                Text(
                  "Take a breath.",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFF9FAFB)
                        : const Color(0xFF1F2937),
                  ),
                ),

                const SizedBox(height: 8),

                // Subtítulo
                Text(
                  "This moment belongs to your focus.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: isDark
                        ? Colors.grey.shade400
                        : Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 40),

                // Botón principal (hereda estilo del theme)
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: theme.elevatedButtonTheme.style?.copyWith(
                    minimumSize: const MaterialStatePropertyAll(Size(180, 48)),
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  child: const Text("Stay Focused"),
                ),

                const SizedBox(height: 20),

                // Frase Pomodō
                Text(
                  "Un descanso para tu mente, no para tu meta.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: isDark
                        ? Colors.grey.shade500
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
