
import 'package:flutter/material.dart';

class SensoresPage extends StatelessWidget {
  const SensoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Monitoreo de Sensores',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1769AA),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1769AA),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.sensors,
                    size: 50,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Sensores del dispositivo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Visualización de movimiento y rotación',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            sensorCard(
              'Acelerómetro',
              Icons.speed,
              Colors.blue,
              'Aceleración en los tres ejes',
              'm/s²',
            ),

            const SizedBox(height: 20),

            sensorCard(
              'Giroscopio',
              Icons.screen_rotation,
              Colors.purple,
              'Velocidad angular del dispositivo',
              'rad/s',
            ),

            const SizedBox(height: 20),

            const Card(
              child: ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: Colors.orange,
                ),
                title: Text('Sensores pendientes'),
                subtitle: Text(
                  'Los valores se mostrarán cuando '
                  'se integren los sensores físicos.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sensorCard(
    String titulo,
    IconData icono,
    Color color,
    String descripcion,
    String unidad,
  ) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, size: 35, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              descripcion,
              style: const TextStyle(color: Colors.grey),
            ),

            const Divider(height: 30),

            Row(
              children: [
                valorEje('X', unidad, color),
                const SizedBox(width: 8),
                valorEje('Y', unidad, color),
                const SizedBox(width: 8),
                valorEje('Z', unidad, color),
              ],
            ),

            const SizedBox(height: 20),

            const Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 12,
                  color: Colors.orange,
                ),
                SizedBox(width: 8),
                Text('Esperando datos del sensor'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget valorEje(
    String eje,
    String unidad,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 4,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              'Eje $eje',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '--',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              unidad,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
