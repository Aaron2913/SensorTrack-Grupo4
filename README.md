
# SensorTrack

## Descripción del proyecto

SensorTrack es una aplicación móvil desarrollada con Flutter
que permite monitorear los sensores físicos de un dispositivo
Android, capturar mediciones y almacenarlas en Supabase.

La aplicación permite consultar el historial de registros
y visualizar estadísticas de las mediciones realizadas.

## Tecnologías utilizadas

- Flutter y Dart: desarrollo de la aplicación móvil.
- Supabase: almacenamiento de mediciones en la nube.
- sensors_plus: lectura del acelerómetro y giroscopio.
- geolocator: obtención de coordenadas GPS.
- fl_chart: visualización de gráficos estadísticos.

## Módulos de la aplicación

### Módulo 1. Inicio y navegación
Presenta una pantalla de bienvenida y un menú principal.
Permite comprobar la conexión con Supabase y el estado
de los sensores disponibles.

### Módulo 2. Lectura de sensores
Obtiene mediciones del acelerómetro y giroscopio
en los ejes X, Y y Z, además de información GPS
como latitud, longitud y precisión.

### Módulo 3. Registro de mediciones
Permite almacenar en Supabase las mediciones capturadas
desde los sensores físicos del dispositivo.

### Módulo 4. Historial
Consulta los registros guardados en Supabase.
Permite revisar los valores, identificadores y fechas
de las mediciones almacenadas.

### Módulo 5. Estadísticas
Muestra la cantidad total de mediciones,
los registros por tipo de sensor, los valores
máximos y mínimos del acelerómetro y gráficos
de evolución de las mediciones.

## Estructura del proyecto

```text
lib/
├── main.dart
├── splash.dart
├── home_page.dart
├── sensores_page.dart
├── ubicacion_page.dart
├── registro_page.dart
├── mediciones_service.dart
├── historial_page.dart
└── estadisticas_page.dart
```

## Base de datos

Se utiliza Supabase con una tabla denominada
`sensor_readings`, que almacena:

- Identificador de la medición.
- Tipo de sensor.
- Valores X, Y y Z.
- Latitud y longitud.
- Precisión GPS.
- Fecha y hora del registro.

## Instalación y ejecución

1. Clonar el repositorio:

   git clone https://github.com/Aaron2913/SensorTrack-Grupo4.git

2. Ingresar a la carpeta del proyecto:

   cd SensorTrack-Grupo4

3. Instalar las dependencias:

   flutter pub get

4. Conectar un dispositivo Android con depuración USB.

5. Ejecutar la aplicación:

   flutter run

Se requiere configurar un proyecto Supabase
con la tabla `sensor_readings` y las políticas
de acceso correspondientes.

## Pruebas realizadas

La aplicación fue probada en un dispositivo Android
físico, verificando:

- Lecturas del acelerómetro.
- Lecturas del giroscopio.
- Obtención de ubicación GPS.
- Almacenamiento de mediciones en Supabase.
- Consulta del historial.
- Visualización de estadísticas.

## Repositorio

https://github.com/Aaron2913/SensorTrack-Grupo4
