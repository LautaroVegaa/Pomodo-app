import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Importar Supabase
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // [NUEVA FUNCIÓN] Lógica de cerrar sesión
  Future<void> _signOut(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      // Nota: No necesitamos navegar manualmente, ya que el StreamBuilder en main.dart
      // detectará el cambio de estado de Auth y redirigirá a LoginScreen.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión cerrada correctamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Configuración",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Sección de Apariencia
          ListTile(
            leading: Icon(Icons.palette_outlined, color: Theme.of(context).textTheme.bodyLarge?.color),
            title: Text(
              "Apariencia",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text("Modo Oscuro"), 
            value: isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
            secondary: Icon(
              isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: isDarkMode ? Theme.of(context).primaryColor : Colors.grey,
            ),
          ),
          const Divider(height: 32),
          
          // Sección de Notificaciones
          ListTile(
            leading: Icon(Icons.notifications_none_outlined, color: Theme.of(context).textTheme.bodyLarge?.color),
            title: Text(
              "Notificaciones",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text("Activar notificaciones"),
            value: true, // Placeholder, aquí iría el estado real
            onChanged: (value) {
              // Lógica para activar/desactivar notificaciones
            },
            secondary: Icon(
              Icons.notifications_active_outlined,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const Divider(height: 32),

          // [NUEVO] Opción de Cerrar Sesión
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              "Cerrar Sesión",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            onTap: () => _signOut(context), // Llamar a la función de cerrar sesión
          ),
        ],
      ),
    );
  }
}