import 'package:flutter/material.dart';
import 'package:pomodo_app/screens/pomodoro_screen.dart';
import 'package:pomodo_app/screens/more_stats_screen.dart';

/// Contenedor principal con navegación inferior persistente.
/// Mantiene el footer visible entre Focus y Stats
/// sin afectar la lógica interna de las pantallas.
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  // 🧩 Pantallas principales de Pomodō (ya existentes)
  final List<Widget> _screens = const [
    PomodoroScreen(),
    MoreStatsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // Mantiene el estado de cada pantalla sin reiniciar
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      // Footer con Focus y Stats
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: theme.cardColor,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor:
            theme.brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            label: 'Focus',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
