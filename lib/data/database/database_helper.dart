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
      version: 8,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          "ALTER TABLE users_settings ADD COLUMN clock_style TEXT NOT NULL DEFAULT 'analog'");
      await db.execute(
          "ALTER TABLE users_settings ADD COLUMN timer_style TEXT NOT NULL DEFAULT 'ring'");
      await db.execute(
          "ALTER TABLE users_settings ADD COLUMN calendar_style TEXT NOT NULL DEFAULT 'timeline'");
    }
    if (oldVersion < 3) {
      await db.execute(
          "ALTER TABLE tasks ADD COLUMN rolled_over_count INTEGER NOT NULL DEFAULT 0");
      await db.execute('''
        CREATE TABLE IF NOT EXISTS lesson_plans (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          created_at TEXT NOT NULL
        );
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS lesson_segments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          lesson_plan_id INTEGER NOT NULL,
          segment_type TEXT NOT NULL,
          duration_minutes INTEGER NOT NULL,
          order_index INTEGER NOT NULL,
          FOREIGN KEY (lesson_plan_id) REFERENCES lesson_plans (id) ON DELETE CASCADE
        );
      ''');
    }
    if (oldVersion < 4) {
      await db.execute("ALTER TABLE tasks ADD COLUMN completion_status TEXT");
    }
    if (oldVersion < 5) {
      await db.execute("ALTER TABLE tasks ADD COLUMN recurrence_end_date TEXT");
    }
    if (oldVersion < 6) {
      await db.execute(
          "ALTER TABLE users_settings ADD COLUMN background_pattern TEXT NOT NULL DEFAULT 'none'");
    }
    if (oldVersion < 7) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS idp_competencies (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          created_at TEXT NOT NULL
        );
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS idp_action_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          competency_id INTEGER NOT NULL,
          bucket TEXT NOT NULL,
          purpose TEXT NOT NULL DEFAULT '',
          action_plan TEXT NOT NULL DEFAULT '',
          start_date TEXT,
          end_date TEXT,
          status TEXT NOT NULL DEFAULT 'not_started',
          achieved_result TEXT NOT NULL DEFAULT '',
          comment TEXT NOT NULL DEFAULT '',
          FOREIGN KEY (competency_id) REFERENCES idp_competencies (id) ON DELETE CASCADE
        );
      ''');
    }
    if (oldVersion < 8) {
      await db.execute(
          "ALTER TABLE lesson_plans ADD COLUMN domain TEXT NOT NULL DEFAULT 'teacher'");
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users_settings (
        id INTEGER PRIMARY KEY,
        theme_type TEXT NOT NULL DEFAULT 'youth_neon_hud',
        ambient_sound TEXT,
        sleep_start_time TEXT NOT NULL DEFAULT '23:00',
        sleep_end_time TEXT NOT NULL DEFAULT '07:00',
        daily_distraction_limit_min INTEGER NOT NULL DEFAULT 90,
        clock_style TEXT NOT NULL DEFAULT 'analog',
        timer_style TEXT NOT NULL DEFAULT 'ring',
        calendar_style TEXT NOT NULL DEFAULT 'timeline',
        background_pattern TEXT NOT NULL DEFAULT 'none'
      );
    ''');;

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
        is_completed INTEGER NOT NULL DEFAULT 0,
        rolled_over_count INTEGER NOT NULL DEFAULT 0,
        completion_status TEXT,
        recurrence_end_date TEXT
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

    await db.execute('''
      CREATE TABLE lesson_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        domain TEXT NOT NULL DEFAULT 'teacher'
      );
    ''');

    await db.execute('''
      CREATE TABLE lesson_segments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lesson_plan_id INTEGER NOT NULL,
        segment_type TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        order_index INTEGER NOT NULL,
        FOREIGN KEY (lesson_plan_id) REFERENCES lesson_plans (id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE idp_competencies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE idp_action_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        competency_id INTEGER NOT NULL,
        bucket TEXT NOT NULL,
        purpose TEXT NOT NULL DEFAULT '',
        action_plan TEXT NOT NULL DEFAULT '',
        start_date TEXT,
        end_date TEXT,
        status TEXT NOT NULL DEFAULT 'not_started',
        achieved_result TEXT NOT NULL DEFAULT '',
        comment TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (competency_id) REFERENCES idp_competencies (id) ON DELETE CASCADE
      );
    ''');

    // Seed default settings row.
    await db.insert('users_settings', {
      'id': 1,
      'theme_type': 'youth_neon_hud',
      'ambient_sound': null,
      'sleep_start_time': '23:00',
      'sleep_end_time': '07:00',
      'daily_distraction_limit_min': 90,
      'clock_style': 'analog',
      'timer_style': 'ring',
      'calendar_style': 'timeline',
      'background_pattern': 'none',
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
