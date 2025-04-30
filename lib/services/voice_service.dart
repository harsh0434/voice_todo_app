import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

enum TtsState { playing, stopped }

class VoiceService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  TtsState _ttsState = TtsState.stopped;
  bool _isInitialized = false;

  Future<bool> initialize() async {
    _isInitialized = await _speechToText.initialize();
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    return _isInitialized;
  }

  Future<bool> startListening({
    required Function(String text) onResult,
    required Function() onListeningComplete,
  }) async {
    if (!_isListening) {
      final listenResult = await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
            onListeningComplete();
            _isListening = false;
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'en_US',
        onSoundLevelChange: (level) {},
        cancelOnError: true,
      );
      _isListening = listenResult ?? false;
    }
    return _isListening;
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
    _isListening = false;
  }

  Future<void> speak(String text) async {
    if (_ttsState == TtsState.playing) {
      await _flutterTts.stop();
    }
    await _flutterTts.speak(text);
    _ttsState = TtsState.playing;
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
    _ttsState = TtsState.stopped;
  }

  bool get isListening => _isListening;
  TtsState get ttsState => _ttsState;
  bool get isInitialized => _isInitialized;
}

final voiceServiceProvider = FutureProvider<VoiceService>((ref) async {
  final service = VoiceService();
  final initialized = await service.initialize();
  if (!initialized) throw Exception('Speech to text initialization failed');
  return service;
});
