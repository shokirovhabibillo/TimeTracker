import '../database/database_helper.dart';
import '../models/focus_session_model.dart';

class FocusSessionRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<int> startSession(FocusSessionModel session) async {
    final db = await _dbHelper.database;
    final map = session.toMap()..remove('id');
    return db.insert('focus_sessions', map);
  }

  Future<void> endSession(int id,
      {required DateTime actualEnd,
      required int completedDurationSeconds,
      required double completionPercentage}) async {
    final db = await _dbHelper.database;
    await db.update(
      'focus_sessions',
      {
        'actual_end': actualEnd.toIso8601String(),
        'completed_duration': completedDurationSeconds,
        'completion_percentage': completionPercentage,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<FocusSessionModel>> getSessionsForTask(int taskId) async {
    final db = await _dbHelper.database;
    final maps = await db.query('focus_sessions',
        where: 'task_id = ?', whereArgs: [taskId], orderBy: 'actual_start DESC');
    return maps.map(FocusSessionModel.fromMap).toList();
  }

  Future<List<FocusSessionModel>> getSessionsForDay(DateTime day) async {
    final db = await _dbHelper.database;
    final start = DateTime(day.year, day.month, day.day).toIso8601String();
    final end =
        DateTime(day.year, day.month, day.day).add(const Duration(days: 1)).toIso8601String();
    final maps = await db.query('focus_sessions',
        where: 'actual_start >= ? AND actual_start < ?',
        whereArgs: [start, end]);
    return maps.map(FocusSessionModel.fromMap).toList();
  }
}
