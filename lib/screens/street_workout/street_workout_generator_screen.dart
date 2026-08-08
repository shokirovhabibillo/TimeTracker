import 'package:flutter/material.dart';

import '../../data/street_workout_catalog.dart';
import 'street_workout_exercise_screen.dart';

class StreetWorkoutGeneratorScreen extends StatefulWidget {
  const StreetWorkoutGeneratorScreen({super.key});

  @override
  State<StreetWorkoutGeneratorScreen> createState() => _StreetWorkoutGeneratorScreenState();
}

class _StreetWorkoutGeneratorScreenState extends State<StreetWorkoutGeneratorScreen> {
  String _goal = 'general';
  String _experience = SwDifficulty.beginner;
  int _durationMin = 20;
  List<StreetWorkoutExercise>? _result;

  static const _goals = {
    'general': 'Umumiy tayyorgarlik',
    'strength': 'Kuch',
    'endurance': 'Chidamlilik',
    'learn_pullup': 'Pull-Up o\'rganish',
    'learn_dip': 'Dip o\'rganish',
  };

  void _generate() {
    List<StreetWorkoutExercise> pool;

    if (_goal == 'learn_pullup') {
      pool = StreetWorkoutCatalog.byCategory(WorkoutCategory.pull);
    } else if (_goal == 'learn_dip') {
      pool = StreetWorkoutCatalog.byCategory(WorkoutCategory.push)
          .where((e) => e.id.contains('dip') || e.id == 'parallel_support')
          .toList();
    } else {
      pool = StreetWorkoutCatalog.exercises;
    }

    if (_experience == SwDifficulty.beginner) {
      pool = pool.where((e) => e.difficulty != SwDifficulty.advanced).toList();
    }

    final maxExercises = (_durationMin / 5).round().clamp(3, 8);

    final picked = <StreetWorkoutExercise>[];
    if (_goal == 'general' || _goal == 'strength' || _goal == 'endurance') {
      for (final cat in WorkoutCategory.all) {
        final match = pool.where((e) => e.category == cat).toList();
        if (match.isNotEmpty) picked.add(match.first);
        if (picked.length >= maxExercises) break;
      }
    }
    for (final e in pool) {
      if (picked.length >= maxExercises) break;
      if (!picked.contains(e)) picked.add(e);
    }

    setState(() => _result = picked.take(maxExercises).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mashg'ulot generatori")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Maqsad', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _goals.entries
                .map((e) => ChoiceChip(
                      label: Text(e.value),
                      selected: _goal == e.key,
                      onSelected: (_) => setState(() => _goal = e.key),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          const Text('Tajriba darajasi', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [SwDifficulty.beginner, SwDifficulty.intermediate, SwDifficulty.advanced]
                .map((d) => ChoiceChip(
                      label: Text(SwDifficulty.label(d)),
                      selected: _experience == d,
                      onSelected: (_) => setState(() => _experience = d),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          const Text('Davomiyligi', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [10, 20, 30, 45]
                .map((d) => ChoiceChip(
                      label: Text('$d daq'),
                      selected: _durationMin == d,
                      onSelected: (_) => setState(() => _durationMin = d),
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
              "Boshlang'ich darajaga ilg'or (advanced) elementlar avtomatik tavsiya etilmaydi.",
              style: TextStyle(fontSize: 11),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 20),
            Text('Tavsiya etilgan mashg\'ulot (${_result!.length} mashq)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._result!.map((e) => Card(
                  child: ListTile(
                    title: Text(e.name),
                    subtitle: Text('${WorkoutCategory.label(e.category)} · ${SwDifficulty.label(e.difficulty)}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => StreetWorkoutExerciseScreen(exercise: e))),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
