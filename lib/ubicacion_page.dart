
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'mediciones_service.dart';

class UbicacionPage extends StatefulWidget {
  const UbicacionPage({super.key});

  @override
  State<UbicacionPage> createState() =>
      _UbicacionPageState();
}

class _UbicacionPageState extends State<UbicacionPage> {
  final servicio = MedicionesService();

  Position? _posicion;

  bool _ocupado = false;

  String _estado = 'Presiona Obtener ubicación';

  // Obtener la ubicación física del dispositivo.
  Future<void> obtenerUbicacion() async {
    if (_ocupado) return;

    setState(() {
      _ocupado = true;
      _posicion = null;
      _estado = 'Obteniendo ubicación...';
    });

    try {
      // Comprobar que la ubicación está activada.
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError(
          'Activa la ubicación del dispositivo.',
        );
      }

      // Comprobar los permisos.
      var permiso = await Geolocator.checkPermission();

      // Solicitar permiso al usuario.
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

      // Capturar la posición del celular.
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

  // Guardar coordenadas en Supabase.
  Future<void> guardarUbicacion() async {
    final posicion = _posicion;

    if (posicion == null || _ocupado) return;

    setState(() {
      _ocupado = true;
    });

    try {
      // Solicitar autorización antes de almacenar.
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

  // Mostrar un dato de ubicación.
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

          ElevatedButton.icon(
            onPressed: _ocupado
                ? null
                : obtenerUbicacion,
            icon: const Icon(Icons.my_location),
            label: const Text('Obtener ubicación'),
          ),

          const SizedBox(height: 12),

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
