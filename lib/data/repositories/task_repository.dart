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

  /// Records how a task was completed: 'on_time', 'late', or 'postponed'.
  /// on_time/late mark it done; postponed leaves it incomplete (so it
  /// still surfaces via getIncompleteTasksBefore for rollover).
  /// Passing 'none' clears any previously set status.
  Future<void> setCompletionStatus(int id, String status) async {
    final db = await _dbHelper.database;
    if (status == 'none') {
      await db.update(
        'tasks',
        {'completion_status': null, 'is_completed': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
      return;
    }
    final isCompleted = status == 'on_time' || status == 'late';
    await db.update(
      'tasks',
      {'completion_status': status, 'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static const Map<int, String> _weekdayAbbr = {
    1: 'MON', 2: 'TUE', 3: 'WED', 4: 'THU', 5: 'FRI', 6: 'SAT', 7: 'SUN',
  };

  bool _recurrenceMatchesDay(String? rule, DateTime day) {
    if (rule == null) return false;
    if (rule == 'DAILY') return true;
    if (rule.startsWith('WEEKLY:')) {
      final days = rule.substring(7).split(',');
      return days.contains(_weekdayAbbr[day.weekday]);
    }
    return false;
  }

  /// Returns every task that should appear on [day] — both tasks whose
  /// stored `start_time` literally falls on that date, AND recurring
  /// tasks (DAILY / WEEKLY:...) created on an earlier date whose rule
  /// matches this day's weekday, projected onto [day] at the same
  /// time-of-day. Without this projection, a "WEEKLY: Mon,Wed,Fri" task
  /// would only ever show up on the exact date it was first created.
  Future<List<TaskModel>> getTasksForDay(DateTime day) async {
    final db = await _dbHelper.database;
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final directMaps = await db.query(
      'tasks',
      where: 'start_time >= ? AND start_time < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
    final direct = directMaps.map(TaskModel.fromMap).toList();
    final directIds = direct.map((t) => t.id).toSet();

    final recurringMaps = await db.query(
      'tasks',
      where: 'is_recurring = 1 AND start_time < ?',
      whereArgs: [startOfDay.toIso8601String()],
    );

    final projected = <TaskModel>[];
    for (final map in recurringMaps) {
      final task = TaskModel.fromMap(map);
      if (directIds.contains(task.id)) continue; // already covered above
      if (!_recurrenceMatchesDay(task.recurrenceRule, day)) continue;
      if (task.recurrenceEndDate != null && day.isAfter(task.recurrenceEndDate!)) continue;
      final duration = task.endTime.difference(task.startTime);
      final newStart =
          DateTime(day.year, day.month, day.day, task.startTime.hour, task.startTime.minute);
      projected.add(task.copyWith(startTime: newStart, endTime: newStart.add(duration)));
    }

    final all = [...direct, ...projected];
    all.sort((a, b) => a.startTime.compareTo(b.startTime));
    return all;
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
    final now = DateTime.now();
    final todaysTasks = await getTasksForDay(now);
    for (final task in todaysTasks) {
      if (!task.startTime.isAfter(now) && !task.endTime.isBefore(now)) {
        return task;
      }
    }
    return null;
  }

  Future<List<TaskModel>> getAllTasks() async {
    final db = await _dbHelper.database;
    final maps = await db.query('tasks', orderBy: 'start_time ASC');
    return maps.map(TaskModel.fromMap).toList();
  }

  /// Incomplete, one-off (non-recurring) tasks whose planned date has
  /// already passed relative to [referenceDay] — candidates the user can
  /// "roll over" (re-plan) onto today instead of losing them silently.
  Future<List<TaskModel>> getIncompleteTasksBefore(DateTime referenceDay) async {
    final db = await _dbHelper.database;
    final startOfDay = DateTime(referenceDay.year, referenceDay.month, referenceDay.day);
    final maps = await db.query(
      'tasks',
      where: 'is_completed = 0 AND is_recurring = 0 AND start_time < ?',
      whereArgs: [startOfDay.toIso8601String()],
      orderBy: 'start_time ASC',
    );
    return maps.map(TaskModel.fromMap).toList();
  }

  /// Moves [task] onto [newDay] (same time-of-day, same duration) and
  /// increments its rollover counter — used both to fix the plan going
  /// forward and to power the "necha marta kechiktirilgan" analytics stat.
  Future<void> rolloverTask(TaskModel task, DateTime newDay) async {
    final db = await _dbHelper.database;
    final duration = task.endTime.difference(task.startTime);
    final newStart = DateTime(
        newDay.year, newDay.month, newDay.day, task.startTime.hour, task.startTime.minute);
    final newEnd = newStart.add(duration);
    await db.update(
      'tasks',
      {
        'start_time': newStart.toIso8601String(),
        'end_time': newEnd.toIso8601String(),
        'rolled_over_count': task.rolledOverCount + 1,
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// Total number of rollovers across all tasks — a simple "how often are
  /// plans slipping" signal surfaced in Analytics.
  Future<int> getTotalRolloverCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT SUM(rolled_over_count) as total FROM tasks');
    return (result.first['total'] as int?) ?? 0;
  }
}
