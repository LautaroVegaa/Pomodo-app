import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller; // [CAMBIO] Añadir controlador opcional
  final TextInputType? keyboardType; // [CAMBIO] Añadir tipo de teclado

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.icon,
    this.isPassword = false,
    this.controller, // [CAMBIO]
    this.keyboardType, // [CAMBIO]
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, // [CAMBIO] Asignar el controlador
      obscureText: isPassword,
      keyboardType: keyboardType, // [CAMBIO] Asignar el tipo de teclado
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Theme.of(context).iconTheme.color),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo no puede estar vacío';
        }
        // Validación básica de email para el campo de email
        if (keyboardType == TextInputType.emailAddress && !value.contains('@')) {
          return 'Ingrese un email válido';
        }
        return null;
      },
    );
  }
}