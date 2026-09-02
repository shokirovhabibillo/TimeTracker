import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/models/task_model.dart';
import '../../data/repositories/daily_spin_repository.dart';
import '../../data/repositories/task_repository.dart';

class SpinnerScreen extends StatefulWidget {
  const SpinnerScreen({super.key});

  @override
  State<SpinnerScreen> createState() => _SpinnerScreenState();
}

// Wheel has 6 segments, alternating multiplier values around it.
const List<int> _wheelSegments = [1, 2, 3, 1, 2, 3];

class _SpinnerScreenState extends State<SpinnerScreen> with SingleTickerProviderStateMixin {
  final _taskRepository = TaskRepository();
  final _spinRepository = DailySpinRepository();
  final _rand = Random();

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));
  late Animation<double> _rotation;

  bool _spinning = false;
  int? _resultMultiplier;
  TaskModel? _resultTask;
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
    final targetSegment = _rand.nextInt(_wheelSegments.length);
    final chosenMultiplier = _wheelSegments[targetSegment];

    // Spin several full turns, landing exactly on the chosen segment
    // under the top pointer.
    final segmentAngle = 2 * pi / _wheelSegments.length;
    final targetAngle = -(targetSegment * segmentAngle) - segmentAngle / 2;
    final extraTurns = 4 + _rand.nextInt(3);
    final endValue = _controller.value + extraTurns * 2 * pi + (targetAngle - (_controller.value % (2 * pi)));

    setState(() {
      _spinning = true;
      _resultMultiplier = null;
      _resultTask = null;
    });

    _rotation = Tween<double>(begin: _controller.value, end: endValue)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.decelerate));
    _controller.forward(from: 0);

    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;

    final id = await _spinRepository.createSpin(DailySpin(
      taskId: chosenTask.id,
      taskTitle: chosenTask.title,
      multiplier: chosenMultiplier,
    ));

    setState(() {
      _spinning = false;
      _resultMultiplier = chosenMultiplier;
      _resultTask = chosenTask;
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

    final multiplierNote = _resultMultiplier == 1 ? '' : ' (${_resultMultiplier}x bonus!)';
    await _taskRepository.createTask(TaskModel(
      title: '🎡 ${_resultTask!.title}$multiplierNote',
      category: _resultTask!.category,
      colorCode: _resultTask!.colorCode,
      startTime: scheduled,
      endTime: scheduled.add(const Duration(minutes: 20)),
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reja kalendariga qo\'shildi!')));
      setState(() {
        _resultMultiplier = null;
        _resultTask = null;
        _spinId = null;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _segmentColor(int multiplier) {
    switch (multiplier) {
      case 3:
        return const Color(0xFFE11D48);
      case 2:
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spiner')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          const Text(
            "G'ildirakni aylantiring — tasodifiy vazifa va bonus multiplikator (1x/2x/3x) tanlanadi.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final angle = _spinning ? _rotation.value : 0.0;
                      return Transform.rotate(angle: angle, child: child);
                    },
                    child: CustomPaint(
                      size: const Size(260, 260),
                      painter: _WheelPainter(segments: _wheelSegments, colorFor: _segmentColor),
                    ),
                  ),
                  const Positioned(top: 0, child: Icon(Icons.arrow_drop_down, size: 40, color: Colors.black87)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: _spinning ? null : _spin,
              icon: const Icon(Icons.casino),
              label: Text(_spinning ? 'Aylanmoqda...' : 'Aylantirish'),
            ),
          ),
          if (_resultTask != null) ...[
            const SizedBox(height: 20),
            Card(
              color: _segmentColor(_resultMultiplier!).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('${_resultMultiplier}x', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_resultTask!.title, style: const TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
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
                  leading: Text('${s.multiplier}x', style: TextStyle(color: _segmentColor(s.multiplier), fontWeight: FontWeight.bold)),
                  title: Text(s.taskTitle, style: const TextStyle(fontSize: 13)),
                  trailing: s.completed ? const Icon(Icons.check_circle, color: Colors.green, size: 18) : null,
                )),
          ],
        ],
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<int> segments;
  final Color Function(int) colorFor;
  _WheelPainter({required this.segments, required this.colorFor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * pi / segments.length;

    for (var i = 0; i < segments.length; i++) {
      final paint = Paint()..color = colorFor(segments[i]);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), i * segmentAngle - pi / 2, segmentAngle, true, paint);

      final labelAngle = (i + 0.5) * segmentAngle - pi / 2;
      final labelOffset = center + Offset(cos(labelAngle), sin(labelAngle)) * radius * 0.65;
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${segments[i]}x',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, labelOffset - Offset(textPainter.width / 2, textPainter.height / 2));
    }

    canvas.drawCircle(center, radius, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 4);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => false;
}
