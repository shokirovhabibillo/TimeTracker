/// Represents a single row in the `tasks` table.
/// Covers scheduled tasks, sleep intervals, meal breaks and habits —
/// they're all just Tasks distinguished by `category`.
class TaskCategory {
  static const work = 'work';
  static const study = 'study';
  static const meal = 'meal';
  static const sleep = 'sleep';
  static const habit = 'habit';
  static const custom = 'custom';

  static const all = [work, study, meal, sleep, habit, custom];

  static String label(String category) {
    switch (category) {
      case work:
        return 'Ish';
      case study:
        return "O'qish";
      case meal:
        return 'Ovqatlanish';
      case sleep:
        return 'Uyqu';
      case habit:
        return 'Odat';
      default:
        return 'Boshqa';
    }
  }
}

class TaskModel {
  final int? id;
  final String title;
  final String category;
  final String colorCode; // HEX, e.g. #00F0FF
  final DateTime startTime;
  final DateTime endTime;
  final bool isRecurring;
  final String? recurrenceRule; // "DAILY" | "WEEKLY:MON,WED,FRI"
  final int notificationOffsetMin;
  final bool isCompleted;

  TaskModel({
    this.id,
    required this.title,
    required this.category,
    required this.colorCode,
    required this.startTime,
    required this.endTime,
    this.isRecurring = false,
    this.recurrenceRule,
    this.notificationOffsetMin = 10,
    this.isCompleted = false,
  });

  int get durationMinutes => endTime.difference(startTime).inMinutes;

  TaskModel copyWith({
    int? id,
    String? title,
    String? category,
    String? colorCode,
    DateTime? startTime,
    DateTime? endTime,
    bool? isRecurring,
    String? recurrenceRule,
    int? notificationOffsetMin,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      colorCode: colorCode ?? this.colorCode,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      notificationOffsetMin: notificationOffsetMin ?? this.notificationOffsetMin,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'color_code': colorCode,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'duration_minutes': durationMinutes,
      'is_recurring': isRecurring ? 1 : 0,
      'recurrence_rule': recurrenceRule,
      'notification_offset_min': notificationOffsetMin,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      category: map['category'] as String,
      colorCode: map['color_code'] as String,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: DateTime.parse(map['end_time'] as String),
      isRecurring: (map['is_recurring'] as int) == 1,
      recurrenceRule: map['recurrence_rule'] as String?,
      notificationOffsetMin: map['notification_offset_min'] as int? ?? 10,
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
    );
  }
}
