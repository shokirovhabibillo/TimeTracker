import 'package:flutter/material.dart';

/// A compact circular "donut" percentage indicator with the number in
/// the center — a more polished alternative to a flat progress bar for
/// showing the day's completion percentage.
class PercentageRing extends StatelessWidget {
  final double value; // 0..1
  final Color color;
  final double size;
  final bool glow;

  const PercentageRing({
    super.key,
    required this.value,
    required this.color,
    this.size = 56,
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
                boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 12)],
              ),
            ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.clamp(0, 1)),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, _) {
              return SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: animatedValue,
                  strokeWidth: size * 0.12,
                  strokeCap: StrokeCap.round,
                  backgroundColor: trackColor,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              );
            },
          ),
          Text(
            '${(value * 100).round()}%',
            style: TextStyle(
              fontSize: size * 0.26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
