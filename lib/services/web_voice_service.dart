import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'dart:js' as js;
import 'package:js/js.dart';

class WebVoiceService {
  html.SpeechRecognition? _recognition;
  final StreamController<String> _controller = StreamController.broadcast();

  WebVoiceService() {
    if (kIsWeb && _hasSpeechRecognitionSupport()) {
      _recognition = html.SpeechRecognition();
      _recognition!.lang = 'en-US';
      _recognition!.continuous = false;
      _recognition!.interimResults = false;
      _recognition!.onResult.listen((event) {
        final jsEvent = js.JsObject.fromBrowserObject(event);
        final results = jsEvent['results'];
        String transcript = '';
        if (results != null && results[0] != null && results[0][0] != null) {
          transcript = results[0][0]['transcript'] ?? '';
        }
        _controller.add(transcript);
      });
      _recognition!.onError.listen((event) {
        _controller.addError(event.error ?? 'Unknown error');
      });
    }
  }

  bool _hasSpeechRecognitionSupport() {
    return js.context.hasProperty('SpeechRecognition') ||
        js.context.hasProperty('webkitSpeechRecognition');
  }

  Stream<String> get onResult => _controller.stream;

  void startListening() {
    _recognition?.start();
  }

  void stopListening() {
    _recognition?.stop();
  }
}
