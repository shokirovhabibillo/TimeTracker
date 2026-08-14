import '../data/models/task_model.dart';

class TimeGap {
  final DateTime start;
  final DateTime end;
  const TimeGap(this.start, this.end);
  Duration get duration => end.difference(start);
}

/// Merges overlapping/nested task intervals first (e.g. a short break
/// nested inside a long work block), then returns the idle windows of
/// 60+ minutes between what's left — the "bo'sh vaqtlar" shown in the
/// Planner and used to suggest IDP scheduling slots.
List<TimeGap> computeFreeGaps(List<TaskModel> tasks) {
  // Passenger-mode transport time isn't "busy" in the usual sense — the
  // user explicitly said they're not driving, so it's available for
  // reading/study/audio lessons and should still show up as free time.
  final busyTasks = tasks.where((t) => !t.isPassengerTransport).toList();
  if (busyTasks.length < 2) return [];
  final sorted = [...busyTasks]..sort((a, b) => a.startTime.compareTo(b.startTime));

  final busy = <TimeGap>[];
  for (final t in sorted) {
    if (busy.isEmpty) {
      busy.add(TimeGap(t.startTime, t.endTime));
      continue;
    }
    final last = busy.last;
    if (!t.startTime.isAfter(last.end)) {
      if (t.endTime.isAfter(last.end)) {
        busy[busy.length - 1] = TimeGap(last.start, t.endTime);
      }
    } else {
      busy.add(TimeGap(t.startTime, t.endTime));
    }
  }

  final gaps = <TimeGap>[];
  for (var i = 0; i < busy.length - 1; i++) {
    final gapStart = busy[i].end;
    final gapEnd = busy[i + 1].start;
    if (gapEnd.difference(gapStart).inMinutes >= 60) {
      gaps.add(TimeGap(gapStart, gapEnd));
    }
  }
  return gaps;
}
