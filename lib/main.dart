
import 'package:flutter/material.dart';
import 'package:sensortrack/splash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Función principal de la aplicación SensorTrack.
/// Inicializa Flutter y establece la conexión con Supabase.
Future<void> main() async {

  // Garantiza que Flutter esté inicializado antes
  // de utilizar servicios externos.
  WidgetsFlutterBinding.ensureInitialized();

  // Configura la conexión con el proyecto Supabase.
  // La clave utilizada es pública (publishable key). 
  await Supabase.initialize(
    url: 'https://kjyyckhxmmgaafsnkflb.supabase.co',
    publishableKey: 'sb_publishable_kZ4jaSEktxzQBkkislJyQA_OxMcpSvu',
  );

  // Inicia la aplicación una vez configurado Supabase.
  runApp(const SensorTrackApp());
}

/// Widget principal de SensorTrack.
/// Define el tema, las configuraciones generales
/// y la pantalla inicial de la aplicación.
class SensorTrackApp extends StatelessWidget {

  const SensorTrackApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      // Oculta la etiqueta DEBUG.
      debugShowCheckedModeBanner: false,

      // Establece el nombre de la aplicación.
      title: 'SensorTrack',

      // Define la apariencia general de la aplicación.
      theme: ThemeData(

        // Color principal de las interfaces.
        primarySwatch: Colors.blue,

        // Color de fondo utilizado en las pantallas.
        scaffoldBackgroundColor: const Color(0xFFF4F7FC),

        // Activa el diseño Material 3.
        useMaterial3: true,
      ),

      // Establece Splash como primera pantalla.
      home: const Splash(),
    );
  }
}
