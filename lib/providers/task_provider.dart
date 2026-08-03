import 'package:flutter/material.dart';

import '../data/models/task_model.dart';
import '../data/repositories/task_repository.dart';
import '../services/notification_service.dart';

class TimeGap {
  final DateTime start;
  final DateTime end;
  const TimeGap(this.start, this.end);
  Duration get duration => end.difference(start);
}

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repository = TaskRepository();

  DateTime _selectedDay = DateTime.now();
  List<TaskModel> _tasksForDay = [];
  List<TaskModel> _incompleteFromPast = [];
  TaskModel? _activeTask;
  List<TaskModel> _activeTaskUpcomingBlocks = [];
  bool _isLoading = false;

  DateTime get selectedDay => _selectedDay;
  List<TaskModel> get tasksForDay => _tasksForDay;
  List<TaskModel> get incompleteFromPast => _incompleteFromPast;
  TaskModel? get activeTask => _activeTask;
  List<TaskModel> get activeTaskUpcomingBlocks => _activeTaskUpcomingBlocks;
  bool get isLoading => _isLoading;

  double get dayProgress {
    if (_tasksForDay.isEmpty) return 0;
    final completed = _tasksForDay.where((t) => t.isCompleted).length;
    return completed / _tasksForDay.length;
  }

  /// Idle windows of 60+ minutes between consecutive scheduled tasks —
  /// surfaced to the user as "you have free time here" warnings so gaps
  /// in the day's plan don't go unnoticed.
  List<TimeGap> get freeGaps {
    if (_tasksForDay.length < 2) return [];
    final sorted = [..._tasksForDay]..sort((a, b) => a.startTime.compareTo(b.startTime));
    final gaps = <TimeGap>[];
    for (var i = 0; i < sorted.length - 1; i++) {
      final gapStart = sorted[i].endTime;
      final gapEnd = sorted[i + 1].startTime;
      if (gapEnd.isAfter(gapStart) && gapEnd.difference(gapStart).inMinutes >= 60) {
        gaps.add(TimeGap(gapStart, gapEnd));
      }
    }
    return gaps;
  }

  Future<void> selectDay(DateTime day) async {
    _selectedDay = day;
    await loadTasksForSelectedDay();
  }

  Future<void> loadTasksForSelectedDay() async {
    _isLoading = true;
    notifyListeners();
    _tasksForDay = await _repository.getTasksForDay(_selectedDay);
    _incompleteFromPast = await _repository.getIncompleteTasksBefore(_selectedDay);
    _isLoading = false;
    notifyListeners();
  }

  /// Moves a stale, incomplete task from a past day onto the currently
  /// selected day so it doesn't just silently disappear from the plan.
  Future<void> rolloverToSelectedDay(TaskModel task) async {
    await _repository.rolloverTask(task, _selectedDay);
    await loadTasksForSelectedDay();
  }

  Future<void> refreshActiveTask() async {
    _activeTask = await _repository.getActiveTask();
    if (_activeTask != null) {
      _activeTaskUpcomingBlocks =
          await _repository.getUpcomingForCategory(_activeTask!.category);
    } else {
      _activeTaskUpcomingBlocks = [];
    }
    notifyListeners();
  }

  Future<void> addTask(TaskModel task) async {
    final id = await _repository.createTask(task);
    await NotificationService.instance
        .scheduleForTask(task.copyWith(id: id));
    await loadTasksForSelectedDay();
  }

  Future<void> updateTask(TaskModel task) async {
    await _repository.updateTask(task);
    if (task.id != null) {
      await NotificationService.instance.cancelForTask(task.id!);
      await NotificationService.instance.scheduleForTask(task);
    }
    await loadTasksForSelectedDay();
  }

  Future<void> deleteTask(int id) async {
    await _repository.deleteTask(id);
    await NotificationService.instance.cancelForTask(id);
    await loadTasksForSelectedDay();
  }

  Future<void> toggleCompleted(TaskModel task) async {
    await _repository.setCompleted(task.id!, !task.isCompleted);
    await loadTasksForSelectedDay();
  }
}
