# Voice-Driven Todo App

A Flutter-based voice-driven todo list application that allows users to manage their tasks entirely through voice commands. The app supports offline voice capture, real-time synchronization across devices, and provides audible confirmations for user actions.

## Features

- **Voice Command Support**: Add, complete, and delete tasks using natural language voice commands
- **Offline Support**: Queue voice commands locally when offline and sync when connectivity is restored
- **Real-time Sync**: Tasks are synchronized across devices in real-time using Firebase
- **Audible Feedback**: Get voice confirmations for your actions and prompts for ambiguous commands
- **Clean UI**: Modern and intuitive user interface with Material Design 3

## Voice Commands

The app supports the following voice commands:

- "Add task [task name]" - Create a new task
- "Complete task [task name]" - Mark a task as complete
- "Delete task [task name]" - Remove a task

## Technical Details

- Built with Flutter and Dart
- Uses Riverpod for state management
- Implements Hive for local storage
- Integrates Firebase for cloud synchronization
- Features speech-to-text and text-to-speech capabilities

## Setup

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:
   - Create a new Firebase project
   - Add your Android/iOS app to the project
   - Download and add the configuration files
4. Run the app:
   ```bash
   flutter run
   ```

## Dependencies

- flutter_riverpod: State management
- speech_to_text: Voice recognition
- flutter_tts: Text-to-speech
- hive: Local storage
- firebase_core & cloud_firestore: Cloud synchronization
- connectivity_plus: Network status monitoring
- uuid: Unique device identification

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
