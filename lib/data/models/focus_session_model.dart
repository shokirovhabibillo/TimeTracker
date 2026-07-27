/// Represents a row in `focus_sessions`: the real, tracked history
/// of work done against a planned Task (via stopwatch/pomodoro).
class FocusSessionModel {
  final int? id;
  final int taskId;
  final DateTime actualStart;
  final DateTime? actualEnd;
  final int completedDurationSeconds;
  final double completionPercentage;

  FocusSessionModel({
    this.id,
    required this.taskId,
    required this.actualStart,
    this.actualEnd,
    this.completedDurationSeconds = 0,
    this.completionPercentage = 0.0,
  });

  FocusSessionModel copyWith({
    DateTime? actualEnd,
    int? completedDurationSeconds,
    double? completionPercentage,
  }) {
    return FocusSessionModel(
      id: id,
      taskId: taskId,
      actualStart: actualStart,
      actualEnd: actualEnd ?? this.actualEnd,
      completedDurationSeconds:
          completedDurationSeconds ?? this.completedDurationSeconds,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'actual_start': actualStart.toIso8601String(),
      'actual_end': actualEnd?.toIso8601String(),
      'completed_duration': completedDurationSeconds,
      'completion_percentage': completionPercentage,
    };
  }

  factory FocusSessionModel.fromMap(Map<String, dynamic> map) {
    return FocusSessionModel(
      id: map['id'] as int?,
      taskId: map['task_id'] as int,
      actualStart: DateTime.parse(map['actual_start'] as String),
      actualEnd: map['actual_end'] != null
          ? DateTime.parse(map['actual_end'] as String)
          : null,
      completedDurationSeconds: map['completed_duration'] as int? ?? 0,
      completionPercentage:
          (map['completion_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
