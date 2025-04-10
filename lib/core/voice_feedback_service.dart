import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Serviço de acessibilidade para feedback de voz
class VoiceFeedbackService {
  static final VoiceFeedbackService _instance = VoiceFeedbackService._internal();
  factory VoiceFeedbackService() => _instance;
  FlutterTts flutterTts = FlutterTts();

  VoiceFeedbackService._internal(){
    _initTts();
  }

  void _initTts() async{
    await flutterTts.setLanguage("pt-BR");
    await flutterTts.setPitch(1); // tom de voz
  }

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> stop() async {
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
      await VoiceFeedbackService().speak(text);
    }
  }

  Future<void> stop() async {
    if (_speechEnabled) {
      await VoiceFeedbackService().stop();
    }
  }
}