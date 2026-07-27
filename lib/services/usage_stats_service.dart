import 'dart:io';
import 'package:usage_stats/usage_stats.dart';

import '../data/models/app_usage_model.dart';
import '../data/repositories/usage_repository.dart';

/// Bridges native OS "Screen Time" data into our local database.
///
/// Android: uses the `usage_stats` plugin, a thin wrapper around
/// `UsageStatsManager`. Requires the special "Usage Access" permission
/// (granted manually by the user in system settings — cannot be
/// requested via a normal runtime permission dialog).
///
/// iOS: Apple's DeviceActivity / Screen Time API (introduced in iOS 15)
/// requires a dedicated App Extension target written in Swift and a
/// Family Controls entitlement from Apple. That native extension can't
/// be generated as pure Dart — this class exposes the same interface
/// and falls back to an empty/manual-entry mode on iOS so the rest of
/// the app (planner, focus mode, theming) works fully. See
/// `ios/DeviceActivityExtension/README.md` for the native scaffold notes.
class UsageStatsService {
  final UsageRepository _usageRepository = UsageRepository();

  bool get isNativeSupported => Platform.isAndroid;

  Future<bool> hasPermission() async {
    if (!Platform.isAndroid) return false;
    final granted = await UsageStats.checkUsagePermission();
    return granted ?? false;
  }

  /// Opens the system "Usage Access" settings screen so the user can
  /// grant permission (Android does not allow a normal runtime prompt).
  Future<void> requestPermission() async {
    if (!Platform.isAndroid) return;
    await UsageStats.grantUsagePermission();
  }

  /// Categorization table for common package names. In production this
  /// would be backed by a remote-config list or the Play Store category
  /// of each package; kept local + editable here for simplicity.
  static const Map<String, String> _knownCategories = {
    'com.instagram.android': AppCategory.social,
    'com.zhiliaoapp.musically': AppCategory.social, // TikTok
    'com.facebook.katana': AppCategory.social,
    'com.twitter.android': AppCategory.social,
    'com.google.android.youtube': AppCategory.entertainment,
    'com.netflix.mediaclient': AppCategory.entertainment,
    'com.supercell.clashofclans': AppCategory.games,
    'com.king.candycrushsaga': AppCategory.games,
    'com.google.android.apps.docs': AppCategory.productivity,
    'com.microsoft.office.outlook': AppCategory.productivity,
    'com.slack': AppCategory.productivity,
  };

  static const Set<String> _distractingCategories = {
    AppCategory.social,
    AppCategory.games,
    AppCategory.entertainment,
  };

  String categoryFor(String packageName) =>
      _knownCategories[packageName] ?? AppCategory.other;

  /// Pulls today's per-app foreground time from Android's UsageStatsManager
  /// and persists it into `app_usage_logs`.
  Future<List<AppUsageModel>> syncTodayUsage() async {
    if (!Platform.isAndroid) return [];

    final hasAccess = await hasPermission();
    if (!hasAccess) return [];

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final stats = await UsageStats.queryUsageStats(startOfDay, now);

    final results = <AppUsageModel>[];
    for (final stat in stats) {
      final pkg = stat.packageName ?? 'unknown';
      final totalMs = stat.totalTimeInForegroundMs ?? 0;
      if (totalMs <= 0) continue;

      final category = categoryFor(pkg);
      final usage = AppUsageModel(
        packageName: pkg,
        appName: pkg.split('.').last,
        appCategory: category,
        timeSpentSeconds: totalMs ~/ 1000,
        logDate: startOfDay,
        isDistracting: _distractingCategories.contains(category),
      );
      await _usageRepository.upsertDailyUsage(usage);
      results.add(usage);
    }
    return results;
  }

  /// Returns true if today's distracting-app time already exceeds the
  /// user's configured daily limit — used to trigger a focus warning.
  Future<bool> exceedsDistractionLimit(int limitMinutes) async {
    final seconds =
        await _usageRepository.getDistractingSecondsForDay(DateTime.now());
    return seconds >= limitMinutes * 60;
  }
}
