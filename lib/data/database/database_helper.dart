import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Central SQLite gateway. Implements the schema:
/// users_settings, tasks, focus_sessions, app_usage_logs.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'focus_life_tracker.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users_settings (
        id INTEGER PRIMARY KEY,
        theme_type TEXT NOT NULL DEFAULT 'hightech',
        ambient_sound TEXT,
        sleep_start_time TEXT NOT NULL DEFAULT '23:00',
        sleep_end_time TEXT NOT NULL DEFAULT '07:00',
        daily_distraction_limit_min INTEGER NOT NULL DEFAULT 90
      );
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        color_code TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        is_recurring INTEGER NOT NULL DEFAULT 0,
        recurrence_rule TEXT,
        notification_offset_min INTEGER NOT NULL DEFAULT 10,
        is_completed INTEGER NOT NULL DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE focus_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        actual_start TEXT NOT NULL,
        actual_end TEXT,
        completed_duration INTEGER NOT NULL DEFAULT 0,
        completion_percentage REAL NOT NULL DEFAULT 0,
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE app_usage_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        package_name TEXT NOT NULL,
        app_name TEXT,
        app_category TEXT NOT NULL,
        time_spent_seconds INTEGER NOT NULL,
        log_date TEXT NOT NULL,
        is_distracting INTEGER NOT NULL DEFAULT 0
      );
    ''');

    // Seed default settings row.
    await db.insert('users_settings', {
      'id': 1,
      'theme_type': 'hightech',
      'ambient_sound': null,
      'sleep_start_time': '23:00',
      'sleep_end_time': '07:00',
      'daily_distraction_limit_min': 90,
    });
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
