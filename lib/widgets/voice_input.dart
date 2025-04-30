import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../services/voice_service.dart';
import '../services/web_voice_service.dart';
import '../providers/todo_provider.dart';

class VoiceInput extends ConsumerStatefulWidget {
  const VoiceInput({super.key});

  @override
  ConsumerState<VoiceInput> createState() => _VoiceInputState();
}

class _VoiceInputState extends ConsumerState<VoiceInput> {
  bool _isListening = false;
  String _statusText = 'Tap the microphone to start';

  Future<void> _startListening(VoiceService voiceService) async {
    final todoNotifier = ref.read(todoNotifierProvider.notifier);
    try {
      setState(() {
        _isListening = true;
        _statusText = 'Listening...';
      });
      final isListening = await voiceService.startListening(
        onResult: (text) async {
          setState(() {
            _statusText = 'Processing: $text';
          });
          await todoNotifier.processVoiceCommand(text);
          setState(() {
            _statusText = 'Tap the microphone to start';
            _isListening = false;
          });
        },
        onListeningComplete: () {
          setState(() {
            _isListening = false;
            _statusText = 'Tap the microphone to start';
          });
        },
      );
      if (!isListening) {
        setState(() {
          _isListening = false;
          _statusText = 'Failed to start listening. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _isListening = false;
        _statusText = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _stopListening(VoiceService voiceService) async {
    await voiceService.stopListening();
    setState(() {
      _isListening = false;
      _statusText = 'Tap the microphone to start';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Web voice input logic
      final webVoiceService = WebVoiceService();
      return _WebVoiceInput(webVoiceService: webVoiceService, ref: ref);
    }
    final voiceServiceAsync = ref.watch(voiceServiceProvider);
    return voiceServiceAsync.when(
      data:
          (voiceService) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _statusText,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                onPressed:
                    _isListening
                        ? () => _stopListening(voiceService)
                        : () => _startListening(voiceService),
                child: Icon(_isListening ? Icons.mic_off : Icons.mic),
              ),
              const SizedBox(height: 8),
              const Text(
                'Voice Commands:\n'
                '• "Add task [task name]"\n'
                '• "Complete task [task name]"\n'
                '• "Delete task [task name]"',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Voice service error: $e')),
    );
  }
}

class _WebVoiceInput extends StatefulWidget {
  final WebVoiceService webVoiceService;
  final WidgetRef ref;
  const _WebVoiceInput({required this.webVoiceService, required this.ref});

  @override
  State<_WebVoiceInput> createState() => _WebVoiceInputState();
}

class _WebVoiceInputState extends State<_WebVoiceInput> {
  bool _isListening = false;
  String _statusText = 'Tap the microphone to start';
  StreamSubscription<String>? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      _statusText = 'Listening...';
    });
    _sub = widget.webVoiceService.onResult.listen(
      (text) async {
        setState(() {
          _statusText = 'Recognized: $text';
          _isListening = false;
        });
        // Process the recognized text as a command
        final todoNotifier = widget.ref.read(todoNotifierProvider.notifier);
        await todoNotifier.processVoiceCommand(text);
      },
      onError: (e) {
        setState(() {
          _statusText = 'Error: $e';
          _isListening = false;
        });
      },
    );
    widget.webVoiceService.startListening();
  }

  void _stopListening() {
    widget.webVoiceService.stopListening();
    setState(() {
      _isListening = false;
      _statusText = 'Tap the microphone to start';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _statusText,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          onPressed: _isListening ? _stopListening : _startListening,
          child: Icon(_isListening ? Icons.mic_off : Icons.mic),
        ),
        const SizedBox(height: 8),
        const Text(
          'Voice Commands (web):\n'
          '• "Add task [task name]"\n'
          '• "Complete task [task name]"\n'
          '• "Delete task [task name]"',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
