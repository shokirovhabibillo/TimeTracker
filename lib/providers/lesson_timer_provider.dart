import 'dart:async';
import 'package:flutter/material.dart';

import '../data/models/lesson_plan_model.dart';
import '../data/repositories/lesson_session_repository.dart';

enum LessonTimerStatus { idle, running, paused, finished }

class LessonTimerProvider extends ChangeNotifier {
  LessonPlanModel? plan;
  int currentIndex = 0;
  Duration elapsedInSegment = Duration.zero;
  LessonTimerStatus status = LessonTimerStatus.idle;

  final _sessionRepository = LessonSessionRepository();
  int? _sessionLogId;

  Timer? _ticker;

  LessonSegment? get currentSegment =>
      (plan == null || currentIndex >= plan!.segments.length) ? null : plan!.segments[currentIndex];

  Duration get totalPlanned => Duration(minutes: plan?.totalMinutes ?? 0);

  Duration get totalElapsed {
    if (plan == null) return Duration.zero;
    final completedMinutes =
        plan!.segments.take(currentIndex).fold<int>(0, (sum, s) => sum + s.durationMinutes);
    return Duration(minutes: completedMinutes) + elapsedInSegment;
  }

  void start(LessonPlanModel lessonPlan) {
    plan = lessonPlan;
    currentIndex = 0;
    elapsedInSegment = Duration.zero;
    status = LessonTimerStatus.running;
    _startTicker();
    _sessionLogId = null;
    _sessionRepository.startSession(lessonPlan.domain, lessonPlan.name).then((id) => _sessionLogId = id);
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final segment = currentSegment;
    if (segment == null) return;
    elapsedInSegment += const Duration(seconds: 1);
    if (elapsedInSegment.inSeconds >= segment.durationMinutes * 60) {
      _advance();
    } else {
      notifyListeners();
    }
  }

  void _advance() {
    if (plan == null) return;
    if (currentIndex < plan!.segments.length - 1) {
      currentIndex++;
      elapsedInSegment = Duration.zero;
    } else {
      status = LessonTimerStatus.finished;
      _ticker?.cancel();
      if (_sessionLogId != null) {
        _sessionRepository.endSession(_sessionLogId!, totalElapsed.inSeconds);
      }
    }
    notifyListeners();
  }

  void skipToNext() => _advance();

  void pause() {
    if (status != LessonTimerStatus.running) return;
    _ticker?.cancel();
    status = LessonTimerStatus.paused;
    notifyListeners();
  }

  void resume() {
    if (status != LessonTimerStatus.paused) return;
    status = LessonTimerStatus.running;
    _startTicker();
    notifyListeners();
  }

  void stop() {
    _ticker?.cancel();
    if (_sessionLogId != null && status != LessonTimerStatus.finished) {
      // Stopped early — still bank the time spent as real usage for
      // that day, rather than losing it just because the plan wasn't
      // finished in full.
      _sessionRepository.endSession(_sessionLogId!, totalElapsed.inSeconds);
    }
    _sessionLogId = null;
    status = LessonTimerStatus.idle;
    plan = null;
    currentIndex = 0;
    elapsedInSegment = Duration.zero;
    notifyListeners();
  }

  String get formattedRemainingInSegment {
    final segment = currentSegment;
    if (segment == null) return '00:00';
    final remaining = Duration(minutes: segment.durationMinutes) - elapsedInSegment;
    final clamped = remaining.isNegative ? Duration.zero : remaining;
    final m = clamped.inMinutes.toString().padLeft(2, '0');
    final s = (clamped.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
