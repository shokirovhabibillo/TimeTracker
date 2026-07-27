import '../database/database_helper.dart';
import '../models/app_usage_model.dart';

class SettingsRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<UserSettingsModel> getSettings() async {
    final db = await _dbHelper.database;
    final maps = await db.query('users_settings', where: 'id = 1', limit: 1);
    if (maps.isEmpty) return UserSettingsModel();
    return UserSettingsModel.fromMap(maps.first);
  }

  Future<void> saveSettings(UserSettingsModel settings) async {
    final db = await _dbHelper.database;
    final map = settings.toMap();
    final rows = await db.update('users_settings', map,
        where: 'id = 1');
    if (rows == 0) {
      // Row somehow missing (e.g. fresh install edge case) — insert it.
      await db.insert('users_settings', map);
    }
  }
}
