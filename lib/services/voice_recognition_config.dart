class VoiceRecognitionConfig {
  static const String defaultLanguage = 'en-US';
  static const double defaultSpeechRate = 0.5;
  static const double defaultVolume = 1.0;
  static const double defaultPitch = 1.0;

  // Command patterns
  static const Map<String, List<String>> commandPatterns = {
    'add': ['add', 'create', 'new', 'remind'],
    'complete': ['complete', 'finish', 'done', 'mark', 'check'],
    'delete': ['delete', 'remove', 'clear'],
  };

  // Natural language patterns
  static const Map<String, String> naturalLanguagePatterns = {
    'reminder': r'remind me to (.+?)(?: at (.+))?$',
    'show_completed': r'show( me)?( all)? completed tasks',
    'whats_due': r"what'?s due (today|tomorrow)",
  };
}
