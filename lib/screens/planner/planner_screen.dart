import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/task_provider.dart';
import '../../widgets/mini_calendar.dart';
import '../../widgets/progress_bar.dart';
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

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reja')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AddTaskScreen(initialDay: taskProvider.selectedDay),
        )),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: MiniCalendarHeader(
              day: taskProvider.selectedDay,
              onPrev: () => taskProvider
                  .selectDay(taskProvider.selectedDay.subtract(const Duration(days: 1))),
              onNext: () => taskProvider
                  .selectDay(taskProvider.selectedDay.add(const Duration(days: 1))),
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
                    glow: true,
                  ),
                ),
                const SizedBox(width: 8),
                Text('${(taskProvider.dayProgress * 100).round()}%'),
              ],
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
