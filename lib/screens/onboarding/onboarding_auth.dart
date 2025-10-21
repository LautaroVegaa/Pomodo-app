// lib/screens/onboarding/onboarding_auth.dart
import 'package:flutter/material.dart';
import 'package:pomodo_app/screens/onboarding/onboarding_name.dart';

class OnboardingAuth extends StatelessWidget {
  const OnboardingAuth({super.key});

  void _continueToNext(BuildContext context) {
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
                // Ícono principal Pomodō
                const Icon(
                  Icons.access_time_rounded,
                  color: Color(0xFF00CFFF),
                  size: 72,
                ),
                const SizedBox(height: 40),

                // Título
                const Text(
                  'This is where your focus journey begins',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 40),

                // Botones de inicio de sesión (decorativos por ahora)
                _buildAuthButton(
                  icon: Icons.mail_outline,
                  text: 'Sign in with Email',
                  onTap: () => _continueToNext(context),
                ),
                const SizedBox(height: 16),
                _buildAuthButton(
                  icon: Icons.apple,
                  text: 'Sign in with Apple',
                  onTap: () => _continueToNext(context),
                ),
                const SizedBox(height: 16),
                _buildAuthButton(
                  icon: Icons.g_mobiledata_rounded,
                  text: 'Sign in with Google',
                  onTap: () => _continueToNext(context),
                ),

                const SizedBox(height: 32),
                // Enlace de registro
                GestureDetector(
                  onTap: () => _continueToNext(context),
                  child: const Text(
                    "Don't have an account? Sign up",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      decoration: TextDecoration.underline,
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

  // --- WIDGET AUXILIAR ---
  Widget _buildAuthButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFF00CFFF), width: 1),
          ),
        ),
        icon: Icon(icon, color: const Color(0xFF00CFFF)),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
