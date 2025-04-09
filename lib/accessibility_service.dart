import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Serviço de acessibilidade para feedback de voz
class AccessibilityService {
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  FlutterTts flutterTts = FlutterTts();

  AccessibilityService._internal();

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("pt-BR");
    await flutterTts.setPitch(1); // tom de voz
    await flutterTts.speak(text);
  }

  Future<void> stopSpeak() async {
    await flutterTts.stop();
  }

}

/// Provider para controlar o estado do feedback de voz
class SpeechProvider extends ChangeNotifier {
  bool _speechEnabled = true;

  bool get speechEnabled => _speechEnabled;

  void set(bool value) {
    _speechEnabled = value;
    notifyListeners();
  }

  Future<void> speak(String text) async {
    if (_speechEnabled) {
      await AccessibilityService().speak(text);
    }
  }

  Future<void> stop() async {
    await AccessibilityService().stopSpeak();
  }
}