import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/lesson_plan_model.dart';
import '../../data/repositories/lesson_plan_repository.dart';
import '../../providers/lesson_timer_provider.dart';
import 'lesson_plan_builder_screen.dart';
import 'lesson_timer_screen.dart';

/// Entry point for a plan domain (Teacher lessons, Bodybuilding, Street
/// Workout, or Warm-up): a saved list of plans, each an ordered sequence
/// of regiments/exercises that the user built themselves.
class TeacherHomeScreen extends StatefulWidget {
  final String domain;
  final String title;
  final String emptyMessage;
  const TeacherHomeScreen({
    super.key,
    this.domain = PlanDomain.teacher,
    this.title = "O'qituvchi rejasi",
    this.emptyMessage = "Hali dars rejasi yaratilmagan. Har bir rejada darsni boshlash, "
        "mavzu tushuntirish, mashq, uy vazifasi va boshqa bosqichlarni "
        "o'zingiz belgilagan tartibda va davomiylikda tuzasiz.",
  });

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  final _repository = LessonPlanRepository();
  List<LessonPlanModel> _plans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _plans = await _repository.getAllPlans(domain: widget.domain);
    setState(() => _loading = false);
  }

  Future<void> _openBuilder({LessonPlanModel? existing}) async {
    final result = await Navigator.of(context).push<LessonPlanModel>(
      MaterialPageRoute(builder: (_) => LessonPlanBuilderScreen(existing: existing, domain: widget.domain)),
    );
    if (result != null) _load();
  }

  Future<void> _deletePlan(LessonPlanModel plan) async {
    await _repository.deletePlan(plan.id!);
    _load();
  }

  void _runPlan(LessonPlanModel plan) {
    context.read<LessonTimerProvider>().start(plan);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LessonTimerScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openBuilder(),
        icon: const Icon(Icons.add),
        label: const Text('Yangi reja'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _plans.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      widget.emptyMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _plans.length,
                  itemBuilder: (context, i) {
                    final plan = _plans[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(plan.name),
                        subtitle: Text('${plan.segments.length} bosqich · ${plan.totalMinutes} daqiqa'),
                        onTap: () => _openBuilder(existing: plan),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.play_circle_fill),
                              onPressed: () => _runPlan(plan),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deletePlan(plan),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
