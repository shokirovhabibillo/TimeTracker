import '../database/database_helper.dart';
import '../models/step_model.dart';

class StepRepository {
  final _dbHelper = DatabaseHelper.instance;

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _dateKeyFor(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<StepLog> getOrCreateTodayLog(int currentCumulativeReading) async {
    final db = await _dbHelper.database;
    final today = _todayKey();
    final rows = await db.query('step_logs', where: 'date = ?', whereArgs: [today]);

    if (rows.isNotEmpty) {
      final log = StepLog.fromMap(rows.first);

      if (currentCumulativeReading >= log.lastReading) {
        // Normal case: counter keeps climbing, just record the new reading.
        final updated = StepLog(
          id: log.id,
          date: log.date,
          midnightBaseline: log.midnightBaseline,
          lastReading: currentCumulativeReading,
          accumulatedOffset: log.accumulatedOffset,
        );
        await db.update('step_logs', updated.toMap(), where: 'id = ?', whereArgs: [log.id]);
        return updated;
      }

      // The raw reading DROPPED below what we last saw — the device was
      // rebooted partway through the day (the hardware counter resets on
      // boot). Bank whatever was counted before the reboot into the
      // offset, then restart the baseline from this new post-reboot
      // reading, so today's total keeps climbing correctly instead of
      // silently losing everything counted so far today.
      final bankedSteps = (log.lastReading - log.midnightBaseline).clamp(0, 999999);
      final updated = StepLog(
        id: log.id,
        date: log.date,
        midnightBaseline: currentCumulativeReading,
        lastReading: currentCumulativeReading,
        accumulatedOffset: log.accumulatedOffset + bankedSteps,
      );
      await db.update('step_logs', updated.toMap(), where: 'id = ?', whereArgs: [log.id]);
      return updated;
    }

    // First reading of a new day: the step sensor is cumulative since
    // the device's last reboot, not since midnight — so if we just used
    // "whatever it reads right now" as the baseline, every step taken
    // before the app happened to be opened today would be silently
    // discarded. Instead, use yesterday's last known reading as today's
    // starting point (the counter only resets on a device reboot, which
    // is rare), so steps taken before first opening the app still count.
    final yesterday = _dateKeyFor(DateTime.now().subtract(const Duration(days: 1)));
    final prevRows = await db.query('step_logs', where: 'date = ?', whereArgs: [yesterday], limit: 1);
    final baseline = prevRows.isNotEmpty && (prevRows.first['last_reading'] as int) <= currentCumulativeReading
        ? prevRows.first['last_reading'] as int
        : currentCumulativeReading;

    final newLog = StepLog(date: today, midnightBaseline: baseline, lastReading: currentCumulativeReading);
    final id = await db.insert('step_logs', newLog.toMap()..remove('id'));
    return StepLog(
      id: id,
      date: newLog.date,
      midnightBaseline: newLog.midnightBaseline,
      lastReading: newLog.lastReading,
      accumulatedOffset: newLog.accumulatedOffset,
    );
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
      final key = _dateKeyFor(day);
      final rows = await db.query('step_logs', where: 'date = ?', whereArgs: [key], limit: 1);
      if (rows.isEmpty) {
        result.add(StepLog(date: key, midnightBaseline: 0, lastReading: 0));
      } else {
        result.add(StepLog.fromMap(rows.first));
      }
    }
    return result;
  }

  /// A single day's log, or a zero-step placeholder if none exists.
  Future<StepLog> getLogForDay(DateTime day) async {
    final db = await _dbHelper.database;
    final key = _dateKeyFor(day);
    final rows = await db.query('step_logs', where: 'date = ?', whereArgs: [key], limit: 1);
    if (rows.isEmpty) return StepLog(date: key, midnightBaseline: 0, lastReading: 0);
    return StepLog.fromMap(rows.first);
  }
}
