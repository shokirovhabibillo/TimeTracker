import '../database/database_helper.dart';
import '../models/app_usage_model.dart';

class UsageRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<void> upsertDailyUsage(AppUsageModel usage) async {
    final db = await _dbHelper.database;
    final dateStr = usage.toMap()['log_date'];
    final existing = await db.query(
      'app_usage_logs',
      where: 'package_name = ? AND log_date = ?',
      whereArgs: [usage.packageName, dateStr],
      limit: 1,
    );
    if (existing.isEmpty) {
      await db.insert('app_usage_logs', usage.toMap()..remove('id'));
    } else {
      await db.update(
        'app_usage_logs',
        {'time_spent_seconds': usage.timeSpentSeconds},
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    }
  }

  Future<List<AppUsageModel>> getUsageForDay(DateTime day) async {
    final db = await _dbHelper.database;
    final dateStr =
        '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final maps = await db.query('app_usage_logs',
        where: 'log_date = ?',
        whereArgs: [dateStr],
        orderBy: 'time_spent_seconds DESC');
    return maps.map(AppUsageModel.fromMap).toList();
  }

  Future<int> getDistractingSecondsForDay(DateTime day) async {
    final usages = await getUsageForDay(day);
    return usages
        .where((u) => u.isDistracting)
        .fold<int>(0, (sum, u) => sum + u.timeSpentSeconds);
  }
}
