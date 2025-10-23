// lib/screens/pomodoro_screen.dart

import 'package:flutter/material.dart';
import 'package:pomodo_app/screens/settings_screen.dart';
import 'package:provider/provider.dart' as provider;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/timer_provider.dart';
import '../widgets/pomodoro_stats_card.dart';
import '../widgets/pomodoro_timer_card.dart';
import '../widgets/duration_slider_dialog.dart';
import 'more_stats_screen.dart';
import 'package:pomodo_app/screens/block/block_home_screen.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  String? displayName;
  bool loading = true;

  // ✅ NUEVO: índice para manejar el ítem activo del footer
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        // ✅ Se obtiene directamente el nombre desde user_metadata
        final fullName = user.userMetadata?['full_name'] as String?;

        setState(() {
          displayName = fullName?.isNotEmpty == true ? fullName : user.email;
          loading = false;
        });
      } else {
        setState(() {
          displayName = 'Usuario';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        displayName = 'Usuario';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = provider.Provider.of<TimerProvider>(context);
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pomodō",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Inicio de la zona centrada (Bienvenido)
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 8.0, bottom: 8.0),
                          child: Text(
                            "Bienvenido, ${displayName ?? 'Usuario'}",
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 8.0, bottom: 24.0),
                          child: Text(
                            "Técnica Pomodoro para estudiantes",
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Fin de la zona centrada
                  const PomodoroTimerCard(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 20,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Personalizar Pomodoro",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return DurationSliderDialog(
                                  title: "Duración del trabajo",
                                  initialValue: timerProvider
                                      .workDurationMinutes
                                      .toDouble(),
                                  onChanged: (value) =>
                                      timerProvider.setWorkDuration(
                                          value.toInt()),
                                  min: 5,
                                  max: 60,
                                  divisions: 11,
                                  formatLabel: (value) =>
                                      "${value.toInt()} minutos",
                                );
                              },
                            );
                          },
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color(0xFF1F2937)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Text(
                                    "${timerProvider.workDurationMinutes} min",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color,
                                        ),
                                  ),
                                  const Text("Trabajo"),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return DurationSliderDialog(
                                  title: "Duración del descanso",
                                  initialValue: timerProvider
                                      .shortBreakDurationMinutes
                                      .toDouble(),
                                  onChanged: (value) =>
                                      timerProvider.setShortBreakDuration(
                                          value.toInt()),
                                  min: 5,
                                  max: 30,
                                  divisions: 5,
                                  formatLabel: (value) =>
                                      "${value.toInt()} minutos",
                                );
                              },
                            );
                          },
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFBFDBFE),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Text(
                                    "${timerProvider.shortBreakDurationMinutes} min",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(context).primaryColor,
                                        ),
                                  ),
                                  Text(
                                    "Descanso",
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Card de motivación
Center(
  child: Container(
    width: MediaQuery.of(context).size.width * 0.9, // ✅ se adapta al ancho del dispositivo
    height: 140, // ✅ altura fija
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF8B5CF6),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center, // ✅ centra verticalmente
      children: [
        Text(
          "¡Mantén el enfoque!",
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400), // ✨ animación suave
          child: Text(
            timerProvider.currentPhrase.isNotEmpty
                ? timerProvider.currentPhrase
                : "Cada ciclo completado te acerca más a tus objetivos de estudio.",
            key: ValueKey(timerProvider.currentPhrase),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white70),
          ),
        ),
      ],
    ),
  ),
),

                  const SizedBox(height: 24),
                  const PomodoroStatsCard(),

                  // ❌ Se eliminó el botón "Ver más estadísticas"
                  // porque ahora el acceso está en el footer (ícono Stats)

                  const SizedBox(height: 24),
                ],
              ),
            ),

      // ✅ FOOTER con íconos Focus / Stats / Block
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);

          if (index == 1) {
            // ✅ Navega a estadísticas y al volver, resetea el ícono activo a "Focus"
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MoreStatsScreen(),
              ),
            ).then((_) {
              setState(() => _currentIndex = 0); // vuelve a Focus al regresar
            });
          } else if (index == 2) {
      // ✅ Navega al Modo Bloqueo (Fase 1: UI + estado)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BlockHomeScreen()),
      ).then((_) {
      setState(() => _currentIndex = 0); // vuelve a Focus al regresar
  });
}
        },
        backgroundColor:
            isDarkMode ? const Color(0xFF0B1120) : Colors.white,
        selectedItemColor: const Color(0xFF3579F6),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Focus',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield_outlined),
            label: 'Block',
          ),
        ],
      ), // ✅ Fin del footer
    );
  }
}
