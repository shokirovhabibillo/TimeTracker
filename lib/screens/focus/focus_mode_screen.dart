import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/task_model.dart';
import '../../providers/settings_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/timer_provider.dart';
import '../../services/audio_service.dart';
import '../../widgets/gamified_progress.dart';
import '../../widgets/mini_calendar.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/timer_display.dart';

/// Full landscape dashboard: header (task + progress), large
/// stopwatch/pomodoro, medium clock, interactive mini-calendar with
/// active-task highlighting, keep-screen-on toggle and white-noise
/// generator. Meant to be entered once a task is started; the screen
/// forces landscape orientation for the duration.
class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({super.key});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  bool _keepScreenOn = false;
  String? _playingTrack;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().refreshActiveTask();
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    if (_keepScreenOn) ScreenWakeService.disable();
    AudioService.instance.stop();
    super.dispose();
  }

  Future<void> _toggleKeepScreenOn(bool value) async {
    setState(() => _keepScreenOn = value);
    if (value) {
      await ScreenWakeService.enable();
    } else {
      await ScreenWakeService.disable();
    }
  }

  Future<void> _toggleTrack(String trackId) async {
    if (_playingTrack == trackId) {
      await AudioService.instance.stop();
      setState(() => _playingTrack = null);
    } else {
      await AudioService.instance.play(trackId);
      setState(() => _playingTrack = trackId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHightech =
        context.watch<SettingsProvider>().themeType == AppThemeType.hightech;
    final accent = isHightech ? AppColors.htElectricCyan : Theme.of(context).colorScheme.primary;
    final highlight = isHightech ? AppColors.htNeonGreen : AppColors.classicOlive;

    final taskProvider = context.watch<TaskProvider>();
    final timerProvider = context.watch<TimerProvider>();
    final activeTask = timerProvider.task ?? taskProvider.activeTask;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(task: activeTask, progress: taskProvider.dayProgress, accent: accent),
            Expanded(
              child: Row(
                children: [
                  // Left: mini calendar + gamified progress
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bugungi jadval',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.white.withOpacity(0.5))),
                          const SizedBox(height: 6),
                          MiniCalendar(
                            tasks: taskProvider.tasksForDay,
                            activeTask: taskProvider.activeTask,
                            activeTaskUpcomingBlocks: taskProvider.activeTaskUpcomingBlocks,
                            onTaskTap: (t) {},
                            highlightColor: highlight,
                            neonStyle: isHightech,
                          ),
                          const Spacer(),
                          if (isHightech)
                            Center(
                              child: GamifiedProgress(
                                progress: taskProvider.dayProgress,
                                style: GamifiedVisualStyle.growingTree,
                                accentColor: highlight,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Center: large timer + clock
                  Expanded(
                    flex: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TimerDisplay(
                          timeText: timerProvider.mode == TimerMode.pomodoro
                              ? timerProvider.formattedPomodoro
                              : timerProvider.formattedElapsed,
                          progress: timerProvider.mode == TimerMode.pomodoro
                              ? 1 -
                                  (timerProvider.pomodoroRemaining.inSeconds /
                                      (TimerProvider.pomodoroFocusMinutes * 60))
                              : timerProvider.progressAgainstPlan,
                          accentColor: accent,
                          subtitle: activeTask?.title ?? "Vazifa tanlanmagan",
                          neonStyle: isHightech,
                        ),
                        const SizedBox(height: 16),
                        _TimerControls(timerProvider: timerProvider, activeTask: activeTask),
                        const SizedBox(height: 12),
                        MediumClock(accentColor: accent),
                      ],
                    ),
                  ),
                  // Right: controls (keep screen on, white noise)
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: const Text('Ekranni yoniq ushlash',
                                style: TextStyle(fontSize: 12)),
                            value: _keepScreenOn,
                            onChanged: _toggleKeepScreenOn,
                          ),
                          const SizedBox(height: 8),
                          Text('Fon ovozi',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.white.withOpacity(0.5))),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: AudioService.tracks.map((t) {
                              final playing = _playingTrack == t.id;
                              return ChoiceChip(
                                label: Text(t.label, style: const TextStyle(fontSize: 11)),
                                selected: playing,
                                selectedColor: accent.withOpacity(0.3),
                                onSelected: (_) => _toggleTrack(t.id),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final TaskModel? task;
  final double progress;
  final Color accent;
  const _Header({required this.task, required this.progress, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task?.title ?? "Faol vazifa yo'q",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                AppProgressBar(value: progress, color: accent, glow: true),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('${(progress * 100).round()}%',
              style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _TimerControls extends StatelessWidget {
  final TimerProvider timerProvider;
  final TaskModel? activeTask;
  const _TimerControls({required this.timerProvider, required this.activeTask});

  @override
  Widget build(BuildContext context) {
    if (activeTask == null) {
      return const Text("Boshlash uchun rejadan vazifa tanlang",
          style: TextStyle(fontSize: 11));
    }

    switch (timerProvider.status) {
      case TimerStatus.idle:
      case TimerStatus.finished:
        return ElevatedButton.icon(
          onPressed: () => timerProvider.start(activeTask!),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Boshlash'),
        );
      case TimerStatus.running:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.pause_circle_filled, size: 32),
              onPressed: timerProvider.pause,
            ),
            IconButton(
              icon: const Icon(Icons.stop_circle, size: 32),
              onPressed: () => timerProvider.stop(),
            ),
          ],
        );
      case TimerStatus.paused:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_circle_filled, size: 32),
              onPressed: timerProvider.resume,
            ),
            IconButton(
              icon: const Icon(Icons.stop_circle, size: 32),
              onPressed: () => timerProvider.stop(),
            ),
          ],
        );
    }
  }
}
