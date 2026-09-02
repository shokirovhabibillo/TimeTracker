import 'package:flutter/material.dart';

import '../../data/models/strategic_goal_model.dart';
import '../../data/repositories/strategic_goal_repository.dart';

class StrategyLevelScreen extends StatefulWidget {
  final int? parentId;
  final String level;
  final String parentTitle;
  const StrategyLevelScreen({super.key, required this.parentId, required this.level, required this.parentTitle});

  @override
  State<StrategyLevelScreen> createState() => _StrategyLevelScreenState();
}

class _StrategyLevelScreenState extends State<StrategyLevelScreen> {
  final _repository = StrategicGoalRepository();
  List<StrategicGoal>? _goals;
  Map<int, double> _progress = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final goals = widget.parentId == null
        ? await _repository.getOrCreateRoots()
        : await _repository.getOrCreateChildren(widget.parentId!, widget.level);
    final progress = <int, double>{};
    for (final g in goals) {
      if (g.id != null) progress[g.id!] = await _repository.getProgress(g);
    }
    if (mounted) {
      setState(() {
        _goals = goals;
        _progress = progress;
      });
    }
  }

  Future<void> _editTitle(StrategicGoal goal) async {
    final controller = TextEditingController(text: goal.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${StrategyLevel.label(goal.level)} #${goal.position}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Maqsad nomi...'),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Bekor qilish')),
          TextButton(onPressed: () => Navigator.of(context).pop(controller.text.trim()), child: const Text('Saqlash')),
        ],
      ),
    );
    if (newTitle != null && goal.id != null) {
      await _repository.updateTitle(goal.id!, newTitle);
      _load();
    }
  }

  Future<void> _toggleDone(StrategicGoal goal) async {
    if (goal.id == null) return;
    await _repository.updateStatus(goal.id!, goal.isDone ? 'active' : 'done');
    _load();
  }

  void _drillDown(StrategicGoal goal) {
    final childLevel = StrategyLevel.childOf(goal.level);
    if (childLevel == null || goal.id == null) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => StrategyLevelScreen(
        parentId: goal.id,
        level: childLevel,
        parentTitle: goal.title.isEmpty ? '${StrategyLevel.label(goal.level)} #${goal.position}' : goal.title,
      ),
    )).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final isLeaf = StrategyLevel.childOf(widget.level) == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(StrategyLevel.label(widget.level)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(widget.parentTitle, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ),
        ),
      ),
      body: _goals == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: 5,
              itemBuilder: (context, i) {
                final goal = _goals!.firstWhere((g) => g.position == i + 1);
                final progress = (_progress[goal.id] ?? 0) / 100;
                final isEmpty = goal.title.isEmpty;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: isLeaf
                        ? Checkbox(value: goal.isDone, onChanged: (_) => _toggleDone(goal))
                        : CircleAvatar(child: Text('${i + 1}')),
                    title: Text(
                      isEmpty ? "Bo'sh — bosing va to'ldiring" : goal.title,
                      style: TextStyle(
                        fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                        color: isEmpty ? Theme.of(context).hintColor : null,
                        decoration: goal.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: !isLeaf && !isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(value: progress, minHeight: 6),
                            ),
                          )
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () => _editTitle(goal)),
                        if (!isLeaf) const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () {
                      if (isEmpty) {
                        _editTitle(goal);
                      } else if (!isLeaf) {
                        _drillDown(goal);
                      } else {
                        _toggleDone(goal);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
