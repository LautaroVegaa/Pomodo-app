// lib/screens/focus_timer_tabs.dart

import 'package:flutter/material.dart';
import 'package:pomodo_app/screens/pomodoro_screen.dart';
import 'package:pomodo_app/screens/settings_screen.dart';
import 'package:pomodo_app/screens/simple_timer_screen.dart';
import 'package:pomodo_app/screens/stopwatch_screen.dart';

class FocusTimerTabs extends StatefulWidget {
  const FocusTimerTabs({super.key});

  @override
  State<FocusTimerTabs> createState() => _FocusTimerTabsState();
}

class _FocusTimerTabsState extends State<FocusTimerTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- AppBar con TabBar Ajustada ---
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final Color unselectedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: false,
      // Título y Acciones
      title: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Pomodō',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                  color: theme.appBarTheme.titleTextStyle?.color ?? theme.textTheme.bodyLarge?.color,
                  letterSpacing: 0.5,
                ),
              ),
              TextSpan(
                text: '.',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  color: theme.primaryColor,
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
            color: theme.textTheme.bodyLarge?.color,
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

      // --- TabBar Configurada ---
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(55.0),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: isDarkMode ? theme.cardColor.withOpacity(0.6) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsets.zero,
            labelColor: Colors.white,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            unselectedLabelColor: unselectedColor,
            unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            dividerColor: Colors.transparent, // Sin línea divisoria

            // ----- CAMBIOS EN LAS PESTAÑAS AQUÍ -----
            tabs: [
              _buildTab(Icons.adjust, 'Pomodoro'), // <--- Icono y texto cambiados
              _buildTab(Icons.timer_outlined, 'Timer'),
              _buildTab(Icons.watch_later_outlined, 'Stopwatch'),
            ],
            // ------------------------------------
          ),
        ),
      ),
    );
  }

  // Helper para construir las pestañas de forma consistente
  Widget _buildTab(IconData icon, String text) {
    return Tab(
      height: 38, // Altura fija y más compacta para cada Tab
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16), // Icono más pequeño
          const SizedBox(width: 5), // Espacio reducido
          Text(text),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // Deshabilita el deslizamiento
        children: const [
          // 1. Pestaña Pomodoro (antes Focus)
          PomodoroScreen(showAppBar: false),

          // 2. Pestaña Timer
          SimpleTimerScreen(),

          // 3. Pestaña Stopwatch
          StopwatchScreen(),
        ],
      ),
    );
  }
}