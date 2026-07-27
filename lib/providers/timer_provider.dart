import 'dart:async';
import 'package:flutter/material.dart';

import '../data/models/focus_session_model.dart';
import '../data/models/task_model.dart';
import '../data/repositories/focus_session_repository.dart';

enum TimerMode { stopwatch, pomodoro }

enum TimerStatus { idle, running, paused, finished }

class TimerProvider extends ChangeNotifier {
  final FocusSessionRepository _sessionRepository = FocusSessionRepository();

  TimerMode mode = TimerMode.stopwatch;
  TimerStatus status = TimerStatus.idle;

  static const pomodoroFocusMinutes = 25;
  static const pomodoroBreakMinutes = 5;

  Duration elapsed = Duration.zero;
  Duration pomodoroRemaining = const Duration(minutes: pomodoroFocusMinutes);
  bool isPomodoroBreak = false;

  Timer? _ticker;
  TaskModel? _task;
  int? _sessionId;
  DateTime? _sessionStart;

  TaskModel? get task => _task;

  double get progressAgainstPlan {
    if (_task == null) return 0;
    final plannedSeconds = _task!.durationMinutes * 60;
    if (plannedSeconds <= 0) return 0;
    return (elapsed.inSeconds / plannedSeconds).clamp(0, 1).toDouble();
  }

  Future<void> start(TaskModel task, {TimerMode withMode = TimerMode.stopwatch}) async {
    _task = task;
    mode = withMode;
    elapsed = Duration.zero;
    pomodoroRemaining = const Duration(minutes: pomodoroFocusMinutes);
    isPomodoroBreak = false;
    status = TimerStatus.running;
    _sessionStart = DateTime.now();

    _sessionId = await _sessionRepository.startSession(
      FocusSessionModel(taskId: task.id!, actualStart: _sessionStart!),
    );

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void _tick() {
    elapsed += const Duration(seconds: 1);

    if (mode == TimerMode.pomodoro) {
      pomodoroRemaining -= const Duration(seconds: 1);
      if (pomodoroRemaining.inSeconds <= 0) {
        isPomodoroBreak = !isPomodoroBreak;
        pomodoroRemaining = Duration(
            minutes: isPomodoroBreak ? pomodoroBreakMinutes : pomodoroFocusMinutes);
      }
    }
    notifyListeners();
  }

  void pause() {
    if (status != TimerStatus.running) return;
    _ticker?.cancel();
    status = TimerStatus.paused;
    notifyListeners();
  }

  void resume() {
    if (status != TimerStatus.paused) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    status = TimerStatus.running;
    notifyListeners();
  }

  Future<void> stop({bool markCompleted = false}) async {
    _ticker?.cancel();
    status = TimerStatus.finished;

    if (_sessionId != null && _task != null) {
      final plannedSeconds = _task!.durationMinutes * 60;
      final pct = plannedSeconds > 0
          ? (elapsed.inSeconds / plannedSeconds * 100).clamp(0, 100).toDouble()
          : 0.0;
      await _sessionRepository.endSession(
        _sessionId!,
        actualEnd: DateTime.now(),
        completedDurationSeconds: elapsed.inSeconds,
        completionPercentage: pct,
      );
    }
    notifyListeners();
  }

  void reset() {
    _ticker?.cancel();
    status = TimerStatus.idle;
    elapsed = Duration.zero;
    pomodoroRemaining = const Duration(minutes: pomodoroFocusMinutes);
    isPomodoroBreak = false;
    _task = null;
    _sessionId = null;
    notifyListeners();
  }

  String get formattedElapsed {
    final h = elapsed.inHours.toString().padLeft(2, '0');
    final m = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final s = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return h == '00' ? '$m:$s' : '$h:$m:$s';
  }

  String get formattedPomodoro {
    final m = pomodoroRemaining.inMinutes.toString().padLeft(2, '0');
    final s = (pomodoroRemaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
