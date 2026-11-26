
import 'package:flutter/material.dart';
import 'package:sensortrack/splash.dart';

void main() {
  runApp(const SensorTrackApp());
}

class SensorTrackApp extends StatelessWidget {
  const SensorTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SensorTrack',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF4F7FC),
        useMaterial3: true,
      ),
      home: const Splash(),
    );
  }
}
