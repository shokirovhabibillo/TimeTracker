import 'package:flutter/material.dart';

import '../../data/trapezius_catalog.dart';
import 'trapezius_exercise_screen.dart';

class TrapeziusGeneratorScreen extends StatefulWidget {
  const TrapeziusGeneratorScreen({super.key});

  @override
  State<TrapeziusGeneratorScreen> createState() => _TrapeziusGeneratorScreenState();
}

class _TrapeziusGeneratorScreenState extends State<TrapeziusGeneratorScreen> {
  String _location = ExerciseLocation.home;
  String _experience = ExerciseDifficulty.beginner;
  List<TrapeziusExercise>? _result;

  void _generate() {
    var pool = TrapeziusCatalog.byLocation(_location);

    // Soddadan murakkabga: boshlang'ich uchun faqat beginner mashqlar,
    // tajribali foydalanuvchi uchun intermediate/advanced ham qo'shiladi.
    if (_experience == ExerciseDifficulty.beginner) {
      pool = pool.where((e) => e.difficulty == ExerciseDifficulty.beginner).toList();
    }

    // Har uchala mintaqadan (upper/middle/lower) hech bo'lmasa bittadan
    // olishga harakat qilib, muvozanatli mashg'ulot tuzamiz.
    final picked = <TrapeziusExercise>[];
    for (final region in [MuscleRegion.upper, MuscleRegion.middle, MuscleRegion.lower]) {
      final match = pool.where((e) => e.muscleRegion == region).toList();
      if (match.isNotEmpty) picked.add(match.first);
    }
    for (final e in pool) {
      if (picked.length >= 5) break;
      if (!picked.contains(e)) picked.add(e);
    }

    setState(() => _result = picked.take(5).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mashg\'ulot generatori')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Joylashuv", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Uy sharoiti'),
                selected: _location == ExerciseLocation.home,
                onSelected: (_) => setState(() => _location = ExerciseLocation.home),
              ),
              ChoiceChip(
                label: const Text('Sport zali'),
                selected: _location == ExerciseLocation.gym,
                onSelected: (_) => setState(() => _location = ExerciseLocation.gym),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Tajriba darajasi', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [ExerciseDifficulty.beginner, ExerciseDifficulty.intermediate, ExerciseDifficulty.advanced]
                .map((d) => ChoiceChip(
                      label: Text(ExerciseDifficulty.label(d)),
                      selected: _experience == d,
                      onSelected: (_) => setState(() => _experience = d),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _generate,
            icon: const Icon(Icons.auto_awesome),
            label: const Text("Mashg'ulot tuzish"),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "Eslatma: og'irlik yoki hajmni keskin oshirish tavsiya etilmaydi — "
              "progress bosqichma-bosqich bo'lishi kerak.",
              style: TextStyle(fontSize: 11),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 20),
            Text('Tavsiya etilgan mashg\'ulot (${_result!.length} mashq)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._result!.map((e) => Card(
                  child: ListTile(
                    title: Text(e.name),
                    subtitle: Text('${MuscleRegion.label(e.muscleRegion)} · ${ExerciseDifficulty.label(e.difficulty)}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => TrapeziusExerciseScreen(exercise: e))),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
