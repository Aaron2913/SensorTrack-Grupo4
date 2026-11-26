
import 'package:flutter/material.dart';
import 'home_page.dart';

/// Pantalla de bienvenida de SensorTrack.
/// Se muestra durante tres segundos antes de
/// navegar automáticamente al menú principal.
class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  /// Ejecuta la navegación cuando inicia la pantalla.
  @override
  void initState() {
    super.initState();
    _irAlInicio();
  }

  /// Espera tres segundos y abre la pantalla principal.
  Future<void> _irAlInicio() async {
    await Future.delayed(
      const Duration(seconds: 3),
    );

    // Verifica que la pantalla siga activa.
    if (!mounted) return;

    // Reemplaza Splash por HomePage, evitando
    // regresar al Splash con el botón Atrás.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  /// Construye la interfaz de bienvenida.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1769AA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.sensors,
                size: 90,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'SensorTrack',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Monitoreo inteligente de sensores',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 45),

            // Indicador visual de carga.
            const CircularProgressIndicator(
              color: Colors.white,
            ),

            const SizedBox(height: 20),

            const Text(
              'Iniciando aplicación...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
