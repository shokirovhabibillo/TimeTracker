import 'dart:convert';

import '../data/models/task_model.dart';

/// Packs/unpacks a day's tasks into a compact JSON payload suitable for
/// a QR code. Times are stored as minutes-from-midnight so the plan
/// re-anchors correctly onto whatever day the receiver imports it into.
class PlanShareService {
  static const _formatVersion = 1;

  static String encodeDayPlan(List<TaskModel> tasks, {String? planName}) {
    final payload = {
      'type': 'flt_day_plan',
      'v': _formatVersion,
      'name': planName ?? "Ulashilgan kun tartibi",
      'tasks': tasks
          .map((t) => {
                'title': t.title,
                'category': t.category,
                'color': t.colorCode,
                'startMin': t.startTime.hour * 60 + t.startTime.minute,
                'endMin': t.endTime.hour * 60 + t.endTime.minute,
                'recurring': t.isRecurring,
                'rule': t.recurrenceRule,
              })
          .toList(),
    };
    return jsonEncode(payload);
  }

  /// Returns null if [raw] isn't a recognizable plan payload (e.g. the
  /// user scanned an unrelated QR code).
  static List<TaskModel>? decodeDayPlan(String raw, {required DateTime targetDay}) {
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic> || json['type'] != 'flt_day_plan') return null;
      final tasksJson = json['tasks'] as List<dynamic>;
      return tasksJson.map((t) {
        final map = t as Map<String, dynamic>;
        final startMin = map['startMin'] as int;
        final endMin = map['endMin'] as int;
        final start = DateTime(targetDay.year, targetDay.month, targetDay.day, startMin ~/ 60, startMin % 60);
        var end = DateTime(targetDay.year, targetDay.month, targetDay.day, endMin ~/ 60, endMin % 60);
        if (!end.isAfter(start)) end = end.add(const Duration(days: 1));
        return TaskModel(
          title: map['title'] as String,
          category: map['category'] as String,
          colorCode: map['color'] as String,
          startTime: start,
          endTime: end,
          isRecurring: map['recurring'] as bool? ?? false,
          recurrenceRule: map['rule'] as String?,
        );
      }).toList();
    } catch (_) {
      return null;
    }
  }

  static String? planNameFrom(String raw) {
    try {
      final json = jsonDecode(raw);
      if (json is Map<String, dynamic> && json['type'] == 'flt_day_plan') {
        return json['name'] as String?;
      }
    } catch (_) {}
    return null;
  }
}
