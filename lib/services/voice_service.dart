import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;

  bool get isListening => _isListening;

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> startListening(Function(String) onResult) async {
    // Temporarily disabled
    _isListening = false;
  }

  Future<void> stopListening() async {
    // Temporarily disabled
    _isListening = false;
  }
} 