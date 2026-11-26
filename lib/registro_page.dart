
import 'package:flutter/material.dart';
import 'sensores_page.dart';
import 'ubicacion_page.dart';
import 'historial_page.dart';

/// Pantalla de acceso al registro de mediciones.
/// Permite elegir sensores físicos, GPS o consultar
/// registros almacenados previamente en Supabase.
class RegistroPage extends StatelessWidget {
  final String tipoInicial;

  const RegistroPage({
    super.key,
    this.tipoInicial = 'accelerometer',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de mediciones'),
        backgroundColor: const Color(0xFF1769AA),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Encabezado principal del módulo.
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: const Color(0xFF1769AA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 55,
                  color: Colors.white,
                ),

                SizedBox(height: 10),

                Text(
                  'Registrar medición',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  'Captura directamente desde los '
                  'sensores del celular.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Acceso al acelerómetro y giroscopio.
          opcion(
            context,
            Icons.sensors,
            'Acelerómetro y giroscopio',
            'Monitorear y guardar valores X, Y, Z',
            const SensoresPage(),
          ),

          const SizedBox(height: 10),

          // Acceso a la captura de ubicación GPS.
          opcion(
            context,
            Icons.location_on,
            'GPS',
            'Obtener y guardar ubicación con autorización',
            const UbicacionPage(),
          ),

          const SizedBox(height: 10),

          // Acceso a los registros almacenados.
          opcion(
            context,
            Icons.history,
            'Consultar registros',
            'Ver mediciones guardadas en Supabase',
            const HistorialPage(),
          ),
        ],
      ),
    );
  }

  /// Construye una tarjeta de menú y utiliza Navigator
  /// para abrir la pantalla seleccionada.
  Widget opcion(
    BuildContext context,
    IconData icono,
    String titulo,
    String detalle,
    Widget pantalla,
  ) {
    return Card(
      color: Colors.white,
      child: ListTile(
        leading: Icon(
          icono,
          color: const Color(0xFF1769AA),
        ),
        title: Text(titulo),
        subtitle: Text(detalle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => pantalla,
            ),
          );
        },
      ),
    );
  }
}
