
import 'package:flutter/material.dart';
import 'mediciones_service.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  final servicio = MedicionesService();

  late Future<List<Map<String, dynamic>>> mediciones;

  @override
  void initState() {
    super.initState();
    mediciones = servicio.getMediciones();
  }

  // Volver a consultar los registros.
  void actualizar() {
    setState(() {
      mediciones = servicio.getMediciones();
    });
  }

  IconData iconoSensor(String tipo) {
    switch (tipo) {
      case 'accelerometer':
        return Icons.speed;
      case 'gyroscope':
        return Icons.screen_rotation;
      case 'gps':
        return Icons.location_on;
      default:
        return Icons.sensors;
    }
  }

  Color colorSensor(String tipo) {
    switch (tipo) {
      case 'accelerometer':
        return Colors.blue;
      case 'gyroscope':
        return Colors.purple;
      case 'gps':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Ventana de detalles de una medición.
  void mostrarDetalle(Map<String, dynamic> medicion) {
    final tipo = medicion['sensor_type'].toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(servicio.nombreSensor(tipo)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${medicion['id']}'),
                const Divider(),
                const Text(
                  'Valores registrados',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(servicio.resumen(medicion)),
                const Divider(),
                const Text(
                  'Fecha y hora',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  servicio.formatearFecha(
                    medicion['recorded_at'],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de mediciones'),
        backgroundColor: const Color(0xFF1769AA),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: actualizar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: mediciones,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      size: 60,
                      color: Colors.red,
                    ),
                    const Text(
                      'No se pudieron consultar los registros',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: actualizar,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final datos = snapshot.data ?? [];

          if (datos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text('No hay mediciones registradas'),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1769AA),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'Total de mediciones: ${datos.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  itemCount: datos.length,
                  itemBuilder: (context, index) {
                    final medicion = datos[index];
                    final tipo =
                        medicion['sensor_type'].toString();

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: CircleAvatar(
                          backgroundColor: colorSensor(tipo),
                          foregroundColor: Colors.white,
                          child: Icon(iconoSensor(tipo)),
                        ),
                        title: Text(
                          servicio.nombreSensor(tipo),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${servicio.resumen(medicion)}\n\n'
                          '${servicio.formatearFecha(medicion['recorded_at'])}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => mostrarDetalle(medicion),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
