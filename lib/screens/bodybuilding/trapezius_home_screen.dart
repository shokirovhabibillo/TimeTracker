import 'package:flutter/material.dart';

import '../../data/trapezius_catalog.dart';
import 'trapezius_exercise_screen.dart';
import 'trapezius_generator_screen.dart';

class TrapeziusHomeScreen extends StatefulWidget {
  const TrapeziusHomeScreen({super.key});

  @override
  State<TrapeziusHomeScreen> createState() => _TrapeziusHomeScreenState();
}

class _TrapeziusHomeScreenState extends State<TrapeziusHomeScreen> {
  String? _region; // null = all
  String? _location; // null = all

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    var list = TrapeziusCatalog.exercises;
    if (_region != null) list = list.where((e) => e.muscleRegion == _region).toList();
    if (_location != null) list = list.where((e) => e.location == _location).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trapetsiya mushaklari'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Mashg\'ulot generatori',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TrapeziusGeneratorScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: scheme.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: scheme.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Trapetsiya 3 qismdan iborat: Upper (yuqori), Middle (o'rta), Lower (pastki). "
                      "Har biri turli mashqlarda ishlaydi.",
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Barchasi'),
                      selected: _region == null,
                      onSelected: (_) => setState(() => _region = null),
                    ),
                    ChoiceChip(
                      label: const Text('Upper'),
                      selected: _region == MuscleRegion.upper,
                      onSelected: (_) => setState(() => _region = MuscleRegion.upper),
                    ),
                    ChoiceChip(
                      label: const Text('Middle'),
                      selected: _region == MuscleRegion.middle,
                      onSelected: (_) => setState(() => _region = MuscleRegion.middle),
                    ),
                    ChoiceChip(
                      label: const Text('Lower'),
                      selected: _region == MuscleRegion.lower,
                      onSelected: (_) => setState(() => _region = MuscleRegion.lower),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text("Uy va Zal"),
                      selected: _location == null,
                      onSelected: (_) => setState(() => _location = null),
                    ),
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
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final e = list[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: scheme.primary.withOpacity(0.15),
                      child: Icon(Icons.fitness_center, color: scheme.primary, size: 20),
                    ),
                    title: Text(e.name),
                    subtitle: Text(
                        '${MuscleRegion.label(e.muscleRegion)} · ${ExerciseDifficulty.label(e.difficulty)} · ${e.equipment}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => TrapeziusExerciseScreen(exercise: e)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
