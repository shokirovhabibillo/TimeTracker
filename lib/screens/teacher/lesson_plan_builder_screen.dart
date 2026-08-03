import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/lesson_plan_model.dart';
import '../../data/repositories/lesson_plan_repository.dart';
import '../../providers/lesson_timer_provider.dart';
import 'lesson_timer_screen.dart';

class LessonPlanBuilderScreen extends StatefulWidget {
  final LessonPlanModel? existing;
  const LessonPlanBuilderScreen({super.key, this.existing});

  @override
  State<LessonPlanBuilderScreen> createState() => _LessonPlanBuilderScreenState();
}

class _LessonPlanBuilderScreenState extends State<LessonPlanBuilderScreen> {
  final _repository = LessonPlanRepository();
  late TextEditingController _nameController;
  late List<LessonSegment> _segments;
  int? _targetMinutes;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _segments = List.of(widget.existing?.segments ?? []);
  }

  int get _totalMinutes => _segments.fold(0, (sum, s) => sum + s.durationMinutes);

  void _applyTemplate(LessonDurationTemplate template) {
    setState(() => _targetMinutes = template.totalMinutes);
  }

  Future<void> _addSegment() async {
    final type = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => _SegmentTypePicker(alreadyUsed: _segments.map((s) => s.type).toSet()),
    );
    if (type == null) return;
    setState(() {
      _segments.add(LessonSegment(type: type, durationMinutes: 10, orderIndex: _segments.length));
    });
  }

  void _changeDuration(int index, int delta) {
    setState(() {
      final s = _segments[index];
      final newDuration = (s.durationMinutes + delta).clamp(5, 180);
      _segments[index] = s.copyWith(durationMinutes: newDuration);
    });
  }

  void _removeSegment(int index) {
    setState(() => _segments.removeAt(index));
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _segments.removeAt(oldIndex);
      _segments.insert(newIndex, item);
    });
  }

  Future<LessonPlanModel?> _save() async {
    if (_nameController.text.trim().isEmpty || _segments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nom kiriting va kamida bitta bosqich qo'shing")),
      );
      return null;
    }
    final orderedSegments = [
      for (var i = 0; i < _segments.length; i++) _segments[i].copyWith(orderIndex: i),
    ];
    int planId;
    if (widget.existing?.id != null) {
      planId = widget.existing!.id!;
      await _repository.updatePlanSegments(planId, _nameController.text.trim(), orderedSegments);
    } else {
      planId = await _repository.createPlan(_nameController.text.trim(), orderedSegments);
    }
    return LessonPlanModel(
      id: planId,
      name: _nameController.text.trim(),
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
      segments: orderedSegments,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overTarget = _targetMinutes != null && _totalMinutes > _targetMinutes!;
    final underTarget = _targetMinutes != null && _totalMinutes < _targetMinutes!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dars rejasini tuzish'),
        actions: [
          TextButton(
            onPressed: () async {
              final plan = await _save();
              if (plan != null && mounted) Navigator.of(context).pop(plan);
            },
            child: const Text('Saqlash'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Dars rejasi nomi (masalan: Algebra 9-sinf)"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: LessonDurationTemplate.all
                  .map((t) => ActionChip(
                        avatar: const Icon(Icons.bolt, size: 16),
                        label: Text(t.label),
                        onPressed: () => _applyTemplate(t),
                      ))
                  .toList(),
            ),
          ),
          if (_targetMinutes != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Jami: $_totalMinutes / $_targetMinutes daq',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: overTarget
                                ? theme.colorScheme.error
                                : (underTarget ? Colors.orange : Colors.green),
                          )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (_totalMinutes / _targetMinutes!).clamp(0, 1.2) / 1.2,
                      minHeight: 8,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      color: overTarget ? theme.colorScheme.error : (underTarget ? Colors.orange : Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: _segments.isEmpty
                ? Center(
                    child: Text("Hali bosqich qo'shilmagan — pastdagi tugma orqali qo'shing",
                        style: TextStyle(color: theme.hintColor)),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                    itemCount: _segments.length,
                    onReorder: _reorder,
                    itemBuilder: (context, index) {
                      final s = _segments[index];
                      return Card(
                        key: ValueKey('${s.type}_$index'),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text(LessonSegmentType.label(s.type)),
                          subtitle: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, size: 20),
                                onPressed: () => _changeDuration(index, -5),
                              ),
                              Text('${s.durationMinutes} daq'),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, size: 20),
                                onPressed: () => _changeDuration(index, 5),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _removeSegment(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_segments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FloatingActionButton.extended(
                heroTag: 'start',
                onPressed: () async {
                  final plan = await _save();
                  if (plan == null || !mounted) return;
                  context.read<LessonTimerProvider>().start(plan);
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LessonTimerScreen()));
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Boshlash'),
              ),
            ),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: _addSegment,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _SegmentTypePicker extends StatelessWidget {
  final Set<String> alreadyUsed;
  const _SegmentTypePicker({required this.alreadyUsed});

  static const _icons = {
    LessonSegmentType.lessonStart: Icons.play_circle_outline,
    LessonSegmentType.attendanceCheck: Icons.checklist,
    LessonSegmentType.homeworkCheck: Icons.assignment_turned_in_outlined,
    LessonSegmentType.topicExplanation: Icons.lightbulb_outline,
    LessonSegmentType.lecture: Icons.record_voice_over_outlined,
    LessonSegmentType.rulesAndDefinitions: Icons.rule_folder_outlined,
    LessonSegmentType.practicalSession: Icons.build_outlined,
    LessonSegmentType.exercise: Icons.fitness_center_outlined,
    LessonSegmentType.review: Icons.replay,
    LessonSegmentType.homeworkAssign: Icons.assignment_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: LessonSegmentType.all.map((type) {
            return ActionChip(
              avatar: Icon(_icons[type] ?? Icons.circle, size: 18),
              label: Text(LessonSegmentType.label(type)),
              onPressed: () => Navigator.of(context).pop(type),
            );
          }).toList(),
        ),
      ),
    );
  }
}
