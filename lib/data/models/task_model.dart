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
  static const laborLeave = 'labor_leave';
  static const privilegedLeave = 'privileged_leave';
  static const annualLeave = 'annual_leave';
  static const idpDevelopment = 'idp_development';
  static const transport = 'transport';

  static const all = [
    work, study, meal, sleep, habit,
    laborLeave, privilegedLeave, annualLeave,
    idpDevelopment, transport,
    custom,
  ];

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
      case laborLeave:
        return 'Mehnat ta\'tili';
      case privilegedLeave:
        return 'Imtiyozli ta\'til';
      case annualLeave:
        return 'Yillik ta\'til (staj)';
      case idpDevelopment:
        return 'Rivojlanish rejasi (IDP)';
      case transport:
        return 'Transport / Yo\'lda';
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
  final int rolledOverCount;
  final String? completionStatus; // 'on_time' | 'late' | 'postponed'
  final DateTime? recurrenceEndDate;
  final bool isPassengerTransport; // Transport category: true = riding as a passenger (free to do other things)

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
    this.rolledOverCount = 0,
    this.completionStatus,
    this.recurrenceEndDate,
    this.isPassengerTransport = false,
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
    int? rolledOverCount,
    String? completionStatus,
    DateTime? recurrenceEndDate,
    bool clearRecurrenceEndDate = false,
    bool? isPassengerTransport,
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
      rolledOverCount: rolledOverCount ?? this.rolledOverCount,
      completionStatus: completionStatus ?? this.completionStatus,
      recurrenceEndDate:
          clearRecurrenceEndDate ? null : (recurrenceEndDate ?? this.recurrenceEndDate),
      isPassengerTransport: isPassengerTransport ?? this.isPassengerTransport,
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
      'rolled_over_count': rolledOverCount,
      'completion_status': completionStatus,
      'recurrence_end_date': recurrenceEndDate?.toIso8601String(),
      'is_passenger_transport': isPassengerTransport ? 1 : 0,
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
      rolledOverCount: map['rolled_over_count'] as int? ?? 0,
      completionStatus: map['completion_status'] as String?,
      recurrenceEndDate: map['recurrence_end_date'] != null
          ? DateTime.parse(map['recurrence_end_date'] as String)
          : null,
      isPassengerTransport: (map['is_passenger_transport'] as int? ?? 0) == 1,
    );
  }
}
