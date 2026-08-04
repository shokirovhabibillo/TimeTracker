import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models/task_model.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final ValueChanged<String> onSetStatus;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onSetStatus,
    required this.onDelete,
  });

  Color get _color {
    final hex = task.colorCode.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  IconData get _statusIcon {
    switch (task.completionStatus) {
      case 'on_time':
        return Icons.check_circle;
      case 'late':
        return Icons.check_circle;
      case 'postponed':
        return Icons.schedule;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  Color _statusColor(BuildContext context) {
    switch (task.completionStatus) {
      case 'on_time':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'postponed':
        return Theme.of(context).colorScheme.onSurface.withOpacity(0.4);
      default:
        return _color;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 6,
          decoration: BoxDecoration(
            color: _color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${TaskCategory.label(task.category)} · ${timeFmt.format(task.startTime)}–${timeFmt.format(task.endTime)}'
          '${task.isRecurring ? " · ${task.recurrenceRule}" : ""}'
          '${task.completionStatus == 'postponed' ? " · Keyinga qoldirilgan" : ""}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<String>(
              icon: Icon(_statusIcon, color: _statusColor(context)),
              tooltip: 'Bajarilish holati',
              onSelected: onSetStatus,
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'on_time', child: Text('Vaqtida bajardi')),
                PopupMenuItem(value: 'late', child: Text('Kechroq bajardim')),
                PopupMenuItem(value: 'postponed', child: Text('Keyinga qoldirildi')),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
