/// A single motivational content card shown on the Motivation Board.
class MotivationItem {
  final String category; // e.g. "Duo", "Hadis", "Olim hikoyasi", "Taxorat"
  final String title;
  final String? arabic;
  final String? transliteration;
  final String body;
  final String source;

  const MotivationItem({
    required this.category,
    required this.title,
    this.arabic,
    this.transliteration,
    required this.body,
    required this.source,
  });
}

class MotivationLibrary {
  static const List<MotivationItem> items = [
    // --- Ilm duolari ---
    MotivationItem(
      category: 'Duo',
      title: 'Ilmni ziyoda qilish duosi',
      transliteration: "Robbi zidniy 'ilma",
      body: 'Ey Robbim, ilmimni ziyoda qil!',
      source: "Qur'on, Toha surasi, 114-oyat",
    ),
    MotivationItem(
      category: 'Duo',
      title: 'Qalbga kenglik va ishga osonlik duosi',
      transliteration:
          "Robbi shrohli sodriy va yassir liy amriy, wahlul 'uqdatam mil lisaaniy yafqohuu qawliy",
      body: "Robbim! Bag'rimni keng qilgin va ishimni oson qilgin, tilimdan tugunni "
          "yechib yuborgin, toki gapimni anglasinlar.",
      source: "Qur'on, Toha surasi, 25-28-oyatlar",
    ),
    MotivationItem(
      category: 'Duo',
      title: 'Foydali ilm va pokiza rizq duosi',
      transliteration:
          "Allohumma inniy as'aluka 'ilman nafi'an, wa rizqon thoyyiban, wa 'amalan mutaqobbalan",
      body: 'Ey Allohim, Sendan foydali ilm, pokiza rizq va qabul bo\'ladigan amal so\'rayman.',
      source: 'Bomdod namozidan keyin o\'qiladigan mashhur duo (Ibn Moja rivoyati)',
    ),
    MotivationItem(
      category: 'Duo',
      title: 'Zehn va tushunishni kengaytirish duosi',
      transliteration: "Robbi zidniy ilman va fahman",
      body: 'Ey Robbim, ilmimni va zehnimni orttir!',
      source: "114-oyat asosidagi, keng tarqalgan qo'shimcha duo (aynan shu shaklda "
          "bitta oyat yoki hadis emas)",
    ),

    // --- Ilm fazilati haqida hadislar ---
    MotivationItem(
      category: 'Hadis',
      title: "Jannat yo'lining oson bo'lishi",
      body: "Kim ilm izlash yo'liga tushsa, Alloh taolo unga jannat yo'lini oson qilib qo'yadi.",
      source: 'Imom Muslim rivoyati (Abu Dardo r.a. hadisi)',
    ),
    MotivationItem(
      category: 'Hadis',
      title: 'Farishtalarning roziligi',
      body: 'Farishtalar tolibi ilmning qilayotgan ishidan rozi bo\'lib, unga qanotlarini yozadilar.',
      source: 'Sahih hadislarda',
    ),
    MotivationItem(
      category: 'Hadis',
      title: "Hamma narsaning istig'for aytishi",
      body: "Ilm yo'lidagi inson uchun daryodagi baliqlar va ko'kdagi qushlargacha "
          "Allohdan uning gunohlarini kechirishini so'raydi.",
      source: 'Imom Muslim rivoyati',
    ),

    // --- Buyuk olimlar hikoyalari ---
    MotivationItem(
      category: 'Olim hikoyasi',
      title: 'Imom al-Buxoriy',
      body: "Kechalari uyqudan uyg'onib, chiroqni yoqar, yodiga tushgan hadisni yozib "
          "qo'yar va buni bir kechada 20 martagacha takrorlar edilar. Eng katta siri — "
          "o'ta kuchli taqvo va shubhali luqmalardan uzoq bo'lish edi.",
      source: "Ilmiy-tarixiy adabiyotda keng tarqalgan rivoyat",
    ),
    MotivationItem(
      category: 'Olim hikoyasi',
      title: 'Abu Rayhon Beruniy',
      body: "Umrlarining oxirgi daqiqalarida, jon taslim qilayotgan vaqtlarida ham "
          "yonlaridagi tabibdan meros masalalariga oid ilmiy masalani so'rab, o'rganib "
          "olganlar. Ular uchun vaqtni to'g'ri taqsimlash eng oliy qoida edi.",
      source: "Ilmiy-tarixiy adabiyotda keng tarqalgan rivoyat",
    ),
    MotivationItem(
      category: 'Olim hikoyasi',
      title: "Imom ash-Shofe'iy",
      body: "Ilmni nur deb bilganlar va zehni pasayganini his qilsalar, darhol ustozlari "
          "Vakiy'ga shikoyat qilganlar. Ustozlari esa gunohlarni tark etishni buyurgan, "
          "chunki Allohning nuri gunohkorga berilmaydi.",
      source: "Ilmiy-tarixiy adabiyotda keng tarqalgan rivoyat",
    ),

    // --- Tahoratdan keyingi amallar ---
    MotivationItem(
      category: 'Taxorat',
      title: 'Shahodat kalimasi — Jannat sakkiz eshigi',
      transliteration: "Ashhadu alla ilaha illallohu vahdahu la sharika lah, va ashhadu "
          "anna Muhammadan abduhu va rasuluh",
      body: 'Men guvohlik beramanki, Allohdan boshqa iloh yo\'q, U yagonadir va sherigi '
          'yo\'qdir. Yana guvohlik beramanki, Muhammad (s.a.v.) Uning quli va Rasulidir — '
          'buni aytgan kishiga Jannatning sakkizta eshigi ochiladi.',
      source: 'Imom Muslim rivoyati: Tahorat, 17; Musafirlar, 294',
    ),
    MotivationItem(
      category: 'Taxorat',
      title: "10 marta salovot — g'am-tashvishdan xalos bo'lish",
      body: "Tahoratdan keyin 10 marta salovot aytgan kishining g'am-qayg'usi ketadi va "
          "duosi qabul bo'ladi.",
      source: "Imom G'azzoliy, \"Ey O'g'lim\" kitobidan — ikkinchi darajali manba, "
          "asosiy hadis to'plamlarida emas",
    ),
    MotivationItem(
      category: 'Taxorat',
      title: 'Tahorat suvidan ortganini ichish (Sunnat)',
      body: "Abu Hayya (r.a.): \"Hazrati Alini (r.a.) ko'rdim — u kishi tahorat "
          "a'zolarini uch martadan yuvib tahorat oldilar, so'ngra tahoratdan ortib "
          "qolgan suvdan ichdilar va 'Rasululloh (s.a.v.) ham xuddi shunday qilgan "
          "edilar' dedilar\".",
      source: 'Nasaiy 136; Termiziy 37; Abu Dovud 50; Buxoriy 25; Ibn Moja 46',
    ),
    MotivationItem(
      category: 'Taxorat',
      title: '"Qadr" surasini o\'qish fazilati',
      body: "Tahorat olgandan keyin bir marta o'qiganlar — siddiqlar qatorida; ikki "
          "marta o'qiganlar — shahidlar qatorida; uch marta o'qiganlar Payg'ambarlar "
          "bilan birga tiriladilar.",
      source: "Daylamiy rivoyati, \"Kanzul-ummol\", V, 72 — ikkinchi darajali manba",
    ),
    MotivationItem(
      category: 'Taxorat',
      title: "Ikki rakat \"Shukri vuzu\" namozi",
      body: "Kimki mukammal tahorat olib, ko'ngliga g'ubor keltirmasdan ikki rakat "
          "namoz o'qisa, uning o'tgan gunohlari kechiriladi.",
      source: 'Buxoriy: Vuzu, 24, 28; Muslim: Tahorat, 3',
    ),

    // --- Doim tahoratda yurish fazilatlari (kechikkanda ko'rsatiladi) ---
    MotivationItem(
      category: 'Taxorat afzalligi',
      title: 'Allohning muhabbati va himoyasi',
      body: "Doim tahoratda yurish insonni Alloh taoloning muhabbatiga sazovor "
          "qiladi, doimo ibodatda turgandek savob oladi va har qanday yomonlikdan "
          "himoyalanadi.",
      source: 'Umumiy islomiy odob-tavsiya',
    ),
    MotivationItem(
      category: 'Taxorat afzalligi',
      title: 'Allohning muhabbati',
      body: "Qur'oni karimda Alloh taolo poklanib yuruvchilarni yaxshi ko'rishi "
          "alohida ta'kidlangan.",
      source: "Qur'on, Tavba surasi, 108-oyat",
    ),
    MotivationItem(
      category: 'Taxorat afzalligi',
      title: "Doimiy ibodatda bo'lish",
      body: "Tahoratli holda yurgan kishi namoz vaqtini kutib o'tirgan yoki doimiy "
          "savob yoziladigan holatda bo'ladi.",
      source: 'Umumiy islomiy odob-tavsiya',
    ),
    MotivationItem(
      category: 'Taxorat afzalligi',
      title: 'Gunohlarning kechirilishi',
      body: "Hadislarda tahorat qilish va uni mukammal bajarish gunohlar to'kilishiga "
          "sabab bo'lishi aytilgan.",
      source: 'Umumiy islomiy odob-tavsiya',
    ),
    MotivationItem(
      category: 'Taxorat afzalligi',
      title: "Ma'naviy poklik va himoya",
      body: "Tahoratli insonga shaytonlar va yomon vasvasalar yaqin kelishi qiyin "
          "bo'ladi.",
      source: 'Umumiy islomiy odob-tavsiya',
    ),
  ];

  static List<MotivationItem> byCategory(String category) =>
      items.where((i) => i.category == category).toList();
}
