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
  static const iceBreaker = 'ice_breaker';
  static const microLecture = 'micro_lecture';
  static const groupPractice = 'group_practice';
  static const feedbackCheck = 'feedback_check';
  static const conclusion = 'conclusion';
  static const interactiveLecture = 'interactive_lecture';
  static const miniDebate = 'mini_debate';
  static const microBreak = 'micro_break';
  static const deepPractice = 'deep_practice';
  static const presentationDefense = 'presentation_defense';
  static const finalAssessment = 'final_assessment';

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
    iceBreaker,
    microLecture,
    groupPractice,
    feedbackCheck,
    conclusion,
    interactiveLecture,
    miniDebate,
    microBreak,
    deepPractice,
    presentationDefense,
    finalAssessment,
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
      case iceBreaker:
        return "Diqqatni jalb qilish (Ice-breaker)";
      case microLecture:
        return "Mikro-ma'ruza";
      case groupPractice:
        return 'Amaliyot va interaktivlik';
      case feedbackCheck:
        return 'Tekshirish va qaytariq';
      case conclusion:
        return 'Xulosa va uyga vazifa';
      case interactiveLecture:
        return "Interaktiv ma'ruza";
      case miniDebate:
        return 'Mini-debat / Savol-javob';
      case microBreak:
        return 'Mikro-tanaffus';
      case deepPractice:
        return 'Chuqurlashtirilgan amaliyot';
      case presentationDefense:
        return 'Taqdimot va himoya';
      case finalAssessment:
        return 'Yakuniy baholash va qaytariq';
      default:
        return 'Boshqa';
    }
  }
}

/// Ready-made lesson structures matching the 45-minute (school/short
/// training) and 90-minute (university/seminar) regimens.
class ReadyLessonTemplate {
  final String name;
  final int totalMinutes;
  final List<({String type, int minutes})> segments;
  const ReadyLessonTemplate(this.name, this.totalMinutes, this.segments);

  static const fortyFive = ReadyLessonTemplate('45 daqiqali dars (maktab/qisqa trening)', 45, [
    (type: LessonSegmentType.iceBreaker, minutes: 5),
    (type: LessonSegmentType.microLecture, minutes: 15),
    (type: LessonSegmentType.groupPractice, minutes: 15),
    (type: LessonSegmentType.feedbackCheck, minutes: 7),
    (type: LessonSegmentType.conclusion, minutes: 3),
  ]);

  static const ninety = ReadyLessonTemplate('90 daqiqali dars (universitet/seminar)', 90, [
    (type: LessonSegmentType.lessonStart, minutes: 5),
    (type: LessonSegmentType.interactiveLecture, minutes: 20),
    (type: LessonSegmentType.miniDebate, minutes: 15),
    (type: LessonSegmentType.microBreak, minutes: 5),
    (type: LessonSegmentType.deepPractice, minutes: 20),
    (type: LessonSegmentType.presentationDefense, minutes: 15),
    (type: LessonSegmentType.finalAssessment, minutes: 10),
  ]);

  static const all = [fortyFive, ninety];
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
