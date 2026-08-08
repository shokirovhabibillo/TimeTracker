import 'package:flutter/material.dart';

import '../../data/street_workout_catalog.dart';

class StreetWorkoutExerciseScreen extends StatelessWidget {
  final StreetWorkoutExercise exercise;
  const StreetWorkoutExerciseScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(exercise.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(14)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle_outline, size: 44, color: scheme.primary),
                const SizedBox(height: 8),
                Text('Texnika animatsiyasi (${exercise.id})', style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                Text("tez orada qo'shiladi", style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(avatar: const Icon(Icons.category, size: 16), label: Text(WorkoutCategory.label(exercise.category))),
              Chip(avatar: const Icon(Icons.bar_chart, size: 16), label: Text(SwDifficulty.label(exercise.difficulty))),
              Chip(avatar: const Icon(Icons.fitness_center, size: 16), label: Text(exercise.equipment)),
              Chip(avatar: const Icon(Icons.repeat, size: 16), label: Text(exercise.beginnerVolume)),
            ],
          ),
          const SizedBox(height: 20),
          Text("Boshlang'ich holat", style: Theme.of(context).textTheme.titleMedium),
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
          const SizedBox(height: 12),
          Row(children: [const Icon(Icons.air, size: 16), const SizedBox(width: 6), Expanded(child: Text(exercise.breathing))]),
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
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text('• Og\'riq paydo bo\'lsa mashqni darhol to\'xtating.', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
          if (exercise.easierVariation != null || exercise.harderVariation != null) ...[
            const SizedBox(height: 20),
            Text("O'tish bosqichlari", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (exercise.easierVariation != null)
                  _progressionChip(context, exercise.easierVariation!, 'Osonroq: '),
                if (exercise.harderVariation != null)
                  _progressionChip(context, exercise.harderVariation!, "Qiyinroq: "),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Keyingi bosqichga o'tish uchun: joriy mashqni belgilangan takror/vaqt bilan "
              "barqaror va to'g'ri texnikada bajarolganingizdan keyin o'ting — shoshilmang.",
              style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
            ),
          ],
        ],
      ),
    );
  }

  Widget _progressionChip(BuildContext context, String id, String prefix) {
    final target = StreetWorkoutCatalog.byId(id);
    if (target == null) return const SizedBox.shrink();
    return ActionChip(
      label: Text('$prefix${target.name}'),
      onPressed: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => StreetWorkoutExerciseScreen(exercise: target)),
      ),
    );
  }
}
