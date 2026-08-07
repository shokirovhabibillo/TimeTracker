/// Which third of the trapezius an exercise primarily targets.
class MuscleRegion {
  static const upper = 'upper';
  static const middle = 'middle';
  static const lower = 'lower';

  static String label(String region) {
    switch (region) {
      case upper:
        return 'Upper Trapezius';
      case middle:
        return 'Middle Trapezius';
      default:
        return 'Lower Trapezius';
    }
  }

  static String description(String region) {
    switch (region) {
      case upper:
        return "Yelkalarni ko'tarish va bo'yinni qo'llab-quvvatlash — "
            "shrug harakatlarida asosiy ishlaydigan qism.";
      case middle:
        return "Kurak suyaklarini bir-biriga yaqinlashtirish (retraction) — "
            "eshkak eshish (row) harakatlarida ishlaydi.";
      default:
        return "Kurak suyagini pastga va ichkariga tortish — Y/T "
            "ko'tarishlarida va yaxshi turish (postura) uchun muhim.";
    }
  }
}

class ExerciseLocation {
  static const home = 'home';
  static const gym = 'gym';
}

class ExerciseDifficulty {
  static const beginner = 'beginner';
  static const intermediate = 'intermediate';
  static const advanced = 'advanced';

  static String label(String d) {
    switch (d) {
      case intermediate:
        return "O'rta";
      case advanced:
        return 'Yuqori';
      default:
        return 'Boshlang\'ich';
    }
  }
}

class TrapeziusExercise {
  final String id;
  final String name;
  final String muscleRegion;
  final String difficulty;
  final String equipment;
  final String location; // home | gym
  final String startingPosition;
  final List<String> steps; // Setup / Movement / Peak / Return sequence
  final String breathing;
  final List<String> commonMistakes;
  final List<String> safetyTips;
  final List<String> alternatives;

  const TrapeziusExercise({
    required this.id,
    required this.name,
    required this.muscleRegion,
    required this.difficulty,
    required this.equipment,
    required this.location,
    required this.startingPosition,
    required this.steps,
    required this.breathing,
    required this.commonMistakes,
    required this.safetyTips,
    required this.alternatives,
  });
}

