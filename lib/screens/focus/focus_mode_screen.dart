import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/medicine_repository.dart';
import '../../providers/settings_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/timer_provider.dart';
import '../../services/audio_service.dart';
import '../../widgets/gamified_progress.dart';
import '../../widgets/list_calendar.dart';
import '../../widgets/mini_calendar.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/swipeable_style_picker.dart';
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
  String? _dueMedicine;
  Timer? _medicineCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().refreshActiveTask();
    });
    _checkDueMedicine();
    _medicineCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) => _checkDueMedicine());
  }

  Future<void> _checkDueMedicine() async {
    final repository = MedicineRepository();
    final now = DateTime.now();
    final meds = await repository.getActiveMedicinesForDay(now);
    final takenKeys = await repository.getTakenDoseKeys(now);
    String? due;
    for (final m in meds) {
      for (final t in m.times) {
        final parts = t.split(':');
        final doseMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
        final nowMinutes = now.hour * 60 + now.minute;
        if (!takenKeys.contains('${m.id}_$t') && (nowMinutes - doseMinutes).abs() <= 10 && nowMinutes >= doseMinutes) {
          due = '${m.name} (${m.dosage})';
        }
      }
    }
    if (mounted) setState(() => _dueMedicine = due);
  }

  @override
  void dispose() {
    _medicineCheckTimer?.cancel();
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

    final timerTimeText = timerProvider.mode == TimerMode.pomodoro
        ? timerProvider.formattedPomodoro
        : timerProvider.formattedElapsed;
    final timerProgressValue = timerProvider.mode == TimerMode.pomodoro
        ? 1 -
            (timerProvider.pomodoroRemaining.inSeconds /
                (TimerProvider.pomodoroFocusMinutes * 60))
        : timerProvider.progressAgainstPlan;
    final timerSubtitle = activeTask?.title ?? "Vazifa tanlanmagan";

    final Widget timer;
    switch (settings.settings.timerStyle) {
      case 'big_digits':
        timer = BigDigitTimerDisplay(
            timeText: timerTimeText, accentColor: accent, subtitle: timerSubtitle);
        break;
      case 'hourglass':
        timer = HourglassTimerDisplay(
            timeText: timerTimeText,
            progress: timerProgressValue,
            accentColor: accent,
            subtitle: timerSubtitle);
        break;
      case 'percentage_ring':
        timer = PercentageRingTimerDisplay(
            timeText: timerTimeText, progress: timerProgressValue, accentColor: accent, subtitle: timerSubtitle);
        break;
      case 'egg':
        timer = EggTimerDisplay(
            timeText: timerTimeText, progress: timerProgressValue, accentColor: accent, subtitle: timerSubtitle);
        break;
      case 'tomato':
        timer = TomatoTimerDisplay(timeText: timerTimeText, progress: timerProgressValue, subtitle: timerSubtitle);
        break;
      case 'mechanical_stopwatch':
        timer = MechanicalStopwatchDisplay(
            timeText: timerTimeText, progress: timerProgressValue, subProgress: timerProgressValue, subtitle: timerSubtitle);
        break;
      case 'hud':
        timer = HudTimerDisplay(timeText: timerTimeText, subtitle: timerSubtitle);
        break;
      case 'flip':
        timer = FlipTimerDisplay(timeText: timerTimeText, accentColor: accent, subtitle: timerSubtitle);
        break;
      default:
        timer = TimerDisplay(
          timeText: timerTimeText,
          progress: timerProgressValue,
          accentColor: accent,
          subtitle: timerSubtitle,
          neonStyle: extras.glowEnabled,
        );
    }

    final Widget clock;
    switch (settings.settings.clockStyle) {
      case 'digital':
        clock = DigitalClock(accentColor: accent);
        break;
      case 'smartwatch_round':
        clock = SmartWatchRoundClock(accentColor: accent);
        break;
      case 'smartwatch_square':
        clock = SmartWatchSquareClock(accentColor: accent);
        break;
      case 'kurant':
        clock = KurantClock(accentColor: accent);
        break;
      case 'day_cycle':
        clock = DayCycleClock(accentColor: accent);
        break;
      case 'islamic_watch':
        clock = IslamicWatchClock(accentColor: accent);
        break;
      case 'gear_wall_clock':
        clock = GearWallClock(accentColor: accent);
        break;
      default:
        clock = MediumClock(accentColor: accent);
    }

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
              if (_dueMedicine != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.medication, size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Dori vaqti: $_dueMedicine', style: const TextStyle(fontSize: 12))),
                      ],
                    ),
                  ),
                ),
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
                        motivationCategory: activeTask?.category,
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
                        motivationCategory: activeTask?.category,
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
  final String? motivationCategory;
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
    this.motivationCategory,
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
                  MotivationBoard(taskCategory: motivationCategory),
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
  final String? motivationCategory;
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
    this.motivationCategory,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
            MotivationBoard(taskCategory: motivationCategory),
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
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: "Soat/Taymer ko'rinishi",
            onPressed: () => _showStylePicker(context),
          ),
        ],
      ),
    );
  }

  void _showStylePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _ClockTimerStyleSheet(),
    );
  }
}

