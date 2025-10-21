// lib/screens/onboarding/onboarding_welcome.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodo_app/screens/onboarding/onboarding_auth.dart';

class OnboardingWelcome extends StatelessWidget {
  const OnboardingWelcome({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('completedOnboarding', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingAuth()),
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
                    onPressed: () => _completeOnboarding(context),
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
