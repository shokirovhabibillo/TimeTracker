/// One day's step baseline — Android's step-counter sensor reports a
/// cumulative count since last boot, so "today's steps" = latest
/// reading minus whatever the counter read at midnight.
class StepLog {
  final int? id;
  final String date; // yyyy-MM-dd
  final int midnightBaseline;
  final int lastReading;

  StepLog({this.id, required this.date, required this.midnightBaseline, required this.lastReading});

  int get todaySteps => (lastReading - midnightBaseline).clamp(0, 999999);
  double get todayDistanceMeters => todaySteps * 0.75; // average stride length

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date,
        'midnight_baseline': midnightBaseline,
        'last_reading': lastReading,
      };

  factory StepLog.fromMap(Map<String, dynamic> map) => StepLog(
        id: map['id'] as int?,
        date: map['date'] as String,
        midnightBaseline: map['midnight_baseline'] as int,
        lastReading: map['last_reading'] as int,
      );
}

/// A single tracked-walk session — the sequence of GPS points sampled
/// while the Route screen was open, used to draw the "shape" of the
/// walk and compute its distance.
class RouteSession {
  final int? id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double distanceMeters;
  final List<({double lat, double lng})> points;

  RouteSession({
    this.id,
    required this.startedAt,
    this.endedAt,
    this.distanceMeters = 0,
    this.points = const [],
  });
}
