import 'package:supabase_flutter/supabase_flutter.dart';

class MedicionesService {
  SupabaseClient get supabase => Supabase.instance.client;
  static Future<void>? _conexionPendiente;

  Future<void> conectar() async {
    if (supabase.auth.currentSession != null) return;
    final pendiente = _conexionPendiente;
    if (pendiente != null) {
      await pendiente;
      return;
    }
    final nueva = _iniciarSesion();
    _conexionPendiente = nueva;
    try {
      await nueva;
    } finally {
      _conexionPendiente = null;
    }
  }

  Future<void> _iniciarSesion() async {
    await supabase.auth.signInAnonymously();
  }

  Future<void> comprobarConexion() async {
    await conectar();
    await supabase.from('sensor_readings').select('id').limit(1);
  }

  Future<void> guardarMedicion(Map<String, dynamic> medicion) async {
    await conectar();
    await supabase.from('sensor_readings').insert(medicion);
  }

  Future<List<Map<String, dynamic>>> getMediciones() async {
    await conectar();
    const cantidad = 100;
    final mediciones = <Map<String, dynamic>>[];
    int inicio = 0;
    while (true) {
      final datos = await supabase
          .from('sensor_readings')
          .select()
          .order('recorded_at', ascending: false)
          .order('id', ascending: false)
          .range(inicio, inicio + cantidad - 1);
      mediciones.addAll(datos);
      if (datos.length < cantidad) break;
      inicio += cantidad;
    }
    return mediciones;
  }

  String nombreSensor(dynamic tipo) {
    switch (tipo) {
      case 'accelerometer':
        return 'Acelerómetro';
      case 'gyroscope':
        return 'Giroscopio';
      case 'gps':
        return 'GPS';
      default:
        return tipo?.toString() ?? 'Sensor desconocido';
    }
  }

  String numero(dynamic valor, {int decimales = 2}) {
    return valor is num && valor.isFinite
        ? valor.toStringAsFixed(decimales)
        : '--';
  }

  String formatearFecha(dynamic valor) {
    final fecha = DateTime.tryParse(valor?.toString() ?? '')?.toLocal();
    if (fecha == null) return 'Fecha no disponible';
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year} '
        '${dos(fecha.hour)}:${dos(fecha.minute)}:${dos(fecha.second)}';
  }

  String resumen(Map<String, dynamic> medicion) {
    if (medicion['sensor_type'] == 'gps') {
      return 'Latitud: ${numero(medicion['latitude'], decimales: 6)}\n'
          'Longitud: ${numero(medicion['longitude'], decimales: 6)}\n'
          'Precisión: ${numero(medicion['accuracy'])} m';
    }
    final unidad = medicion['sensor_type'] == 'accelerometer'
        ? 'm/s²'
        : medicion['sensor_type'] == 'gyroscope' ? 'rad/s' : '';
    return 'X: ${numero(medicion['x'])} $unidad\n'
        'Y: ${numero(medicion['y'])} $unidad\n'
        'Z: ${numero(medicion['z'])} $unidad';
  }
}

// Funciones compatibles con la primera versión de historial y estadísticas.
Future<List<Map<String, dynamic>>> getMediciones() =>
    MedicionesService().getMediciones();
String nombreSensor(dynamic tipo) => MedicionesService().nombreSensor(tipo);
String numero(dynamic valor, [int decimales = 2]) =>
    MedicionesService().numero(valor, decimales: decimales);
String fechaMedicion(dynamic valor) => MedicionesService().formatearFecha(valor);
