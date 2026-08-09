import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models/task_model.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final ValueChanged<String> onSetStatus;
  final Future<void> Function() onDelete;

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

  bool get _isFutureDay {
    final taskDate = DateTime(task.startTime.year, task.startTime.month, task.startTime.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return taskDate.isAfter(today);
  }

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm');
    final futureDay = _isFutureDay;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.only(left: 8, right: 2),
        minLeadingWidth: 10,
        horizontalTitleGap: 8,
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
            futureDay
                ? Tooltip(
                    message: "Kelgusi kun — hali belgilab bo'lmaydi",
                    child: Icon(Icons.radio_button_unchecked, size: 22,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                  )
                : PopupMenuButton<String>(
                    icon: Icon(_statusIcon, size: 22, color: _statusColor(context)),
                    tooltip: 'Bajarilish holati',
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    onSelected: onSetStatus,
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'on_time', child: Text('Vaqtida bajardi')),
                      const PopupMenuItem(value: 'late', child: Text('Kechroq bajardim')),
                      const PopupMenuItem(value: 'postponed', child: Text('Keyinga qoldirildi')),
                      if (task.completionStatus != null)
                        const PopupMenuItem(value: 'none', child: Text('Bekor qilish')),
                    ],
                  ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Vazifani o'chirish"),
        content: Text('"${task.title}" o\'chirilsinmi?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Yo'q")),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Ha')),
        ],
      ),
    );
    if (confirmed == true) await onDelete();
  }
}
