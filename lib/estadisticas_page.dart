
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'mediciones_service.dart';

class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({super.key});

  @override
  State<EstadisticasPage> createState() =>
      _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  final servicio = MedicionesService();

  late Future<List<Map<String, dynamic>>> mediciones;

  String sensorGrafico = 'accelerometer';

  @override
  void initState() {
    super.initState();
    mediciones = servicio.getMediciones();
  }

  void actualizar() {
    setState(() {
      mediciones = servicio.getMediciones();
    });
  }

  // Obtener el valor mínimo de un eje.
  double? minimo(
    List<Map<String, dynamic>> datos,
    String eje,
  ) {
    final valores = datos
        .map((m) => m[eje])
        .whereType<num>()
        .where((v) => v.isFinite)
        .toList();

    if (valores.isEmpty) return null;

    valores.sort();
    return valores.first.toDouble();
  }

  // Obtener el valor máximo de un eje.
  double? maximo(
    List<Map<String, dynamic>> datos,
    String eje,
  ) {
    final valores = datos
        .map((m) => m[eje])
        .whereType<num>()
        .where((v) => v.isFinite)
        .toList();

    if (valores.isEmpty) return null;

    valores.sort();
    return valores.last.toDouble();
  }

  // Tarjeta con cantidad de registros.
  Widget tarjetaCantidad(
    String titulo,
    int cantidad,
    IconData icono,
    Color color,
  ) {
    return Card(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icono, color: color, size: 35),
        title: Text(titulo),
        trailing: Text(
          '$cantidad',
          style: TextStyle(
            color: color,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Mostrar máximos y mínimos.
  Widget tarjetaExtremos(
    List<Map<String, dynamic>> acelerometro,
  ) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Máximos y mínimos del acelerómetro',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Unidad: m/s²'),
            const SizedBox(height: 15),
            Table(
              border: TableBorder.all(
                color: Colors.black12,
              ),
              children: [
                const TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Eje'),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Mínimo'),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Máximo'),
                    ),
                  ],
                ),
                for (final eje in ['x', 'y', 'z'])
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(eje.toUpperCase()),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          servicio.numero(
                            minimo(acelerometro, eje),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          servicio.numero(
                            maximo(acelerometro, eje),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Generar una línea del gráfico.
  LineChartBarData linea(
    List<Map<String, dynamic>> datos,
    String eje,
    Color color,
  ) {
    final puntos = <FlSpot>[];

    for (int i = 0; i < datos.length; i++) {
      final valor = datos[i][eje];

      if (valor is num && valor.isFinite) {
        puntos.add(
          FlSpot(i.toDouble(), valor.toDouble()),
        );
      }
    }

    return LineChartBarData(
      spots: puntos,
      color: color,
      barWidth: 2.5,
      isCurved: false,
      dotData: const FlDotData(show: true),
    );
  }

  // Gráfico de evolución de los sensores.
  Widget grafico(
    List<Map<String, dynamic>> acelerometro,
    List<Map<String, dynamic>> giroscopio,
  ) {
    final seleccionados =
        sensorGrafico == 'accelerometer'
            ? acelerometro
            : giroscopio;

    // Seleccionar las últimas 30 capturas
    // y ordenarlas desde la más antigua.
    final datos = seleccionados
        .where(
          (m) => ['x', 'y', 'z'].every(
            (eje) => m[eje] is num &&
                (m[eje] as num).isFinite,
          ),
        )
        .take(30)
        .toList()
        .reversed
        .toList();

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Evolución de las mediciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            DropdownButton<String>(
              value: sensorGrafico,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: 'accelerometer',
                  child: Text('Acelerómetro'),
                ),
                DropdownMenuItem(
                  value: 'gyroscope',
                  child: Text('Giroscopio'),
                ),
              ],
              onChanged: (valor) {
                if (valor != null) {
                  setState(() {
                    sensorGrafico = valor;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Eje X',
                  style: TextStyle(color: Colors.blue),
                ),
                SizedBox(width: 20),
                Text(
                  'Eje Y',
                  style: TextStyle(color: Colors.green),
                ),
                SizedBox(width: 20),
                Text(
                  'Eje Z',
                  style: TextStyle(color: Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (datos.isEmpty)
              const Center(
                child: Text('No hay datos para graficar'),
              )
            else
              SizedBox(
                height: 230,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: datos.length > 1
                        ? (datos.length - 1).toDouble()
                        : 1.0,
                    lineBarsData: [
                      linea(datos, 'x', Colors.blue),
                      linea(datos, 'y', Colors.green),
                      linea(datos, 'z', Colors.orange),
                    ],
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(show: true),
                    titlesData: const FlTitlesData(
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 15),
            Text(
              sensorGrafico == 'accelerometer'
                  ? 'Unidad: m/s²'
                  : 'Unidad: rad/s',
            ),
            const Text('Eje horizontal: orden de captura'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Error al consultar Supabase'),
                  ElevatedButton(
                    onPressed: actualizar,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final datos = snapshot.data ?? [];

          final acelerometro = datos.where(
            (m) => m['sensor_type'] == 'accelerometer',
          ).toList();

          final giroscopio = datos.where(
            (m) => m['sensor_type'] == 'gyroscope',
          ).toList();

          final gps = datos.where(
            (m) => m['sensor_type'] == 'gps',
          ).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1769AA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.bar_chart,
                        size: 50,
                        color: Colors.white,
                      ),
                      const Text(
                        'Total de registros',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '${datos.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Mediciones por sensor',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                tarjetaCantidad(
                  'Acelerómetro',
                  acelerometro.length,
                  Icons.speed,
                  Colors.blue,
                ),

                tarjetaCantidad(
                  'Giroscopio',
                  giroscopio.length,
                  Icons.screen_rotation,
                  Colors.purple,
                ),

                tarjetaCantidad(
                  'GPS',
                  gps.length,
                  Icons.location_on,
                  Colors.green,
                ),

                const SizedBox(height: 15),

                tarjetaExtremos(acelerometro),

                const SizedBox(height: 15),

                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Última ubicación registrada',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (gps.isEmpty)
                          const Text(
                            'No hay ubicaciones registradas',
                          )
                        else ...[
                          Text(
                            servicio.resumen(gps.first),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            servicio.formatearFecha(
                              gps.first['recorded_at'],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                grafico(acelerometro, giroscopio),
              ],
            ),
          );
        },
      ),
    );
  }
}
