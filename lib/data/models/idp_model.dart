/// The three fixed development "buckets" of the classic 70-20-10 model,
/// matching the sample: Ish joyida rivojlanish (70%), Ustoz-shogird
/// an'anasi/Feedback (20%), Training/kitob/qo'llanmalar (10%).
class IdpBucket {
  static const workplace = 'workplace';
  static const mentorFeedback = 'mentor_feedback';
  static const training = 'training';

  static const all = [workplace, mentorFeedback, training];

  static String label(String bucket) {
    switch (bucket) {
      case workplace:
        return "Amaliy rivojlanish - 70%";
      case mentorFeedback:
        return "Ustoz-shogird an'anasi, Feedback - 20%";
      case training:
        return "Training, kitob, qo'llanmalar - 10%";
      default:
        return bucket;
    }
  }
}

class IdpCompetencyType {
  static const skill = 'skill';
  static const knowledge = 'knowledge';

  static String label(String type) => type == knowledge ? 'Bilimlarni rivojlantirish' : 'Qobiliyatlarni rivojlantirish';
}

/// Example placeholder text per bucket — helps the user understand what
/// to write, based on the "Nutq so'zlash" (skill) and "Soliq hisoblash"
/// (knowledge) sample plans.
class IdpFieldHints {
  static String purpose(String bucket) {
    switch (bucket) {
      case IdpBucket.workplace:
        return "Masalan: Ommaviy chiqishlarda fikrni aniq, ravon yetkazishni o'rganish";
      case IdpBucket.mentorFeedback:
        return "Masalan: Ustoz/hamkasbdan chiqishlarim bo'yicha fikr-mulohaza olish";
      default:
        return "Masalan: Soliq kodeksi va hisoblash bo'yicha kitob/kurslardan o'qish";
    }
  }

  static String actionPlan(String bucket) {
    switch (bucket) {
      case IdpBucket.workplace:
        return "Masalan: 1-hafta — nazariya/tahlil, 2-hafta — mashqlar, 3-hafta — "
            "improvizatsiya, 4-hafta — 5 daqiqali taqdimot bilan chiqish";
      case IdpBucket.mentorFeedback:
        return "Masalan: Har haftada 1 marta chiqishimni ko'rsatib, kamchiliklarimni so'rayman";
      default:
        return "Masalan: my.soliq.uz orqali amaliy masalalarni yechish, JShDS hisoblash misollari";
    }
  }

  static String achievedResult() =>
      "Masalan: So'z boyligi oshdi, hayajonni boshqarish ko'nikmasi paydo bo'ldi";

  static String comment() => "Masalan: Keyingi safar diksiya mashqlariga ko'proq vaqt ajratish kerak";
}

class IdpStatus {
  static const notStarted = 'not_started';
  static const inProgress = 'in_progress';
  static const completed = 'completed';

  static const all = [notStarted, inProgress, completed];

  static String label(String status) {
    switch (status) {
      case inProgress:
        return 'Jarayonda';
      case completed:
        return 'Tugallandi';
      default:
        return 'Boshlanmadi';
    }
  }
}

/// One row of a competency's 70-20-10 breakdown — the "Maqsad / Harakat
/// rejasi / vaqt / jarayon / natija / izoh" columns from the sample sheet.
class IdpActionItem {
  final int? id;
  final int? competencyId;
  final String bucket;
  final String purpose; // Maqsad
  final String actionPlan; // Harakat rejasi o'lchamda
  final DateTime? startDate;
  final DateTime? endDate;
  final String status; // Jarayon
  final String achievedResult; // Erishilgan natija
  final String comment; // Izoh

  IdpActionItem({
    this.id,
    this.competencyId,
    required this.bucket,
    this.purpose = '',
    this.actionPlan = '',
    this.startDate,
    this.endDate,
    this.status = IdpStatus.notStarted,
    this.achievedResult = '',
    this.comment = '',
  });

  IdpActionItem copyWith({
    String? purpose,
    String? actionPlan,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? achievedResult,
    String? comment,
  }) {
    return IdpActionItem(
      id: id,
      competencyId: competencyId,
      bucket: bucket,
      purpose: purpose ?? this.purpose,
      actionPlan: actionPlan ?? this.actionPlan,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      achievedResult: achievedResult ?? this.achievedResult,
      comment: comment ?? this.comment,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'competency_id': competencyId,
        'bucket': bucket,
        'purpose': purpose,
        'action_plan': actionPlan,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'status': status,
        'achieved_result': achievedResult,
        'comment': comment,
      };

  factory IdpActionItem.fromMap(Map<String, dynamic> map) => IdpActionItem(
        id: map['id'] as int?,
        competencyId: map['competency_id'] as int?,
        bucket: map['bucket'] as String,
        purpose: map['purpose'] as String? ?? '',
        actionPlan: map['action_plan'] as String? ?? '',
        startDate: map['start_date'] != null ? DateTime.parse(map['start_date'] as String) : null,
        endDate: map['end_date'] != null ? DateTime.parse(map['end_date'] as String) : null,
        status: map['status'] as String? ?? IdpStatus.notStarted,
        achievedResult: map['achieved_result'] as String? ?? '',
        comment: map['comment'] as String? ?? '',
      );
}

/// A single development competency ("Qobiliyat nomi") with its 70-20-10
/// breakdown.
class IdpCompetency {
  final int? id;
  final String name;
  final String competencyType;
  final DateTime createdAt;
  final List<IdpActionItem> items;

  IdpCompetency({
    this.id,
    required this.name,
    this.competencyType = IdpCompetencyType.skill,
    required this.createdAt,
    this.items = const [],
  });

  double get overallProgress {
    if (items.isEmpty) return 0;
    final completed = items.where((i) => i.status == IdpStatus.completed).length;
    return completed / items.length;
  }
}
