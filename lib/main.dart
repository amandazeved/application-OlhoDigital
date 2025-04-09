import 'package:flutter/material.dart';
import 'package:flutter_application_1/settings_page.dart';
import 'home_page.dart';
import 'camera_page.dart';
import "accessibility_service.dart";
import 'package:provider/provider.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

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
      },
      navigatorObservers: [routeObserver],
    );
  }
}

