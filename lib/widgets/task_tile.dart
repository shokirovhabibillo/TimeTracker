import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models/task_model.dart';
import 'crumple_to_trash_tile.dart';

class TaskTile extends StatefulWidget {
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

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  CrumpleToTrashController? _crumpleController;
  bool _collapsed = false;

  TaskModel get task => widget.task;

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
    if (_collapsed) {
      return AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.zero,
        child: const SizedBox(height: 0, width: double.infinity),
      );
    }

    final timeFmt = DateFormat('HH:mm');
    final futureDay = _isFutureDay;
    final card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: widget.onTap,
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
        title: Row(
          children: [
            if (task.priority == 3) const Text('🔴 ', style: TextStyle(fontSize: 12)),
            if (task.priority == 1) const Text('🟢 ', style: TextStyle(fontSize: 12)),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${TaskCategory.label(task.category)} · ${timeFmt.format(task.startTime)}\u2013${timeFmt.format(task.endTime)}'
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
                    onSelected: widget.onSetStatus,
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

    return CrumpleToTrashTile(
      onControllerReady: (c) => _crumpleController = c,
      onFinished: _onFlightFinished,
      child: card,
    );
  }

  void _onFlightFinished() {
    if (!mounted) return;
    setState(() => _collapsed = true);
    _showUndoSnackBar();
  }

  void _showUndoSnackBar() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    var undone = false;
    messenger.showSnackBar(
      SnackBar(
        content: const Text("O'chirildi"),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Bekor qilish',
          onPressed: () {
            undone = true;
            if (mounted) setState(() => _collapsed = false);
            _crumpleController?.undo();
          },
        ),
      ),
    );
    // Explicit timer instead of relying on SnackBar's .closed future —
    // that future can resolve early/unpredictably if another snackbar
    // interrupts this one, which was leaving deletions stuck pending.
    Timer(const Duration(seconds: 4, milliseconds: 200), () async {
      if (!undone) await widget.onDelete();
    });
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
    if (confirmed == true) _crumpleController?.trigger();
  }
}
