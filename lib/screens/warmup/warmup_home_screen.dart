import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/lesson_plan_model.dart';
import '../../providers/lesson_timer_provider.dart';
import '../teacher/lesson_timer_screen.dart';

/// Badantarbiya / warm-up — ready-made Quick and Full sequences, reusing
/// the same sequential timer engine ("generalized Pomodoro") that
/// already powers the Teacher and Sport modules.
class WarmupHomeScreen extends StatelessWidget {
  const WarmupHomeScreen({super.key});

  void _start(BuildContext context, WarmupTemplate template) {
    final segments = [
      for (var i = 0; i < template.segments.length; i++)
        LessonSegment(type: template.segments[i].type, durationMinutes: template.segments[i].minutes, orderIndex: i),
    ];
    final plan = LessonPlanModel(
      name: template.name,
      createdAt: DateTime.now(),
      segments: segments,
      domain: PlanDomain.warmup,
    );
    context.read<LessonTimerProvider>().start(plan);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LessonTimerScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('🔥 Badantarbiya')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: scheme.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
            child: const Text(
              "Warm-up nazorat qilinadigan va qulay bo'lishi kerak. Keskin yoki kuch bilan "
              "cho'zilishlardan saqlaning — maqsad asosiy mashg'ulotga tayyorlanish.",
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
          for (final template in WarmupTemplate.all)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: CircleAvatar(child: Icon(Icons.whatshot, color: scheme.primary)),
                title: Text(template.name),
                subtitle: Text('${template.segments.length} bosqich · ${template.totalMinutes} daqiqa · Intensivlik: Past-O\'rta'),
                trailing: const Icon(Icons.play_circle_fill),
                onTap: () => _start(context, template),
              ),
            ),
          const SizedBox(height: 12),
          Text('Nima uchun tayyorlanmoqchisiz?', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _TargetChip(label: 'Yuqori tana'),
              _TargetChip(label: 'Pastki tana'),
              _TargetChip(label: "Butun tana"),
              _TargetChip(label: 'Street Workout'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Yuqoridagi \"Full Warm-up\" barcha yo'nalishlarni qamrab oladi — "
            "maxsus yo'nalish tanlash tez orada qo'shiladi.",
            style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }
}

class _TargetChip extends StatelessWidget {
  final String label;
  const _TargetChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}
