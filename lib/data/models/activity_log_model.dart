class AppActivityType {
  static const walking = 'walking';
  static const running = 'running';
  static const cycling = 'cycling';
  static const vehicle = 'vehicle';
  static const still = 'still';

  static String label(String t) {
    switch (t) {
      case walking:
        return "Piyoda";
      case running:
        return "Yugurish";
      case cycling:
        return "Velosipedda";
      case vehicle:
        return "Avtomobilda";
      default:
        return "Harakatsiz";
    }
  }

  // Rough average speeds (km/h) used only to *estimate* distance for
  // modes we can't measure precisely without GPS (cycling/vehicle).
  // Walking/running distance instead comes from the accurate
  // steps × stride-length calculation.
  static double approxSpeedKmh(String t) {
    switch (t) {
      case cycling:
        return 15;
      case vehicle:
        return 35; // shahar ichi o'rtacha tezlik taxmini
      default:
        return 0;
    }
  }
}

/// One day's snapshot: steps, active minutes, calories, and seconds
/// spent in each detected activity mode.
class DailyActivityLog {
  final String date; // yyyy-MM-dd
  final int steps;
  final int activityMinutes;
  final int calories;
  final Map<String, int> secondsByActivity; // ActivityType -> seconds

  DailyActivityLog({
    required this.date,
    this.steps = 0,
    this.activityMinutes = 0,
    this.calories = 0,
    this.secondsByActivity = const {},
  });

  double distanceForKm(String type) {
    if (type == AppActivityType.walking || type == AppActivityType.running) {
      // Handled precisely elsewhere via steps; not derived from time here.
      return 0;
    }
    final seconds = secondsByActivity[type] ?? 0;
    return (seconds / 3600) * AppActivityType.approxSpeedKmh(type);
  }
}
