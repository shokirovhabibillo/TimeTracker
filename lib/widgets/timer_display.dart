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
    final trackColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.08);
    final subtitleColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
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
              backgroundColor: trackColor,
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
                style: TextStyle(fontSize: 12, color: subtitleColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Sand-timer visual — the fill level (top chamber emptying into the
/// bottom one) tracks [progress] instead of a ring or plain digits.
class HourglassTimerDisplay extends StatelessWidget {
  final String timeText;
  final double progress; // 0..1
  final Color accentColor;
  final String subtitle;

  const HourglassTimerDisplay({
    super.key,
    required this.timeText,
    required this.progress,
    required this.accentColor,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final glassColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.4);
    final subtitleColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 140,
          height: 180,
          child: CustomPaint(
            painter: _HourglassPainter(progress: progress.clamp(0, 1), sandColor: accentColor, glassColor: glassColor),
          ),
        ),
        const SizedBox(height: 12),
        Text(timeText,
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: accentColor)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 12, color: subtitleColor)),
      ],
    );
  }
}

class _HourglassPainter extends CustomPainter {
  final double progress; // 0 = full top, 1 = full bottom (time elapsed)
  final Color sandColor;
  final Color glassColor;
  _HourglassPainter({required this.progress, required this.sandColor, required this.glassColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final glassPaint = Paint()
      ..color = glassColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final outline = Path()
      ..moveTo(w * 0.1, h * 0.02)
      ..lineTo(w * 0.9, h * 0.02)
      ..lineTo(w * 0.55, h * 0.48)
      ..lineTo(w * 0.9, h * 0.98)
      ..lineTo(w * 0.1, h * 0.98)
      ..lineTo(w * 0.45, h * 0.48)
      ..close();
    canvas.drawPath(outline, glassPaint);

    final sandPaint = Paint()..color = sandColor;

    // Top chamber sand (shrinks as progress increases).
    final topRemaining = 1 - progress;
    if (topRemaining > 0.02) {
      final topH = h * 0.44 * topRemaining;
      final topSand = Path()
        ..moveTo(w * 0.15, h * 0.06)
        ..lineTo(w * 0.85, h * 0.06)
        ..lineTo(w * 0.5, h * 0.06 + topH)
        ..close();
      canvas.drawPath(topSand, sandPaint);
    }

    // Falling stream.
    if (progress > 0.02 && progress < 0.98) {
      canvas.drawLine(Offset(w * 0.5, h * 0.46), Offset(w * 0.5, h * 0.54),
          Paint()..color = sandColor..strokeWidth = 2);
    }

    // Bottom chamber sand (grows as progress increases), piling up from the base.
    if (progress > 0.02) {
      final bottomH = h * 0.46 * progress;
      final baseY = h * 0.96;
      final topY = baseY - bottomH;
      final spread = (w * 0.4) * progress;
      final bottomSand = Path()
        ..moveTo(w * 0.5 - spread.clamp(0, w * 0.4), baseY)
        ..lineTo(w * 0.5 + spread.clamp(0, w * 0.4), baseY)
        ..lineTo(w * 0.5, topY.clamp(h * 0.5, baseY))
        ..close();
      canvas.drawPath(bottomSand, sandPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HourglassPainter oldDelegate) => oldDelegate.progress != progress;
}

/// Retro split-flap ("flip clock") style digit display.
class FlipTimerDisplay extends StatelessWidget {
  final String timeText;
  final Color accentColor;
  final String subtitle;

  const FlipTimerDisplay({
    super.key,
    required this.timeText,
    required this.accentColor,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    final chars = timeText.split('');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: chars.map((c) {
            if (c == ':') {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(':', style: TextStyle(fontSize: 40, color: accentColor, fontWeight: FontWeight.bold)),
              );
            }
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 34,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: accentColor.withOpacity(0.5), width: 1.5),
              ),
              child: Text(
                c,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: accentColor,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(subtitle, style: TextStyle(fontSize: 12, color: subtitleColor)),
      ],
    );
  }
}


/// to the ring TimerDisplay. No progress ring, just huge readable numbers.
class BigDigitTimerDisplay extends StatelessWidget {
  final String timeText;
  final Color accentColor;
  final String subtitle;

  const BigDigitTimerDisplay({
    super.key,
    required this.timeText,
    required this.accentColor,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          timeText,
          style: TextStyle(
            fontSize: 88,
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: accentColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(subtitle, style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }
}

/// Minimal digital clock — HH:mm:ss in large plain text, no clock face.
class DigitalClock extends StatelessWidget {
  final Color accentColor;
  const DigitalClock({super.key, required this.accentColor});

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
      initialData: DateTime.now(),
      builder: (context, snapshot) {
        final now = snapshot.data!;
        return Text(
          '${_two(now.hour)}:${_two(now.minute)}:${_two(now.second)}',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: accentColor,
          ),
        );
      },
    );
  }
}
class MediumClock extends StatelessWidget {
  final Color accentColor;
  const MediumClock({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final handColor = Theme.of(context).colorScheme.onSurface;
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
      initialData: DateTime.now(),
      builder: (context, snapshot) {
        final now = snapshot.data!;
        return SizedBox(
          width: 120,
          height: 120,
          child: CustomPaint(
            painter: _ClockPainter(time: now, accentColor: accentColor, handColor: handColor),
          ),
        );
      },
    );
  }
}

/// Round "smart watch" face — a bezel ring with digital time + date,
/// mimicking a round Apple Watch / WearOS face.
class SmartWatchRoundClock extends StatelessWidget {
  final Color accentColor;
  const SmartWatchRoundClock({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
      initialData: DateTime.now(),
      builder: (context, snapshot) {
        final now = snapshot.data!;
        final timeStr =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        return Container(
          width: 130,
          height: 130,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: onSurface.withOpacity(0.15), width: 6),
            color: Colors.black87,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(timeStr,
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFeatures: const [FontFeature.tabularFigures()])),
                const SizedBox(height: 4),
                Text('${now.day}/${now.month}',
                    style: TextStyle(fontSize: 12, color: accentColor)),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Square "smart watch" face — rounded-square bezel, Apple-Watch-square
/// style, digital time.
class SmartWatchSquareClock extends StatelessWidget {
  final Color accentColor;
  const SmartWatchSquareClock({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
      initialData: DateTime.now(),
      builder: (context, snapshot) {
        final now = snapshot.data!;
        final timeStr =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        return Container(
          width: 120,
          height: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.black87,
            border: Border.all(color: Colors.black, width: 4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(timeStr,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFeatures: const [FontFeature.tabularFigures()])),
              const SizedBox(height: 4),
              Container(width: 30, height: 3, color: accentColor),
              const SizedBox(height: 4),
              Text('${now.day} kun', style: TextStyle(fontSize: 11, color: accentColor)),
            ],
          ),
        );
      },
    );
  }
}

/// Wall/pendulum ("kurant") clock — analog face with a swinging pendulum
/// underneath for a classic living-room-clock feel.
class KurantClock extends StatefulWidget {
  final Color accentColor;
  const KurantClock({super.key, required this.accentColor});

  @override
  State<KurantClock> createState() => _KurantClockState();
}

class _KurantClockState extends State<KurantClock> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final handColor = Theme.of(context).colorScheme.onSurface;
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
      initialData: DateTime.now(),
      builder: (context, snapshot) {
        final now = snapshot.data!;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: CustomPaint(
                painter: _ClockPainter(time: now, accentColor: widget.accentColor, handColor: handColor),
              ),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final angle = (sin(_controller.value * pi * 2)) * 0.35;
                return Transform.rotate(
                  alignment: Alignment.topCenter,
                  angle: angle,
                  child: SizedBox(
                    width: 4,
                    height: 30,
                    child: CustomPaint(
                      painter: _PendulumPainter(color: widget.accentColor),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _PendulumPainter extends CustomPainter {
  final Color color;
  _PendulumPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height - 6),
        Paint()..color = color.withOpacity(0.6)..strokeWidth = 2);
    canvas.drawCircle(Offset(size.width / 2, size.height - 3), 5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PendulumPainter oldDelegate) => oldDelegate.color != color;
}

class _ClockPainter extends CustomPainter {
  final DateTime time;
  final Color accentColor;
  final Color handColor;
  _ClockPainter({required this.time, required this.accentColor, required this.handColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final facePaint = Paint()..color = handColor.withOpacity(0.05);
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
          inner, outer, Paint()..color = handColor.withOpacity(0.4)..strokeWidth = 1.5);
    }

    final hourAngle = (time.hour % 12 + time.minute / 60) * pi / 6;
    final minuteAngle = (time.minute + time.second / 60) * pi / 30;
    final secondAngle = time.second * pi / 30;

    _drawHand(canvas, center, hourAngle, radius * 0.5, 3, handColor);
    _drawHand(canvas, center, minuteAngle, radius * 0.72, 2, handColor.withOpacity(0.75));
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
