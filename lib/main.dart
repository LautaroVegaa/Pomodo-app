// lib/main.dart
import 'package:flutter/material.dart';
import 'package:pomodo_app/providers/theme_provider.dart';
import 'package:pomodo_app/providers/timer_provider.dart';
import 'package:pomodo_app/screens/login_screen.dart';
import 'package:pomodo_app/screens/onboarding/onboarding_welcome.dart';
import 'package:pomodo_app/theme/app_theme.dart';
import 'package:provider/provider.dart' as provider; // Alias mantenido
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart'; // Asegúrate que este archivo exista y tenga tus claves Supabase

// Import del contenedor con bottom nav persistente
import 'package:pomodo_app/screens/main_scaffold.dart';

// Import de los providers de los otros timers
import 'package:pomodo_app/providers/simple_timer_provider.dart';
import 'package:pomodo_app/providers/stopwatch_provider.dart';

// ✅ 1. Crear la GlobalKey para el Navigator
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Supabase
  await Supabase.initialize(
    url: supabaseUrl, // Asegúrate que estas variables existan en config.dart
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

  Future<void> _initializeApp() async {
    final prefs = await SharedPreferences.getInstance();
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
    if (!_initialized) {
      // Pantalla de carga simple mientras inicializa
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFF0A0F24), // Un color de fondo oscuro
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF00CFFF)), // Indicador con color primario
          ),
        ),
      );
    }

    // Lógica para decidir la pantalla inicial
    Widget home;
    if (!_completedOnboarding) {
      home = const OnboardingWelcome();
    } else if (_session != null) {
      home = const MainScaffold(); // Pantalla principal con navegación
    } else {
      home = const LoginScreen(); // Si completó onboarding pero no hay sesión
    }

    // Construcción principal de la app con Providers
    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => ThemeProvider()),
        provider.ChangeNotifierProvider(create: (_) => TimerProvider()),
        provider.ChangeNotifierProvider(create: (_) => SimpleTimerProvider()),
        provider.ChangeNotifierProvider(create: (_) => StopwatchProvider()),
      ],
      child: provider.Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            // ✅ 2. Asignar la key al MaterialApp
            navigatorKey: navigatorKey,
            title: 'Pomodō',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: home, // Pantalla inicial decidida arriba
             // ✅ 3. Definir rutas nombradas
             routes: {
               // Ruta principal que muestra el MainScaffold (con BottomNavBar)
               '/home': (context) => const MainScaffold(),
               '/login': (context) => const LoginScreen(),
               // Puedes añadir más rutas si las necesitas
               // '/settings': (context) => const SettingsScreen(),
             },
          );
        },
      ),
    );
  }
}