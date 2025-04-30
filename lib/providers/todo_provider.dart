import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../services/sync_service.dart';
import '../services/voice_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import '../models/voice_command.dart';
import '../services/sqlite_service.dart';
import '../services/firebase_realtime_service.dart';

part 'todo_provider.g.dart';

final clarificationPromptProvider = StateProvider<String?>((ref) => null);

@riverpod
class TodoNotifier extends _$TodoNotifier {
  TodoNotifier() {
    // Listen for connectivity changes and process queued commands when online
    Connectivity().onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        await _processQueuedCommands();
      }
    });
  }

  @override
  FutureOr<List<Todo>> build() async {
    final taskMaps = await SQLiteService.getTasks();
    return taskMaps.map((m) => Todo.fromMap(m)).toList();
  }

  Future<void> addTodo(String title, {String description = ''}) async {
    final now = DateTime.now();
    final todo = Todo(title: title, description: description, updatedAt: now);
    await SQLiteService.insertTask(todo.toMap());
    await FirebaseRealtimeService().pushTaskToFirebase(todo);
    final taskMaps = await SQLiteService.getTasks();
    state = AsyncValue.data(taskMaps.map((m) => Todo.fromMap(m)).toList());
  }

  Future<void> updateTodo(Todo todo) async {
    final updatedTodo = todo.copyWith(updatedAt: DateTime.now());
    await SQLiteService.updateTask(updatedTodo.toMap());
    await FirebaseRealtimeService().pushTaskToFirebase(updatedTodo);
    final taskMaps = await SQLiteService.getTasks();
    state = AsyncValue.data(taskMaps.map((m) => Todo.fromMap(m)).toList());
  }

  Future<void> deleteTodo(String id) async {
    await SQLiteService.deleteTask(id);
    await FirebaseRealtimeService().removeTaskFromFirebase(id);
    final taskMaps = await SQLiteService.getTasks();
    state = AsyncValue.data(taskMaps.map((m) => Todo.fromMap(m)).toList());
  }

  Future<void> toggleTodo(String id) async {
    final taskMaps = await SQLiteService.getTasks();
    final todos = taskMaps.map((m) => Todo.fromMap(m)).toList();
    final todo = todos.firstWhere((t) => t.id == id);
    if (todo != null) {
      final updatedTodo = todo.copyWith(
        isCompleted: !todo.isCompleted,
        completedAt: !todo.isCompleted ? DateTime.now() : null,
      );
      await updateTodo(updatedTodo);
    }
  }

  Future<void> processVoiceCommand(String command) async {
    final voiceService = await ref.read(voiceServiceProvider.future);
    final connectivity = await Connectivity().checkConnectivity();
    final isOnline = connectivity != ConnectivityResult.none;
    final clarificationPrompt = ref.read(clarificationPromptProvider.notifier);

    // Find a pending queued command matching this command in SQLite
    List<Map<String, dynamic>> queuedMaps =
        await SQLiteService.getQueuedCommands();
    VoiceCommand? currentCmd;
    try {
      currentCmd = queuedMaps
          .map((m) => VoiceCommand.fromMap(m))
          .lastWhere(
            (c) =>
                c.command == command && c.status == VoiceCommandStatus.pending,
          );
    } catch (_) {
      currentCmd = null;
    }

    if (!isOnline) {
      // Queue the command for later processing
      final queued = VoiceCommand(command: command, timestamp: DateTime.now());
      await SQLiteService.insertQueuedCommand(queued.toMap());
      await voiceService.speak(
        'You are offline. Your command has been queued.',
      );
      queued.appResponse = 'You are offline. Your command has been queued.';
      await SQLiteService.updateQueuedCommand(queued.key ?? 0, queued.toMap());
      return;
    }

    // Robust intent and task extraction
    final parsed = _parseVoiceCommand(command);
    String appResponse;
    if (parsed == null) {
      appResponse =
          'Sorry, I did not understand your command. Please try again.';
      clarificationPrompt.state = appResponse;
      await voiceService.speak(appResponse);
      if (currentCmd != null) {
        currentCmd.appResponse = appResponse;
        await SQLiteService.updateQueuedCommand(
          currentCmd.key ?? 0,
          currentCmd.toMap(),
        );
      } else {
        final newCmd = VoiceCommand(
          command: command,
          timestamp: DateTime.now(),
          appResponse: appResponse,
        );
        await SQLiteService.insertQueuedCommand(newCmd.toMap());
      }
      return;
    }
    final intent = parsed['intent'];
    final task = parsed['task'];
    if (task == null || task.isEmpty) {
      appResponse = 'Please specify the task.';
      clarificationPrompt.state = appResponse;
      await voiceService.speak(appResponse);
      if (currentCmd != null) {
        currentCmd.appResponse = appResponse;
        await SQLiteService.updateQueuedCommand(
          currentCmd.key ?? 0,
          currentCmd.toMap(),
        );
      } else {
        final newCmd = VoiceCommand(
          command: command,
          timestamp: DateTime.now(),
          appResponse: appResponse,
        );
        await SQLiteService.insertQueuedCommand(newCmd.toMap());
      }
      return;
    }
    clarificationPrompt.state = null; // Clear any previous prompt
    switch (intent) {
      case 'add':
        await addTodo(task);
        appResponse = 'Added new task: $task';
        await voiceService.speak(appResponse);
        break;
      case 'complete':
        final todos =
            (await SQLiteService.getTasks())
                .map((m) => Todo.fromMap(m))
                .toList();
        final todo = todos.firstWhere(
          (t) => t.title.toLowerCase().contains(task.toLowerCase()),
          orElse: () => Todo(title: '', description: ''),
        );
        if (todo != null && todo.title.isNotEmpty) {
          await toggleTodo(todo.id);
          appResponse = 'Marked task as complete: ${todo.title}';
          await voiceService.speak(appResponse);
        } else {
          appResponse = 'Could not find a matching task to complete.';
          clarificationPrompt.state = appResponse;
          await voiceService.speak(appResponse);
        }
        break;
      case 'delete':
        final todos =
            (await SQLiteService.getTasks())
                .map((m) => Todo.fromMap(m))
                .toList();
        final todo = todos.firstWhere(
          (t) => t.title.toLowerCase().contains(task.toLowerCase()),
          orElse: () => Todo(title: '', description: ''),
        );
        if (todo != null && todo.title.isNotEmpty) {
          await deleteTodo(todo.id);
          appResponse = 'Deleted task: ${todo.title}';
          await voiceService.speak(appResponse);
        } else {
          appResponse = 'Could not find a matching task to delete.';
          clarificationPrompt.state = appResponse;
          await voiceService.speak(appResponse);
        }
        break;
      default:
        appResponse = 'Sorry, I did not understand your command.';
        clarificationPrompt.state = appResponse;
        await voiceService.speak(appResponse);
    }
    // Save the app response to the command
    if (currentCmd != null) {
      currentCmd.appResponse = appResponse;
      await SQLiteService.updateQueuedCommand(
        currentCmd.key ?? 0,
        currentCmd.toMap(),
      );
    } else {
      final newCmd = VoiceCommand(
        command: command,
        timestamp: DateTime.now(),
        appResponse: appResponse,
      );
      await SQLiteService.insertQueuedCommand(newCmd.toMap());
    }
  }

  Map<String, String?>? _parseVoiceCommand(String command) {
    final lower = command.toLowerCase();
    // NLP: Remind me to ... at ...
    final remindPattern = RegExp(
      r'remind me to (.+?)(?: at (.+))?$',
      caseSensitive: false,
      multiLine: false,
    );
    final showCompletedPattern = RegExp(r'show( me)?( all)? completed tasks');
    final whatsDuePattern = RegExp(r"what'?s due (today|tomorrow)");

    if (remindPattern.hasMatch(lower)) {
      final match = remindPattern.firstMatch(lower);
      return {
        'intent': 'add',
        'task': match?.group(1)?.trim(),
        'reminder': match?.group(2)?.trim(),
      };
    } else if (showCompletedPattern.hasMatch(lower)) {
      return {'intent': 'show_completed', 'task': null};
    } else if (whatsDuePattern.hasMatch(lower)) {
      final match = whatsDuePattern.firstMatch(lower);
      return {'intent': 'show_due', 'when': match?.group(1)?.trim()};
    }

    // Existing patterns
    final addPattern = RegExp(r'^(add|create|remind|new) (task )?(.*)');
    final completePattern = RegExp(
      r'^(complete|finish|done|mark|check) (task )?(.*)',
    );
    final deletePattern = RegExp(r'^(delete|remove|clear) (task )?(.*)');
    if (addPattern.hasMatch(lower)) {
      final match = addPattern.firstMatch(lower);
      return {'intent': 'add', 'task': match?.group(3)?.trim()};
    } else if (completePattern.hasMatch(lower)) {
      final match = completePattern.firstMatch(lower);
      return {'intent': 'complete', 'task': match?.group(3)?.trim()};
    } else if (deletePattern.hasMatch(lower)) {
      final match = deletePattern.firstMatch(lower);
      return {'intent': 'delete', 'task': match?.group(3)?.trim()};
    }
    // Fallback: try to infer intent from keywords
    if (lower.contains('add') ||
        lower.contains('create') ||
        lower.contains('remind')) {
      return {
        'intent': 'add',
        'task': lower.replaceAll(RegExp(r'add|create|remind|task'), '').trim(),
      };
    } else if (lower.contains('complete') ||
        lower.contains('finish') ||
        lower.contains('done')) {
      return {
        'intent': 'complete',
        'task':
            lower.replaceAll(RegExp(r'complete|finish|done|task'), '').trim(),
      };
    } else if (lower.contains('delete') ||
        lower.contains('remove') ||
        lower.contains('clear')) {
      return {
        'intent': 'delete',
        'task':
            lower.replaceAll(RegExp(r'delete|remove|clear|task'), '').trim(),
      };
    }
    return null;
  }

  Future<void> _processQueuedCommands() async {
    final queuedMaps = await SQLiteService.getQueuedCommands();
    final commands =
        queuedMaps
            .map((m) => VoiceCommand.fromMap(m))
            .where((c) => c.status == VoiceCommandStatus.pending)
            .toList();
    final voiceService = await ref.read(voiceServiceProvider.future);
    for (final cmd in commands) {
      // Try to process the command
      try {
        await processVoiceCommand(cmd.command);
        cmd.status = VoiceCommandStatus.synced;
        await SQLiteService.updateQueuedCommand(cmd.key ?? 0, cmd.toMap());
        await voiceService.speak('Processed queued command: ${cmd.command}');
      } catch (e) {
        cmd.status = VoiceCommandStatus.error;
        await SQLiteService.updateQueuedCommand(cmd.key ?? 0, cmd.toMap());
        await voiceService.speak(
          'Failed to process queued command: ${cmd.command}',
        );
      }
    }
  }
}

final queuedVoiceCommandsProvider = StreamProvider<List<VoiceCommand>>((
  ref,
) async* {
  // Poll SQLite every second for changes (since sqflite has no native watch)
  while (true) {
    final maps = await SQLiteService.getQueuedCommands();
    yield maps.map((m) => VoiceCommand.fromMap(m)).toList();
    await Future.delayed(const Duration(seconds: 1));
  }
});
