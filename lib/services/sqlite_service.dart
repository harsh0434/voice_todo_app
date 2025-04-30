import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'voice_todo_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            isCompleted INTEGER,
            completedAt TEXT,
            createdAt TEXT,
            updatedAt TEXT,
            deviceId TEXT,
            isSynced INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE queued_commands (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            command TEXT,
            timestamp TEXT,
            status TEXT,
            appResponse TEXT
          )
        ''');
      },
    );
  }

  // CRUD for tasks
  static Future<void> insertTask(Map<String, dynamic> task) async {
    final db = await database;
    await db.insert(
      'tasks',
      task,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;
    return db.query('tasks');
  }

  static Future<void> updateTask(Map<String, dynamic> task) async {
    final db = await database;
    await db.update('tasks', task, where: 'id = ?', whereArgs: [task['id']]);
  }

  static Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD for queued commands
  static Future<void> insertQueuedCommand(Map<String, dynamic> cmd) async {
    final db = await database;
    await db.insert('queued_commands', cmd);
  }

  static Future<List<Map<String, dynamic>>> getQueuedCommands() async {
    final db = await database;
    return db.query('queued_commands');
  }

  static Future<void> updateQueuedCommand(
    int id,
    Map<String, dynamic> cmd,
  ) async {
    final db = await database;
    await db.update('queued_commands', cmd, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteQueuedCommand(int id) async {
    final db = await database;
    await db.delete('queued_commands', where: 'id = ?', whereArgs: [id]);
  }
}
