import 'family_link_model.dart';

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
  final String themeType; // ThemeSpec.id, e.g. "youth_neon_hud"
  final String? ambientSound;
  final String sleepStartTime; // "HH:mm"
  final String sleepEndTime; // "HH:mm"
  final int dailyDistractionLimitMin;
  final String clockStyle; // "analog" | "digital"
  final String timerStyle; // "ring" | "big_digits"
  final String calendarStyle; // "timeline" | "list"
  final String backgroundPattern; // BackgroundPatternType.name
  final bool hasSeenOnboarding;
  final double fontScale;
  final String deviceId;
  final String familyRole; // DeviceRole: none | parent | child
  final String? linkedChildDeviceId; // set on the parent's device once linked
  final String? childDisplayName; // set on the child's device (shown to parent)
  final String buttonStyle; // 'normal' | 'glass' | 'liquid_glass' | 'ornate'
  final String locale; // 'uz' | 'ru' | 'en'
  final String visualizationMode; // 'smartphone' | 'smartwatch'

  UserSettingsModel({
    this.id = 1,
    this.themeType = 'youth_neon_hud',
    this.ambientSound,
    this.sleepStartTime = '23:00',
    this.sleepEndTime = '07:00',
    this.dailyDistractionLimitMin = 90,
    this.clockStyle = 'analog',
    this.timerStyle = 'ring',
    this.calendarStyle = 'timeline',
    this.backgroundPattern = 'none',
    this.hasSeenOnboarding = false,
    this.fontScale = 1.0,
    this.deviceId = '',
    this.familyRole = DeviceRole.none,
    this.linkedChildDeviceId,
    this.childDisplayName,
    this.buttonStyle = 'normal',
    this.locale = 'uz',
    this.visualizationMode = 'smartphone',
  });

  UserSettingsModel copyWith({
    String? themeType,
    String? ambientSound,
    String? sleepStartTime,
    String? sleepEndTime,
    int? dailyDistractionLimitMin,
    String? clockStyle,
    String? timerStyle,
    String? calendarStyle,
    String? backgroundPattern,
    bool? hasSeenOnboarding,
    double? fontScale,
    String? deviceId,
    String? familyRole,
    String? linkedChildDeviceId,
    String? childDisplayName,
    String? buttonStyle,
    String? locale,
    String? visualizationMode,
  }) {
    return UserSettingsModel(
      id: id,
      themeType: themeType ?? this.themeType,
      ambientSound: ambientSound ?? this.ambientSound,
      sleepStartTime: sleepStartTime ?? this.sleepStartTime,
      sleepEndTime: sleepEndTime ?? this.sleepEndTime,
      dailyDistractionLimitMin:
          dailyDistractionLimitMin ?? this.dailyDistractionLimitMin,
      clockStyle: clockStyle ?? this.clockStyle,
      timerStyle: timerStyle ?? this.timerStyle,
      calendarStyle: calendarStyle ?? this.calendarStyle,
      backgroundPattern: backgroundPattern ?? this.backgroundPattern,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      fontScale: fontScale ?? this.fontScale,
      deviceId: deviceId ?? this.deviceId,
      familyRole: familyRole ?? this.familyRole,
      linkedChildDeviceId: linkedChildDeviceId ?? this.linkedChildDeviceId,
      childDisplayName: childDisplayName ?? this.childDisplayName,
      buttonStyle: buttonStyle ?? this.buttonStyle,
      locale: locale ?? this.locale,
      visualizationMode: visualizationMode ?? this.visualizationMode,
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
      'clock_style': clockStyle,
      'timer_style': timerStyle,
      'calendar_style': calendarStyle,
      'background_pattern': backgroundPattern,
      'has_seen_onboarding': hasSeenOnboarding ? 1 : 0,
      'font_scale': fontScale,
      'device_id': deviceId,
      'family_role': familyRole,
      'linked_child_device_id': linkedChildDeviceId,
      'child_display_name': childDisplayName,
      'button_style': buttonStyle,
      'locale': locale,
      'visualization_mode': visualizationMode,
    };
  }

  factory UserSettingsModel.fromMap(Map<String, dynamic> map) {
    return UserSettingsModel(
      id: map['id'] as int? ?? 1,
      themeType: map['theme_type'] as String? ?? 'youth_neon_hud',
      ambientSound: map['ambient_sound'] as String?,
      sleepStartTime: map['sleep_start_time'] as String? ?? '23:00',
      sleepEndTime: map['sleep_end_time'] as String? ?? '07:00',
      dailyDistractionLimitMin:
          map['daily_distraction_limit_min'] as int? ?? 90,
      clockStyle: map['clock_style'] as String? ?? 'analog',
      timerStyle: map['timer_style'] as String? ?? 'ring',
      calendarStyle: map['calendar_style'] as String? ?? 'timeline',
      backgroundPattern: map['background_pattern'] as String? ?? 'none',
      hasSeenOnboarding: (map['has_seen_onboarding'] as int? ?? 0) == 1,
      fontScale: (map['font_scale'] as num?)?.toDouble() ?? 1.0,
      deviceId: map['device_id'] as String? ?? '',
      familyRole: map['family_role'] as String? ?? DeviceRole.none,
      linkedChildDeviceId: map['linked_child_device_id'] as String?,
      childDisplayName: map['child_display_name'] as String?,
      buttonStyle: map['button_style'] as String? ?? 'normal',
      locale: map['locale'] as String? ?? 'uz',
      visualizationMode: map['visualization_mode'] as String? ?? 'smartphone',
    );
  }
}
