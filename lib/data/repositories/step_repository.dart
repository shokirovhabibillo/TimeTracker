import 'dart:convert';

import '../database/database_helper.dart';
import '../models/step_model.dart';

class StepRepository {
  final _dbHelper = DatabaseHelper.instance;

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<StepLog> getOrCreateTodayLog(int currentCumulativeReading) async {
    final db = await _dbHelper.database;
    final today = _todayKey();
    final rows = await db.query('step_logs', where: 'date = ?', whereArgs: [today]);
    if (rows.isNotEmpty) {
      final log = StepLog.fromMap(rows.first);
      if (currentCumulativeReading > log.lastReading) {
        final updated = StepLog(
          id: log.id,
          date: log.date,
          midnightBaseline: log.midnightBaseline,
          lastReading: currentCumulativeReading,
        );
        await db.update('step_logs', updated.toMap(), where: 'id = ?', whereArgs: [log.id]);
        return updated;
      }
      return log;
    }
    final newLog = StepLog(date: today, midnightBaseline: currentCumulativeReading, lastReading: currentCumulativeReading);
    final id = await db.insert('step_logs', newLog.toMap()..remove('id'));
    return StepLog(id: id, date: newLog.date, midnightBaseline: newLog.midnightBaseline, lastReading: newLog.lastReading);
  }

  Future<void> updateReading(int logId, int currentCumulativeReading) async {
    final db = await _dbHelper.database;
    await db.update('step_logs', {'last_reading': currentCumulativeReading}, where: 'id = ?', whereArgs: [logId]);
  }

  /// Returns the last [days] days' logs (including today), oldest first,
  /// with a zero-step placeholder for any day that has no record yet.
  Future<List<StepLog>> getLastDays(int days) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final result = <StepLog>[];
    for (var i = days - 1; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key =
          '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final rows = await db.query('step_logs', where: 'date = ?', whereArgs: [key], limit: 1);
      if (rows.isEmpty) {
        result.add(StepLog(date: key, midnightBaseline: 0, lastReading: 0));
      } else {
        result.add(StepLog.fromMap(rows.first));
      }
    }
    return result;
  }

  Future<int> saveRouteSession(RouteSession session) async {
    final db = await _dbHelper.database;
    return db.insert('route_sessions', {
      'started_at': session.startedAt.toIso8601String(),
      'ended_at': session.endedAt?.toIso8601String(),
      'distance_meters': session.distanceMeters,
      'points_json': jsonEncode(session.points.map((p) => [p.lat, p.lng]).toList()),
    });
  }

  Future<List<RouteSession>> getSessionsForDay(DateTime day) async {
    final db = await _dbHelper.database;
    final start = DateTime(day.year, day.month, day.day).toIso8601String();
    final end = DateTime(day.year, day.month, day.day).add(const Duration(days: 1)).toIso8601String();
    final rows = await db.query('route_sessions',
        where: 'started_at >= ? AND started_at < ?', whereArgs: [start, end], orderBy: 'started_at ASC');
    return rows.map((r) {
      final rawPoints = jsonDecode(r['points_json'] as String) as List<dynamic>;
      return RouteSession(
        id: r['id'] as int,
        startedAt: DateTime.parse(r['started_at'] as String),
        endedAt: r['ended_at'] != null ? DateTime.parse(r['ended_at'] as String) : null,
        distanceMeters: (r['distance_meters'] as num).toDouble(),
        points: rawPoints.map((p) => (lat: (p[0] as num).toDouble(), lng: (p[1] as num).toDouble())).toList(),
      );
    }).toList();
  }
}
