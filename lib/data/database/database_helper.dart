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
      version: 25,
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
    if (oldVersion < 9) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS flashcards (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          deck TEXT NOT NULL,
          front TEXT NOT NULL,
          back TEXT NOT NULL,
          transliteration TEXT,
          interval_days INTEGER NOT NULL DEFAULT 0,
          repetitions INTEGER NOT NULL DEFAULT 0,
          ease_factor REAL NOT NULL DEFAULT 2.5,
          next_review_date TEXT NOT NULL,
          created_at TEXT NOT NULL
        );
      ''');
    }
    if (oldVersion < 10) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS step_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL UNIQUE,
          midnight_baseline INTEGER NOT NULL,
          last_reading INTEGER NOT NULL
        );
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS route_sessions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          started_at TEXT NOT NULL,
          ended_at TEXT,
          distance_meters REAL NOT NULL DEFAULT 0,
          points_json TEXT NOT NULL
        );
      ''');
    }
    if (oldVersion < 11) {
      await db.execute(
          "ALTER TABLE users_settings ADD COLUMN has_seen_onboarding INTEGER NOT NULL DEFAULT 0");
    }
    if (oldVersion < 12) {
      await db.execute(
          "ALTER TABLE idp_competencies ADD COLUMN competency_type TEXT NOT NULL DEFAULT 'skill'");
    }
    if (oldVersion < 13) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS task_completions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          task_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          is_completed INTEGER NOT NULL DEFAULT 0,
          completion_status TEXT,
          UNIQUE(task_id, date)
        );
      ''');
    }
    if (oldVersion < 14) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS reading_books (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          file_path TEXT NOT NULL UNIQUE,
          title TEXT NOT NULL,
          last_page INTEGER NOT NULL DEFAULT 1,
          total_pages INTEGER NOT NULL DEFAULT 0,
          added_at TEXT NOT NULL,
          last_opened_at TEXT NOT NULL
        );
      ''');
    }
    if (oldVersion < 15) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS activity_time_log (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          activity_type TEXT NOT NULL,
          seconds INTEGER NOT NULL DEFAULT 0,
          UNIQUE(date, activity_type)
        );
      ''');
    }
    if (oldVersion < 16) {
      await db.execute(
          "ALTER TABLE users_settings ADD COLUMN font_scale REAL NOT NULL DEFAULT 1.0");
    }
    if (oldVersion < 17) {
      await db.execute("ALTER TABLE users_settings ADD COLUMN device_id TEXT NOT NULL DEFAULT ''");
      await db.execute(
          "ALTER TABLE users_settings ADD COLUMN family_role TEXT NOT NULL DEFAULT 'none'");
      await db.execute("ALTER TABLE users_settings ADD COLUMN linked_child_device_id TEXT");
      await db.execute("ALTER TABLE users_settings ADD COLUMN child_display_name TEXT");
    }
    if (oldVersion < 18) {
      await db.execute(
          "ALTER TABLE users_settings ADD COLUMN button_style TEXT NOT NULL DEFAULT 'normal'");
      await db.execute(
          "ALTER TABLE users_settings ADD COLUMN visualization_mode TEXT NOT NULL DEFAULT 'smartphone'");
    }
    if (oldVersion < 19) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS medicines (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          dosage TEXT NOT NULL,
          times TEXT NOT NULL,
          start_date TEXT NOT NULL,
          end_date TEXT,
          notes TEXT NOT NULL DEFAULT ''
        );
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS dose_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          medicine_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          time TEXT NOT NULL,
          taken INTEGER NOT NULL DEFAULT 0,
          UNIQUE(medicine_id, date, time)
        );
      ''');
    }
    if (oldVersion < 20) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS daily_game_log (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          game_id TEXT NOT NULL,
          date TEXT NOT NULL,
          session_start_at TEXT NOT NULL,
          completed_at TEXT,
          score INTEGER NOT NULL DEFAULT 0,
          UNIQUE(game_id, date)
        );
      ''');
    }
    if (oldVersion < 21) {
      await db.execute(
          "ALTER TABLE tasks ADD COLUMN is_passenger_transport INTEGER NOT NULL DEFAULT 0");
    }
    if (oldVersion < 22) {
      await db.execute("ALTER TABLE users_settings ADD COLUMN locale TEXT NOT NULL DEFAULT 'uz'");
    }
    if (oldVersion < 23) {
      await db.execute("ALTER TABLE step_logs ADD COLUMN accumulated_offset INTEGER NOT NULL DEFAULT 0");
    }
    if (oldVersion < 24) {
      await db.execute("ALTER TABLE tasks ADD COLUMN priority INTEGER NOT NULL DEFAULT 2");
      await db.execute('''
        CREATE TABLE IF NOT EXISTS strategic_goals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          parent_id INTEGER REFERENCES strategic_goals(id) ON DELETE CASCADE,
          level TEXT NOT NULL CHECK(level IN ('asr','decade','year','month','week','day')),
          position INTEGER NOT NULL CHECK(position BETWEEN 1 AND 5),
          title TEXT NOT NULL,
          period_start TEXT,
          period_end TEXT,
          status TEXT NOT NULL DEFAULT 'active',
          linked_task_id INTEGER,
          created_at TEXT NOT NULL
        );
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_strategic_parent ON strategic_goals(parent_id)');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS daily_spins (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          task_id INTEGER,
          task_title TEXT NOT NULL,
          multiplier INTEGER NOT NULL CHECK(multiplier IN (1,2,3)),
          scheduled_time TEXT,
          completed INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL
        );
      ''');
    }
    if (oldVersion < 25) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS lesson_session_log (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          domain TEXT NOT NULL,
          plan_name TEXT NOT NULL,
          date TEXT NOT NULL,
          started_at TEXT NOT NULL,
          completed_at TEXT,
          elapsed_seconds INTEGER NOT NULL DEFAULT 0
        );
      ''');
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
        background_pattern TEXT NOT NULL DEFAULT 'none',
        has_seen_onboarding INTEGER NOT NULL DEFAULT 0,
        font_scale REAL NOT NULL DEFAULT 1.0,
        device_id TEXT NOT NULL DEFAULT '',
        family_role TEXT NOT NULL DEFAULT 'none',
        linked_child_device_id TEXT,
        child_display_name TEXT,
        button_style TEXT NOT NULL DEFAULT 'normal',
        visualization_mode TEXT NOT NULL DEFAULT 'smartphone',
        locale TEXT NOT NULL DEFAULT 'uz'
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
        is_completed INTEGER NOT NULL DEFAULT 0,
        rolled_over_count INTEGER NOT NULL DEFAULT 0,
        completion_status TEXT,
        recurrence_end_date TEXT,
        is_passenger_transport INTEGER NOT NULL DEFAULT 0,
        priority INTEGER NOT NULL DEFAULT 2
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
        competency_type TEXT NOT NULL DEFAULT 'skill',
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

    await db.execute('''
      CREATE TABLE task_completions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        completion_status TEXT,
        UNIQUE(task_id, date)
      );
    ''');

    await db.execute('''
      CREATE TABLE reading_books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_path TEXT NOT NULL UNIQUE,
        title TEXT NOT NULL,
        last_page INTEGER NOT NULL DEFAULT 1,
        total_pages INTEGER NOT NULL DEFAULT 0,
        added_at TEXT NOT NULL,
        last_opened_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE activity_time_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        activity_type TEXT NOT NULL,
        seconds INTEGER NOT NULL DEFAULT 0,
        UNIQUE(date, activity_type)
      );
    ''');

    await db.execute('''
      CREATE TABLE medicines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        times TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        notes TEXT NOT NULL DEFAULT ''
      );
    ''');

    await db.execute('''
      CREATE TABLE dose_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicine_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        taken INTEGER NOT NULL DEFAULT 0,
        UNIQUE(medicine_id, date, time)
      );
    ''');

    await db.execute('''
      CREATE TABLE daily_game_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        game_id TEXT NOT NULL,
        date TEXT NOT NULL,
        session_start_at TEXT NOT NULL,
        completed_at TEXT,
        score INTEGER NOT NULL DEFAULT 0,
        UNIQUE(game_id, date)
      );
    ''');

    await db.execute('''
      CREATE TABLE strategic_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        parent_id INTEGER REFERENCES strategic_goals(id) ON DELETE CASCADE,
        level TEXT NOT NULL CHECK(level IN ('asr','decade','year','month','week','day')),
        position INTEGER NOT NULL CHECK(position BETWEEN 1 AND 5),
        title TEXT NOT NULL,
        period_start TEXT,
        period_end TEXT,
        status TEXT NOT NULL DEFAULT 'active',
        linked_task_id INTEGER,
        created_at TEXT NOT NULL
      );
    ''');
    await db.execute('CREATE INDEX idx_strategic_parent ON strategic_goals(parent_id)');

    await db.execute('''
      CREATE TABLE daily_spins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER,
        task_title TEXT NOT NULL,
        multiplier INTEGER NOT NULL CHECK(multiplier IN (1,2,3)),
        scheduled_time TEXT,
        completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE lesson_session_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        domain TEXT NOT NULL,
        plan_name TEXT NOT NULL,
        date TEXT NOT NULL,
        started_at TEXT NOT NULL,
        completed_at TEXT,
        elapsed_seconds INTEGER NOT NULL DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE flashcards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deck TEXT NOT NULL,
        front TEXT NOT NULL,
        back TEXT NOT NULL,
        transliteration TEXT,
        interval_days INTEGER NOT NULL DEFAULT 0,
        repetitions INTEGER NOT NULL DEFAULT 0,
        ease_factor REAL NOT NULL DEFAULT 2.5,
        next_review_date TEXT NOT NULL,
        created_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE step_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        midnight_baseline INTEGER NOT NULL,
        last_reading INTEGER NOT NULL,
        accumulated_offset INTEGER NOT NULL DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE route_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        started_at TEXT NOT NULL,
        ended_at TEXT,
        distance_meters REAL NOT NULL DEFAULT 0,
        points_json TEXT NOT NULL
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
