// lib/screens/onboarding/onboarding_gender.dart
import 'package:flutter/material.dart';
import 'package:pomodo_app/screens/onboarding/onboarding_goals.dart';

class OnboardingGender extends StatefulWidget {
  const OnboardingGender({super.key});

  @override
  State<OnboardingGender> createState() => _OnboardingGenderState();
}

class _OnboardingGenderState extends State<OnboardingGender> {
  String? _selectedGender;

  /// 🟣 Guarda la selección de género en memoria temporal
  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  /// 🟢 Avanza al siguiente paso si hay una selección
  void _continueToNext() {
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your gender.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 🟢 En el futuro se puede guardar esta preferencia en Supabase o SharedPreferences
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingGoals()),
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
                const Text(
                  "What is your gender?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // --- Opciones ---
                _buildOption("Male"),
                const SizedBox(height: 16),
                _buildOption("Female"),
                const SizedBox(height: 16),
                _buildOption("Other"),

                const SizedBox(height: 40),

                // --- Botón Continue ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _continueToNext,
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

  /// 🔹 Construye cada opción de género con animación
  Widget _buildOption(String gender) {
    final isSelected = _selectedGender == gender;

    return GestureDetector(
      onTap: () => _selectGender(gender),
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
          gender,
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
