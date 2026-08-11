/// A medicine the user takes regularly, with its dosage and daily times.
class Medicine {
  final int? id;
  final String name;
  final String dosage; // e.g. "1 tabletka", "5 ml"
  final List<String> times; // "HH:mm" strings, one per daily dose
  final DateTime startDate;
  final DateTime? endDate; // null = ongoing/no end
  final String notes;

  Medicine({
    this.id,
    required this.name,
    required this.dosage,
    required this.times,
    required this.startDate,
    this.endDate,
    this.notes = '',
  });

  Medicine copyWith({
    String? name,
    String? dosage,
    List<String>? times,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  }) {
    return Medicine(
      id: id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      times: times ?? this.times,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'times': times.join(','),
        'start_date': startDate.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'notes': notes,
      };

  factory Medicine.fromMap(Map<String, dynamic> map) => Medicine(
        id: map['id'] as int?,
        name: map['name'] as String,
        dosage: map['dosage'] as String,
        times: (map['times'] as String).split(',').where((t) => t.isNotEmpty).toList(),
        startDate: DateTime.parse(map['start_date'] as String),
        endDate: map['end_date'] != null ? DateTime.parse(map['end_date'] as String) : null,
        notes: map['notes'] as String? ?? '',
      );
}

/// Whether a specific dose (medicine + date + time) was taken.
class DoseLog {
  final int? id;
  final int medicineId;
  final String date; // yyyy-MM-dd
  final String time; // HH:mm
  final bool taken;

  DoseLog({this.id, required this.medicineId, required this.date, required this.time, this.taken = false});

  Map<String, dynamic> toMap() => {
        'id': id,
        'medicine_id': medicineId,
        'date': date,
        'time': time,
        'taken': taken ? 1 : 0,
      };

  factory DoseLog.fromMap(Map<String, dynamic> map) => DoseLog(
        id: map['id'] as int?,
        medicineId: map['medicine_id'] as int,
        date: map['date'] as String,
        time: map['time'] as String,
        taken: (map['taken'] as int? ?? 0) == 1,
      );
}
