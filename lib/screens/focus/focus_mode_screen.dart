import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/task_model.dart';
import '../../providers/settings_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/timer_provider.dart';
import '../../services/audio_service.dart';
import '../../widgets/gamified_progress.dart';
import '../../widgets/list_calendar.dart';
import '../../widgets/mini_calendar.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/timer_display.dart';
import '../../widgets/motivation_board.dart';

/// Focus dashboard: header (task + progress), large stopwatch/pomodoro,
/// clock, interactive calendar with active-task highlighting, keep-screen-on
/// toggle and white-noise generator.
///
/// The screen *requests* landscape orientation while active (a hint that
/// works on most devices), but it never assumes that request succeeded.
/// [OrientationBuilder] reports the device's actual current orientation,
/// and layout switches (3-column row vs. stacked column) based on that —
/// so the UI never breaks even if the OS ignores the rotation request
/// (e.g. some MIUI/Xiaomi devices with system-level rotation lock).
class FocusModeScreen extends StatefulWidget {
  final bool isActive;
  const FocusModeScreen({super.key, this.isActive = true});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  bool _keepScreenOn = false;
  String? _playingTrack;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().refreshActiveTask();
    });
  }

  @override
  void dispose() {
    if (_keepScreenOn) ScreenWakeService.disable();
    AudioService.instance.stop();
    super.dispose();
  }

  Future<void> _toggleKeepScreenOn() async {
    final next = !_keepScreenOn;
    setState(() => _keepScreenOn = next);
    if (next) {
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
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final extras = theme.extension<AppThemeExtras>()!;
    final accent = theme.colorScheme.primary;
    final highlight = extras.highlightColor;

    final taskProvider = context.watch<TaskProvider>();
    final timerProvider = context.watch<TimerProvider>();
    final activeTask = timerProvider.task ?? taskProvider.activeTask;

    final calendar = settings.settings.calendarStyle == 'list'
        ? ListCalendar(
            tasks: taskProvider.tasksForDay,
            activeTask: taskProvider.activeTask,
            onTaskTap: (t) {},
            highlightColor: highlight,
          )
        : MiniCalendar(
            tasks: taskProvider.tasksForDay,
            activeTask: taskProvider.activeTask,
            activeTaskUpcomingBlocks: taskProvider.activeTaskUpcomingBlocks,
            onTaskTap: (t) {},
            highlightColor: highlight,
            neonStyle: extras.glowEnabled,
          );

    final timer = settings.settings.timerStyle == 'big_digits'
        ? BigDigitTimerDisplay(
            timeText: timerProvider.mode == TimerMode.pomodoro
                ? timerProvider.formattedPomodoro
                : timerProvider.formattedElapsed,
            accentColor: accent,
            subtitle: activeTask?.title ?? "Vazifa tanlanmagan",
          )
        : TimerDisplay(
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
            neonStyle: extras.glowEnabled,
          );

    final clock = settings.settings.clockStyle == 'digital'
        ? DigitalClock(accentColor: accent)
        : MediumClock(accentColor: accent);

    final controls = _CompactControls(
      keepScreenOn: _keepScreenOn,
      onToggleKeepScreenOn: _toggleKeepScreenOn,
      playingTrack: _playingTrack,
      onToggleTrack: _toggleTrack,
      accent: accent,
    );

    return Scaffold(
      body: SafeArea(
        child: OrientationBuilder(builder: (context, orientation) {
          final isLandscape = orientation == Orientation.landscape;
          // The motivation board (duas/hadiths/stories) is meant for
          // break/idle moments, not while actively focusing — showing it
          // only when the timer is paused/idle/finished, or during a
          // Pomodoro break, keeps it from being a constant distraction.
          final showMotivation = timerProvider.status != TimerStatus.running ||
              (timerProvider.mode == TimerMode.pomodoro && timerProvider.isPomodoroBreak);

          return Column(
            children: [
              _Header(task: activeTask, progress: taskProvider.dayProgress, accent: accent),
              Expanded(
                child: isLandscape
                    ? _LandscapeBody(
                        calendar: calendar,
                        timer: timer,
                        clock: clock,
                        controls: controls,
                        timerControls: _TimerControls(timerProvider: timerProvider, activeTask: activeTask),
                        dayProgress: taskProvider.dayProgress,
                        highlight: highlight,
                        calmMode: extras.calmMode,
                        showMotivation: showMotivation,
                      )
                    : _PortraitBody(
                        calendar: calendar,
                        timer: timer,
                        clock: clock,
                        controls: controls,
                        timerControls: _TimerControls(timerProvider: timerProvider, activeTask: activeTask),
                        dayProgress: taskProvider.dayProgress,
                        highlight: highlight,
                        calmMode: extras.calmMode,
                        showMotivation: showMotivation,
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _LandscapeBody extends StatelessWidget {
  final Widget calendar, timer, clock, controls, timerControls;
  final double dayProgress;
  final Color highlight;
  final bool calmMode;
  final bool showMotivation;
  const _LandscapeBody({
    required this.calendar,
    required this.timer,
    required this.clock,
    required this.controls,
    required this.timerControls,
    required this.dayProgress,
    required this.highlight,
    required this.calmMode,
    required this.showMotivation,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bugungi jadval',
                    style: TextStyle(
                        fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                const SizedBox(height: 6),
                Expanded(child: SingleChildScrollView(child: calendar)),
                if (!calmMode)
                  Center(
                    child: GamifiedProgress(
                        progress: dayProgress, style: GamifiedVisualStyle.growingTree, accentColor: highlight),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                timer,
                const SizedBox(height: 16),
                timerControls,
                const SizedBox(height: 12),
                clock,
                if (showMotivation) ...[
                  const SizedBox(height: 16),
                  const MotivationBoard(),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [controls]),
          ),
        ),
      ],
    );
  }
}

class _PortraitBody extends StatelessWidget {
  final Widget calendar, timer, clock, controls, timerControls;
  final double dayProgress;
  final Color highlight;
  final bool calmMode;
  final bool showMotivation;
  const _PortraitBody({
    required this.calendar,
    required this.timer,
    required this.clock,
    required this.controls,
    required this.timerControls,
    required this.dayProgress,
    required this.highlight,
    required this.calmMode,
    required this.showMotivation,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          timer,
          const SizedBox(height: 12),
          timerControls,
          const SizedBox(height: 16),
          clock,
          const SizedBox(height: 12),
          controls,
          if (showMotivation) ...[
            const SizedBox(height: 16),
            const MotivationBoard(),
          ],
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Bugungi jadval',
                style: TextStyle(
                    fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
          ),
          const SizedBox(height: 6),
          calendar,
          if (!calmMode) ...[
            const SizedBox(height: 12),
            GamifiedProgress(progress: dayProgress, style: GamifiedVisualStyle.growingTree, accentColor: highlight),
          ],
        ],
      ),
    );
  }
}

/// Icon-only keep-screen-on toggle + icon-only ambient-sound picker —
/// compact by design (no text labels), with tooltips carrying the labels.
class _CompactControls extends StatelessWidget {
  final bool keepScreenOn;
  final VoidCallback onToggleKeepScreenOn;
  final String? playingTrack;
  final ValueChanged<String> onToggleTrack;
  final Color accent;

  const _CompactControls({
    required this.keepScreenOn,
    required this.onToggleKeepScreenOn,
    required this.playingTrack,
    required this.onToggleTrack,
    required this.accent,
  });

  static const _trackIcons = {
    'white_noise': Icons.graphic_eq,
    'rain': Icons.water_drop,
    'forest': Icons.park,
    'brown_noise': Icons.waves,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        Tooltip(
          message: "Ekranni yoniq ushlash",
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onToggleKeepScreenOn,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: keepScreenOn ? accent : scheme.surfaceContainerHighest,
              child: Icon(
                keepScreenOn ? Icons.lightbulb : Icons.lightbulb_outline,
                size: 18,
                color: keepScreenOn ? scheme.onPrimary : scheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ),
        for (final entry in _trackIcons.entries)
          Tooltip(
            message: AudioService.tracks
                .firstWhere((t) => t.id == entry.key, orElse: () => AudioService.tracks.first)
                .label,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => onToggleTrack(entry.key),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: playingTrack == entry.key ? accent : scheme.surfaceContainerHighest,
                child: Icon(
                  entry.value,
                  size: 18,
                  color: playingTrack == entry.key ? scheme.onPrimary : scheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ),
      ],
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
    final extras = Theme.of(context).extension<AppThemeExtras>()!;
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
                AppProgressBar(value: progress, color: accent, glow: extras.glowEnabled),
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
