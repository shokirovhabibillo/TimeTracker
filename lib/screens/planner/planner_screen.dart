import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/task_model.dart';
import '../../providers/settings_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/mini_calendar.dart';
import '../../widgets/coach_mark.dart';
import '../../widgets/percentage_ring.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/striped_percentage_ring.dart';
import '../../widgets/radial_quick_add.dart';
import '../../widgets/task_tile.dart';
import 'add_task_screen.dart';
import 'qr_export_screen.dart';
import 'qr_import_screen.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  List<String> _medicineReminders = [];
  List<String> _projectDeadlines = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasksForSelectedDay();
      _loadCrossSystemReminders();
    });
  }

  Future<void> _loadCrossSystemReminders() async {
    final deviceId = context.read<SettingsProvider>().settings.deviceId;
    final result = await context.read<TaskProvider>().loadTodayCrossSystemReminders(deviceId);
    if (mounted) {
      setState(() {
        _medicineReminders = result.medicineTimes;
        _projectDeadlines = result.projectDeadlines;
      });
    }
  }

  void _openAddTask(BuildContext context, {String? category}) {
    final taskProvider = context.read<TaskProvider>();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AddTaskScreen(initialDay: taskProvider.selectedDay, initialCategory: category),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    final extras = theme.extension<AppThemeExtras>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reja'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            tooltip: 'Kun tartibini ulashish (QR)',
            onPressed: taskProvider.tasksForDay.isEmpty
                ? null
                : () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => QrExportScreen(tasks: taskProvider.tasksForDay),
                    )),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'QR orqali kun tartibini olish',
            onPressed: () async {
              final imported = await Navigator.of(context).push<List<TaskModel>>(
                MaterialPageRoute(builder: (_) => QrImportScreen(targetDay: taskProvider.selectedDay)),
              );
              if (imported == null || imported.isEmpty) return;
              for (final t in imported) {
                await taskProvider.addTask(t);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${imported.length} vazifa import qilindi')),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 64),
        child: CoachMark(
          id: 'planner_add',
          message: "Yangi vazifa, uyqu, ovqat yoki odat qo'shish",
          bubbleAbove: true,
          child: RadialQuickAddButton(
          actions: [
            RadialAction(
                icon: Icons.task_alt, label: 'Vazifa', onTap: () => _openAddTask(context, category: TaskCategory.work)),
            RadialAction(
                icon: Icons.bedtime, label: 'Uyqu', onTap: () => _openAddTask(context, category: TaskCategory.sleep)),
            RadialAction(
                icon: Icons.restaurant, label: 'Ovqat', onTap: () => _openAddTask(context, category: TaskCategory.meal)),
            RadialAction(
                icon: Icons.repeat, label: 'Odat', onTap: () => _openAddTask(context, category: TaskCategory.habit)),
          ],
        ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    StripedPercentageRing(
                      value: taskProvider.dayProgress,
                      color: theme.colorScheme.primary,
                      size: 76,
                      glow: extras.glowEnabled,
                    ),
                    const SizedBox(height: 2),
                    Text('Bugungi\nbajarilish',
                        textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: theme.hintColor)),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MiniCalendarHeader(
                    day: taskProvider.selectedDay,
                    onPrev: () =>
                        taskProvider.selectDay(taskProvider.selectedDay.subtract(const Duration(days: 1))),
                    onNext: () =>
                        taskProvider.selectDay(taskProvider.selectedDay.add(const Duration(days: 1))),
                    onToday: () => taskProvider.selectDay(DateTime.now()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_medicineReminders.isNotEmpty || _projectDeadlines.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.colorScheme.tertiary.withOpacity(0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_medicineReminders.isNotEmpty)
                      Row(children: [
                        const Icon(Icons.medication, size: 14),
                        const SizedBox(width: 6),
                        Expanded(child: Text('Dori: ${_medicineReminders.join(", ")}', style: const TextStyle(fontSize: 12))),
                      ]),
                    if (_medicineReminders.isNotEmpty && _projectDeadlines.isNotEmpty) const SizedBox(height: 4),
                    if (_projectDeadlines.isNotEmpty)
                      Row(children: [
                        const Icon(Icons.dashboard, size: 14),
                        const SizedBox(width: 6),
                        Expanded(child: Text('Bugun tugaydi: ${_projectDeadlines.join(", ")}', style: const TextStyle(fontSize: 12))),
                      ]),
                  ],
                ),
              ),
            ),
          if (taskProvider.freeGaps.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: extras.warningColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: extras.warningColor.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 16, color: extras.warningColor),
                        const SizedBox(width: 6),
                        Text("Bo'sh vaqtlar aniqlandi",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold, color: extras.warningColor)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...taskProvider.freeGaps.map((g) {
                      final fmt = DateFormat('HH:mm');
                      final h = g.duration.inMinutes ~/ 60;
                      final m = g.duration.inMinutes % 60;
                      final durationText = h > 0 ? '${h} soat${m > 0 ? ' $m daq' : ''}' : '$m daqiqa';
                      return Text('${fmt.format(g.start)}–${fmt.format(g.end)} ($durationText)',
                          style: const TextStyle(fontSize: 12));
                    }),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: taskProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : taskProvider.tasksForDay.isEmpty
                    ? Center(
                        child: Text(
                          "Bu kunga hali vazifa qo'shilmagan",
                          style: TextStyle(color: theme.hintColor),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 140),
                        itemCount: taskProvider.tasksForDay.length,
                        itemBuilder: (context, i) {
                          final task = taskProvider.tasksForDay[i];
                          return TaskTile(
                            task: task,
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => AddTaskScreen(
                                existing: task,
                                initialDay: taskProvider.selectedDay,
                              ),
                            )),
                            onSetStatus: (status) => taskProvider.setTaskCompletionStatus(task, status),
                            onDelete: () => taskProvider.deleteTask(task.id!),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
