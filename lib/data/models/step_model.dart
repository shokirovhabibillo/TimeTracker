/// One day's step baseline — Android's step-counter sensor reports a
/// cumulative count since last boot, so "today's steps" = latest
/// reading minus whatever the counter read at midnight.
///
/// [accumulatedOffset] handles a mid-day device reboot: when the raw
/// sensor count suddenly drops (reboot resets it to ~0), the steps
/// already counted before the reboot are "banked" into this offset so
/// they aren't lost — without it, a reboot partway through the day
/// would silently erase everything counted so far.
class StepLog {
  final int? id;
  final String date; // yyyy-MM-dd
  final int midnightBaseline;
  final int lastReading;
  final int accumulatedOffset;

  StepLog({
    this.id,
    required this.date,
    required this.midnightBaseline,
    required this.lastReading,
    this.accumulatedOffset = 0,
  });

  int get todaySteps => ((lastReading - midnightBaseline) + accumulatedOffset).clamp(0, 999999);
  double get todayDistanceMeters => todaySteps * 0.75; // average stride length

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date,
        'midnight_baseline': midnightBaseline,
        'last_reading': lastReading,
        'accumulated_offset': accumulatedOffset,
      };

  factory StepLog.fromMap(Map<String, dynamic> map) => StepLog(
        id: map['id'] as int?,
        date: map['date'] as String,
        midnightBaseline: map['midnight_baseline'] as int,
        lastReading: map['last_reading'] as int,
        accumulatedOffset: map['accumulated_offset'] as int? ?? 0,
      );
}
