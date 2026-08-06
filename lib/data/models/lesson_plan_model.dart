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

/// Which "domain" a plan belongs to — determines which segment-type
/// vocabulary the builder offers.
class PlanDomain {
  static const teacher = 'teacher';
  static const bodybuilding = 'bodybuilding';
  static const streetWorkout = 'street_workout';
  static const warmup = 'warmup';

  static const all = [teacher, bodybuilding, streetWorkout, warmup];

  static String label(String domain) {
    switch (domain) {
      case bodybuilding:
        return 'Bodybuilding';
      case streetWorkout:
        return "Street Workout (ko'cha mashqlari)";
      case warmup:
        return "Badantarbiya (qizib olish)";
      default:
        return "O'qituvchi rejasi";
    }
  }
}

/// Bodybuilding muscle-group / set-structure segments.
class BodybuildingSegmentType {
  static const warmupSet = 'bb_warmup_set';
  static const chest = 'bb_chest';
  static const back = 'bb_back';
  static const shoulders = 'bb_shoulders';
  static const trapezius = 'bb_trapezius';
  static const biceps = 'bb_biceps';
  static const triceps = 'bb_triceps';
  static const legs = 'bb_legs';
  static const abs = 'bb_abs';
  static const rest = 'bb_rest';

  static const all = [warmupSet, chest, back, shoulders, trapezius, biceps, triceps, legs, abs, rest];

  static String label(String type) {
    switch (type) {
      case warmupSet:
        return "Isinish seti";
      case chest:
        return "Ko'krak mushaklari";
      case back:
        return 'Orqa mushaklari';
      case shoulders:
        return 'Yelka mushaklari';
      case trapezius:
        return 'Trapetsiya';
      case biceps:
        return 'Biceps';
      case triceps:
        return 'Triceps';
      case legs:
        return 'Oyoq mushaklari';
      case abs:
        return 'Qorin mushaklari';
      case rest:
        return 'Setlar orasidagi dam';
      default:
        return 'Boshqa';
    }
  }
}

/// Street Workout (calisthenics) segments.
class StreetWorkoutSegmentType {
  static const pullUps = 'sw_pull_ups';
  static const dips = 'sw_dips';
  static const pushUps = 'sw_push_ups';
  static const squats = 'sw_squats';
  static const plank = 'sw_plank';
  static const burpees = 'sw_burpees';
  static const muscleUp = 'sw_muscle_up';
  static const rest = 'sw_rest';

  static const all = [pullUps, dips, pushUps, squats, plank, burpees, muscleUp, rest];

  static String label(String type) {
    switch (type) {
      case pullUps:
        return "Turnikda tortilish";
      case dips:
        return 'Brusda itarish (dips)';
      case pushUps:
        return "Yerdan ko'tarilish (push-up)";
      case squats:
        return 'Squat (cho\'nqayish)';
      case plank:
        return 'Plank (tortishish)';
      case burpees:
        return 'Burpee';
      case muscleUp:
        return 'Muscle-up';
      case rest:
        return 'Dam olish';
      default:
        return 'Boshqa';
    }
  }
}

/// Warm-up (badantarbiya) segments — light stretches/mobility before a
/// harder session.
class WarmupSegmentType {
  static const neckRotation = 'wu_neck';
  static const armRotation = 'wu_arm';
  static const torsoBend = 'wu_torso';
  static const jogInPlace = 'wu_jog';
  static const legSwing = 'wu_leg_swing';
  static const jointMobility = 'wu_joint';
  static const finalStretch = 'wu_stretch';

  static const all = [neckRotation, armRotation, torsoBend, jogInPlace, legSwing, jointMobility, finalStretch];

  static String label(String type) {
    switch (type) {
      case neckRotation:
        return "Bo'yin aylanishi";
      case armRotation:
        return "Qo'l aylanishi";
      case torsoBend:
        return 'Bel egilishi';
      case jogInPlace:
        return "Joyida yugurish";
      case legSwing:
        return "Oyoq siltash";
      case jointMobility:
        return "Bo'g'imlar mashqi";
      case finalStretch:
        return 'Cho\'zilish (stretching)';
      default:
        return 'Boshqa';
    }
  }
}

/// Returns the right segment-type vocabulary for a given [domain].
List<String> segmentTypesForDomain(String domain) {
  switch (domain) {
    case PlanDomain.bodybuilding:
      return BodybuildingSegmentType.all;
    case PlanDomain.streetWorkout:
      return StreetWorkoutSegmentType.all;
    case PlanDomain.warmup:
      return WarmupSegmentType.all;
    default:
      return LessonSegmentType.all;
  }
}

String segmentLabelForDomain(String domain, String type) {
  switch (domain) {
    case PlanDomain.bodybuilding:
      return BodybuildingSegmentType.label(type);
    case PlanDomain.streetWorkout:
      return StreetWorkoutSegmentType.label(type);
    case PlanDomain.warmup:
      return WarmupSegmentType.label(type);
    default:
      return LessonSegmentType.label(type);
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

/// A teacher-defined lesson (or workout routine, if [domain] is a
/// fitness domain): an ordered list of [LessonSegment]s.
class LessonPlanModel {
  final int? id;
  final String name;
  final DateTime createdAt;
  final List<LessonSegment> segments;
  final String domain;

  LessonPlanModel({
    this.id,
    required this.name,
    required this.createdAt,
    this.segments = const [],
    this.domain = PlanDomain.teacher,
  });

  int get totalMinutes => segments.fold(0, (sum, s) => sum + s.durationMinutes);

  LessonPlanModel copyWith({String? name, List<LessonSegment>? segments}) {
    return LessonPlanModel(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
      segments: segments ?? this.segments,
      domain: domain,
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
