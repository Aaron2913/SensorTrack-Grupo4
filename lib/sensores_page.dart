
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'mediciones_service.dart';

/// Pantalla que monitorea el acelerómetro y giroscopio.
/// Presenta los valores X, Y y Z en tiempo real y permite
/// guardar capturas de ambos sensores en Supabase.
class SensoresPage extends StatefulWidget {
  const SensoresPage({super.key});

  @override
  State<SensoresPage> createState() => _SensoresPageState();
}

class _SensoresPageState extends State<SensoresPage> {
  final servicio = MedicionesService();

  // Suscripciones para recibir lecturas de ambos sensores.
  StreamSubscription<AccelerometerEvent>? _acelerometroSub;
  StreamSubscription<GyroscopeEvent>? _giroscopioSub;

  // Almacenan temporalmente la última lectura.
  Map<String, dynamic>? _acelerometro;
  Map<String, dynamic>? _giroscopio;

  String _estadoA = 'Esperando lectura';
  String _estadoG = 'Esperando lectura';

  // Evita guardar varias mediciones simultáneamente.
  bool _guardando = false;

  /// Inicia la captura de sensores al abrir la pantalla.
  @override
  void initState() {
    super.initState();

    // Escucha los cambios del acelerómetro físico
    // aproximadamente cada 200 milisegundos.
    _acelerometroSub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 200),
    ).timeout(const Duration(seconds: 5)).listen(
      (evento) {
        if (!mounted) return;

        setState(() {
          _acelerometro = medicion(
            'accelerometer',
            evento.x,
            evento.y,
            evento.z,
          );

          _estadoA = 'Lectura en tiempo real';
        });
      },
      onError: (Object error) {
        if (!mounted) return;

        setState(() {
          _acelerometro = null;
          _estadoA = 'Sin lectura del acelerómetro';
        });
      },
      cancelOnError: true,
    );

    // Escucha el giroscopio para detectar
    // la velocidad de rotación del dispositivo.
    _giroscopioSub = gyroscopeEventStream(
      samplingPeriod: const Duration(milliseconds: 200),
    ).timeout(const Duration(seconds: 5)).listen(
      (evento) {
        if (!mounted) return;

        setState(() {
          _giroscopio = medicion(
            'gyroscope',
            evento.x,
            evento.y,
            evento.z,
          );

          _estadoG = 'Lectura en tiempo real';
        });
      },
      onError: (Object error) {
        if (!mounted) return;

        setState(() {
          _giroscopio = null;
          _estadoG = 'Sin lectura del giroscopio';
        });
      },
      cancelOnError: true,
    );
  }

  /// Construye una medición con los valores de sus
  /// tres ejes y la fecha de captura en formato UTC.
  Map<String, dynamic> medicion(
    String tipo,
    double x,
    double y,
    double z,
  ) {
    return {
      'sensor_type': tipo,
      'x': x,
      'y': y,
      'z': z,
      'recorded_at': DateTime.now()
          .toUtc()
          .toIso8601String(),
    };
  }

  /// Guarda la medición capturada en Supabase.
  /// Muestra mensajes de éxito o error al usuario.
  Future<void> guardar(
    Map<String, dynamic> datos,
  ) async {
    if (_guardando) return;

    final captura = Map<String, dynamic>.from(datos);

    setState(() {
      _guardando = true;
    });

    try {
      // Envía los datos al servicio de base de datos.
      await servicio.guardarMedicion(captura);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medición guardada en Supabase'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      debugPrint('Error al guardar sensor: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar la medición'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  /// Cancela las suscripciones al salir de la pantalla.
  /// Evita que los sensores sigan enviando datos
  /// a un widget que ya no está activo.
  @override
  void dispose() {
    _acelerometroSub?.cancel();
    _giroscopioSub?.cancel();

    super.dispose();
  }

  /// Construye las tarjetas de ambos sensores.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoreo de Sensores'),
        backgroundColor: const Color(0xFF1769AA),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
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
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // Tarjeta del acelerómetro.
          sensorCard(
            'Acelerómetro',
            Icons.speed,
            Colors.blue,
            'm/s²',
            _acelerometro,
            _estadoA,
          ),

          const SizedBox(height: 20),

          // Tarjeta del giroscopio.
          sensorCard(
            'Giroscopio',
            Icons.screen_rotation,
            Colors.purple,
            'rad/s',
            _giroscopio,
            _estadoG,
          ),
        ],
      ),
    );
  }

  /// Construye una tarjeta reutilizable para mostrar
  /// valores X, Y, Z, fecha, estado y botón de guardado.
  Widget sensorCard(
    String titulo,
    IconData icono,
    Color color,
    String unidad,
    Map<String, dynamic>? datos,
    String estado,
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

            const Divider(height: 30),

            // Muestra los tres ejes del sensor.
            Row(
              children: [
                for (final eje in ['x', 'y', 'z'])
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 3,
                      ),
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
                            'Eje ${eje.toUpperCase()}',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              servicio.numero(datos?[eje]),
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Text(unidad),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 15),

            // Estado de disponibilidad del sensor.
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 12,
                  color: datos != null
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(estado)),
              ],
            ),

            // Fecha de la última captura disponible.
            if (datos != null)
              Text(
                'Captura: ${servicio.formatearFecha(
                  datos['recorded_at'],
                )}',
              ),

            const SizedBox(height: 15),

            // Guarda la última medición en Supabase.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: datos == null || _guardando
                    ? null
                    : () => guardar(datos),

                icon: const Icon(Icons.save),

                label: Text(
                  _guardando
                      ? 'Guardando...'
                      : 'Guardar medición',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
