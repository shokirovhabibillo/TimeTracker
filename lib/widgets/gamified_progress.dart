import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

enum GamifiedVisualStyle { growingTree, chargingBattery, stars }

/// Small gamified visual that reflects the day's completion percentage.
/// Purely decorative reward feedback — style varies per theme mood.
class GamifiedProgress extends StatelessWidget {
  final double progress; // 0..1
  final GamifiedVisualStyle style;
  final Color accentColor;

  const GamifiedProgress({
    super.key,
    required this.progress,
    this.style = GamifiedVisualStyle.growingTree,
    this.accentColor = const Color(0xFF39FF14),
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case GamifiedVisualStyle.growingTree:
        return _TreeVisual(progress: progress, color: accentColor);
      case GamifiedVisualStyle.chargingBattery:
        return _BatteryVisual(progress: progress, color: accentColor);
      case GamifiedVisualStyle.stars:
        return _StarsVisual(progress: progress, color: accentColor);
    }
  }
}

class _TreeVisual extends StatelessWidget {
  final double progress;
  final Color color;
  const _TreeVisual({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    final scale = 0.3 + progress.clamp(0, 1) * 0.7;
    final extras = Theme.of(context).extension<AppThemeExtras>();
    final textColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
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
              child: Icon(
                Icons.park,
                size: 56,
                color: color,
                shadows: (extras?.glowEnabled ?? false) ? AppTheme.neonGlow(color) : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text('${(progress * 100).round()}% bajarildi',
            style: TextStyle(fontSize: 10, color: textColor)),
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
    final borderColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.15);
    final textColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 60,
          height: 32,
          child: CustomPaint(
            painter: _BatteryPainter(progress: progress.clamp(0, 1), color: color, borderColor: borderColor),
          ),
        ),
        const SizedBox(height: 4),
        Text('${(progress * 100).round()}% quvvat', style: TextStyle(fontSize: 10, color: textColor)),
      ],
    );
  }
}

class _BatteryPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color borderColor;
  _BatteryPainter({required this.progress, required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyRect = Rect.fromLTWH(0, 0, size.width - 6, size.height);
    final bodyRRect = RRect.fromRectAndRadius(bodyRect, const Radius.circular(4));
    canvas.drawRRect(
        bodyRRect,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    final capRect = Rect.fromLTWH(size.width - 6, size.height * 0.28, 6, size.height * 0.44);
    canvas.drawRect(capRect, Paint()..color = borderColor);

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

/// "Yulduzlar" — bolalar/yoshlar temalari uchun o'yin-uslubidagi mukofot
/// vizuali: har bir 20% progress uchun bitta yulduz yonadi.
class _StarsVisual extends StatelessWidget {
  final double progress;
  final Color color;
  const _StarsVisual({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    final litStars = (progress.clamp(0, 1) * 5).round();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) {
            final lit = i < litStars;
            return Icon(
              lit ? Icons.star : Icons.star_border,
              size: 22,
              color: lit ? color : textColor,
            );
          }),
        ),
        const SizedBox(height: 4),
        Text('${(progress * 100).round()}% bajarildi', style: TextStyle(fontSize: 10, color: textColor)),
      ],
    );
  }
}
