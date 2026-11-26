
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'mediciones_service.dart';

/// Pantalla encargada de obtener la ubicación GPS.
/// Muestra coordenadas, precisión y fecha de captura.
/// Permite guardar los datos con autorización del usuario.
class UbicacionPage extends StatefulWidget {
  const UbicacionPage({super.key});

  @override
  State<UbicacionPage> createState() =>
      _UbicacionPageState();
}

class _UbicacionPageState extends State<UbicacionPage> {
  final servicio = MedicionesService();

  // Última ubicación capturada.
  Position? _posicion;

  // Controla el estado de carga de las operaciones.
  bool _ocupado = false;

  String _estado = 'Presiona Obtener ubicación';

  /// Solicita permisos y obtiene la posición GPS.
  Future<void> obtenerUbicacion() async {
    if (_ocupado) return;

    setState(() {
      _ocupado = true;
      _posicion = null;
      _estado = 'Obteniendo ubicación...';
    });

    try {
      // Verifica que el servicio de ubicación esté activo.
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError(
          'Activa la ubicación del dispositivo.',
        );
      }

      // Comprueba los permisos de ubicación.
      var permiso = await Geolocator.checkPermission();

      // Solicita autorización si todavía no está concedida.
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.deniedForever) {
        throw StateError(
          'Autoriza la ubicación desde los ajustes '
          'de la aplicación.',
        );
      }

      if (permiso != LocationPermission.whileInUse &&
          permiso != LocationPermission.always) {
        throw StateError(
          'No se concedió el permiso de ubicación.',
        );
      }

      // Obtiene latitud, longitud, precisión y fecha.
      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );

      if (!mounted) return;

      setState(() {
        _posicion = posicion;
        _estado = 'Ubicación obtenida';
      });

    } catch (error) {
      if (!mounted) return;

      // Presenta un mensaje comprensible si ocurre un error.
      setState(() {
        _estado = error is StateError
            ? error.message.toString()
            : 'No se pudo obtener la ubicación. '
                'Intenta nuevamente.';
      });

    } finally {
      if (mounted) {
        setState(() {
          _ocupado = false;
        });
      }
    }
  }

  /// Solicita autorización para guardar la ubicación.
  /// Envía las coordenadas a Supabase únicamente
  /// cuando el usuario confirma el almacenamiento.
  Future<void> guardarUbicacion() async {
    final posicion = _posicion;

    if (posicion == null || _ocupado) return;

    setState(() {
      _ocupado = true;
    });

    try {
      // Muestra el diálogo de consentimiento.
      final autorizado = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Guardar ubicación'),
          content: const Text(
            '¿Autorizas guardar esta ubicación en Supabase?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Autorizar'),
            ),
          ],
        ),
      );

      if (!mounted || autorizado != true) return;

      // Construye el registro GPS para sensor_readings.
      await servicio.guardarMedicion({
        'sensor_type': 'gps',
        'latitude': posicion.latitude,
        'longitude': posicion.longitude,
        'accuracy': posicion.accuracy,
        'recorded_at': posicion.timestamp
            .toUtc()
            .toIso8601String(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ubicación guardada en Supabase'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar la ubicación'),
          backgroundColor: Colors.red,
        ),
      );

    } finally {
      if (mounted) {
        setState(() {
          _ocupado = false;
        });
      }
    }
  }

  /// Construye una fila para mostrar un dato de ubicación.
  Widget dato(
    IconData icono,
    Color color,
    String titulo,
    String valor,
  ) {
    return ListTile(
      leading: Icon(icono, color: color),
      title: Text(titulo),
      subtitle: Text(valor),
    );
  }

  /// Construye la interfaz de captura y registro GPS.
  @override
  Widget build(BuildContext context) {
    final p = _posicion;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación GPS'),
        backgroundColor: const Color(0xFF1769AA),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Encabezado del módulo.
          Container(
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

          // Tarjeta con los valores obtenidos mediante GPS.
          Card(
            color: Colors.white,
            child: Column(
              children: [
                dato(
                  Icons.public,
                  Colors.blue,
                  'Latitud',
                  servicio.numero(
                    p?.latitude,
                    decimales: 6,
                  ),
                ),

                const Divider(height: 1),

                dato(
                  Icons.explore,
                  Colors.green,
                  'Longitud',
                  servicio.numero(
                    p?.longitude,
                    decimales: 6,
                  ),
                ),

                const Divider(height: 1),

                dato(
                  Icons.gps_fixed,
                  Colors.orange,
                  'Precisión',
                  p == null
                      ? '--'
                      : '${servicio.numero(p.accuracy)} m',
                ),

                const Divider(height: 1),

                dato(
                  Icons.access_time,
                  Colors.purple,
                  'Fecha y hora',
                  p == null
                      ? '--'
                      : servicio.formatearFecha(p.timestamp),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // Botón para iniciar la lectura GPS.
          ElevatedButton.icon(
            onPressed: _ocupado
                ? null
                : obtenerUbicacion,
            icon: const Icon(Icons.my_location),
            label: const Text('Obtener ubicación'),
          ),

          const SizedBox(height: 12),

          // Permite guardar cuando existe una ubicación.
          OutlinedButton.icon(
            onPressed: _ocupado || p == null
                ? null
                : guardarUbicacion,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Guardar medición GPS'),
          ),

          if (_ocupado)
            const LinearProgressIndicator(),

          const SizedBox(height: 20),

          // Informa el estado de la captura GPS.
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.info_outline,
                color: Colors.blue,
              ),
              title: const Text('Estado del GPS'),
              subtitle: Text(_estado),
            ),
          ),
        ],
      ),
    );
  }
}
