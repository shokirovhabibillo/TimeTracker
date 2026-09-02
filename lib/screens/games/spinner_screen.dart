import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/models/task_model.dart';
import '../../data/repositories/daily_spin_repository.dart';
import '../../data/repositories/task_repository.dart';

/// A real 3-reel slot machine — three separate spinning "windows" (each
/// with its own viewing hole), mounted on a frame with three "ear" tabs
/// up top. Reel 1 lands on a task, reel 2 on a suggested time-of-day
/// window, reel 3 on how many times to repeat it — matching a real
/// slot machine's staggered stop (leftmost reel stops first).
class SpinnerScreen extends StatefulWidget {
  const SpinnerScreen({super.key});

  @override
  State<SpinnerScreen> createState() => _SpinnerScreenState();
}

const List<String> _timeWindows = ['Ertalab', 'Tushlikdan oldin', 'Tushdan keyin', 'Kechqurun'];
const List<int> _repeatCounts = [1, 2, 3];

class _SpinnerScreenState extends State<SpinnerScreen> with TickerProviderStateMixin {
  final _taskRepository = TaskRepository();
  final _spinRepository = DailySpinRepository();
  final _rand = Random();

  static const _itemHeight = 56.0;
  late final AnimationController _reel1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
  late final AnimationController _reel2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 2300));
  late final AnimationController _reel3 = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800));

  List<String> _reel1Items = ['?'];
  List<String> _reel2Items = List.of(_timeWindows);
  List<String> _reel3Items = _repeatCounts.map((c) => '${c}x').toList();

  bool _spinning = false;
  TaskModel? _resultTask;
  String? _resultWindow;
  int? _resultMultiplier;
  int? _spinId;
  List<DailySpin> _recent = [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final recent = await _spinRepository.getRecent();
    if (mounted) setState(() => _recent = recent);
  }

  /// Builds a long "strip" for a reel: the real candidates repeated
  /// several times (for a satisfying multi-loop spin), ending exactly
  /// on [landOn] as the final visible item.
  List<String> _buildStrip(List<String> candidates, String landOn, int loops) {
    final strip = <String>[];
    for (var i = 0; i < loops; i++) {
      strip.addAll(candidates..shuffle(_rand));
    }
    strip.add(landOn);
    return strip;
  }

  Future<void> _spin() async {
    if (_spinning) return;
    final tasks = await _taskRepository.getTasksForDay(DateTime.now());
    final incomplete = tasks.where((t) => !t.isCompleted).toList();
    if (incomplete.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Bugungi rejada bajarilmagan vazifa yo'q")));
      }
      return;
    }

    final chosenTask = incomplete[_rand.nextInt(incomplete.length)];
    final chosenWindow = _timeWindows[_rand.nextInt(_timeWindows.length)];
    final chosenCount = _repeatCounts[_rand.nextInt(_repeatCounts.length)];

    setState(() {
      _spinning = true;
      _resultTask = null;
      _resultWindow = null;
      _resultMultiplier = null;
      _reel1Items = _buildStrip(incomplete.map((t) => t.title).toList(), chosenTask.title, 3);
      _reel2Items = _buildStrip(_timeWindows, chosenWindow, 4);
      _reel3Items = _buildStrip(_repeatCounts.map((c) => '${c}x').toList(), '${chosenCount}x', 5);
    });

    await Future.wait([
      _reel1.forward(from: 0),
      _reel2.forward(from: 0),
      _reel3.forward(from: 0),
    ]);

    if (!mounted) return;
    final id = await _spinRepository.createSpin(DailySpin(
      taskId: chosenTask.id,
      taskTitle: chosenTask.title,
      multiplier: chosenCount,
    ));

    setState(() {
      _spinning = false;
      _resultTask = chosenTask;
      _resultWindow = chosenWindow;
      _resultMultiplier = chosenCount;
      _spinId = id;
    });
    _loadRecent();
  }

  Future<void> _scheduleResult() async {
    if (_resultTask == null || _spinId == null) return;
    final now = DateTime.now();
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(now));
    if (picked == null) return;

    final scheduled = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    await _spinRepository.setScheduledTime(_spinId!, scheduled);

    final multiplierNote = _resultMultiplier == 1 ? '' : ' (${_resultMultiplier}x)';
    await _taskRepository.createTask(TaskModel(
      title: '🎰 ${_resultTask!.title}$multiplierNote',
      category: _resultTask!.category,
      colorCode: _resultTask!.colorCode,
      startTime: scheduled,
      endTime: scheduled.add(const Duration(minutes: 20)),
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reja kalendariga qo\'shildi!')));
      setState(() {
        _resultTask = null;
        _resultWindow = null;
        _resultMultiplier = null;
        _spinId = null;
      });
    }
  }

  @override
  void dispose() {
    _reel1.dispose();
    _reel2.dispose();
    _reel3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spiner')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          const Text(
            "Dastakni torting — 1-teshikda qaysi vazifa, 2-teshikda qaysi vaqt oralig'i, "
            "3-teshikda necha marta bajarish chiqadi.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 20),
          _buildMachine(),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: _spinning ? null : _spin,
              icon: const Icon(Icons.casino),
              label: Text(_spinning ? 'Aylanmoqda...' : 'Dastakni tortish'),
            ),
          ),
          if (_resultTask != null) ...[
            const SizedBox(height: 20),
            Card(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(_resultTask!.title, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    Text('$_resultWindow · ${_resultMultiplier}x bajarish', style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _scheduleResult,
                      icon: const Icon(Icons.schedule),
                      label: const Text('Bajarish vaqtini belgilash'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (_recent.isNotEmpty) ...[
            const SizedBox(height: 28),
            Text('Oxirgi aylantirishlar', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ..._recent.map((s) => ListTile(
                  dense: true,
                  leading: Text('${s.multiplier}x', style: const TextStyle(fontWeight: FontWeight.bold)),
                  title: Text(s.taskTitle, style: const TextStyle(fontSize: 13)),
                  trailing: s.completed ? const Icon(Icons.check_circle, color: Colors.green, size: 18) : null,
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildMachine() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.primary.withOpacity(0.3), width: 2),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // The three "ears" — small tabs poking up from the frame, one
          // above each reel's hole.
          Positioned(
            top: -18,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (i) => _Ear(color: scheme.primary)),
            ),
          ),
          Row(
            children: [
              Expanded(child: _SlotReel(controller: _reel1, items: _reel1Items, itemHeight: _itemHeight, fontSize: 12)),
              const SizedBox(width: 8),
              Expanded(child: _SlotReel(controller: _reel2, items: _reel2Items, itemHeight: _itemHeight, fontSize: 12)),
              const SizedBox(width: 8),
              Expanded(child: _SlotReel(controller: _reel3, items: _reel3Items, itemHeight: _itemHeight, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Ear extends StatelessWidget {
  final Color color;
  const _Ear({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 22,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      ),
    );
  }
}

/// One spinning reel — a fixed-height "hole" (ClipRect) showing one
/// item at a time, with the full item strip scrolling vertically
/// behind it and decelerating to a stop on the final item.
class _SlotReel extends StatelessWidget {
  final AnimationController controller;
  final List<String> items;
  final double itemHeight;
  final double fontSize;
  const _SlotReel({required this.controller, required this.items, required this.itemHeight, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: itemHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outline.withOpacity(0.3)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      clipBehavior: Clip.hardEdge,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          if (items.isEmpty) return const SizedBox.shrink();
          final totalHeight = items.length * itemHeight;
          final targetOffset = totalHeight - itemHeight; // scroll to the final (landing) item
          final eased = Curves.decelerate.transform(controller.value);
          final offset = targetOffset * eased;

          return Transform.translate(
            offset: Offset(0, -offset),
            child: Column(
              children: items
                  .map((item) => SizedBox(
                        height: itemHeight,
                        child: Center(
                          child: Text(
                            item,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
