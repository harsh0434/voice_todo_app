# Voice-Driven Todo App

A Flutter-based voice-driven todo list application that allows users to manage their tasks entirely through voice commands. The app supports offline voice capture, real-time synchronization across devices, and provides audible confirmations for user actions.

## Features

### Voice Command Support
- Natural language processing for task management
- Support for multiple command patterns:
  - "Add task [task name]"
  - "Complete task [task name]"
  - "Delete task [task name]"
  - "Remind me to [task] at [time]"
  - "Show completed tasks"
  - "What's due today/tomorrow"

### Offline Support
- Voice command queueing when offline
- Local storage using SQLite
- Automatic sync when connectivity is restored
- Conflict resolution using timestamps

### Real-time Sync
- Firebase Realtime Database integration
- Multi-device synchronization
- Automatic conflict resolution
- Status indicators for sync state

### User Experience
- Chat-like conversation history
- Visual status indicators
- Audible feedback for actions
- Clarification prompts for ambiguous commands
- Material Design 3 UI

## Technical Architecture

### State Management
- Riverpod for state management
- Providers for dependency injection
- Async state handling

### Data Layer
- SQLite for local storage
- Firebase Realtime Database for cloud sync
- Conflict resolution using timestamps
- Offline-first architecture

### Voice Processing
- Web: Native SpeechRecognition API
- Mobile: speech_to_text package
- Text-to-speech feedback
- Natural language command parsing

### UI Components
- Conversation bubbles for command history
- Status indicators for sync/connectivity
- Voice input widget
- Task list with completion status

## Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/harsh0434/voice_todo_app.git
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Create a new Firebase project
   - Add your Android/iOS app to the project
   - Download and add the configuration files:
     - Android: `google-services.json`
     - iOS: `GoogleService-Info.plist`

4. Run the app:
   ```bash
   flutter run
   ```

## Dependencies

- **State Management**
  - flutter_riverpod
  - riverpod_annotation

- **Voice Processing**
  - speech_to_text
  - flutter_tts

- **Storage & Sync**
  - sqflite
  - firebase_core
  - firebase_database

- **Utilities**
  - connectivity_plus
  - path_provider
  - uuid

## Project Structure

```
lib/
├── models/           # Data models
├── providers/        # State management
├── screens/          # UI screens
├── services/         # Business logic
│   ├── voice/       # Voice processing
│   ├── storage/     # Local storage
│   └── sync/        # Cloud sync
└── widgets/         # Reusable UI components
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
