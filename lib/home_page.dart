
import 'package:flutter/material.dart';
import 'sensores_page.dart';
import 'ubicacion_page.dart';
import 'registro_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SensorTrack',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1769AA),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bienvenida
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1769AA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.sensors,
                    color: Colors.white,
                    size: 45,
                  ),
                  SizedBox(height: 12),
                  Text(
                    '¡Bienvenido a SensorTrack!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Monitorea los sensores de tu dispositivo móvil.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Estado del sistema
            const Text(
              'Estado del sistema',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Card(
              color: Colors.white,
              child: ListTile(
                leading: Icon(
                  Icons.cloud_outlined,
                  color: Colors.orange,
                ),
                title: Text('Conexión con Supabase'),
                subtitle: Text('Pendiente de integración'),
                trailing: Icon(
                  Icons.info_outline,
                  color: Colors.orange,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Sensores del dispositivo
            const Text(
              'Sensores del dispositivo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Card(
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.speed,
                      color: Colors.blue,
                    ),
                    title: Text('Acelerómetro'),
                    subtitle: Text('Pendiente de lectura'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.screen_rotation,
                      color: Colors.purple,
                    ),
                    title: Text('Giroscopio'),
                    subtitle: Text('Pendiente de lectura'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: Colors.green,
                    ),
                    title: Text('GPS'),
                    subtitle: Text('Pendiente de lectura'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Menú principal
            const Text(
              'Menú principal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1.25,
              children: [
                menuCard(
                  context,
                  'Sensores',
                  Icons.sensors,
                  Colors.blue,
                ),
                menuCard(
                  context,
                  'Ubicación',
                  Icons.location_on,
                  Colors.green,
                ),
                menuCard(
                  context,
                  'Registro',
                  Icons.save_outlined,
                  Colors.teal,
                ),
                menuCard(
                  context,
                  'Historial',
                  Icons.history,
                  Colors.orange,
                ),
                menuCard(
                  context,
                  'Estadísticas',
                  Icons.bar_chart,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Tarjetas del menú
  Widget menuCard(
    BuildContext context,
    String titulo,
    IconData icono,
    Color color,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Widget pantalla;

        if (titulo == 'Sensores') {
          pantalla = const SensoresPage();
        } else if (titulo == 'Ubicación') {
          pantalla = const UbicacionPage();
        } else if (titulo == 'Registro') {
          pantalla = const RegistroPage();
        } else {
          pantalla = PantallaTemporal(
            titulo: titulo,
            icono: icono,
          );
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => pantalla,
          ),
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              size: 42,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pantalla temporal para módulos pendientes
class PantallaTemporal extends StatelessWidget {
  final String titulo;
  final IconData icono;

  const PantallaTemporal({
    super.key,
    required this.titulo,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: const Color(0xFF1769AA),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            Text(
              'Módulo de $titulo',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text('Próximamente'),
          ],
        ),
      ),
    );
  }
}
