import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models/task_model.dart';

/// Simple vertical list of today's tasks in time order — the most
/// readable alternative to [MiniCalendar]'s horizontal timeline,
/// intended for the elderly theme and the Medication module.
class ListCalendar extends StatelessWidget {
  final List<TaskModel> tasks;
  final TaskModel? activeTask;
  final void Function(TaskModel) onTaskTap;
  final Color highlightColor;

  const ListCalendar({
    super.key,
    required this.tasks,
    required this.activeTask,
    required this.onTaskTap,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Text(
        "Bugun uchun vazifa yo'q",
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
      );
    }
    final timeFmt = DateFormat('HH:mm');
    return Column(
      children: tasks.map((task) {
        final isActive = activeTask?.id == task.id;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: InkWell(
            onTap: () => onTaskTap(task),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? highlightColor.withOpacity(0.15) : Colors.transparent,
                border: Border.all(
                  color: isActive ? highlightColor : Theme.of(context).colorScheme.outlineVariant,
                  width: isActive ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(timeFmt.format(task.startTime),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(task.title, style: const TextStyle(fontSize: 16)),
                  ),
                  if (isActive) Icon(Icons.play_circle_fill, color: highlightColor),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
