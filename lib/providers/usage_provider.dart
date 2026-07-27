import 'package:flutter/material.dart';

import '../data/models/app_usage_model.dart';
import '../data/repositories/usage_repository.dart';
import '../services/notification_service.dart';
import '../services/usage_stats_service.dart';

class UsageProvider extends ChangeNotifier {
  final UsageStatsService _usageStatsService = UsageStatsService();
  final UsageRepository _usageRepository = UsageRepository();

  List<AppUsageModel> _todayUsage = [];
  bool _hasPermission = false;
  bool get isNativeSupported => _usageStatsService.isNativeSupported;
  bool get hasPermission => _hasPermission;
  List<AppUsageModel> get todayUsage => _todayUsage;

  int get totalDistractingSeconds => _todayUsage
      .where((u) => u.isDistracting)
      .fold(0, (sum, u) => sum + u.timeSpentSeconds);

  Map<String, int> get secondsByCategory {
    final map = <String, int>{};
    for (final u in _todayUsage) {
      map[u.appCategory] = (map[u.appCategory] ?? 0) + u.timeSpentSeconds;
    }
    return map;
  }

  Future<void> checkPermission() async {
    _hasPermission = await _usageStatsService.hasPermission();
    notifyListeners();
  }

  Future<void> requestPermission() async {
    await _usageStatsService.requestPermission();
    await checkPermission();
  }

  Future<void> refresh() async {
    await _usageStatsService.syncTodayUsage();
    _todayUsage = await _usageRepository.getUsageForDay(DateTime.now());
    notifyListeners();
  }

  /// Compares today's distracting-app time against the configured limit
  /// and fires a local notification warning if it's exceeded.
  Future<void> checkAndWarnIfOverLimit(int limitMinutes) async {
    final exceeded =
        await _usageStatsService.exceedsDistractionLimit(limitMinutes);
    if (exceeded) {
      final minutesUsed = totalDistractingSeconds ~/ 60;
      await NotificationService.instance.showFocusWarning(
        "Bugun chalg'ituvchi ilovalarda $minutesUsed daqiqa sarfladingiz — "
        "belgilangan limit $limitMinutes daqiqa edi.",
      );
    }
  }
}
