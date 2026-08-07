import 'package:flutter/material.dart';

import '../../data/trapezius_catalog.dart';

class TrapeziusExerciseScreen extends StatelessWidget {
  final TrapeziusExercise exercise;
  const TrapeziusExerciseScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(exercise.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Placeholder for the real technique animation (GIF/MP4/Lottie).
          // Drop the actual asset file into assets/exercises/<id>.* and
          // swap this Container for a Video/Lottie widget when ready.
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle_outline, size: 48, color: scheme.primary),
                const SizedBox(height: 8),
                Text('Texnika animatsiyasi (${exercise.id})',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                Text("tez orada qo'shiladi", style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // "Watch Technique" style quick indicators.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(avatar: const Icon(Icons.my_location, size: 16), label: Text(MuscleRegion.label(exercise.muscleRegion))),
              Chip(avatar: const Icon(Icons.bar_chart, size: 16), label: Text(ExerciseDifficulty.label(exercise.difficulty))),
              Chip(avatar: const Icon(Icons.fitness_center, size: 16), label: Text(exercise.equipment)),
              Chip(avatar: const Icon(Icons.air, size: 16), label: Text(exercise.breathing)),
            ],
          ),
          const SizedBox(height: 20),
          Text('Boshlang\'ich holat', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(exercise.startingPosition),
          const SizedBox(height: 20),
          Text('Bajarish tartibi', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...exercise.steps.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(radius: 12, backgroundColor: scheme.primary, child: Text('${e.key + 1}', style: const TextStyle(fontSize: 11, color: Colors.white))),
                    const SizedBox(width: 10),
                    Expanded(child: Text(e.value)),
                  ],
                ),
              )),
          const SizedBox(height: 20),
          Text("Ko'p uchraydigan xatolar", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...exercise.commonMistakes.map((m) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(children: [const Text('❌ '), Expanded(child: Text(m))]),
              )),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: scheme.error.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.shield_outlined, size: 18, color: scheme.error),
                  const SizedBox(width: 6),
                  const Text('Xavfsizlik', style: TextStyle(fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 8),
                ...exercise.safetyTips.map((s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('• $s', style: const TextStyle(fontSize: 13)),
                    )),
                const SizedBox(height: 4),
                const Text('• Og\'riq paydo bo\'lsa mashqni darhol to\'xtating.', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
          if (exercise.alternatives.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Muqobil mashqlar', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: exercise.alternatives.map((id) {
                final alt = TrapeziusCatalog.byId(id);
                if (alt == null) return const SizedBox.shrink();
                return ActionChip(
                  label: Text(alt.name),
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => TrapeziusExerciseScreen(exercise: alt)),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${exercise.name} boshlandi — omad!')),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Exercise'),
          ),
        ],
      ),
    );
  }
}
