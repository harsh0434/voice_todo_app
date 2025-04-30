import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sqlite_service.dart';
import 'firebase_realtime_service.dart';
import '../models/todo.dart';

class SyncManager {
  final FirebaseRealtimeService _firebaseService;
  final Ref _ref;

  SyncManager(this._firebaseService, this._ref) {
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        await syncPendingChanges();
      }
    });
  }

  Future<void> syncPendingChanges() async {
    // Sync local changes to Firebase
    final localTasks = await SQLiteService.getTasks();
    for (final taskMap in localTasks) {
      final task = Todo.fromMap(taskMap);
      await _firebaseService.pushTaskToFirebase(task);
    }

    // Sync queued commands
    final queuedCommands = await SQLiteService.getQueuedCommands();
    for (final command in queuedCommands) {
      if (command['status'] == 'pending') {
        await _firebaseService.pushTaskToFirebase(Todo.fromMap(command));
      }
    }

    // Pull remote changes
    final remoteTasks = await _firebaseService.getRemoteTasks();
    for (final task in remoteTasks) {
      final localTask = await SQLiteService.getTaskById(task.id);
      if (localTask == null ||
          task.updatedAt.isAfter(DateTime.parse(localTask['updatedAt']))) {
        await SQLiteService.updateTask(task.toMap());
      }
    }
  }
}

final syncManagerProvider = Provider<SyncManager>((ref) {
  final firebaseService = FirebaseRealtimeService();
  return SyncManager(firebaseService, ref);
});
