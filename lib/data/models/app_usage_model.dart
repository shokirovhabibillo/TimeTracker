class AppCategory {
  static const social = 'social';
  static const games = 'games';
  static const entertainment = 'entertainment';
  static const productivity = 'productivity';
  static const other = 'other';
}

/// Row in `app_usage_logs`.
class AppUsageModel {
  final int? id;
  final String packageName;
  final String appName;
  final String appCategory;
  final int timeSpentSeconds;
  final DateTime logDate;
  final bool isDistracting;

  AppUsageModel({
    this.id,
    required this.packageName,
    required this.appName,
    required this.appCategory,
    required this.timeSpentSeconds,
    required this.logDate,
    this.isDistracting = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'package_name': packageName,
      'app_name': appName,
      'app_category': appCategory,
      'time_spent_seconds': timeSpentSeconds,
      'log_date':
          '${logDate.year.toString().padLeft(4, '0')}-${logDate.month.toString().padLeft(2, '0')}-${logDate.day.toString().padLeft(2, '0')}',
      'is_distracting': isDistracting ? 1 : 0,
    };
  }

  factory AppUsageModel.fromMap(Map<String, dynamic> map) {
    return AppUsageModel(
      id: map['id'] as int?,
      packageName: map['package_name'] as String,
      appName: map['app_name'] as String? ?? map['package_name'] as String,
      appCategory: map['app_category'] as String,
      timeSpentSeconds: map['time_spent_seconds'] as int,
      logDate: DateTime.parse(map['log_date'] as String),
      isDistracting: (map['is_distracting'] as int? ?? 0) == 1,
    );
  }
}

/// Row in `users_settings`. Single-row table (id = 1) holding
/// theme + ambient sound + sleep window preferences.
class UserSettingsModel {
  final int id;
  final String themeType; // "classic" | "hightech"
  final String? ambientSound;
  final String sleepStartTime; // "HH:mm"
  final String sleepEndTime; // "HH:mm"
  final int dailyDistractionLimitMin;

  UserSettingsModel({
    this.id = 1,
    this.themeType = 'hightech',
    this.ambientSound,
    this.sleepStartTime = '23:00',
    this.sleepEndTime = '07:00',
    this.dailyDistractionLimitMin = 90,
  });

  UserSettingsModel copyWith({
    String? themeType,
    String? ambientSound,
    String? sleepStartTime,
    String? sleepEndTime,
    int? dailyDistractionLimitMin,
  }) {
    return UserSettingsModel(
      id: id,
      themeType: themeType ?? this.themeType,
      ambientSound: ambientSound ?? this.ambientSound,
      sleepStartTime: sleepStartTime ?? this.sleepStartTime,
      sleepEndTime: sleepEndTime ?? this.sleepEndTime,
      dailyDistractionLimitMin:
          dailyDistractionLimitMin ?? this.dailyDistractionLimitMin,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'theme_type': themeType,
      'ambient_sound': ambientSound,
      'sleep_start_time': sleepStartTime,
      'sleep_end_time': sleepEndTime,
      'daily_distraction_limit_min': dailyDistractionLimitMin,
    };
  }

  factory UserSettingsModel.fromMap(Map<String, dynamic> map) {
    return UserSettingsModel(
      id: map['id'] as int? ?? 1,
      themeType: map['theme_type'] as String? ?? 'hightech',
      ambientSound: map['ambient_sound'] as String?,
      sleepStartTime: map['sleep_start_time'] as String? ?? '23:00',
      sleepEndTime: map['sleep_end_time'] as String? ?? '07:00',
      dailyDistractionLimitMin:
          map['daily_distraction_limit_min'] as int? ?? 90,
    );
  }
}
