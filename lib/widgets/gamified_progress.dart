import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

enum GamifiedVisualStyle { growingTree, chargingBattery }

/// Small gamified visual that reflects the day's completion percentage.
/// Purely decorative reward feedback for the High-Tech HUD theme.
class GamifiedProgress extends StatelessWidget {
  final double progress; // 0..1
  final GamifiedVisualStyle style;
  final Color accentColor;

  const GamifiedProgress({
    super.key,
    required this.progress,
    this.style = GamifiedVisualStyle.growingTree,
    this.accentColor = AppColors.htNeonGreen,
  });

  @override
  Widget build(BuildContext context) {
    return style == GamifiedVisualStyle.growingTree
        ? _TreeVisual(progress: progress, color: accentColor)
        : _BatteryVisual(progress: progress, color: accentColor);
  }
}

class _TreeVisual extends StatelessWidget {
  final double progress;
  final Color color;
  const _TreeVisual({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    final scale = 0.3 + progress.clamp(0, 1) * 0.7;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 70,
          width: 70,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 400),
              alignment: Alignment.bottomCenter,
              child: Icon(Icons.park, size: 56, color: color, shadows: AppTheme.neonGlow(color)),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text('${(progress * 100).round()}% bajarildi',
            style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6))),
      ],
    );
  }
}

class _BatteryVisual extends StatelessWidget {
  final double progress;
  final Color color;
  const _BatteryVisual({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 60,
          height: 32,
          child: CustomPaint(
            painter: _BatteryPainter(progress: progress.clamp(0, 1), color: color),
          ),
        ),
        const SizedBox(height: 4),
        Text('${(progress * 100).round()}% quvvat',
            style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6))),
      ],
    );
  }
}

class _BatteryPainter extends CustomPainter {
  final double progress;
  final Color color;
  _BatteryPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyRect = Rect.fromLTWH(0, 0, size.width - 6, size.height);
    final bodyRRect = RRect.fromRectAndRadius(bodyRect, const Radius.circular(4));
    canvas.drawRRect(
        bodyRRect,
        Paint()
          ..color = Colors.white.withOpacity(0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    final capRect = Rect.fromLTWH(size.width - 6, size.height * 0.28, 6, size.height * 0.44);
    canvas.drawRect(capRect, Paint()..color = Colors.white.withOpacity(0.3));

    final fillWidth = (size.width - 10) * progress;
    final fillRect = Rect.fromLTWH(2, 2, fillWidth, size.height - 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(fillRect, const Radius.circular(2)),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _BatteryPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
