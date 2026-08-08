import '../database/database_helper.dart';

class ActivityTimeRepository {
  final _dbHelper = DatabaseHelper.instance;

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Adds [seconds] of the given [activityType] to today's tally.
  Future<void> addSeconds(String activityType, int seconds) async {
    if (seconds <= 0) return;
    final db = await _dbHelper.database;
    final dateKey = _dateKey(DateTime.now());
    final rows = await db.query('activity_time_log',
        where: 'date = ? AND activity_type = ?', whereArgs: [dateKey, activityType], limit: 1);
    if (rows.isEmpty) {
      await db.insert('activity_time_log', {'date': dateKey, 'activity_type': activityType, 'seconds': seconds});
    } else {
      final current = rows.first['seconds'] as int;
      await db.update('activity_time_log', {'seconds': current + seconds},
          where: 'id = ?', whereArgs: [rows.first['id']]);
    }
  }

  /// Returns {activityType: totalSeconds} for [day].
  Future<Map<String, int>> getSecondsByActivity(DateTime day) async {
    final db = await _dbHelper.database;
    final dateKey = _dateKey(day);
    final rows = await db.query('activity_time_log', where: 'date = ?', whereArgs: [dateKey]);
    final map = <String, int>{};
    for (final r in rows) {
      map[r['activity_type'] as String] = r['seconds'] as int;
    }
    return map;
  }
}
