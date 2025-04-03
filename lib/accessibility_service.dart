import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class AccessibilityService {
  FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("pt-BR");
    await flutterTts.setPitch(1); // tom de voz
    await flutterTts.speak(text);
  }

  Future<void> stopSpeak() async {
    await flutterTts.stop();
  }

  Future<String> startListening() async {
    bool available = await _speech.initialize(onStatus: (status) {
        print("Status do reconhecimento: $status");
      },
      onError: (error) {
        print("Erro no reconhecimento: $error");
      },
    );

    if (available) {
      final completer = Completer<String>();

      _speech.listen(
        onResult: (result) {
          if (result.finalResult && result.recognizedWords.isNotEmpty){
            print("Reconhecido: ${result.recognizedWords}");
            completer.complete(result.recognizedWords);
          }
        },
        listenFor: Duration(seconds: 10), // ✅ Mantém o microfone aberto por 5s
        pauseFor: Duration(seconds: 2), // ✅ Espera 2s antes de encerrar
      );
      return completer.future;
    } else {
      print("Não foi possível inicializar o reconhecimento de fala.");
      return 'nao foi possivel';
    }
  }

  void stopListening() {
    _speech.stop();
  }

  Future<void> requestPermissions() async {
    await Permission.microphone.request();
  }
}
