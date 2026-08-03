import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../widgets/mini_calendar.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/radial_quick_add.dart';
import '../../widgets/task_tile.dart';
import 'add_task_screen.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasksForSelectedDay();
    });
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
      appBar: AppBar(title: const Text('Reja')),
      floatingActionButton: RadialQuickAddButton(
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: MiniCalendarHeader(
              day: taskProvider.selectedDay,
              onPrev: () =>
                  taskProvider.selectDay(taskProvider.selectedDay.subtract(const Duration(days: 1))),
              onNext: () =>
                  taskProvider.selectDay(taskProvider.selectedDay.add(const Duration(days: 1))),
              onToday: () => taskProvider.selectDay(DateTime.now()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: AppProgressBar(
                    value: taskProvider.dayProgress,
                    color: theme.colorScheme.primary,
                    glow: extras.glowEnabled,
                  ),
                ),
                const SizedBox(width: 8),
                Text('${(taskProvider.dayProgress * 100).round()}%'),
              ],
            ),
          ),
          const SizedBox(height: 8),
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
          if (taskProvider.incompleteFromPast.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.pending_actions, size: 16, color: theme.colorScheme.secondary),
                        const SizedBox(width: 6),
                        Text("Bajarilmagan vazifalar (o'tgan kunlardan)",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.secondary)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...taskProvider.incompleteFromPast.map((task) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(task.title,
                                      style: const TextStyle(fontSize: 13),
                                      overflow: TextOverflow.ellipsis)),
                              TextButton(
                                onPressed: () => taskProvider.rolloverToSelectedDay(task),
                                child: const Text("Bugunga ko'chirish", style: TextStyle(fontSize: 11)),
                              ),
                            ],
                          ),
                        )),
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
                            onToggleComplete: () => taskProvider.toggleCompleted(task),
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
