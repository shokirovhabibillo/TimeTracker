/// Which "deck" a flashcard belongs to. Language decks are named by
/// CEFR level ('lang_a1'..'lang_c2'); the Quran memorization deck is
/// 'quran'.
class DeckType {
  static const langA1 = 'lang_a1';
  static const langA2 = 'lang_a2';
  static const langB1 = 'lang_b1';
  static const langB2 = 'lang_b2';
  static const langC1 = 'lang_c1';
  static const langC2 = 'lang_c2';
  static const quran = 'quran';

  static const languageLevels = [langA1, langA2, langB1, langB2, langC1, langC2];

  static String label(String deck) {
    switch (deck) {
      case langA1:
        return "A1 — Boshlang'ich";
      case langA2:
        return 'A2 — Elementar';
      case langB1:
        return "B1 — O'rta";
      case langB2:
        return "B2 — O'rtadan yuqori";
      case langC1:
        return 'C1 — Yuqori';
      case langC2:
        return 'C2 — Mukammal';
      case quran:
        return "Qur'on yodlash";
      default:
        return deck;
    }
  }
}

/// How well the user recalled a card — drives the SM-2-style interval
/// calculation, same idea as Anki's "Again / Hard / Good / Easy".
enum RecallQuality { again, hard, good, easy }

class Flashcard {
  final int? id;
  final String deck;
  final String front;
  final String back;
  final String? transliteration;
  final int intervalDays;
  final int repetitions;
  final double easeFactor;
  final DateTime nextReviewDate;
  final DateTime createdAt;

  Flashcard({
    this.id,
    required this.deck,
    required this.front,
    required this.back,
    this.transliteration,
    this.intervalDays = 0,
    this.repetitions = 0,
    this.easeFactor = 2.5,
    required this.nextReviewDate,
    required this.createdAt,
  });

  bool get isDue => !nextReviewDate.isAfter(DateTime.now());

  /// Simplified SM-2: on a lapse ("again"), reset the interval to 1 day
  /// and lower the ease factor; on success, grow the interval by the
  /// ease factor (adjusted by how easy the recall felt).
  Flashcard reviewed(RecallQuality quality) {
    double newEase = easeFactor;
    int newInterval;
    int newRepetitions = repetitions + 1;

    switch (quality) {
      case RecallQuality.again:
        newEase = (easeFactor - 0.2).clamp(1.3, 3.0);
        newInterval = 1;
        newRepetitions = 0;
        break;
      case RecallQuality.hard:
        newEase = (easeFactor - 0.15).clamp(1.3, 3.0);
        newInterval = intervalDays <= 1 ? 1 : (intervalDays * 1.2).round();
        break;
      case RecallQuality.good:
        newInterval = intervalDays <= 0 ? 1 : (intervalDays * newEase).round();
        break;
      case RecallQuality.easy:
        newEase = (easeFactor + 0.15).clamp(1.3, 3.0);
        newInterval = intervalDays <= 0 ? 2 : (intervalDays * newEase * 1.3).round();
        break;
    }
    newInterval = newInterval.clamp(1, 365);

    return Flashcard(
      id: id,
      deck: deck,
      front: front,
      back: back,
      transliteration: transliteration,
      intervalDays: newInterval,
      repetitions: newRepetitions,
      easeFactor: newEase,
      nextReviewDate: DateTime.now().add(Duration(days: newInterval)),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'deck': deck,
        'front': front,
        'back': back,
        'transliteration': transliteration,
        'interval_days': intervalDays,
        'repetitions': repetitions,
        'ease_factor': easeFactor,
        'next_review_date': nextReviewDate.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  factory Flashcard.fromMap(Map<String, dynamic> map) => Flashcard(
        id: map['id'] as int?,
        deck: map['deck'] as String,
        front: map['front'] as String,
        back: map['back'] as String,
        transliteration: map['transliteration'] as String?,
        intervalDays: map['interval_days'] as int? ?? 0,
        repetitions: map['repetitions'] as int? ?? 0,
        easeFactor: (map['ease_factor'] as num?)?.toDouble() ?? 2.5,
        nextReviewDate: DateTime.parse(map['next_review_date'] as String),
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
