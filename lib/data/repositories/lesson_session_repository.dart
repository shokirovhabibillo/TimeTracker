import '../database/database_helper.dart';

class LessonSessionRepository {
  final _dbHelper = DatabaseHelper.instance;

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<int> startSession(String domain, String planName) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    return db.insert('lesson_session_log', {
      'domain': domain,
      'plan_name': planName,
      'date': _dateKey(now),
      'started_at': now.toIso8601String(),
      'completed_at': null,
      'elapsed_seconds': 0,
    });
  }

  Future<void> endSession(int id, int elapsedSeconds) async {
    final db = await _dbHelper.database;
    await db.update(
      'lesson_session_log',
      {'completed_at': DateTime.now().toIso8601String(), 'elapsed_seconds': elapsedSeconds},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// {domain: totalSeconds} for [day] — used by the Monthly Report and
  /// the unified daily activity score.
  Future<Map<String, int>> getSecondsByDomainForDay(DateTime day) async {
    final db = await _dbHelper.database;
    final rows = await db.query('lesson_session_log', where: 'date = ?', whereArgs: [_dateKey(day)]);
    final result = <String, int>{};
    for (final r in rows) {
      final domain = r['domain'] as String;
      final seconds = r['elapsed_seconds'] as int? ?? 0;
      result[domain] = (result[domain] ?? 0) + seconds;
    }
    return result;
  }

  Future<bool> anySessionOnDay(DateTime day) async {
    final db = await _dbHelper.database;
    final rows = await db.query('lesson_session_log', where: 'date = ?', whereArgs: [_dateKey(day)], limit: 1);
    return rows.isNotEmpty;
  }
}
