import 'package:flutter/material.dart';

import '../../data/models/lesson_plan_model.dart';
import '../teacher/teacher_home_screen.dart';

/// Entry point for the Sport module — three workout domains, each
/// reusing the same reorderable plan-builder and sequential timer as
/// the Teacher module, just with a fitness-specific segment vocabulary.
class SportHomeScreen extends StatelessWidget {
  const SportHomeScreen({super.key});

  static const _domains = [
    (
      domain: PlanDomain.bodybuilding,
      title: 'Bodybuilding',
      subtitle: 'Mushak guruhlari va setlar ketma-ketligi',
      icon: Icons.fitness_center,
    ),
    (
      domain: PlanDomain.streetWorkout,
      title: "Street Workout",
      subtitle: "Ko'cha mashqlari — turnik, brus, squat va h.k.",
      icon: Icons.sports_gymnastics,
    ),
    (
      domain: PlanDomain.warmup,
      title: 'Badantarbiya',
      subtitle: "Qizib olish uchun mashqlar",
      icon: Icons.self_improvement,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sport')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _domains.map((d) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: CircleAvatar(child: Icon(d.icon)),
              title: Text(d.title),
              subtitle: Text(d.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => TeacherHomeScreen(
                  domain: d.domain,
                  title: d.title,
                  emptyMessage: "Hali ${d.title} rejasi yaratilmagan. Mashqlarni "
                      "o'zingiz tanlab, ketma-ketligi va davomiyligini belgilaysiz.",
                ),
              )),
            ),
          );
        }).toList(),
      ),
    );
  }
}
