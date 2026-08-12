import 'dart:math';
import 'package:flutter/material.dart';

enum BackgroundPatternType { none, asian, middleEastern, european, western, highTech, layered3D }

extension BackgroundPatternLabel on BackgroundPatternType {
  String get label {
    switch (this) {
      case BackgroundPatternType.none:
        return "Yo'q (toza fon)";
      case BackgroundPatternType.asian:
        return 'Osiyo xalqlari';
      case BackgroundPatternType.middleEastern:
        return 'Yaqin Sharq';
      case BackgroundPatternType.european:
        return 'Yevropa';
      case BackgroundPatternType.western:
        return "G'arb (minimalist)";
      case BackgroundPatternType.highTech:
        return 'Zamonaviy High-Tech';
      case BackgroundPatternType.layered3D:
        return '3D qatlamli (premium)';
    }
  }
}

/// Wraps [child] with a subtle, low-opacity tiled decorative pattern
/// behind it — purely cosmetic, never interferes with readability.
class PatternedBackground extends StatefulWidget {
  final BackgroundPatternType pattern;
  final Widget child;
  const PatternedBackground({super.key, required this.pattern, required this.child});

  @override
  State<PatternedBackground> createState() => _PatternedBackgroundState();
}

class _PatternedBackgroundState extends State<PatternedBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _drift =
      AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pattern == BackgroundPatternType.none) return widget.child;
    final color = Theme.of(context).colorScheme.onSurface;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Stack(
      children: [
        Positioned.fill(
          child: widget.pattern == BackgroundPatternType.layered3D && !reduceMotion
              ? AnimatedBuilder(
                  animation: _drift,
                  builder: (context, _) =>
                      CustomPaint(painter: _PatternPainter(pattern: widget.pattern, color: color, driftT: _drift.value)),
                )
              : CustomPaint(painter: _PatternPainter(pattern: widget.pattern, color: color, driftT: 0)),
        ),
        widget.child,
      ],
    );
  }
}

class _PatternPainter extends CustomPainter {
  final BackgroundPatternType pattern;
  final Color color;
  final double driftT;
  _PatternPainter({required this.pattern, required this.color, this.driftT = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    switch (pattern) {
      case BackgroundPatternType.asian:
        _paintAsianWaves(canvas, size, paint);
        break;
      case BackgroundPatternType.middleEastern:
        _paintIslamicStars(canvas, size, paint);
        break;
      case BackgroundPatternType.european:
        _paintDamask(canvas, size, paint);
        break;
      case BackgroundPatternType.western:
        _paintGrid(canvas, size, paint);
        break;
      case BackgroundPatternType.highTech:
        _paintCircuit(canvas, size, paint);
        break;
      case BackgroundPatternType.layered3D:
        _paintLayered3D(canvas, size);
        break;
      case BackgroundPatternType.none:
        break;
    }
  }

  // Rolling cloud/wave motif — evokes East/South-East Asian textile patterns.
  void _paintAsianWaves(Canvas canvas, Size size, Paint paint) {
    const spacing = 48.0;
    for (double y = -spacing; y < size.height + spacing; y += spacing) {
      final path = Path()..moveTo(-spacing, y);
      for (double x = -spacing; x < size.width + spacing; x += spacing) {
        path.quadraticBezierTo(x + spacing / 2, y - 18, x + spacing, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  // 8-point star lattice — classic Islamic geometric pattern.
  void _paintIslamicStars(Canvas canvas, Size size, Paint paint) {
    const cell = 56.0;
    for (double cy = cell / 2; cy < size.height + cell; cy += cell) {
      for (double cx = cell / 2; cx < size.width + cell; cx += cell) {
        final path = Path();
        const points = 8;
        for (int i = 0; i <= points; i++) {
          final angle = (pi * 2 / points) * i;
          final r = i.isEven ? cell * 0.42 : cell * 0.2;
          final x = cx + r * cos(angle);
          final y = cy + r * sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  // Repeating diamond + dot lattice — European damask/filigree feel.
  void _paintDamask(Canvas canvas, Size size, Paint paint) {
    const cell = 50.0;
    for (double cy = 0; cy < size.height + cell; cy += cell) {
      for (double cx = 0; cx < size.width + cell; cx += cell) {
        final offsetX = (cy ~/ cell).isEven ? 0.0 : cell / 2;
        final center = Offset(cx + offsetX, cy);
        final diamond = Path()
          ..moveTo(center.dx, center.dy - 14)
          ..lineTo(center.dx + 14, center.dy)
          ..lineTo(center.dx, center.dy + 14)
          ..lineTo(center.dx - 14, center.dy)
          ..close();
        canvas.drawPath(diamond, paint);
        canvas.drawCircle(center, 2, Paint()..color = paint.color);
      }
    }
  }

  // Plain minimalist grid — clean Western/Scandinavian feel.
  void _paintGrid(Canvas canvas, Size size, Paint paint) {
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  // Circuit-board style lines with node junctions — high-tech feel.
  void _paintCircuit(Canvas canvas, Size size, Paint paint) {
    const cell = 60.0;
    final rand = Random(42); // fixed seed so the pattern doesn't jitter on rebuild
    for (double y = 0; y < size.height; y += cell) {
      for (double x = 0; x < size.width; x += cell) {
        final horizontal = rand.nextBool();
        if (horizontal) {
          canvas.drawLine(Offset(x, y + cell / 2), Offset(x + cell, y + cell / 2), paint);
        } else {
          canvas.drawLine(Offset(x + cell / 2, y), Offset(x + cell / 2, y + cell), paint);
        }
        canvas.drawCircle(Offset(x + cell / 2, y + cell / 2), 2.5, Paint()..color = paint.color);
      }
    }
  }

  // Large soft diagonal panels at varying "depth" — nearer panels are
  // bigger/brighter, farther ones smaller/dimmer, evoking a coverflow-like
  // layered perspective without literally being a card carousel. A very
  // slow drift (driftT, 0..1 looping) gives an almost-imperceptible
  // parallax feel; callers pass driftT=0 for Reduced Motion.
  void _paintLayered3D(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.42;
    final driftShift = sin(driftT * 2 * pi) * 14; // px, barely noticeable

    const layers = 5;
    for (int i = 0; i < layers; i++) {
      final depth = i / (layers - 1); // 0 = nearest, 1 = farthest
      final scale = 1.0 - depth * 0.55;
      final opacity = 0.05 * (1 - depth * 0.7);
      final dx = driftShift * (1 - depth) * 0.6 + (i.isEven ? -1 : 1) * depth * 40;
      final dy = -depth * 90;
      final w = size.width * 0.95 * scale;
      final h = size.height * 0.5 * scale;

      final rect = Rect.fromCenter(center: Offset(cx + dx, cy + dy), width: w, height: h);
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(36 * scale));

      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      // Slight perspective skew — panels "tilt" a little more the farther back they are.
      final skew = 0.08 * depth * (i.isEven ? 1 : -1);
      canvas.transform(Matrix4.skewX(skew).storage);
      canvas.translate(-rect.center.dx, -rect.center.dy);

      canvas.drawRRect(rrect, Paint()..color = color.withOpacity(opacity));
      // Soft top-edge highlight to sell the "glass panel" depth cue.
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = color.withOpacity(opacity * 1.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) =>
      oldDelegate.pattern != pattern || oldDelegate.color != color || oldDelegate.driftT != driftT;
}
