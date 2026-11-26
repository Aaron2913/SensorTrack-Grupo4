
import 'package:flutter/material.dart';

class RegistroPage extends StatefulWidget {
  final String tipoInicial;

  const RegistroPage({
    super.key,
    this.tipoInicial = 'accelerometer',
  });

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();

  final _x = TextEditingController();
  final _y = TextEditingController();
  final _z = TextEditingController();

  final _latitud = TextEditingController();
  final _longitud = TextEditingController();
  final _precision = TextEditingController();

  // Registros temporales para probar el frontend.
  final List<Map<String, dynamic>> _registros = [];

  late String _tipo;

  @override
  void initState() {
    super.initState();
    _tipo = widget.tipoInicial;
  }

  @override
  void dispose() {
    _x.dispose();
    _y.dispose();
    _z.dispose();
    _latitud.dispose();
    _longitud.dispose();
    _precision.dispose();
    super.dispose();
  }

  String? _validarNumero(
    String? texto, {
    double? minimo,
    double? maximo,
  }) {
    if (texto == null || texto.trim().isEmpty) {
      return 'Campo obligatorio';
    }

    final numero = double.tryParse(
      texto.trim().replaceAll(',', '.'),
    );

    if (numero == null || !numero.isFinite) {
      return 'Número inválido';
    }

    if (minimo != null && numero < minimo) {
      return 'Mínimo: $minimo';
    }

    if (maximo != null && numero > maximo) {
      return 'Máximo: $maximo';
    }

    return null;
  }

  Widget campoNumero(
    String titulo,
    TextEditingController controller, {
    double? minimo,
    double? maximo,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        decoration: InputDecoration(
          labelText: titulo,
          prefixIcon: const Icon(Icons.numbers),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (valor) => _validarNumero(
          valor,
          minimo: minimo,
          maximo: maximo,
        ),
      ),
    );
  }

  double leerNumero(TextEditingController controller) {
    return double.parse(
      controller.text.trim().replaceAll(',', '.'),
    );
  }

  void guardarMedicion() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final esGps = _tipo == 'gps';

    // Estructura preparada para la tabla sensor_readings.
    final medicion = <String, dynamic>{
      'sensor_type': _tipo,
      'x': esGps ? null : leerNumero(_x),
      'y': esGps ? null : leerNumero(_y),
      'z': esGps ? null : leerNumero(_z),
      'latitude': esGps ? leerNumero(_latitud) : null,
      'longitude': esGps ? leerNumero(_longitud) : null,
      'accuracy': esGps ? leerNumero(_precision) : null,
      'recorded_at': DateTime.now().toIso8601String(),
    };

    // DEMOSTRACIÓN: todavía no se envía a Supabase.
    setState(() {
      _registros.insert(0, medicion);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Medición añadida a la demostración. '
          'Aún no se guardó en Supabase.',
        ),
      ),
    );
  }

  String nombreSensor(String tipo) {
    if (tipo == 'accelerometer') {
      return 'Acelerómetro';
    }

    if (tipo == 'gyroscope') {
      return 'Giroscopio';
    }

    return 'GPS';
  }

  String resumen(Map<String, dynamic> medicion) {
    if (medicion['sensor_type'] == 'gps') {
      return 'Lat: ${medicion['latitude']}  '
          'Lon: ${medicion['longitude']}\n'
          'Precisión: ${medicion['accuracy']} m';
    }

    return 'X: ${medicion['x']}  '
        'Y: ${medicion['y']}  '
        'Z: ${medicion['z']}';
  }

  void consultarRegistros() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Consulta de registros'),
          content: SizedBox(
            width: double.maxFinite,
            child: _registros.isEmpty
                ? const Text(
                    'Todavía no hay mediciones de prueba.',
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _registros.length,
                    itemBuilder: (context, index) {
                      final medicion = _registros[index];

                      return ListTile(
                        leading: const Icon(
                          Icons.sensors,
                          color: Colors.blue,
                        ),
                        title: Text(
                          nombreSensor(
                            medicion['sensor_type'],
                          ),
                        ),
                        subtitle: Text(
                          '${resumen(medicion)}\n'
                          '${medicion['recorded_at']}',
                        ),
                      );
                    },
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
    final esGps = _tipo == 'gps';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registro de mediciones',
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
                    Icons.cloud_upload_outlined,
                    color: Colors.white,
                    size: 55,
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
                    'Interfaz preparada para Supabase',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Card(
              child: ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: Colors.orange,
                ),
                title: Text('Modo demostración'),
                subtitle: Text(
                  'Ingresa datos de prueba. Se conservarán '
                  'solo mientras esta pantalla esté abierta.',
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nueva medición',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        initialValue: _tipo,
                        decoration: InputDecoration(
                          labelText: 'Tipo de sensor',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'accelerometer',
                            child: Text('Acelerómetro'),
                          ),
                          DropdownMenuItem(
                            value: 'gyroscope',
                            child: Text('Giroscopio'),
                          ),
                          DropdownMenuItem(
                            value: 'gps',
                            child: Text('GPS'),
                          ),
                        ],
                        onChanged: (valor) {
                          if (valor != null) {
                            setState(() {
                              _tipo = valor;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      if (!esGps) ...[
                        campoNumero('Eje X', _x),
                        campoNumero('Eje Y', _y),
                        campoNumero('Eje Z', _z),
                      ],

                      if (esGps) ...[
                        campoNumero(
                          'Latitud',
                          _latitud,
                          minimo: -90,
                          maximo: 90,
                        ),
                        campoNumero(
                          'Longitud',
                          _longitud,
                          minimo: -180,
                          maximo: 180,
                        ),
                        campoNumero(
                          'Precisión en metros',
                          _precision,
                          minimo: 0,
                        ),
                      ],

                      const SizedBox(height: 10),

                      const Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'La fecha y hora se asignarán '
                              'automáticamente.',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: guardarMedicion,
                          icon: const Icon(Icons.save),
                          label: const Text(
                            'Guardar medición (prueba)',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: consultarRegistros,
                icon: const Icon(Icons.search),
                label: const Text(
                  'Consultar registros (prueba)',
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Mediciones de esta sesión',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                CircleAvatar(
                  child: Text('${_registros.length}'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (_registros.isEmpty)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Sin mediciones de prueba'),
                  subtitle: Text(
                    'Los registros aparecerán aquí.',
                  ),
                ),
              ),

            for (final medicion in _registros)
              Card(
                color: Colors.white,
                child: ListTile(
                  leading: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  title: Text(
                    nombreSensor(medicion['sensor_type']),
                  ),
                  subtitle: Text(
                    '${resumen(medicion)}\n'
                    '${medicion['recorded_at']}',
                  ),
                  isThreeLine: true,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
