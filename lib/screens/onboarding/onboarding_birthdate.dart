// lib/screens/onboarding/onboarding_birthdate.dart
import 'package:flutter/material.dart';
import 'package:pomodo_app/screens/onboarding/onboarding_gender.dart';

class OnboardingBirthdate extends StatefulWidget {
  const OnboardingBirthdate({super.key});

  @override
  State<OnboardingBirthdate> createState() => _OnboardingBirthdateState();
}

class _OnboardingBirthdateState extends State<OnboardingBirthdate> {
  DateTime? _selectedDate;

  /// 🗓️ Selector de fecha con tema personalizado Pomodō
  void _pickDate() async {
    final now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20), // valor por defecto: 20 años atrás
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        // 🎨 Personalización de colores (tema oscuro Pomodō)
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00CFFF), // azul Pomodō
              onPrimary: Colors.black,
              surface: Color(0xFF101C40),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Color(0xFF0A0F24),
          ),
          child: child!,
        );
      },
    );

    // ✅ Solo actualizar si el usuario realmente seleccionó una fecha nueva
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// 🟢 Avanza al siguiente paso del onboarding
  void _continueToNext() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your birthdate.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 🟢 En el futuro, esta fecha podría guardarse en Supabase o SharedPreferences
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingGender()),
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
                  "Your Birthdate",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // --- Campo visual del selector ---
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: const Color(0xFF00CFFF),
                          width: 1,
                      ),
                    ),
                    child: Text(
                      _selectedDate == null
                          ? "Enter your birthdate"
                          : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // --- Botón "Continue" ---
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
}
