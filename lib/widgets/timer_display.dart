import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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
    final capH = h * 0.06;
    final neckY = h * 0.5;
    final neckHalfW = w * 0.045;

    // Wooden end-caps (top and bottom), giving it a real hourglass-stand look.
    final woodPaint = Paint()..color = const Color(0xFF8D6748);
    final capRadius = Radius.circular(capH * 0.4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.06, 0, w * 0.88, capH), capRadius),
      woodPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.06, h - capH, w * 0.88, capH), capRadius),
      woodPaint,
    );

    // Curved glass silhouette — bulges out top/bottom, pinches at the neck.
    final glassOutline = Path()
      ..moveTo(w * 0.14, capH)
      ..quadraticBezierTo(w * 0.08, h * 0.28, w * 0.5 - neckHalfW, neckY)
      ..quadraticBezierTo(w * 0.08, h * 0.72, w * 0.14, h - capH)
      ..lineTo(w * 0.86, h - capH)
      ..quadraticBezierTo(w * 0.92, h * 0.72, w * 0.5 + neckHalfW, neckY)
      ..quadraticBezierTo(w * 0.92, h * 0.28, w * 0.86, capH)
      ..close();

    // Subtle glass fill (very light) plus a glossy highlight streak.
    canvas.drawPath(glassOutline, Paint()..color = glassColor.withOpacity(0.06));
    canvas.drawPath(
      glassOutline,
      Paint()
        ..color = glassColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.save();
    canvas.clipPath(glassOutline);
    canvas.drawLine(
      Offset(w * 0.28, capH + 4),
      Offset(w * 0.28, h - capH - 4),
      Paint()
        ..color = Colors.white.withOpacity(0.25)
        ..strokeWidth = w * 0.05
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    final sandPaint = Paint()..color = sandColor;

    canvas.save();
    canvas.clipPath(glassOutline);

    // Top chamber sand (shrinks as progress increases) — flat top, pinched bottom.
    final topRemaining = 1 - progress;
    if (topRemaining > 0.02) {
      final startY = neckY - (neckY - capH) * topRemaining;
      final topSand = Path()
        ..moveTo(w * 0.16, startY)
        ..lineTo(w * 0.84, startY)
        ..quadraticBezierTo(w * 0.5, neckY - 6, w * 0.5 - neckHalfW, neckY)
        ..lineTo(w * 0.5 + neckHalfW, neckY)
        ..quadraticBezierTo(w * 0.5, neckY - 6, w * 0.84, startY)
        ..close();
      canvas.drawPath(topSand, sandPaint);
    }

    // Falling stream through the neck.
    if (progress > 0.02 && progress < 0.98) {
      canvas.drawLine(Offset(w * 0.5, neckY - 4), Offset(w * 0.5, neckY + 4),
          Paint()..color = sandColor..strokeWidth = 2.5);
    }

    // Bottom chamber sand (grows as progress increases), piling up from the base.
    if (progress > 0.02) {
      final baseY = h - capH - 2;
      final maxPileH = (baseY - neckY) * 0.9;
      final pileH = maxPileH * progress;
      final topY = baseY - pileH;
      final spread = (w * 0.36) * progress;
      final bottomSand = Path()
        ..moveTo(w * 0.5 - spread, baseY)
        ..lineTo(w * 0.5 + spread, baseY)
        ..lineTo(w * 0.5, topY.clamp(neckY, baseY))
        ..close();
      canvas.drawPath(bottomSand, sandPaint);
    }

    canvas.restore();
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


/// Percentage-ring timer — tick marks and 10%-100% labels around the
/// ring, like a physical countdown-timer gadget.
class PercentageRingTimerDisplay extends StatelessWidget {
  final String timeText;
  final double progress;
  final Color accentColor;
  final String subtitle;

  const PercentageRingTimerDisplay({
    super.key,
    required this.timeText,
    required this.progress,
    required this.accentColor,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final trackColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.15);
    final subtitleColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(240, 240),
                painter: _PercentageRingPainter(progress: progress.clamp(0, 1), color: accentColor, trackColor: trackColor),
              ),
              Text(timeText,
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      fontFeatures: const [FontFeature.tabularFigures()])),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(subtitle, style: TextStyle(fontSize: 12, color: subtitleColor)),
      ],
    );
  }
}

class _PercentageRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  _PercentageRingPainter({required this.progress, required this.color, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 18;

    for (int i = 0; i < 40; i++) {
      final angle = 2 * pi * i / 40 - pi / 2;
      final isMajor = i % 4 == 0;
      final r1 = radius + (isMajor ? 10 : 6);
      final r2 = radius + 14;
      final p1 = Offset(center.dx + r1 * cos(angle), center.dy + r1 * sin(angle));
      final p2 = Offset(center.dx + r2 * cos(angle), center.dy + r2 * sin(angle));
      canvas.drawLine(p1, p2, Paint()..color = trackColor..strokeWidth = isMajor ? 2 : 1);
    }

    canvas.drawCircle(center, radius, Paint()..color = trackColor..style = PaintingStyle.stroke..strokeWidth = 10);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _PercentageRingPainter oldDelegate) => oldDelegate.progress != progress;
}

