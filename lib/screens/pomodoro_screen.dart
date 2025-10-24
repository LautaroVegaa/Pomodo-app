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

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  String? displayName;
  bool loading = true;

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
  elevation: 0,
  backgroundColor: Colors.transparent, // mantiene fondo coherente con el tema
  centerTitle: false,
  title: Padding(
    padding: const EdgeInsets.only(top: 8.0), // 👈 más “aire” arriba
    child: RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Pomodō',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22,
              // ✅ ahora toma color del AppBarTheme según el modo (claro/oscuro)
              color: Theme.of(context).appBarTheme.titleTextStyle?.color
                  ?? Theme.of(context).textTheme.bodyLarge?.color,
              letterSpacing: 0.5,
            ),
          ),
          TextSpan(
            text: '.',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 24,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    ),
  ),
  actions: [
    IconButton(
      icon: Icon(
        Icons.settings_outlined,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
      },
    ),
    const SizedBox(width: 8),
  ],
),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Se removió el bloque de bienvenida y subtítulo
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
                                  initialValue:
                                      timerProvider.workDurationMinutes.toDouble(),
                                  onChanged: (value) =>
                                      timerProvider.setWorkDuration(value.toInt()),
                                  min: 5,
                                  max: 60,
                                  divisions: 11,
                                  formatLabel: (value) => "${value.toInt()} minutos",
                                );
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              color:
                                  isDarkMode ? const Color(0xFF1F2937) : Colors.grey.shade100,
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
Center(
  child: Container(
    width: MediaQuery.of(context).size.width * 0.9,
    height: 70,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: const Color.fromARGB(90, 21, 1, 75), // azulado translúcido
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color.fromARGB(255, 44, 94, 175), // azul-violeta más frío
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color.fromARGB(255, 46, 102, 192).withOpacity(0.4),
          blurRadius: 10,
          spreadRadius: 0.5,
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.auto_awesome, // ✨
          color: Color(0xFF93C5FD), // azul-lavanda para el ícono
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              timerProvider.currentPhrase.isNotEmpty
                  ? timerProvider.currentPhrase
                  : "Silencia el ruido. Escuchá tu propósito.",
              key: ValueKey(timerProvider.currentPhrase),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ),
        ),
      ],
    ),
  ),
),
const SizedBox(height: 24),
const PomodoroStatsCard(),
const SizedBox(height: 24),


                ],
              ),
            ),
    );
  }
}