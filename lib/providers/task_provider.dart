import 'package:flutter/material.dart';

import '../config/supabase_config.dart';
import '../data/models/medicine_model.dart';
import '../data/models/project_model.dart';
import '../data/models/task_model.dart';
import '../data/repositories/medicine_repository.dart';
import '../data/repositories/task_repository.dart';
import '../services/notification_service.dart';
import '../services/project_service.dart';
import '../utils/schedule_utils.dart';

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

  /// Today's cross-system reminders — unfinished medicine doses and any
  /// project-task deadlines landing today — so the Reja screen isn't
  /// blind to what's happening in the Medicine and Project modules.
  Future<({List<String> medicineTimes, List<String> projectDeadlines})> loadTodayCrossSystemReminders(
      String deviceId) async {
    final medicineRepo = MedicineRepository();
    final today = DateTime.now();
    final activeMeds = await medicineRepo.getActiveMedicinesForDay(today);
    final takenKeys = await medicineRepo.getTakenDoseKeys(today);
    final medicineTimes = <String>[];
    for (final m in activeMeds) {
      for (final t in m.times) {
        if (!takenKeys.contains('${m.id}_$t')) medicineTimes.add('${m.name} ($t)');
      }
    }
    medicineTimes.sort();

    final projectDeadlines = <String>[];
    if (SupabaseConfig.isConfigured && deviceId.isNotEmpty) {
      try {
        final projects = await ProjectService.instance.getMyProjects(deviceId);
        for (final p in projects) {
          final tasks = await ProjectService.instance.getTasks(p.id);
          for (final t in tasks) {
            if (t.status != ProjectTaskStatus.done &&
                t.deadline != null &&
                t.deadline!.year == today.year &&
                t.deadline!.month == today.month &&
                t.deadline!.day == today.day) {
              projectDeadlines.add('${p.name}: ${t.title}');
            }
          }
        }
      } catch (_) {
        // Offline or Supabase unreachable — just skip, not critical.
      }
    }
    return (medicineTimes: medicineTimes, projectDeadlines: projectDeadlines);
  }

  /// Idle windows of 60+ minutes between consecutive scheduled tasks —
  /// surfaced to the user as "you have free time here" warnings so gaps
  /// in the day's plan don't go unnoticed.
  ///
  /// Overlapping/nested tasks (e.g. a 10-minute "Tanaffus" sitting inside
  /// an 08:00-17:50 "Ish" block) are merged into a single busy interval
  /// first — otherwise the nested task's end time would be mistaken for
  /// the end of all activity, and the still-ongoing outer task's
  /// remaining time would be misreported as "free".
  List<TimeGap> get freeGaps => computeFreeGaps(_tasksForDay);

  /// Each category's share of today's scheduled time, by duration —
  /// feeds the big donut chart at the top of the Analytics screen.
  Map<String, Duration> get categoryBreakdown {
    final map = <String, Duration>{};
    for (final t in _tasksForDay) {
      map[t.category] = (map[t.category] ?? Duration.zero) + t.endTime.difference(t.startTime);
    }
    return map;
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
    final saved = task.copyWith(id: id);
    await NotificationService.instance.scheduleForTask(saved);
    await NotificationService.instance.scheduleMotivationForTask(saved);
    await loadTasksForSelectedDay();
  }

  Future<void> updateTask(TaskModel task) async {
    await _repository.updateTask(task);
    if (task.id != null) {
      await NotificationService.instance.cancelForTask(task.id!);
      await NotificationService.instance.cancelMotivationForTask(task.id!);
      await NotificationService.instance.scheduleForTask(task);
      await NotificationService.instance.scheduleMotivationForTask(task);
    }
    await loadTasksForSelectedDay();
  }

  Future<void> deleteTask(int id) async {
    await _repository.deleteTask(id);
    await NotificationService.instance.cancelForTask(id);
    await NotificationService.instance.cancelMotivationForTask(id);
    await loadTasksForSelectedDay();
  }

  Future<void> toggleCompleted(TaskModel task) async {
    await _repository.setCompleted(task.id!, !task.isCompleted);
    await loadTasksForSelectedDay();
  }

  Future<void> setTaskCompletionStatus(TaskModel task, String status) async {
    await _repository.setCompletionStatusForDate(
      task.id!,
      DateTime(task.startTime.year, task.startTime.month, task.startTime.day),
      status,
      isRecurring: task.isRecurring,
    );
    await loadTasksForSelectedDay();
  }
}
