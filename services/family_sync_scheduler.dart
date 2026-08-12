import 'dart:async';

import '../data/models/family_link_model.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/task_repository.dart';
import 'family_link_service.dart';

/// Runs quietly in the background on the child's device — every couple
/// of minutes, pushes today's plan up to Supabase so a linked parent
/// can see it. No-ops entirely if the device's role isn't "child".
class FamilySyncScheduler {
  static final FamilySyncScheduler instance = FamilySyncScheduler._();
  FamilySyncScheduler._();

  Timer? _timer;
  final _settingsRepository = SettingsRepository();
  final _taskRepository = TaskRepository();

  void start() {
    _syncOnce();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 2), (_) => _syncOnce());
  }

  Future<void> _syncOnce() async {
    try {
      final settings = await _settingsRepository.getSettings();
      if (settings.familyRole != DeviceRole.child || settings.deviceId.isEmpty) return;

      final today = DateTime.now();
      final tasks = await _taskRepository.getTasksForDay(today);
      if (tasks.isEmpty) return;
      final completed = tasks.where((t) => t.isCompleted).length;
      final progress = completed / tasks.length;

      await FamilyLinkService.instance.pushSnapshot(
        childDeviceId: settings.deviceId,
        day: today,
        tasks: tasks,
        dayProgress: progress,
      );
    } catch (_) {
      // Offline or Supabase unreachable — silently skip this cycle,
      // will retry on the next timer tick.
    }
  }

  void dispose() => _timer?.cancel();
}
