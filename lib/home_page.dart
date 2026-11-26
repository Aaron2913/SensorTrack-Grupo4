
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';

import 'sensores_page.dart';
import 'ubicacion_page.dart';
import 'registro_page.dart';
import 'historial_page.dart';
import 'estadisticas_page.dart';
import 'mediciones_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final servicio = MedicionesService();

  late Future<void> _conexion;
  late Future<List<String>> _sensores;

  @override
  void initState() {
    super.initState();

    _conexion = servicio.comprobarConexion().timeout(
      const Duration(seconds: 15),
    );

    _sensores = comprobarSensores();
  }

  // Comprobar si un sensor proporciona lecturas.
  Future<String> comprobarSensor(
    Stream<dynamic> stream,
  ) async {
    try {
      await stream
          .timeout(const Duration(seconds: 5))
          .first;

      return 'Lectura disponible';

    } catch (_) {
      return 'Sin lectura; comprueba el dispositivo';
    }
  }

  // Comprobar el estado de la ubicación.
  Future<String> comprobarGps() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return 'Servicio desactivado';
      }

      final permiso = await Geolocator.checkPermission();

      if (permiso == LocationPermission.whileInUse ||
          permiso == LocationPermission.always) {
        return 'Servicio activo y permiso concedido';
      }

      return 'Servicio activo; permiso pendiente';

    } catch (_) {
      return 'No se pudo comprobar el GPS';
    }
  }

  // Comprobar los tres sensores.
  Future<List<String>> comprobarSensores() {
    return Future.wait([
      comprobarSensor(accelerometerEventStream()),
      comprobarSensor(gyroscopeEventStream()),
      comprobarGps(),
    ]);
  }

  // Actualizar el estado del sistema.
  void actualizar() {
    setState(() {
      _conexion = servicio.comprobarConexion().timeout(
        const Duration(seconds: 15),
      );

      _sensores = comprobarSensores();
    });
  }

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
            // Bienvenida.
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

            // Estado de Supabase.
            const Text(
              'Estado del sistema',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            FutureBuilder<void>(
              future: _conexion,

              builder: (context, snapshot) {
                final cargando =
                    snapshot.connectionState ==
                        ConnectionState.waiting;

                final conectado =
                    !cargando && !snapshot.hasError;

                return Card(
                  color: Colors.white,
                  child: ListTile(
                    leading: Icon(
                      conectado
                          ? Icons.cloud_done
                          : Icons.cloud_outlined,

                      color: cargando
                          ? Colors.orange
                          : conectado
                              ? Colors.green
                              : Colors.red,
                    ),

                    title: const Text(
                      'Conexión con Supabase',
                    ),

                    subtitle: Text(
                      cargando
                          ? 'Comprobando conexión...'
                          : conectado
                              ? 'Última comprobación correcta'
                              : 'Error de conexión',
                    ),

                    trailing: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: cargando
                          ? null
                          : actualizar,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            // Estado de los sensores.
            const Text(
              'Sensores del dispositivo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            FutureBuilder<List<String>>(
              future: _sensores,

              builder: (context, snapshot) {
                final estados =
                    snapshot.connectionState ==
                            ConnectionState.waiting
                        ? [
                            'Comprobando...',
                            'Comprobando...',
                            'Comprobando...',
                          ]
                        : snapshot.data ??
                            [
                              'Sin lectura',
                              'Sin lectura',
                              'Sin lectura',
                            ];

                return Card(
                  color: Colors.white,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.speed,
                          color: Colors.blue,
                        ),
                        title: const Text('Acelerómetro'),
                        subtitle: Text(estados[0]),
                      ),

                      const Divider(height: 1),

                      ListTile(
                        leading: const Icon(
                          Icons.screen_rotation,
                          color: Colors.purple,
                        ),
                        title: const Text('Giroscopio'),
                        subtitle: Text(estados[1]),
                      ),

                      const Divider(height: 1),

                      ListTile(
                        leading: const Icon(
                          Icons.location_on,
                          color: Colors.green,
                        ),
                        title: const Text('GPS'),
                        subtitle: Text(estados[2]),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            // Menú principal.
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
                  const SensoresPage(),
                ),

                menuCard(
                  context,
                  'Ubicación',
                  Icons.location_on,
                  Colors.green,
                  const UbicacionPage(),
                ),

                menuCard(
                  context,
                  'Registro',
                  Icons.save_outlined,
                  Colors.teal,
                  const RegistroPage(),
                ),

                menuCard(
                  context,
                  'Historial',
                  Icons.history,
                  Colors.orange,
                  const HistorialPage(),
                ),

                menuCard(
                  context,
                  'Estadísticas',
                  Icons.bar_chart,
                  Colors.purple,
                  const EstadisticasPage(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Tarjetas para navegar entre pantallas.
  Widget menuCard(
    BuildContext context,
    String titulo,
    IconData icono,
    Color color,
    Widget pantalla,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => pantalla,
          ),
        ).then((_) {
          if (mounted) {
            actualizar();
          }
        });
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
