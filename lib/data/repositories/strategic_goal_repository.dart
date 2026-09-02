import '../database/database_helper.dart';
import '../models/strategic_goal_model.dart';

class StrategicGoalRepository {
  final _dbHelper = DatabaseHelper.instance;

  /// The 5 root ("asr") goals — created lazily on first use so a fresh
  /// install starts with 5 empty slots ready to be filled in.
  Future<List<StrategicGoal>> getOrCreateRoots() async {
    final existing = await getChildren(null, StrategyLevel.asr);
    if (existing.length == 5) return existing;

    final db = await _dbHelper.database;
    final existingPositions = existing.map((g) => g.position).toSet();
    for (var p = 1; p <= 5; p++) {
      if (existingPositions.contains(p)) continue;
      await db.insert('strategic_goals', StrategicGoal(
        parentId: null,
        level: StrategyLevel.asr,
        position: p,
        title: '',
      ).toMap()..remove('id'));
    }
    return getChildren(null, StrategyLevel.asr);
  }

  /// The 5 slots under [parentId] at [level] — created lazily (empty
  /// title) if they don't exist yet, same "always exactly 5" pattern.
  Future<List<StrategicGoal>> getOrCreateChildren(int parentId, String level) async {
    final existing = await getChildren(parentId, level);
    if (existing.length == 5) return existing;

    final db = await _dbHelper.database;
    final existingPositions = existing.map((g) => g.position).toSet();
    for (var p = 1; p <= 5; p++) {
      if (existingPositions.contains(p)) continue;
      await db.insert('strategic_goals', StrategicGoal(
        parentId: parentId,
        level: level,
        position: p,
        title: '',
      ).toMap()..remove('id'));
    }
    return getChildren(parentId, level);
  }

  Future<List<StrategicGoal>> getChildren(int? parentId, String level) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'strategic_goals',
      where: parentId == null ? 'parent_id IS NULL AND level = ?' : 'parent_id = ? AND level = ?',
      whereArgs: parentId == null ? [level] : [parentId, level],
      orderBy: 'position',
    );
    return rows.map((r) => StrategicGoal.fromMap(r)).toList();
  }

  Future<StrategicGoal?> getById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query('strategic_goals', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return StrategicGoal.fromMap(rows.first);
  }

  Future<void> updateTitle(int id, String title) async {
    final db = await _dbHelper.database;
    await db.update('strategic_goals', {'title': title}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateStatus(int id, String status) async {
    final db = await _dbHelper.database;
    await db.update('strategic_goals', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> linkTask(int id, int? taskId) async {
    final db = await _dbHelper.database;
    await db.update('strategic_goals', {'linked_task_id': taskId}, where: 'id = ?', whereArgs: [id]);
  }

  /// Progress for a goal = (done children / 5) * 100, recursively — a
  /// leaf ("day") goal's progress is just 100 if done, 0 otherwise,
  /// since it has no children of its own to aggregate.
  Future<double> getProgress(StrategicGoal goal) async {
    final childLevel = StrategyLevel.childOf(goal.level);
    if (childLevel == null) return goal.isDone ? 100 : 0;

    final children = await getChildren(goal.id, childLevel);
    if (children.isEmpty) return goal.isDone ? 100 : 0;

    double total = 0;
    for (final c in children) {
      total += await getProgress(c);
    }
    return total / 5; // always exactly 5 slots per the Rule of 5
  }
}