/// Sun/moon day-cycle clock — a circle with the sun/moon positioned to
/// show roughly where "now" sits in the day/night cycle.
class DayCycleClock extends StatelessWidget {
  final Color accentColor;
  const DayCycleClock({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
      initialData: DateTime.now(),
      builder: (context, snapshot) {
        final now = snapshot.data!;
        final dayFraction = (now.hour * 60 + now.minute) / (24 * 60);
        return SizedBox(
          width: 130,
          height: 130,
          child: CustomPaint(
            painter: _DayCyclePainter(dayFraction: dayFraction, lineColor: onSurface.withOpacity(0.2)),
            child: Center(
              child: Text(
                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: onSurface),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DayCyclePainter extends CustomPainter {
  final double dayFraction;
  final Color lineColor;
  _DayCyclePainter({required this.dayFraction, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 12;
    canvas.drawCircle(center, radius, Paint()..color = lineColor..style = PaintingStyle.stroke..strokeWidth = 1.5);

    final angle = 2 * pi * dayFraction - pi / 2;
    final isDay = dayFraction > 0.25 && dayFraction < 0.75;
    final bodyPos = Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));

    canvas.drawCircle(bodyPos, 8, Paint()..color = isDay ? const Color(0xFFFFC940) : const Color(0xFFB0BEC5));
  }

  @override
  bool shouldRepaint(covariant _DayCyclePainter oldDelegate) => true;
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

/// Islamic-watch-style face — inspired by "Al-Salah"/"Al-Fajr" smart
/// watches: digital time, an approximate Hijri date, and the Qibla
/// bearing (computed once from the device's last known location,
/// pointing to the Kaaba) — no live compass/magnetometer needed.
class IslamicWatchClock extends StatefulWidget {
  final Color accentColor;
  const IslamicWatchClock({super.key, required this.accentColor});

  @override
  State<IslamicWatchClock> createState() => _IslamicWatchClockState();
}

class _IslamicWatchClockState extends State<IslamicWatchClock> {
  double? _qiblaBearing;

  @override
  void initState() {
    super.initState();
    _loadQibla();
  }

  Future<void> _loadQibla() async {
    try {
      final pos = await Geolocator.getLastKnownPosition();
      if (pos == null) return;
      const kaabaLat = 21.4225, kaabaLng = 39.8262;
      final lat1 = pos.latitude * pi / 180;
      final lat2 = kaabaLat * pi / 180;
      final dLng = (kaabaLng - pos.longitude) * pi / 180;
      final y = sin(dLng) * cos(lat2);
      final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
      final bearing = (atan2(y, x) * 180 / pi + 360) % 360;
      if (mounted) setState(() => _qiblaBearing = bearing);
    } catch (_) {
      // No location permission/service — Qibla readout just stays hidden.
    }
  }

  String _approxHijriDate(DateTime g) {
    // Widely-used simple Kuwaiti-algorithm-style approximation — good
    // enough for a watch-face display, not a substitute for a proper
    // mosque-verified calendar.
    final jd = g.millisecondsSinceEpoch / 86400000.0 + 2440587.5;
    final islamicEpoch = 1948439.5;
    final daysSinceEpoch = (jd - islamicEpoch).floor();
    final cycles = (daysSinceEpoch / 10631).floor();
    var remaining = daysSinceEpoch - cycles * 10631;
    var year = cycles * 30 + 1;
    while (true) {
      final yearLength = _isHijriLeap(year) ? 355 : 354;
      if (remaining < yearLength) break;
      remaining -= yearLength;
      year++;
    }
    const monthLengths = [30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29];
    var month = 1;
    for (final len in monthLengths) {
      final actualLen = (month == 12 && _isHijriLeap(year)) ? 30 : len;
      if (remaining < actualLen) break;
      remaining -= actualLen;
      month++;
    }
    final day = remaining.floor() + 1;
    const monthNames = [
      'Muharram', 'Safar', "Rabi' I", "Rabi' II", 'Jumada I', 'Jumada II',
      'Rajab', "Sha'ban", 'Ramazon', 'Shavvol', "Zul-Qa'da", "Zul-Hijja",
    ];
    final monthName = monthNames[(month - 1).clamp(0, 11)];
    return '$day $monthName $year';
  }

  bool _isHijriLeap(int year) => (11 * year + 14) % 30 < 11;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(const Duration(seconds: 30), (_) => DateTime.now()),
      initialData: DateTime.now(),
      builder: (context, snapshot) {
        final now = snapshot.data!;
        final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        return Container(
          width: 190,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0E2A1A), Color(0xFF163B24)]),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: widget.accentColor.withOpacity(0.5), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_approxHijriDate(now),
                  style: TextStyle(color: widget.accentColor, fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(timeStr,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [FontFeature.tabularFigures()])),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.explore_outlined, size: 14, color: widget.accentColor),
                  const SizedBox(width: 4),
                  Text(
                    _qiblaBearing != null ? "Qibla: ${_qiblaBearing!.round()}°" : "Qibla: joylashuv kerak",
                    style: TextStyle(color: widget.accentColor, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
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
