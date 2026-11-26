
import 'package:flutter/material.dart';
import 'registro_page.dart';

class UbicacionPage extends StatelessWidget {
  const UbicacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ubicación GPS',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1769AA),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFF1769AA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 65,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Mi ubicación',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Información geográfica del dispositivo',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Card(
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.public,
                      color: Colors.blue,
                    ),
                    title: Text('Latitud'),
                    subtitle: Text('Pendiente de lectura'),
                    trailing: Text('--'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.explore,
                      color: Colors.green,
                    ),
                    title: Text('Longitud'),
                    subtitle: Text('Pendiente de lectura'),
                    trailing: Text('--'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.gps_fixed,
                      color: Colors.orange,
                    ),
                    title: Text('Precisión'),
                    subtitle: Text('Metros'),
                    trailing: Text('--'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.access_time,
                      color: Colors.purple,
                    ),
                    title: Text('Fecha y hora'),
                    subtitle: Text('Última captura'),
                    trailing: Text('--'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              height: 170,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    color: Colors.blue,
                    size: 65,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Vista de ubicación',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Ubicación pendiente de integración',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'La lectura GPS está pendiente '
                        'de integración.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.my_location),
                label: const Text('Obtener ubicación'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const RegistroPage(tipoInicial: 'gps'),
                    ),
                  );
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text('Registrar medición GPS'),
              ),
            ),

            const SizedBox(height: 20),

            const Card(
              child: ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: Colors.orange,
                ),
                title: Text('Estado del GPS'),
                subtitle: Text(
                  'La lectura real del GPS se integrará '
                  'posteriormente.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
