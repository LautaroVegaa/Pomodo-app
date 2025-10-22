// lib/screens/onboarding/onboarding_values.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodo_app/screens/login_screen.dart'; // ✅ Dirige al login luego de completar el onboarding

class OnboardingValues extends StatefulWidget {
  const OnboardingValues({super.key});

  @override
  State<OnboardingValues> createState() => _OnboardingValuesState();
}

class _OnboardingValuesState extends State<OnboardingValues> {
  String? _selectedValue;

  void _selectValue(String value) {
    setState(() {
      _selectedValue = value;
    });
  }

  Future<void> _finishOnboarding() async {
    if (_selectedValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select one option.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('completedOnboarding', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // ✅ Gradiente unificado (mismo que en las otras pantallas)
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF050A14), // azul casi negro
            Color(0xFF0E1A2B), // azul oscuro
          ],
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
                const Text(
                  "What’s most important to you right now?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // --- Opciones ---
                _buildOption("Energy"),
                const SizedBox(height: 16),
                _buildOption("Calmness"),
                const SizedBox(height: 16),
                _buildOption("Balance"),
                const SizedBox(height: 16),
                _buildOption("Discipline"),

                const SizedBox(height: 40),

                // --- Botón final ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _finishOnboarding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // ✅ blanco
                      foregroundColor: Colors.black87, // texto oscuro
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Start Pomodō',
                      style: TextStyle(
                        fontSize: 18,
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

  Widget _buildOption(String value) {
    final isSelected = _selectedValue == value;

    return GestureDetector(
      onTap: () => _selectValue(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00CFFF).withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00CFFF)
                : Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? const Color(0xFF00CFFF) : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
