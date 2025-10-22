// lib/screens/onboarding/onboarding_goals.dart
import 'package:flutter/material.dart';
import 'package:pomodo_app/screens/onboarding/onboarding_values.dart';

class OnboardingGoals extends StatefulWidget {
  const OnboardingGoals({super.key});

  @override
  State<OnboardingGoals> createState() => _OnboardingGoalsState();
}

class _OnboardingGoalsState extends State<OnboardingGoals> {
  String? _selectedGoal;

  void _selectGoal(String goal) {
    setState(() {
      _selectedGoal = goal;
    });
  }

  void _continueToNext() {
    if (_selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select one option.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingValues()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // ✅ Gradiente unificado (igual que en el resto)
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
                  "What do you want to achieve with Pomodō?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // --- Opciones ---
                _buildOption("Improve focus"),
                const SizedBox(height: 16),
                _buildOption("Manage stress"),
                const SizedBox(height: 16),
                _buildOption("Build consistency"),

                const SizedBox(height: 40),

                // --- Botón Continue ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _continueToNext,
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
                      'Continue',
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

  /// 🔹 Crea las tarjetas de opción animadas
  Widget _buildOption(String goal) {
    final isSelected = _selectedGoal == goal;

    return GestureDetector(
      onTap: () => _selectGoal(goal),
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
          goal,
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
