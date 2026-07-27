import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_theme.dart';
import '../data/models/task_model.dart';

/// Compact interactive timeline of the day's schedule. Tapping a block
/// jumps focus to that task. Blocks belonging to the same category as
/// the currently ACTIVE task and lying in the future are drawn in the
/// distinctive accent (Neon Green in High-Tech theme) with a glow.
class MiniCalendar extends StatelessWidget {
  final List<TaskModel> tasks;
  final TaskModel? activeTask;
  final List<TaskModel> activeTaskUpcomingBlocks;
  final void Function(TaskModel) onTaskTap;
  final Color highlightColor;
  final bool neonStyle;

  const MiniCalendar({
    super.key,
    required this.tasks,
    required this.activeTask,
    required this.activeTaskUpcomingBlocks,
    required this.onTaskTap,
    this.highlightColor = AppColors.htNeonGreen,
    this.neonStyle = true,
  });

  static const int startHour = 6;
  static const int endHour = 24;

  @override
  Widget build(BuildContext context) {
    final totalMinutes = (endHour - startHour) * 60;
    final now = DateTime.now();
    final upcomingIds = activeTaskUpcomingBlocks.map((t) => t.id).toSet();

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      return SizedBox(
        height: 92,
        child: Stack(
          children: [
            // Hour ticks
            Positioned.fill(
              child: Row(
                children: List.generate(endHour - startHour, (i) {
                  return Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 2, top: 2),
                        child: Text(
                          '${startHour + i}',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Task blocks
            ...tasks.map((task) {
              final blockColor = _colorFor(task.colorCode);
              final isActiveNow = activeTask?.id == task.id;
              final isFutureSameCategory =
                  upcomingIds.contains(task.id) && task.startTime.isAfter(now);
              final left = _minutesFromStart(task.startTime) / totalMinutes * width;
              final blockWidth =
                  (task.durationMinutes / totalMinutes * width).clamp(4.0, width);

              final effectiveColor =
                  (isActiveNow || isFutureSameCategory) ? highlightColor : blockColor;

              return Positioned(
                left: left.clamp(0, width - 2),
                top: 20,
                width: blockWidth,
                height: 60,
                child: GestureDetector(
                  onTap: () => onTaskTap(task),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      color: effectiveColor.withOpacity(isActiveNow ? 0.85 : 0.55),
                      borderRadius: BorderRadius.circular(6),
                      border: isActiveNow
                          ? Border.all(color: effectiveColor, width: 1.5)
                          : null,
                      boxShadow: neonStyle && (isActiveNow || isFutureSameCategory)
                          ? AppTheme.neonGlow(effectiveColor, intensity: 0.55)
                          : null,
                    ),
                    child: Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            }),
            // "Now" marker
            if (now.hour >= startHour && now.hour < endHour)
              Positioned(
                left: (_minutesFromStart(now) / totalMinutes * width) - 1,
                top: 0,
                bottom: 0,
                child: Container(width: 2, color: highlightColor),
              ),
          ],
        ),
      );
    });
  }

  double _minutesFromStart(DateTime t) {
    final startOfWindow = DateTime(t.year, t.month, t.day, startHour);
    return t.difference(startOfWindow).inMinutes.clamp(0, (endHour - startHour) * 60).toDouble();
  }

  Color _colorFor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }
}

/// Small header label showing the currently selected/displayed date,
/// with prev/next day arrows — the "interactive" part of the mini calendar.
class MiniCalendarHeader extends StatelessWidget {
  final DateTime day;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToday;

  const MiniCalendarHeader({
    super.key,
    required this.day,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPrev),
        Expanded(
          child: GestureDetector(
            onTap: onToday,
            child: Text(
              DateFormat('EEE, d MMM').format(day),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext),
      ],
    );
  }
}
