import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/settings_page.dart';
import 'pages/home_page.dart';
import 'pages/camera_page.dart';
import "core/voice_feedback_service.dart";
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SpeechProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Camera app',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/camera': (context) => CameraPage(),
        '/settings': (context) => SettingsPage(),
      }
    );
  }
}

