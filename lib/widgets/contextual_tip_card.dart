// lib/widgets/contextual_tip_card.dart

import 'package:flutter/material.dart';

class ContextualTipCard extends StatelessWidget {
  final String text;
  final IconData icon;

  const ContextualTipCard({
    super.key,
    required this.text,
    this.icon = Icons.lightbulb_outline, // Icono por defecto
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Estilo adaptado del contenedor de frases de PomodoroScreen
    return Container(
      width: MediaQuery.of(context).size.width * 0.9, // Ancho similar
      constraints: const BoxConstraints(minHeight: 70), // Altura mínima adaptable
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color.fromARGB(90, 40, 50, 90) // Azulado oscuro translúcido
            : const Color(0xFFE0E7FF), // Azul muy claro (indigo-100)
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? const Color.fromARGB(255, 60, 70, 110) // Borde azul grisáceo oscuro
              : const Color(0xFFC7D2FE), // Borde azul claro (indigo-200)
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isDarkMode ? const Color(0xFFA5B4FC) : theme.primaryColor, // Color de icono adaptado
            size: 18,
          ),
          const SizedBox(width: 10), // Un poco más de espacio
          Expanded(
            child: AnimatedSwitcher( // Animación al cambiar el texto
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child); // Transición suave
              },
              child: Text(
                text.isNotEmpty ? text : "Mantén la concentración.", // Texto por defecto si está vacío
                key: ValueKey<String>(text), // Clave para la animación correcta
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode // Color de texto adaptado
                      ? Colors.white.withOpacity(0.9)
                      : theme.textTheme.bodyLarge?.color?.withOpacity(0.85),
                  fontSize: 14,
                  height: 1.4, // Interlineado
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}