/// Full trapezius catalog from the spec — home + gym exercises across
/// all three muscle regions. Kept as a reusable, data-driven structure
/// so other muscle groups (chest, back, shoulders...) can follow the
/// same pattern later.
class TrapeziusCatalog {
  static const List<TrapeziusExercise> exercises = [
    TrapeziusExercise(
      id: 'backpack_shrug',
      name: 'Backpack Shrug',
      muscleRegion: MuscleRegion.upper,
      difficulty: ExerciseDifficulty.beginner,
      equipment: "Ryukzak yoki mos og'irlikdagi buyum",
      location: ExerciseLocation.home,
      startingPosition: 'Gavdani tik tutib, ryukzakni ikki qo\'lda ushlab turing.',
      steps: [
        'Setup: Gavdani tik tuting, yelkalarni bo\'shashtiring.',
        'Movement: Yelkalarni to\'g\'ridan-to\'g\'ri yuqoriga ko\'taring.',
        'Peak: Tepada qisqa pauza qiling, mushakni his qiling.',
        'Return: Sekin boshlang\'ich holatga qaytaring.',
      ],
      breathing: "Ko'tarishda nafas chiqaring, tushirishda nafas oling.",
      commonMistakes: [
        "Yelkalarni aylantirish",
        "Harakatni juda tez bajarish",
        "Haddan tashqari og'ir vazn tanlash",
      ],
      safetyTips: [
        "Harakatni nazorat bilan bajaring",
        "Og'riq sezsangiz to'xtating",
      ],
      alternatives: ['resistance_band_shrug', 'wall_y_raise'],
    ),
    TrapeziusExercise(
      id: 'resistance_band_shrug',
      name: 'Resistance Band Shrug',
      muscleRegion: MuscleRegion.upper,
      difficulty: ExerciseDifficulty.beginner,
      equipment: 'Elastik qarshilik tasmasi',
      location: ExerciseLocation.home,
      startingPosition: "Tasma ustida tik turing, ikki uchini qo'lda ushlang.",
      steps: [
        'Setup: Qo\'llar yon tomonda bo\'shashgan.',
        "Movement: Yelkalarni qarshilikka qarshi yuqoriga ko'taring.",
        'Peak: Tepada qisqa pauza.',
        'Return: Sekin pastga tushiring.',
      ],
      breathing: "Ko'tarishda nafas chiqaring.",
      commonMistakes: ['Yelkalarni aylantirish', 'Sakrab bajarish'],
      safetyTips: ["Gavdani barqaror tuting", 'Nazoratsiz harakatdan saqlaning'],
      alternatives: ['backpack_shrug'],
    ),
    TrapeziusExercise(
      id: 'wall_y_raise',
      name: 'Wall Y Raise',
      muscleRegion: MuscleRegion.lower,
      difficulty: ExerciseDifficulty.beginner,
      equipment: 'Jihozsiz',
      location: ExerciseLocation.home,
      startingPosition: "Devorga orqa (yoki old) bilan suyanib, qo'llarni Y shaklida ko'taring.",
      steps: [
        "Setup: Qo'llar devorga yengil tegib turadi.",
        "Movement: Qo'llarni Y shaklida sekin ko'taring.",
        'Peak: Kurak pastki qismini siqib, qisqa pauza.',
        'Return: Sekin tushiring.',
      ],
      breathing: "Ko'tarishda nafas chiqaring.",
      commonMistakes: ['Yelkani ko\'tarib yuborish', "Bo'yinni zo'riqtirish"],
      safetyTips: ["Kichik, nazoratli harakat qiling"],
      alternatives: ['prone_y_raise'],
    ),
    TrapeziusExercise(
      id: 'prone_y_raise',
      name: 'Prone Y Raise',
      muscleRegion: MuscleRegion.lower,
      difficulty: ExerciseDifficulty.beginner,
      equipment: 'Gilam',
      location: ExerciseLocation.home,
      startingPosition: "Qorin bilan yotib, qo'llarni oldinga Y shaklida cho'zing.",
      steps: [
        'Setup: Qo\'llar polga yaqin.',
        "Movement: Qo'llarni sekin yuqoriga ko'taring.",
        'Peak: Qisqa pauza.',
        'Return: Sekin tushiring.',
      ],
      breathing: "Ko'tarishda nafas chiqaring.",
      commonMistakes: ["Tirsakni bukish", "Bo'yinni ko'tarish"],
      safetyTips: ["Bo'yinni neytral tuting"],
      alternatives: ['wall_y_raise', 'prone_t_raise'],
    ),
    TrapeziusExercise(
      id: 'prone_t_raise',
      name: 'Prone T Raise',
      muscleRegion: MuscleRegion.middle,
      difficulty: ExerciseDifficulty.beginner,
      equipment: 'Gilam',
      location: ExerciseLocation.home,
      startingPosition: "Qorin bilan yotib, qo'llarni yon tomonga T shaklida yoying.",
      steps: [
        'Setup: Qo\'llar T shaklida, polga yaqin.',
        "Movement: Qo'llarni yon tomonga ko'taring.",
        'Peak: Kurak suyaklarini siqing.',
        'Return: Sekin tushiring.',
      ],
      breathing: "Ko'tarishda nafas chiqaring.",
      commonMistakes: ['Yelkani haddan tashqari ko\'tarish'],
      safetyTips: ["Bo'yinni neytral tuting"],
      alternatives: ['scapular_retraction'],
    ),
    TrapeziusExercise(
      id: 'scapular_retraction',
      name: 'Scapular Retraction',
      muscleRegion: MuscleRegion.middle,
      difficulty: ExerciseDifficulty.beginner,
      equipment: 'Jihozsiz yoki rezina',
      location: ExerciseLocation.home,
      startingPosition: 'Tik turib, qo\'llarni oldinga cho\'zing.',
      steps: [
        'Setup: Kurak suyaklari bo\'sh holatda.',
        "Movement: Kurak suyaklarini bir-biriga yaqinlashtiring.",
        'Peak: Qisqa pauza.',
        'Return: Sekin bo\'shashtiring.',
      ],
      breathing: "Siqishda nafas chiqaring.",
      commonMistakes: ["Yelkani ko'tarib yuborish", "Belni egish"],
      safetyTips: ["Harakat kichik va nazoratli bo'lsin"],
      alternatives: ['prone_t_raise'],
    ),
    TrapeziusExercise(
      id: 'dumbbell_shrug',
      name: 'Dumbbell Shrug',
      muscleRegion: MuscleRegion.upper,
      difficulty: ExerciseDifficulty.beginner,
      equipment: 'Gantel',
      location: ExerciseLocation.gym,
      startingPosition: "Tik turib, gantellarni yon tomonda ushlang.",
      steps: [
        'Setup: Qo\'llar yon tomonda bo\'shashgan.',
        "Movement: Yelkalarni to'g'ridan-to'g'ri yuqoriga ko'taring.",
        'Peak: Tepada qisqa pauza.',
        'Return: Sekin tushiring.',
      ],
      breathing: "Ko'tarishda nafas chiqaring.",
      commonMistakes: ['Yelkani aylantirish', "Tirsakni bukish"],
      safetyTips: ["Og'irlikni asta oshiring"],
      alternatives: ['barbell_shrug', 'cable_shrug'],
    ),
    TrapeziusExercise(
      id: 'barbell_shrug',
      name: 'Barbell Shrug',
      muscleRegion: MuscleRegion.upper,
      difficulty: ExerciseDifficulty.intermediate,
      equipment: 'Shtanga',
      location: ExerciseLocation.gym,
      startingPosition: 'Tik turib, shtangani sonlar oldida ushlang.',
      steps: [
        'Setup: Umurtqa neytral.',
        "Movement: Yelkalarni yuqoriga ko'taring.",
        'Peak: Qisqa pauza.',
        'Return: Sekin tushiring.',
      ],
      breathing: "Ko'tarishda nafas chiqaring.",
      commonMistakes: ['Yelka aylanishi', "Ortiqcha vazn"],
      safetyTips: ["Gavdani barqaror tuting"],
      alternatives: ['dumbbell_shrug'],
    ),
    TrapeziusExercise(
      id: 'cable_shrug',
      name: 'Cable Shrug',
      muscleRegion: MuscleRegion.upper,
      difficulty: ExerciseDifficulty.intermediate,
      equipment: 'Trenajyor (kabel)',
      location: ExerciseLocation.gym,
      startingPosition: 'Tik turib, kabel dastalarini ushlang.',
      steps: [
        'Setup: Tirsaklar deyarli tekis.',
        "Movement: Yelkalarni vertikal ko'taring.",
        'Peak: Qisqa siqish.',
        'Return: Sekin tushiring.',
      ],
      breathing: "Ko'tarishda nafas chiqaring.",
      commonMistakes: ['Yelka aylanishi'],
      safetyTips: ["Ortiqcha vazn qo'ymang"],
      alternatives: ['dumbbell_shrug', 'machine_shrug'],
    ),
    TrapeziusExercise(
      id: 'machine_shrug',
      name: 'Machine Shrug',
      muscleRegion: MuscleRegion.upper,
      difficulty: ExerciseDifficulty.beginner,
      equipment: 'Shrug trenajyori',
      location: ExerciseLocation.gym,
      startingPosition: "Trenajyorda o'tirgan/tik holatda, dastalarni ushlang.",
      steps: [
        'Setup: Yelkalar bo\'shashgan.',
        "Movement: Yelkalarni vertikal ko'taring.",
        'Peak: Qisqa pauza.',
        'Return: Sekin tushiring.',
      ],
      breathing: "Ko'tarishda nafas chiqaring.",
      commonMistakes: ['Yelka aylanishi'],
      safetyTips: ["Trenajyor sozlamalarini tekshiring"],
      alternatives: ['dumbbell_shrug'],
    ),
    TrapeziusExercise(
      id: 'face_pull',
      name: 'Face Pull',
      muscleRegion: MuscleRegion.middle,
      difficulty: ExerciseDifficulty.intermediate,
      equipment: 'Kabel + arqon',
      location: ExerciseLocation.gym,
      startingPosition: "Kabel trenajyoriga qarab turib, arqonni ikki qo'lda ushlang.",
      steps: [
        'Setup: Qo\'llar oldinga cho\'zilgan.',
        "Movement: Arqonni yuzga tomon torting, tirsaklar tashqariga.",
        'Peak: Yelka orqasini siqing.',
        'Return: Sekin qo\'llarni cho\'zing.',
      ],
      breathing: "Tortishda nafas chiqaring.",
      commonMistakes: ["Keskin tortish", "Og'ir vazn"],
      safetyTips: ["Umurtqani neytral tuting"],
      alternatives: ['cable_y_raise', 'chest_supported_row'],
    ),
    TrapeziusExercise(
      id: 'cable_y_raise',
      name: 'Cable Y Raise',
      muscleRegion: MuscleRegion.lower,
      difficulty: ExerciseDifficulty.intermediate,
      equipment: 'Kabel trenajyori',
      location: ExerciseLocation.gym,
      startingPosition: "Kabelga burchak ostida turib, qo'llarni pastda tuting.",
      steps: [
        'Setup: Qo\'llar pastda.',
        "Movement: Qo'llarni diagonal Y shaklida ko'taring.",
        'Peak: Y holatida qisqa pauza.',
        'Return: Sekin tushiring.',
      ],
      breathing: "Ko'tarishda nafas chiqaring.",
      commonMistakes: ["Yelkani ko'tarib yuborish"],
      safetyTips: ["Yengil vazndan boshlang"],
      alternatives: ['prone_y_raise'],
    ),
    TrapeziusExercise(
      id: 'chest_supported_row',
      name: 'Chest-Supported Row',
      muscleRegion: MuscleRegion.middle,
      difficulty: ExerciseDifficulty.intermediate,
      equipment: "Qiya skameyka + gantel",
      location: ExerciseLocation.gym,
      startingPosition: "Ko'krak bilan skameykaga suyanib, qo'llar pastga cho'zilgan.",
      steps: [
        'Setup: Ko\'krak qo\'llab-quvvatlangan.',
        "Movement: Dastalarni tanaga tomon torting, kurak suyaklarini yaqinlashtiring.",
        'Peak: Qisqa siqish.',
        'Return: Sekin cho\'zing.',
      ],
      breathing: "Tortishda nafas chiqaring.",
      commonMistakes: ['Keskin tortish'],
      safetyTips: ["Ko'krakni doim tayangan holda saqlang"],
      alternatives: ['seated_cable_row', 'face_pull'],
    ),
    TrapeziusExercise(
      id: 'seated_cable_row',
      name: 'Seated Cable Row',
      muscleRegion: MuscleRegion.middle,
      difficulty: ExerciseDifficulty.beginner,
      equipment: 'Kabel trenajyori',
      location: ExerciseLocation.gym,
      startingPosition: "O'tirgan holda, dastani ikki qo'lda ushlang.",
      steps: [
        'Setup: Umurtqa tik.',
        "Movement: Dastani tanaga tomon torting.",
        'Peak: Kurak suyaklarini siqing.',
        'Return: Sekin cho\'zing.',
      ],
      breathing: "Tortishda nafas chiqaring.",
      commonMistakes: ["Orqaga qattiq engashish"],
      safetyTips: ["Nazoratli harakat qiling"],
      alternatives: ['chest_supported_row'],
    ),
  ];

  static List<TrapeziusExercise> byRegion(String region) =>
      exercises.where((e) => e.muscleRegion == region).toList();

  static List<TrapeziusExercise> byLocation(String location) =>
      exercises.where((e) => e.location == location).toList();

  static TrapeziusExercise? byId(String id) {
    for (final e in exercises) {
      if (e.id == id) return e;
    }
    return null;
  }
}
