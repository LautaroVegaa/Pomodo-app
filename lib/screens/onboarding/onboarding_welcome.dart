// lib/screens/onboarding/onboarding_welcome.dart
import 'package:flutter/material.dart';
import 'package:pomodo_app/screens/onboarding/onboarding_goals.dart';

class OnboardingWelcome extends StatelessWidget {
  const OnboardingWelcome({super.key});

  void _continueToNext(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingGoals()),
    );
  }

// ✅ Ítem con ícono check celeste y texto blanco
Widget _buildItem(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center, // centra el bloque completo
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Contenedor con ancho fijo para alinear íconos verticalmente
        SizedBox(
          width: 24, // mismo ancho para todos los íconos
          child: const Icon(
            Icons.check_circle,
            color: Color(0xFF00BFFF),
          ),
        ),
        const SizedBox(width: 8),
        // Texto alineado al inicio dentro del bloque
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Fondo transparente para que se vea el gradiente
      backgroundColor: Colors.transparent,
      body: Container(
        // ✅ Gradiente azul oscuro (reemplaza el color sólido anterior)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF050A14), // azul casi negro
              Color(0xFF0E1A2B), // azul oscuro más suave
            ],
          ),
        ),
        // 🚨 CAMBIO CLAVE: Usamos SingleChildScrollView para evitar el overflow
        child: SingleChildScrollView(
          // 🚨 Añadimos SafeArea para evitar que el contenido se solape con barras del sistema
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              // 🚨 CAMBIO CLAVE: Cambiamos Column por un Container con altura fija.
              // Usaremos el alto total de la pantalla para asegurarnos de que el
              // contenido intente ocupar toda la altura.
              child: Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                ),
                child: Column(
                  // 🚨 Mantenemos mainAxisAlignment.spaceBetween para distribuir
                  // el espacio entre la imagen/texto y el botón.
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 60),

                    // 🖼 Imagen principal y texto
                    Column(
                      children: [
                        // 🖼 Imagen principal
                        Image.asset(
                          // NOTA: Asegúrate de que 'assets/images/onb_welcome.png' exista.
                          'assets/images/onb_welcome.png',
                          width: MediaQuery.of(context).size.width * 0.85,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(height: 8), // 🔧 acercar texto a la imagen

                        // 📝 Texto y lista
                        const Text(
                          'Welcome to Pomodō',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildItem('Boost your focus'),
                        _buildItem('Improve habits'),
                        _buildItem('Track progress'),
                        _buildItem('Build consistency'),
                      ],
                    ),

                    // 🚨 REMOVIDO: Se eliminó el `Spacer()` que causaba problemas con la altura.
                    // El `mainAxisAlignment: MainAxisAlignment.spaceBetween` del Column
                    // junto con el `minHeight` del Container se encargan de la distribución.

                    // 🔘 Botón continuar (blanco)
                    Padding(
                      // 🚨 Aumentamos el bottom padding a 40 para más espacio en la parte inferior
                      padding: const EdgeInsets.only(bottom: 40, top: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _continueToNext(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87, // texto oscuro
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}