class StrategyLevel {
  static const asr = 'asr';
  static const decade = 'decade';
  static const year = 'year';
  static const month = 'month';
  static const week = 'week';
  static const day = 'day';

  /// What comes below [level] when drilling in — null for the leaf.
  static String? childOf(String level) {
    switch (level) {
      case asr:
        return decade;
      case decade:
        return year;
      case year:
        return month;
      case month:
        return week;
      case week:
        return day;
      default:
        return null;
    }
  }

  static String label(String level) {
    switch (level) {
      case asr:
        return '100 yillik ASR';
      case decade:
        return "O'n yillik";
      case year:
        return 'Yillik';
      case month:
        return 'Oylik';
      case week:
        return 'Haftalik';
      case day:
        return 'Kunlik';
      default:
        return level;
    }
  }
}

class StrategicGoal {
  final int? id;
  final int? parentId;
  final String level;
  final int position; // 1..5
  final String title;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final String status; // 'active' | 'done' | 'abandoned'
  final int? linkedTaskId;
  final DateTime createdAt;

  StrategicGoal({
    this.id,
    this.parentId,
    required this.level,
    required this.position,
    required this.title,
    this.periodStart,
    this.periodEnd,
    this.status = 'active',
    this.linkedTaskId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isDone => status == 'done';

  Map<String, dynamic> toMap() => {
        'id': id,
        'parent_id': parentId,
        'level': level,
        'position': position,
        'title': title,
        'period_start': periodStart?.toIso8601String(),
        'period_end': periodEnd?.toIso8601String(),
        'status': status,
        'linked_task_id': linkedTaskId,
        'created_at': createdAt.toIso8601String(),
      };

  factory StrategicGoal.fromMap(Map<String, dynamic> map) => StrategicGoal(
        id: map['id'] as int?,
        parentId: map['parent_id'] as int?,
        level: map['level'] as String,
        position: map['position'] as int,
        title: map['title'] as String,
        periodStart: map['period_start'] != null ? DateTime.parse(map['period_start'] as String) : null,
        periodEnd: map['period_end'] != null ? DateTime.parse(map['period_end'] as String) : null,
        status: map['status'] as String? ?? 'active',
        linkedTaskId: map['linked_task_id'] as int?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
