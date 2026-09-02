import '../database/database_helper.dart';

class DailySpin {
  final int? id;
  final int? taskId;
  final String taskTitle;
  final int multiplier; // 1, 2, or 3
  final DateTime? scheduledTime;
  final bool completed;
  final DateTime createdAt;

  DailySpin({
    this.id,
    this.taskId,
    required this.taskTitle,
    required this.multiplier,
    this.scheduledTime,
    this.completed = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'task_id': taskId,
        'task_title': taskTitle,
        'multiplier': multiplier,
        'scheduled_time': scheduledTime?.toIso8601String(),
        'completed': completed ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
      };

  factory DailySpin.fromMap(Map<String, dynamic> map) => DailySpin(
        id: map['id'] as int?,
        taskId: map['task_id'] as int?,
        taskTitle: map['task_title'] as String,
        multiplier: map['multiplier'] as int,
        scheduledTime: map['scheduled_time'] != null ? DateTime.parse(map['scheduled_time'] as String) : null,
        completed: (map['completed'] as int? ?? 0) == 1,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}

class DailySpinRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<int> createSpin(DailySpin spin) async {
    final db = await _dbHelper.database;
    return db.insert('daily_spins', spin.toMap()..remove('id'));
  }

  Future<void> setScheduledTime(int id, DateTime time) async {
    final db = await _dbHelper.database;
    await db.update('daily_spins', {'scheduled_time': time.toIso8601String()}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markCompleted(int id) async {
    final db = await _dbHelper.database;
    await db.update('daily_spins', {'completed': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<DailySpin>> getRecent({int limit = 10}) async {
    final db = await _dbHelper.database;
    final rows = await db.query('daily_spins', orderBy: 'created_at DESC', limit: limit);
    return rows.map((r) => DailySpin.fromMap(r)).toList();
  }

  /// {multiplier: count} across all spins — for a simple stats summary.
  Future<Map<int, int>> getMultiplierStats() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('SELECT multiplier, COUNT(*) as c FROM daily_spins GROUP BY multiplier');
    return {for (final r in rows) r['multiplier'] as int: r['c'] as int};
  }
}
