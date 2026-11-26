
import 'package:flutter/material.dart';
import 'package:sensortrack/splash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kjyyckhxmmgaafsnkflb.supabase.co',
    publishableKey: 'sb_publishable_kZ4jaSEktxzQBkkislJyQA_OxMcpSvu',
  );

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
