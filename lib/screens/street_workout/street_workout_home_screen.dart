import 'package:flutter/material.dart';

import '../../data/street_workout_catalog.dart';
import 'street_workout_exercise_screen.dart';
import 'street_workout_generator_screen.dart';

class StreetWorkoutHomeScreen extends StatefulWidget {
  const StreetWorkoutHomeScreen({super.key});

  @override
  State<StreetWorkoutHomeScreen> createState() => _StreetWorkoutHomeScreenState();
}

class _StreetWorkoutHomeScreenState extends State<StreetWorkoutHomeScreen> {
  String _category = WorkoutCategory.pull;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final list = StreetWorkoutCatalog.byCategory(_category);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Street Workout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: "Mashg'ulot generatori",
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const StreetWorkoutGeneratorScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              children: WorkoutCategory.all
                  .map((c) => ChoiceChip(
                        label: Text(WorkoutCategory.label(c)),
                        selected: _category == c,
                        onSelected: (_) => setState(() => _category = c),
                      ))
                  .toList(),
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
                      child: Icon(Icons.sports_gymnastics, color: scheme.primary, size: 20),
                    ),
                    title: Text(e.name),
                    subtitle: Text('${SwDifficulty.label(e.difficulty)} · ${e.equipment}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => StreetWorkoutExerciseScreen(exercise: e))),
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
