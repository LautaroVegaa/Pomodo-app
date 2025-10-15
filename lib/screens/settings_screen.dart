import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/theme_provider.dart';
import '../providers/timer_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // --- Cerrar sesión ---
  Future<void> _signOut(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión cerrada correctamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final timerProvider = Provider.of<TimerProvider>(context);

    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    // Controladores para los campos numéricos
    final TextEditingController intervalController = TextEditingController(
      text: timerProvider.longBreakInterval.toString(),
    );

    final TextEditingController longBreakController = TextEditingController(
      text: timerProvider.longBreakDurationMinutes.toString(),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Configuración",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Apariencia ---
          ListTile(
            leading: Icon(Icons.palette_outlined,
                color: Theme.of(context).textTheme.bodyLarge?.color),
            title: Text(
              "Apariencia",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text("Modo oscuro"),
            value: isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(value),
            secondary: Icon(
              isDarkMode
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              color: isDarkMode
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
          ),
          const Divider(height: 32),

          // --- Notificaciones ---
          ListTile(
            leading: Icon(Icons.notifications_none_outlined,
                color: Theme.of(context).textTheme.bodyLarge?.color),
            title: Text(
              "Notificaciones",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text("Activar notificaciones"),
            value: timerProvider.notificationsEnabled,
            onChanged: (value) => timerProvider.setNotificationsEnabled(value),
            secondary: Icon(
              Icons.notifications_active_outlined,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const Divider(height: 32),

          // --- Pomodoro Automático ---
          ListTile(
            leading: Icon(Icons.timer_outlined,
                color: Theme.of(context).textTheme.bodyLarge?.color),
            title: Text(
              "Pomodoro automático",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          // ✅ Traducido: Auto Start Breaks → Inicio automático de descansos
          SwitchListTile(
            title: const Text("Inicio automático de descansos"),
            value: timerProvider.autoStartBreaks,
            onChanged: (value) => timerProvider.setAutoStartBreaks(value),
            secondary: Icon(
              Icons.free_breakfast_outlined,
              color: Theme.of(context).primaryColor,
            ),
          ),

          // ✅ Traducido: Auto Start Pomodoros → Inicio automático de pomodoros
          SwitchListTile(
            title: const Text("Inicio automático de pomodoros"),
            value: timerProvider.autoStartPomodoros,
            onChanged: (value) => timerProvider.setAutoStartPomodoros(value),
            secondary: Icon(
              Icons.play_circle_outline,
              color: Theme.of(context).primaryColor,
            ),
          ),

          // ✅ Traducido: Long Break Interval → Intervalo de descanso largo
          ListTile(
            title: const Text("Intervalo de descanso largo"),
            trailing: SizedBox(
              width: 60,
              child: TextField(
                controller: intervalController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  final int? parsed = int.tryParse(value);
                  if (parsed != null) {
                    timerProvider.setLongBreakInterval(parsed);
                  }
                },
              ),
            ),
          ),

          // --- Duración del descanso largo ---
          ListTile(
            title: const Text("Duración del descanso largo (min)"),
            trailing: SizedBox(
              width: 60,
              child: TextField(
                controller: longBreakController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  final int? parsed = int.tryParse(value);
                  if (parsed != null) {
                    timerProvider.setLongBreakDuration(parsed);
                  }
                },
              ),
            ),
          ),

          const Divider(height: 32),

          // --- Cerrar sesión ---
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              "Cerrar sesión",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
            ),
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}
