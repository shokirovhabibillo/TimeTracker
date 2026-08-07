import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import '../../utils/schedule_utils.dart';

/// Returns true if the item was scheduled.
Future<bool> showScheduleIdpItemDialog(BuildContext context, {required String title}) async {
  final repository = TaskRepository();
  DateTime day = DateTime.now();
  TimeOfDay start = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay end = const TimeOfDay(hour: 19, minute: 0);
  List<TimeGap> gaps = [];
  bool loaded = false;

  Future<void> loadGaps(void Function(void Function()) setState) async {
    final tasks = await repository.getTasksForDay(day);
    gaps = computeFreeGaps(tasks);
    loaded = true;
    setState(() {});
  }

  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        if (!loaded) {
          loadGaps(setState);
        }
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(DateFormat('d MMM yyyy').format(day)),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: day,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    day = picked;
                    loaded = false;
                    await loadGaps(setState);
                  }
                },
              ),
              const SizedBox(height: 12),
              if (gaps.isNotEmpty) ...[
                const Text("Shu kunda bo'sh vaqtlar:", style: TextStyle(fontSize: 12)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: gaps.map((g) {
                    final fmt = DateFormat('HH:mm');
                    return ActionChip(
                      label: Text('${fmt.format(g.start)}–${fmt.format(g.end)}'),
                      onPressed: () => setState(() {
                        start = TimeOfDay.fromDateTime(g.start);
                        end = TimeOfDay(
                            hour: g.start.hour + 1 > 23 ? 23 : g.start.hour + 1, minute: g.start.minute);
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ] else
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text("Bu kun uchun bo'sh vaqt topilmadi — vaqtni qo'lda tanlang.",
                      style: TextStyle(fontSize: 12)),
                ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showTimePicker(context: context, initialTime: start);
                        if (picked != null) setState(() => start = picked);
                      },
                      child: Text('Boshlanish: ${start.format(context)}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showTimePicker(context: context, initialTime: end);
                        if (picked != null) setState(() => end = picked);
                      },
                      child: Text('Tugash: ${end.format(context)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final startDt = DateTime(day.year, day.month, day.day, start.hour, start.minute);
                  var endDt = DateTime(day.year, day.month, day.day, end.hour, end.minute);
                  if (!endDt.isAfter(startDt)) endDt = endDt.add(const Duration(hours: 1));
                  await repository.createTask(TaskModel(
                    title: title,
                    category: TaskCategory.idpDevelopment,
                    colorCode: '#F97316',
                    startTime: startDt,
                    endTime: endDt,
                  ));
                  if (context.mounted) Navigator.of(context).pop(true);
                },
                child: const Text('Kun jadvaliga qo\'shish'),
              ),
            ],
          ),
        );
      },
    ),
  );

  return result ?? false;
}
