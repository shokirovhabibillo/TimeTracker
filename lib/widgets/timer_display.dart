import 'dart:math';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Large circular Stopwatch/Pomodoro display — the centerpiece of the
/// landscape Focus Mode dashboard.
class TimerDisplay extends StatelessWidget {
  final String timeText;
  final double progress; // 0..1, progress against the planned task duration
  final Color accentColor;
  final bool neonStyle;
  final String subtitle;

  const TimerDisplay({
    super.key,
    required this.timeText,
    required this.progress,
    required this.accentColor,
    required this.subtitle,
    this.neonStyle = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 260,
            height: 260,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 10,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation(accentColor),
            ),
          ),
          if (neonStyle)
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: AppTheme.neonGlow(accentColor, intensity: 0.25),
              ),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeText,
                style: TextStyle(
                  fontSize: 46,
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Medium analog clock shown alongside the timer.
class MediumClock extends StatelessWidget {
  final Color accentColor;
  const MediumClock({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
      initialData: DateTime.now(),
      builder: (context, snapshot) {
        final now = snapshot.data!;
        return SizedBox(
          width: 120,
          height: 120,
          child: CustomPaint(
            painter: _ClockPainter(time: now, accentColor: accentColor),
          ),
        );
      },
    );
  }
}

class _ClockPainter extends CustomPainter {
  final DateTime time;
  final Color accentColor;
  _ClockPainter({required this.time, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final facePaint = Paint()..color = Colors.white.withOpacity(0.05);
    canvas.drawCircle(center, radius, facePaint);

    final rimPaint = Paint()
      ..color = accentColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 1, rimPaint);

    for (int i = 0; i < 12; i++) {
      final angle = i * pi / 6;
      final outer = Offset(center.dx + radius * 0.9 * sin(angle),
          center.dy - radius * 0.9 * cos(angle));
      final inner = Offset(center.dx + radius * 0.78 * sin(angle),
          center.dy - radius * 0.78 * cos(angle));
      canvas.drawLine(
          inner, outer, Paint()..color = Colors.white.withOpacity(0.4)..strokeWidth = 1.5);
    }

    final hourAngle = (time.hour % 12 + time.minute / 60) * pi / 6;
    final minuteAngle = (time.minute + time.second / 60) * pi / 30;
    final secondAngle = time.second * pi / 30;

    _drawHand(canvas, center, hourAngle, radius * 0.5, 3, Colors.white);
    _drawHand(canvas, center, minuteAngle, radius * 0.72, 2, Colors.white70);
    _drawHand(canvas, center, secondAngle, radius * 0.8, 1, accentColor);

    canvas.drawCircle(center, 3, Paint()..color = accentColor);
  }

  void _drawHand(Canvas canvas, Offset center, double angle, double length,
      double width, Color color) {
    final end = Offset(center.dx + length * sin(angle), center.dy - length * cos(angle));
    canvas.drawLine(center, end,
        Paint()
          ..color = color
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) => true;
}
