/// Fixed set of lesson "regiment" types a teacher can arrange into a
/// custom sequence — order and duration are entirely up to the teacher.
class LessonSegmentType {
  static const lessonStart = 'lesson_start';
  static const topicExplanation = 'topic_explanation';
  static const lecture = 'lecture';
  static const rulesAndDefinitions = 'rules_and_definitions';
  static const practicalSession = 'practical_session';
  static const exercise = 'exercise';
  static const homeworkCheck = 'homework_check';
  static const homeworkAssign = 'homework_assign';
  static const review = 'review';
  static const attendanceCheck = 'attendance_check';

  static const all = [
    lessonStart,
    attendanceCheck,
    homeworkCheck,
    topicExplanation,
    lecture,
    rulesAndDefinitions,
    practicalSession,
    exercise,
    review,
    homeworkAssign,
  ];

  static String label(String type) {
    switch (type) {
      case lessonStart:
        return 'Darsni boshlash';
      case topicExplanation:
        return 'Mavzuni tushuntirish';
      case lecture:
        return "Ma'ruza";
      case rulesAndDefinitions:
        return "Qoida va ta'riflar";
      case practicalSession:
        return 'Amaliy mashg\'ulot';
      case exercise:
        return 'Mashq bajarish';
      case homeworkCheck:
        return 'Uy vazifasini tekshirish';
      case homeworkAssign:
        return 'Uyga vazifa berish';
      case review:
        return 'Takrorlash';
      case attendanceCheck:
        return 'Davomatni tekshirish';
      default:
        return 'Boshqa';
    }
  }
}

/// A single ordered stage within a [LessonPlanModel].
class LessonSegment {
  final int? id;
  final int? lessonPlanId;
  final String type;
  final int durationMinutes;
  final int orderIndex;

  LessonSegment({
    this.id,
    this.lessonPlanId,
    required this.type,
    required this.durationMinutes,
    required this.orderIndex,
  });

  LessonSegment copyWith({int? durationMinutes, int? orderIndex}) {
    return LessonSegment(
      id: id,
      lessonPlanId: lessonPlanId,
      type: type,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'lesson_plan_id': lessonPlanId,
        'segment_type': type,
        'duration_minutes': durationMinutes,
        'order_index': orderIndex,
      };

  factory LessonSegment.fromMap(Map<String, dynamic> map) => LessonSegment(
        id: map['id'] as int?,
        lessonPlanId: map['lesson_plan_id'] as int?,
        type: map['segment_type'] as String,
        durationMinutes: map['duration_minutes'] as int,
        orderIndex: map['order_index'] as int,
      );
}

/// A teacher-defined lesson: an ordered list of [LessonSegment]s.
class LessonPlanModel {
  final int? id;
  final String name;
  final DateTime createdAt;
  final List<LessonSegment> segments;

  LessonPlanModel({
    this.id,
    required this.name,
    required this.createdAt,
    this.segments = const [],
  });

  int get totalMinutes => segments.fold(0, (sum, s) => sum + s.durationMinutes);

  LessonPlanModel copyWith({String? name, List<LessonSegment>? segments}) {
    return LessonPlanModel(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
      segments: segments ?? this.segments,
    );
  }
}

/// Quick-start duration templates mentioned by the teacher:
/// 1 akademik soat = 45 daqiqa, 1 para dars = 90 daqiqa.
class LessonDurationTemplate {
  final String label;
  final int totalMinutes;
  const LessonDurationTemplate(this.label, this.totalMinutes);

  static const academicHour = LessonDurationTemplate('1 akademik soat (45 daq)', 45);
  static const para = LessonDurationTemplate('1 para dars (90 daq)', 90);
  static const all = [academicHour, para];
}
