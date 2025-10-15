// lib/main.dart

import 'package:flutter/material.dart';
import 'package:pomodo_app/providers/theme_provider.dart';
import 'package:pomodo_app/providers/timer_provider.dart';
import 'package:pomodo_app/screens/login_screen.dart';
import 'package:pomodo_app/screens/pomodoro_screen.dart';
import 'package:pomodo_app/theme/app_theme.dart';
import 'package:provider/provider.dart' as provider;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart'; // Asegúrate de que este archivo exista

// [NUEVO] Widget de carga, definido aquí para ser accesible
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl, // Desde config.dart
    anonKey: supabaseAnonKey, // Desde config.dart
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // ✅ [MEJORADO] Guarda el nombre y actualiza estadísticas tras iniciar sesión
  void _saveUserNameFromSession(BuildContext context, Session session) {
    final user = session.user;
    if (user != null) {
      // Accedemos al provider
      final timerProvider =
          provider.Provider.of<TimerProvider>(context, listen: false);

      // Extraemos el nombre del usuario
      final fullName = user.userMetadata?['full_name'] as String?;

      if (fullName != null && fullName.isNotEmpty) {
        timerProvider.setUserName(fullName);
      } else {
        timerProvider.setUserName(user.email ?? "Usuario");
      }

      // 🟢 NUEVO: Recarga las estadísticas del día actual al iniciar sesión
      timerProvider.loadTodayStatsIfAvailable();
    }
  }

  @override
  Widget build(BuildContext context) {
    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => ThemeProvider()),
        provider.ChangeNotifierProvider(create: (_) => TimerProvider()),
      ],
      child: provider.Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Pomodō',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: StreamBuilder<AuthState>(
              // Escucha los cambios de sesión en Supabase
              stream: Supabase.instance.client.auth.onAuthStateChange,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingScreen();
                }

                if (snapshot.hasData && snapshot.data!.session != null) {
                  final session = snapshot.data!.session!;

                  // Guarda el nombre del usuario y carga estadísticas
                  _saveUserNameFromSession(context, session);

                  return const PomodoroScreen();
                }

                // Si no hay sesión activa
                return const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
