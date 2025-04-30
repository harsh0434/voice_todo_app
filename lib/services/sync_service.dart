import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo.dart';

class SyncService {
  final FirebaseFirestore _firestore;
  final Box<Todo> _todoBox;
  final String _deviceId;

  SyncService(this._firestore, this._todoBox, this._deviceId);

  Future<void> syncTodos() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return;
    }

    // Sync local changes to cloud
    final localTodos = _todoBox.values.where((todo) => !todo.isSynced).toList();
    for (final todo in localTodos) {
      await _firestore.collection('todos').doc(todo.id).set(todo.toJson());
      todo.isSynced = true;
      await todo.save();
    }

    // Sync cloud changes to local
    final cloudSnapshot =
        await _firestore
            .collection('todos')
            .where('deviceId', isNotEqualTo: _deviceId)
            .get();

    for (final doc in cloudSnapshot.docs) {
      final cloudTodo = Todo.fromJson(doc.data());
      final localTodo = _todoBox.get(cloudTodo.id);

      if (localTodo == null) {
        await _todoBox.put(cloudTodo.id, cloudTodo);
      } else if (cloudTodo.createdAt.isAfter(localTodo.createdAt)) {
        await _todoBox.put(cloudTodo.id, cloudTodo);
      }
    }
  }

  Future<void> addTodo(Todo todo) async {
    todo.deviceId = _deviceId;
    await _todoBox.put(todo.id, todo);
    await syncTodos();
  }

  Future<void> updateTodo(Todo todo) async {
    await _todoBox.put(todo.id, todo);
    await syncTodos();
  }

  Future<void> deleteTodo(String id) async {
    await _todoBox.delete(id);
    await _firestore.collection('todos').doc(id).delete();
  }

  Stream<List<Todo>> watchTodos() {
    return _todoBox.watch().map((_) => _todoBox.values.toList());
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  throw UnimplementedError('SyncService provider must be initialized');
});
