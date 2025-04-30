import 'package:firebase_database/firebase_database.dart';
import '../models/todo.dart';
import 'sqlite_service.dart';

class FirebaseRealtimeService {
  final DatabaseReference _tasksRef = FirebaseDatabase.instance.ref('tasks');

  // Listen for remote changes and update SQLite
  void startListeningForRemoteChanges() {
    _tasksRef.onChildAdded.listen(_onTaskChanged);
    _tasksRef.onChildChanged.listen(_onTaskChanged);
    _tasksRef.onChildRemoved.listen(_onTaskRemoved);
  }

  Future<void> _onTaskChanged(DatabaseEvent event) async {
    if (event.snapshot.value == null) return;
    final data = Map<String, dynamic>.from(event.snapshot.value as Map);
    final remoteTodo = Todo.fromJson(data);
    final localTasks =
        (await SQLiteService.getTasks()).map((m) => Todo.fromMap(m)).toList();
    Todo? localTodo;
    try {
      localTodo = localTasks.firstWhere((t) => t.id == remoteTodo.id);
    } catch (_) {
      localTodo = null;
    }
    // Conflict resolution: lastModified wins
    if (localTodo == null ||
        (remoteTodo.updatedAt != null &&
            (localTodo.updatedAt == null ||
                remoteTodo.updatedAt!.isAfter(localTodo.updatedAt!)))) {
      await SQLiteService.insertTask(remoteTodo.toMap());
    }
  }

  Future<void> _onTaskRemoved(DatabaseEvent event) async {
    final id = event.snapshot.key;
    if (id != null) {
      await SQLiteService.deleteTask(id);
    }
  }

  // Push local changes to Firebase
  Future<void> pushTaskToFirebase(Todo todo) async {
    await _tasksRef.child(todo.id).set(todo.toJson());
  }

  // Remove task from Firebase
  Future<void> removeTaskFromFirebase(String id) async {
    await _tasksRef.child(id).remove();
  }
}
