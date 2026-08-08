import 'dart:math';
import 'package:flutter/material.dart';

/// A percentage ring drawn as short dash segments rather than a solid
/// arc — more visually attention-grabbing, used at the top of the
/// Planner screen for the day's completion percentage.
class StripedPercentageRing extends StatelessWidget {
  final double value; // 0..1
  final Color color;
  final double size;
  final bool glow;

  const StripedPercentageRing({
    super.key,
    required this.value,
    required this.color,
    this.size = 72,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    final trackColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (glow)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 14)],
              ),
            ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.clamp(0, 1)),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, _) {
              return CustomPaint(
                size: Size(size, size),
                painter: _StripedRingPainter(progress: animatedValue, color: color, trackColor: trackColor),
              );
            },
          ),
          Text(
            '${(value * 100).round()}%',
            style: TextStyle(fontSize: size * 0.24, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class _StripedRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  _StripedRingPainter({required this.progress, required this.color, required this.trackColor});

  static const _dashCount = 60;
  static const _dashFraction = 0.62; // fraction of each slot that's "on"

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 6;
    final anglePerDash = (2 * pi) / _dashCount;
    final activeDashes = (progress * _dashCount).round();

    for (var i = 0; i < _dashCount; i++) {
      final start = -pi / 2 + i * anglePerDash;
      final sweep = anglePerDash * _dashFraction;
      final paint = Paint()
        ..color = i < activeDashes ? color : trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StripedRingPainter oldDelegate) => oldDelegate.progress != progress;
}
