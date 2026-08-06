import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/lesson_plan_model.dart';
import '../../providers/lesson_timer_provider.dart';

class LessonTimerScreen extends StatelessWidget {
  const LessonTimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<LessonTimerProvider>();
    final scheme = Theme.of(context).colorScheme;

    if (timer.plan == null) {
      return const Scaffold(body: Center(child: Text('Reja tanlanmagan')));
    }

    return PopScope(
      canPop: timer.status != LessonTimerStatus.running,
      child: Scaffold(
        appBar: AppBar(
          title: Text(timer.plan!.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.stop_circle_outlined),
              onPressed: () {
                timer.stop();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: OrientationBuilder(builder: (context, orientation) {
            final isLandscape = orientation == Orientation.landscape;
            final board = _SegmentBoard(timer: timer);
            final display = _CurrentSegmentDisplay(timer: timer, scheme: scheme);

            if (isLandscape) {
              return Row(
                children: [
                  Expanded(flex: 5, child: display),
                  Expanded(flex: 4, child: board),
                ],
              );
            }
            return Column(
              children: [
                Expanded(flex: 3, child: display),
                Expanded(flex: 4, child: board),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _CurrentSegmentDisplay extends StatelessWidget {
  final LessonTimerProvider timer;
  final ColorScheme scheme;
  const _CurrentSegmentDisplay({required this.timer, required this.scheme});

  @override
  Widget build(BuildContext context) {
    final segment = timer.currentSegment;
    if (segment == null || timer.status == LessonTimerStatus.finished) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.celebration, size: 48, color: scheme.primary),
            const SizedBox(height: 12),
            const Text('Dars yakunlandi!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    final segmentProgress =
        (timer.elapsedInSegment.inSeconds / (segment.durationMinutes * 60)).clamp(0.0, 1.0);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(segmentLabelForDomain(timer.plan!.domain, segment.type),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: segmentProgress,
                    strokeWidth: 10,
                    backgroundColor: scheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(scheme.primary),
                  ),
                ),
                Text(timer.formattedRemainingInSegment,
                    style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: scheme.primary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (timer.status == LessonTimerStatus.running)
                IconButton(
                    icon: const Icon(Icons.pause_circle_filled, size: 36), onPressed: timer.pause)
              else
                IconButton(
                    icon: const Icon(Icons.play_circle_filled, size: 36), onPressed: timer.resume),
              IconButton(
                  icon: const Icon(Icons.skip_next, size: 36), onPressed: timer.skipToNext),
            ],
          ),
        ],
      ),
    );
  }
}

/// Board next to the timer listing every segment, highlighting the
/// current one and comparing progress against the lesson's total
/// planned duration.
class _SegmentBoard extends StatelessWidget {
  final LessonTimerProvider timer;
  const _SegmentBoard({required this.timer});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final plan = timer.plan!;
    final totalProgress =
        (timer.totalElapsed.inSeconds / (timer.totalPlanned.inSeconds == 0 ? 1 : timer.totalPlanned.inSeconds))
            .clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Umumiy: ${timer.totalElapsed.inMinutes} / ${plan.totalMinutes} daq',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: totalProgress,
              minHeight: 6,
              backgroundColor: scheme.surfaceContainerHighest,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: plan.segments.length,
              itemBuilder: (context, i) {
                final s = plan.segments[i];
                final isCurrent = i == timer.currentIndex && timer.status != LessonTimerStatus.finished;
                final isDone = i < timer.currentIndex || timer.status == LessonTimerStatus.finished;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? scheme.primary.withOpacity(0.15)
                        : (isDone ? scheme.surfaceContainerHighest.withOpacity(0.4) : null),
                    borderRadius: BorderRadius.circular(8),
                    border: isCurrent ? Border.all(color: scheme.primary, width: 1.5) : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isDone ? Icons.check_circle : (isCurrent ? Icons.play_circle_fill : Icons.circle_outlined),
                        size: 16,
                        color: isDone ? Colors.green : (isCurrent ? scheme.primary : scheme.onSurface.withOpacity(0.3)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          segmentLabelForDomain(plan.domain, s.type),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      Text('${s.durationMinutes} daq', style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
