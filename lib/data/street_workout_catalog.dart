class WorkoutCategory {
  static const pull = 'pull';
  static const push = 'push';
  static const legs = 'legs';
  static const core = 'core';
  static const fullBody = 'full_body';

  static const all = [pull, push, legs, core, fullBody];

  static String label(String c) {
    switch (c) {
      case pull:
        return 'PULL';
      case push:
        return 'PUSH';
      case legs:
        return 'LEGS';
      case core:
        return 'CORE';
      default:
        return 'FULL BODY';
    }
  }
}

class SwDifficulty {
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
        return "Boshlang'ich";
    }
  }
}

class StreetWorkoutExercise {
  final String id;
  final String name;
  final String category;
  final String difficulty;
  final String equipment;
  final String startingPosition;
  final List<String> steps;
  final String breathing;
  final String beginnerVolume;
  final List<String> commonMistakes;
  final List<String> safetyTips;
  final String? easierVariation;
  final String? harderVariation;

  const StreetWorkoutExercise({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.equipment,
    required this.startingPosition,
    required this.steps,
    required this.breathing,
    required this.beginnerVolume,
    required this.commonMistakes,
    required this.safetyTips,
    this.easierVariation,
    this.harderVariation,
  });
}

class StreetWorkoutCatalog {
  static const List<StreetWorkoutExercise> exercises = [
    StreetWorkoutExercise(
      id: 'dead_hang',
      name: 'Dead Hang',
      category: WorkoutCategory.pull,
      difficulty: SwDifficulty.beginner,
      equipment: 'Turnik',
      startingPosition: "Turnikni ikki qo'lda ushlab, tanani osilgan holatda ushlab turing.",
      steps: ['Setup: Qo\'llar yelka kengligida.', "Hold: Tanani bo'shashgan holda osilgan tuting.", 'Return: Nazorat bilan tushing.'],
      breathing: 'Sekin, tabiiy nafas oling.',
      beginnerVolume: '3 x 15-20 soniya',
      commonMistakes: ["Yelkani ko'tarib yuborish", "Nafasni ushlab turish"],
      safetyTips: ["Panjalar toliqsa darhol tushing"],
      harderVariation: 'scapular_pullup',
    ),
    StreetWorkoutExercise(
      id: 'scapular_pullup',
      name: 'Scapular Pull-Up',
      category: WorkoutCategory.pull,
      difficulty: SwDifficulty.beginner,
      equipment: 'Turnik',
      startingPosition: "Osilgan holatda, qo'llar tekis.",
      steps: ['Setup: Osilgan holat.', "Movement: Kurak suyaklarini pastga tortib, tanani ozgina ko'taring.", 'Return: Sekin tushiring.'],
      breathing: "Ko'tarishda nafas chiqaring.",
      beginnerVolume: '3 x 6-8 takror',
      commonMistakes: ['Tirsakni bukish'],
      safetyTips: ['Kichik harakat qiling'],
      easierVariation: 'dead_hang',
      harderVariation: 'assisted_pullup',
    ),
    StreetWorkoutExercise(
      id: 'assisted_pullup',
      name: 'Assisted Pull-Up',
      category: WorkoutCategory.pull,
      difficulty: SwDifficulty.intermediate,
      equipment: "Rezina tasma yoki trenajyor",
      startingPosition: 'Yordamchi tasma bilan osilgan holat.',
      steps: ['Setup: Tasma oyoq ostida.', "Movement: Tanani yuqoriga tortib chiqing.", 'Return: Nazorat bilan tushing.'],
      breathing: "Ko'tarishda nafas chiqaring.",
      beginnerVolume: '3 x 5-8 takror',
      commonMistakes: ['Tanani tebratish'],
      safetyTips: ['Mos qattiqlikdagi tasma tanlang'],
      easierVariation: 'scapular_pullup',
      harderVariation: 'pullup',
    ),
    StreetWorkoutExercise(
      id: 'pullup',
      name: 'Pull-Up',
      category: WorkoutCategory.pull,
      difficulty: SwDifficulty.advanced,
      equipment: 'Turnik',
      startingPosition: "Turnikni xavfsiz ushlab, tana nazorat ostida.",
      steps: [
        "Setup: Turnikni ushlash, tana nazorat ostida.",
        "Movement: Tirsaklarni pastga va tanaga tomon yo'naltirib, tanani yuqoriga torting.",
        'Top: Harakat nazorat qilinadi.',
        'Return: Sekin va nazorat bilan pastga tushing.',
      ],
      breathing: "Ko'tarishda nafas chiqaring.",
      beginnerVolume: '3 x 3-5 takror',
      commonMistakes: ["Tanani haddan tashqari tebratish", "Harakatni shoshirish", "Nazoratsiz tushish"],
      safetyTips: ["Og'riq bo'lsa davom ettirmang"],
      easierVariation: 'assisted_pullup',
      harderVariation: 'chinup',
    ),
    StreetWorkoutExercise(
      id: 'chinup',
      name: 'Chin-Up',
      category: WorkoutCategory.pull,
      difficulty: SwDifficulty.advanced,
      equipment: 'Turnik',
      startingPosition: "Panjalar ichkariga qaragan holda turnikni ushlang.",
      steps: ['Setup: Panjalar ichkariga.', "Movement: Tanani yuqoriga torting.", 'Return: Nazorat bilan tushing.'],
      breathing: "Ko'tarishda nafas chiqaring.",
      beginnerVolume: '3 x 3-5 takror',
      commonMistakes: ["Tebranish"],
      safetyTips: ["Nazoratsiz harakatdan saqlaning"],
      easierVariation: 'pullup',
    ),
    StreetWorkoutExercise(
      id: 'inverted_row',
      name: 'Australian / Inverted Row',
      category: WorkoutCategory.pull,
      difficulty: SwDifficulty.beginner,
      equipment: 'Past turnik yoki brus',
      startingPosition: "Tana pastda, oyoqlar yerga tegib, past turnikni ushlang.",
      steps: ["Setup: Tana to'g'ri chiziqda.", "Movement: Ko'krakni turnikka torting.", 'Return: Sekin tushiring.'],
      breathing: "Tortishda nafas chiqaring.",
      beginnerVolume: '3 x 8-10 takror',
      commonMistakes: ["Belni egish"],
      safetyTips: ["Tanani to'g'ri chiziqda ushlang"],
      harderVariation: 'pullup',
    ),
    StreetWorkoutExercise(
      id: 'incline_pushup',
      name: 'Incline Push-Up',
      category: WorkoutCategory.push,
      difficulty: SwDifficulty.beginner,
      equipment: "Skameyka yoki devor",
      startingPosition: "Qo'llarni ko'tarilgan yuzaga qo'yib, tana qiya holatda.",
      steps: ["Setup: Qo'llar yelka kengligida.", "Movement: Ko'krakni yuzaga yaqinlashtiring.", 'Return: Yuqoriga qaytaring.'],
      breathing: "Pastga tushishda nafas oling.",
      beginnerVolume: '3 x 10-12 takror',
      commonMistakes: ["Belni egish"],
      safetyTips: ["Tanani to'g'ri chiziqda ushlang"],
      harderVariation: 'pushup',
    ),
    StreetWorkoutExercise(
      id: 'pushup',
      name: 'Push-Up',
      category: WorkoutCategory.push,
      difficulty: SwDifficulty.intermediate,
      equipment: 'Jihozsiz',
      startingPosition: "Plank holatida, qo'llar yelka kengligida.",
      steps: ["Setup: Tana to'g'ri chiziqda.", "Movement: Tirsaklarni bukib, ko'krakni pastga tushiring.", "Return: Qo'llar bilan yuqoriga qaytaring."],
      breathing: "Pastga tushishda nafas oling, ko'tarilishda chiqaring.",
      beginnerVolume: '3 x 8-12 takror',
      commonMistakes: ["Belni cho'ktirish", "To'liq amplitudasiz bajarish"],
      safetyTips: ["Tanani qattiq ushlang"],
      easierVariation: 'incline_pushup',
      harderVariation: 'diamond_pushup',
    ),
    StreetWorkoutExercise(
      id: 'diamond_pushup',
      name: 'Diamond Push-Up',
      category: WorkoutCategory.push,
      difficulty: SwDifficulty.advanced,
      equipment: 'Jihozsiz',
      startingPosition: "Qo'llar bir-biriga yaqin, olmos shaklida.",
      steps: ["Setup: Qo'llar yaqin.", "Movement: Tirsaklarni tanaga yaqin tutib pastga tushing.", 'Return: Yuqoriga qaytaring.'],
      breathing: "Pastga tushishda nafas oling.",
      beginnerVolume: '3 x 6-10 takror',
      commonMistakes: ['Tirsakni tashqariga ochish'],
      safetyTips: ["Bilak bo'g'imiga yuk tushmasligini kuzating"],
      easierVariation: 'pushup',
    ),
    StreetWorkoutExercise(
      id: 'parallel_support',
      name: 'Parallel Bar Support Hold',
      category: WorkoutCategory.push,
      difficulty: SwDifficulty.beginner,
      equipment: 'Parallel brus',
      startingPosition: "Brusda qo'llar tekis, tana ko'tarilgan.",
      steps: ["Setup: Qo'llar tekis.", 'Hold: Tanani barqaror ushlab turing.', 'Return: Sekin tushing.'],
      breathing: 'Tabiiy nafas oling.',
      beginnerVolume: '3 x 15-20 soniya',
      commonMistakes: ["Yelkani ko'tarib yuborish"],
      safetyTips: ['Brus mahkamligini tekshiring'],
      harderVariation: 'assisted_dip',
    ),
    StreetWorkoutExercise(
      id: 'assisted_dip',
      name: 'Assisted Dip',
      category: WorkoutCategory.push,
      difficulty: SwDifficulty.intermediate,
      equipment: 'Parallel brus + tasma',
      startingPosition: 'Tasma yordamida brusda.',
      steps: ['Setup: Tana barqaror.', 'Movement: Tirsaklarni nazorat bilan bukib pastga tushing.', "Return: Qo'llar yordamida yuqoriga qaytaring."],
      breathing: "Pastga tushishda nafas oling.",
      beginnerVolume: '3 x 5-8 takror',
      commonMistakes: ['Haddan tashqari pastga tushish'],
      safetyTips: ["Harakat amplitudasi individual bo'lsin"],
      easierVariation: 'parallel_support',
      harderVariation: 'dip',
    ),
    StreetWorkoutExercise(
      id: 'dip',
      name: 'Dip',
      category: WorkoutCategory.push,
      difficulty: SwDifficulty.advanced,
      equipment: 'Parallel brus',
      startingPosition: 'Tana barqaror, yelkalar nazorat ostida.',
      steps: ['Setup: Tana barqaror.', 'Movement: Tirsaklarni nazorat bilan bukib tanani pastga tushiring.', "Return: Qo'llar yordamida yuqoriga qaytaring."],
      breathing: "Pastga tushishda nafas oling.",
      beginnerVolume: '3 x 5-8 takror',
      commonMistakes: ['Majburan juda pastga tushish'],
      safetyTips: ["Harakat amplitudasini majburlamang"],
      easierVariation: 'assisted_dip',
    ),
    StreetWorkoutExercise(
      id: 'bodyweight_squat_sw',
      name: 'Bodyweight Squat',
      category: WorkoutCategory.legs,
      difficulty: SwDifficulty.beginner,
      equipment: 'Jihozsiz',
      startingPosition: "Oyoqlar qulay kenglikda.",
      steps: ['Setup: Oyoqlar qulay kenglikda.', 'Movement: Son va tizzalarni nazorat bilan bukib pastga tushing.', 'Bottom: Bel va tizzalar barqaror.', 'Return: Oyoqlar orqali yuqoriga qaytaring.'],
      breathing: "Pastga tushishda nafas oling.",
      beginnerVolume: '3 x 12-15 takror',
      commonMistakes: ["Tizzalarni ichkariga qulatish", "Nazoratsiz bajarish"],
      safetyTips: ["Tizza yo'nalishini kuzating"],
      harderVariation: 'reverse_lunge',
    ),
    StreetWorkoutExercise(
      id: 'reverse_lunge',
      name: 'Reverse Lunge',
      category: WorkoutCategory.legs,
      difficulty: SwDifficulty.intermediate,
      equipment: 'Jihozsiz',
      startingPosition: 'Tik turgan holat.',
      steps: ['Setup: Tik turing.', 'Movement: Bir oyoqni orqaga qadam tashlab pastga tushing.', "Return: Boshlang'ich holatga qaytaring."],
      breathing: 'Pastga tushishda nafas oling.',
      beginnerVolume: '3 x 8-10 (har oyoqqa)',
      commonMistakes: ["Muvozanatni yo'qotish"],
      safetyTips: ["Kerak bo'lsa devordan tayanch oling"],
      easierVariation: 'bodyweight_squat_sw',
      harderVariation: 'split_squat',
    ),
    StreetWorkoutExercise(
      id: 'split_squat',
      name: 'Split Squat',
      category: WorkoutCategory.legs,
      difficulty: SwDifficulty.advanced,
      equipment: 'Jihozsiz',
      startingPosition: 'Bir oyoq oldinda, statik holat.',
      steps: ['Setup: Oyoqlar statik.', 'Movement: Pastga tushing.', 'Return: Yuqoriga qaytaring.'],
      breathing: 'Pastga tushishda nafas oling.',
      beginnerVolume: '3 x 6-8 (har oyoqqa)',
      commonMistakes: ["Old tizzani uchdan oshirish"],
      safetyTips: ['Nazoratli harakat qiling'],
      easierVariation: 'reverse_lunge',
    ),
    StreetWorkoutExercise(
      id: 'stepup',
      name: 'Step-Up',
      category: WorkoutCategory.legs,
      difficulty: SwDifficulty.beginner,
      equipment: 'Skameyka yoki zinapoya',
      startingPosition: "Balandroq yuza oldida turing.",
      steps: ['Setup: Balandroq yuza oldida.', "Movement: Bir oyoq bilan bosib chiqing.", 'Return: Nazorat bilan tushing.'],
      breathing: "Ko'tarilishda nafas chiqaring.",
      beginnerVolume: '3 x 8-10 (har oyoqqa)',
      commonMistakes: ["Sirg'anish xavfi"],
      safetyTips: ["Yuza mahkam turganini tekshiring"],
    ),
    StreetWorkoutExercise(
      id: 'calf_raise_sw',
      name: 'Calf Raise',
      category: WorkoutCategory.legs,
      difficulty: SwDifficulty.beginner,
      equipment: 'Jihozsiz',
      startingPosition: 'Tik turgan holat.',
      steps: ['Setup: Tik turing.', "Movement: Oyoq uchlarida ko'tariling.", 'Return: Sekin tushing.'],
      breathing: "Ko'tarilishda nafas chiqaring.",
      beginnerVolume: '3 x 15-20 takror',
      commonMistakes: ['Tezlashtirish'],
      safetyTips: ['Muvozanat uchun devordan tutishingiz mumkin'],
    ),
    StreetWorkoutExercise(
      id: 'glute_bridge',
      name: 'Glute Bridge',
      category: WorkoutCategory.legs,
      difficulty: SwDifficulty.beginner,
      equipment: 'Gilam',
      startingPosition: 'Chalqancha yotib, tizzalar bukilgan.',
      steps: ['Setup: Oyoq kaftlari yerda.', "Movement: Sonlarni yuqoriga ko'taring.", 'Return: Sekin tushiring.'],
      breathing: "Ko'tarilishda nafas chiqaring.",
      beginnerVolume: '3 x 12-15 takror',
      commonMistakes: ['Belni haddan tashqari egish'],
      safetyTips: ['Qorin mushaklarini tortib turing'],
    ),
    StreetWorkoutExercise(
      id: 'plank',
      name: 'Plank',
      category: WorkoutCategory.core,
      difficulty: SwDifficulty.beginner,
      equipment: 'Jihozsiz',
      startingPosition: "Tirsaklar yerda, tana to'g'ri chiziqda.",
      steps: ["Setup: Tana to'g'ri chiziqda.", 'Hold: Qorin mushaklarini tortib turing.', "Return: Sekin bo'shashtiring."],
      breathing: 'Tabiiy nafas oling.',
      beginnerVolume: '3 x 20-30 soniya',
      commonMistakes: ["Beldan egilish", "Dumbani ko'tarib yuborish"],
      safetyTips: ["Bel og'rig'i bo'lsa to'xtating"],
      harderVariation: 'side_plank',
    ),
    StreetWorkoutExercise(
      id: 'side_plank',
      name: 'Side Plank',
      category: WorkoutCategory.core,
      difficulty: SwDifficulty.intermediate,
      equipment: 'Jihozsiz',
      startingPosition: 'Yonboshlab, bir tirsak yerda.',
      steps: ['Setup: Yonbosh holat.', "Hold: Tanani to'g'ri chiziqda ushlang.", 'Return: Sekin tushing.'],
      breathing: 'Tabiiy nafas oling.',
      beginnerVolume: '3 x 15-20 soniya (har tomonga)',
      commonMistakes: ['Sonni pastga tushirib yuborish'],
      safetyTips: ['Nazorat bilan bajaring'],
      easierVariation: 'plank',
    ),
    StreetWorkoutExercise(
      id: 'dead_bug',
      name: 'Dead Bug',
      category: WorkoutCategory.core,
      difficulty: SwDifficulty.beginner,
      equipment: 'Gilam',
      startingPosition: "Chalqancha yotib, qo'l-oyoqlar tepada.",
      steps: ["Setup: Qo'l-oyoq tepada.", "Movement: Qarama-qarshi qo'l-oyoqni sekin cho'zing.", "Return: Boshlang'ich holatga qaytaring."],
      breathing: "Cho'zishda nafas chiqaring.",
      beginnerVolume: '3 x 8-10 (har tomonga)',
      commonMistakes: ['Belni yerdan ko\'tarib yuborish'],
      safetyTips: ['Sekin va nazoratli bajaring'],
      harderVariation: 'hanging_knee_raise',
    ),
    StreetWorkoutExercise(
      id: 'hanging_knee_raise',
      name: 'Hanging Knee Raise',
      category: WorkoutCategory.core,
      difficulty: SwDifficulty.intermediate,
      equipment: 'Turnik',
      startingPosition: 'Turnikda osilgan holat.',
      steps: ['Setup: Osilgan holat.', "Movement: Tizzalarni ko'krakka tomon torting.", 'Return: Sekin tushiring.'],
      breathing: "Ko'tarishda nafas chiqaring.",
      beginnerVolume: '3 x 6-10 takror',
      commonMistakes: ['Tebranish'],
      safetyTips: ['Nazoratsiz sakrashdan saqlaning'],
      easierVariation: 'dead_bug',
      harderVariation: 'knee_tuck',
    ),
    StreetWorkoutExercise(
      id: 'knee_tuck',
      name: 'Knee Tuck',
      category: WorkoutCategory.core,
      difficulty: SwDifficulty.intermediate,
      equipment: 'Jihozsiz yoki slayder',
      startingPosition: 'Plank holatida.',
      steps: ['Setup: Plank holati.', "Movement: Tizzalarni ko'krakka torting.", "Return: Boshlang'ich holatga qaytaring."],
      breathing: "Tortishda nafas chiqaring.",
      beginnerVolume: '3 x 8-10 takror',
      commonMistakes: ["Dumbani ko'tarib yuborish"],
      safetyTips: ['Tananingizni barqaror tuting'],
      easierVariation: 'hanging_knee_raise',
      harderVariation: 'leg_raise',
    ),
    StreetWorkoutExercise(
      id: 'leg_raise',
      name: 'Leg Raise',
      category: WorkoutCategory.core,
      difficulty: SwDifficulty.advanced,
      equipment: 'Turnik',
      startingPosition: 'Turnikda osilgan holat.',
      steps: ['Setup: Osilgan holat.', "Movement: To'g'ri oyoqlarni ko'krak sathigacha ko'taring.", 'Return: Sekin tushiring.'],
      breathing: "Ko'tarishda nafas chiqaring.",
      beginnerVolume: '3 x 5-8 takror',
      commonMistakes: ['Tebranish', 'Tizzani bukish'],
      safetyTips: ["Bu — ilg'or daraja mashqi, shoshilmang"],
      easierVariation: 'knee_tuck',
    ),
    StreetWorkoutExercise(
      id: 'mountain_climber',
      name: 'Mountain Climber',
      category: WorkoutCategory.fullBody,
      difficulty: SwDifficulty.intermediate,
      equipment: 'Jihozsiz',
      startingPosition: 'Plank holatida.',
      steps: ['Setup: Plank holati.', "Movement: Tizzalarni almashinib ko'krakka torting.", 'Return: Ritmni saqlang.'],
      breathing: "Ritmik nafas oling.",
      beginnerVolume: '3 x 20-30 soniya',
      commonMistakes: ["Dumbani ko'tarib yuborish"],
      safetyTips: ["Tananingizni barqaror tuting"],
    ),
    StreetWorkoutExercise(
      id: 'burpee',
      name: 'Burpee',
      category: WorkoutCategory.fullBody,
      difficulty: SwDifficulty.advanced,
      equipment: 'Jihozsiz',
      startingPosition: 'Tik turgan holat.',
      steps: ["Setup: Tik turing.", "Movement: Pastga cho'nqayib, plankga o'ting, push-up qiling, sakrab qaytang.", 'Return: Yuqoriga sakrang.'],
      breathing: "Har bosqichda nafasni nazorat qiling.",
      beginnerVolume: "3 x 5-8 takror (ixtiyoriy, condition uchun)",
      commonMistakes: ["Charchagach texnikani buzish"],
      safetyTips: ["Bu — ixtiyoriy, yuqori intensivlikdagi mashq, boshlang'ich uchun majburiy emas"],
    ),
  ];

  static List<StreetWorkoutExercise> byCategory(String category) =>
      exercises.where((e) => e.category == category).toList();

  static StreetWorkoutExercise? byId(String id) {
    for (final e in exercises) {
      if (e.id == id) return e;
    }
    return null;
  }
}
