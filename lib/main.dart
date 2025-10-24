// lib/main.dart
import 'package:flutter/material.dart';
import 'package:pomodo_app/providers/theme_provider.dart';
import 'package:pomodo_app/providers/timer_provider.dart';
import 'package:pomodo_app/screens/login_screen.dart';
import 'package:pomodo_app/screens/pomodoro_screen.dart';
import 'package:pomodo_app/screens/onboarding/onboarding_welcome.dart';
import 'package:pomodo_app/theme/app_theme.dart';
import 'package:provider/provider.dart' as provider;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

// ✅ NUEVO: import del contenedor con bottom nav persistente
import 'package:pomodo_app/screens/main_scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;
  bool _completedOnboarding = false;
  Session? _session;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// 🔹 Inicializa SharedPreferences y Supabase antes de construir la app
  Future<void> _initializeApp() async {
    final prefs = await SharedPreferences.getInstance();
    // ✅ La clave 'completedOnboarding' se verifica aquí.
    final completed = prefs.getBool('completedOnboarding') ?? false;
    final session = Supabase.instance.client.auth.currentSession;

    setState(() {
      _completedOnboarding = completed;
      _session = session;
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mientras no termine de inicializar, no muestra nada más que una splash
    if (!_initialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFF0A0F24),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF00CFFF)),
          ),
        ),
      );
    }

    // ✅ Lógica definitiva: decide la pantalla inicial
    Widget home;
    if (!_completedOnboarding) {
      // 🥇 1. Si NO completó el onboarding (es nuevo) → lo mostramos
      home = const OnboardingWelcome();
    } else if (_session != null) {
      // 🥈 2. Si completó el onboarding Y hay sesión iniciada → contenedor con bottom nav persistente
      home = const MainScaffold(); // ← reemplaza a PomodoroScreen manteniendo la lógica
    } else {
      // 🥉 3. Si completó el onboarding pero NO tiene sesión → Login
      home = const LoginScreen();
    }

    // 🔹 Ahora sí construimos toda la app normalmente
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
            home: home, // 🔑 Usa el widget decidido por la lógica de arriba
          );
        },
      ),
    );
  }
}
