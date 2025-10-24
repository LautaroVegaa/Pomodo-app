import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Fondo general
    scaffoldBackgroundColor: const Color(0xFFF9FAFB),

    // Primario Pomodō
    primaryColor: const Color(0xFF3B82F6),

    // ✅ Cards unificadas más claras y consistentes (temporizador + estadísticas)
    cardColor: const Color(0xFFECEEF1),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF9FAFB),
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Color(0xFF1F2937),
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      iconTheme: IconThemeData(color: Color(0xFF1F2937)),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Color(0xFF1F2937)),
      bodyLarge: TextStyle(color: Color(0xFF1F2937)),
    ),

    // ✅ Mismo tono aplicado al CardTheme
    cardTheme: CardThemeData(
      color: const Color(0xFFECEEF1),
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        borderSide: BorderSide(color: Color(0xFF3B82F6), width: 2),
      ),
    ),

    iconTheme: const IconThemeData(color: Colors.grey),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor: const Color(0xFF111827),
    primaryColor: const Color(0xFF3B82F6),

    cardColor: const Color(0xFF1F2937),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF111827),
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Color(0xFFF9FAFB),
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      iconTheme: IconThemeData(color: Color(0xFFF9FAFB)),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Color(0xFFF9FAFB)),
      bodyLarge: TextStyle(color: Color(0xFFF9FAFB)),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF1F2937),
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1F2937),
      hintStyle: TextStyle(color: Colors.grey.shade400),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        borderSide: BorderSide(color: Color(0xFF3B82F6), width: 2),
      ),
    ),

    iconTheme: IconThemeData(color: Colors.grey.shade400),
  );
}
