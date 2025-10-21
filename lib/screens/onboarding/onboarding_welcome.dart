// lib/screens/onboarding/onboarding_welcome.dart
import 'package:flutter/material.dart';
// Quitado: import 'package:shared_preferences/shared_preferences.dart';
// Quitado: import 'package:pomodo_app/screens/login_screen.dart';
import 'package:pomodo_app/screens/onboarding/onboarding_name.dart'; // ✅ Importar la siguiente pantalla

class OnboardingWelcome extends StatelessWidget {
  const OnboardingWelcome({super.key});

  // 🟢 Método corregido: Solo navega a la siguiente pantalla, NO guarda el flag.
  void _continueToNext(BuildContext context) {
    // Si la aplicación se reinicia aquí, el usuario verá la pantalla de bienvenida.
    // Esto es correcto, ya que no ha completado el onboarding.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingName()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A0F24), Color(0xFF101C40)], // Azul oscuro Pomodō
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono o logo Pomodō
                const Icon(
                  Icons.access_time_rounded,
                  color: Color(0xFF00CFFF),
                  size: 72,
                ),
                const SizedBox(height: 40),

                // Título
                const Text(
                  'Welcome to Pomodō',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Beneficios
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('✅ Boost your focus',
                        style: TextStyle(color: Colors.white70, fontSize: 16)),
                    Text('✅ Improve habits',
                        style: TextStyle(color: Colors.white70, fontSize: 16)),
                    Text('✅ Track progress',
                        style: TextStyle(color: Colors.white70, fontSize: 16)),
                    Text('✅ Build consistency',
                        style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 40),

                // Botón "Continue"
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _continueToNext(context), // ✅ Llamada corregida
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00CFFF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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