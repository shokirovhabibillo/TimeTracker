import '../database/database_helper.dart';
import '../models/task_model.dart';

class TaskRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<int> createTask(TaskModel task) async {
    final db = await _dbHelper.database;
    final map = task.toMap()..remove('id');
    return db.insert('tasks', map);
  }

  Future<int> updateTask(TaskModel task) async {
    final db = await _dbHelper.database;
    return db.update('tasks', task.toMap(),
        where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> deleteTask(int id) async {
    final db = await _dbHelper.database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> setCompleted(int id, bool completed) async {
    final db = await _dbHelper.database;
    return db.update('tasks', {'is_completed': completed ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TaskModel>> getTasksForDay(DateTime day) async {
    final db = await _dbHelper.database;
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final maps = await db.query(
      'tasks',
      where: 'start_time >= ? AND start_time < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'start_time ASC',
    );
    return maps.map(TaskModel.fromMap).toList();
  }

  /// Tasks that overlap "now or later" — used to highlight future
  /// blocks of the currently active task in the mini calendar.
  Future<List<TaskModel>> getUpcomingForCategory(String category) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    final maps = await db.query(
      'tasks',
      where: 'category = ? AND end_time >= ?',
      whereArgs: [category, now],
      orderBy: 'start_time ASC',
    );
    return maps.map(TaskModel.fromMap).toList();
  }

  Future<TaskModel?> getActiveTask() async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    final maps = await db.query(
      'tasks',
      where: 'start_time <= ? AND end_time >= ?',
      whereArgs: [now, now],
      orderBy: 'start_time ASC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return TaskModel.fromMap(maps.first);
  }

  Future<List<TaskModel>> getAllTasks() async {
    final db = await _dbHelper.database;
    final maps = await db.query('tasks', orderBy: 'start_time ASC');
    return maps.map(TaskModel.fromMap).toList();
  }
}
