import 'package:flutter/material.dart';

/// Preview/roadmap for the future language-learning module — CEFR
/// levels laid out as a path. Full leveled lesson content (vocabulary,
/// spaced repetition, etc.) is a separate future build; this screen
/// gives a real, honest structure to build on rather than an empty page.
class StudyHomeScreen extends StatelessWidget {
  const StudyHomeScreen({super.key});

  static const _levels = [
    ('A1', 'Boshlang\'ich', Icons.looks_one_outlined),
    ('A2', 'Elementar', Icons.looks_two_outlined),
    ('B1', "O'rta", Icons.looks_3_outlined),
    ('B2', "O'rtadan yuqori", Icons.looks_4_outlined),
    ('C1', 'Yuqori', Icons.looks_5_outlined),
    ('C2', 'Mukammal', Icons.looks_6_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text("O'qish")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Bu bo'lim hali to'liq ishlab chiqilmoqda — darajali darslar, "
              "so'z-kartochkalar va takrorlash tizimi keyingi bosqichda "
              "qo'shiladi. Hozircha CEFR (A1-C2) yo'l xaritasi tayyor.",
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          ..._levels.map((l) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(child: Icon(l.$3, size: 18)),
                  title: Text('${l.$1} — ${l.$2}'),
                  trailing: const Chip(label: Text('Tez orada', style: TextStyle(fontSize: 11))),
                  enabled: false,
                ),
              )),
        ],
      ),
    );
  }
}