class _ClockTimerStyleSheet extends StatelessWidget {
  const _ClockTimerStyleSheet();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 12),
          SwipeableStylePicker(
            label: 'Soat (chapga/o\'ngga suring)',
            ids: const [
              'analog', 'digital', 'smartwatch_round', 'smartwatch_square',
              'kurant', 'day_cycle', 'islamic_watch', 'gear_wall_clock',
            ],
            displayLabels: const {
              'analog': 'Analog',
              'digital': 'Raqamli',
              'smartwatch_round': 'Smart watch (dumaloq)',
              'smartwatch_square': "Smart watch (to'rtburchak)",
              'kurant': 'Kurant (mayatnikli)',
              'day_cycle': 'Quyosh/Oy aylanishi',
              'islamic_watch': 'Islomiy soat (Qibla)',
              'gear_wall_clock': "Mexanik g'ildirakli (3D)",
            },
            value: settings.settings.clockStyle,
            onChanged: settings.setClockStyle,
            previewBuilder: (id) {
              final accent = Theme.of(context).colorScheme.primary;
              switch (id) {
                case 'digital':
                  return DigitalClock(accentColor: accent);
                case 'smartwatch_round':
                  return SmartWatchRoundClock(accentColor: accent);
                case 'smartwatch_square':
                  return SmartWatchSquareClock(accentColor: accent);
                case 'kurant':
                  return KurantClock(accentColor: accent);
                case 'day_cycle':
                  return DayCycleClock(accentColor: accent);
                case 'islamic_watch':
                  return IslamicWatchClock(accentColor: accent);
                case 'gear_wall_clock':
                  return GearWallClock(accentColor: accent);
                default:
                  return MediumClock(accentColor: accent);
              }
            },
          ),
          SwipeableStylePicker(
            label: 'Taymer (chapga/o\'ngga suring)',
            ids: const [
              'ring', 'big_digits', 'hourglass', 'flip', 'percentage_ring',
              'egg', 'tomato', 'mechanical_stopwatch', 'hud',
            ],
            displayLabels: const {
              'ring': "Halqa",
              'big_digits': 'Katta raqam',
              'hourglass': 'Qumsoat',
              'flip': "Retro (mexanik qog'ozli)",
              'percentage_ring': 'Foizli halqa',
              'egg': "Tuxum taymer (3D)",
              'tomato': 'Pomidor (Pomodoro, 3D)',
              'mechanical_stopwatch': 'Mexanik sekundomer (3D)',
              'hud': 'HUD (avtomobil uslubi)',
            },
            value: settings.settings.timerStyle,
            onChanged: settings.setTimerStyle,
            previewBuilder: (id) {
              final accent = Theme.of(context).colorScheme.primary;
              const demoTime = '12:34';
              switch (id) {
                case 'big_digits':
                  return BigDigitTimerDisplay(timeText: demoTime, accentColor: accent, subtitle: '');
                case 'hourglass':
                  return HourglassTimerDisplay(timeText: demoTime, progress: 0.4, accentColor: accent, subtitle: '');
                case 'flip':
                  return FlipTimerDisplay(timeText: demoTime, accentColor: accent, subtitle: '');
                case 'percentage_ring':
                  return PercentageRingTimerDisplay(timeText: demoTime, progress: 0.4, accentColor: accent, subtitle: '');
                case 'egg':
                  return EggTimerDisplay(timeText: demoTime, progress: 0.4, accentColor: accent, subtitle: '');
                case 'tomato':
                  return TomatoTimerDisplay(timeText: demoTime, progress: 0.4, subtitle: '');
                case 'mechanical_stopwatch':
                  return MechanicalStopwatchDisplay(timeText: demoTime, progress: 0.4, subProgress: 0.4, subtitle: '');
                case 'hud':
                  return HudTimerDisplay(timeText: demoTime, subtitle: '');
                default:
                  return TimerDisplay(timeText: demoTime, progress: 0.4, accentColor: accent, subtitle: '', neonStyle: false);
              }
            },
          ),
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
