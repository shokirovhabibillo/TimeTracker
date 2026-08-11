import 'package:flutter/material.dart';

/// Broad movement categories — used to pick which schematic animation
/// shape/motion to play, so we don't need one bespoke animation per
/// exercise (40+ of them) but still get a genuinely representative
/// visual for each.
class MovementPattern {
  static const verticalPull = 'vertical_pull'; // pull-up, lat pulldown
  static const verticalPush = 'vertical_push'; // dip, shoulder press
  static const horizontalPull = 'horizontal_pull'; // row, face pull
  static const horizontalPush = 'horizontal_push'; // push-up, bench
  static const squat = 'squat'; // squat, lunge, step-up
  static const hinge = 'hinge'; // deadlift-like, glute bridge
  static const staticHold = 'static_hold'; // plank, dead hang, support hold
  static const isolationRaise = 'isolation_raise'; // shrug, lateral/Y raise
  static const core = 'core'; // knee raise, dead bug, crunch-like
  static const calf = 'calf'; // calf raise
}

/// Simple stick-figure schematic showing START -> MOVE -> PEAK -> RETURN
/// for a given [pattern]. Not a substitute for a real recorded/rendered
/// animation, but gives a genuinely useful sense of the movement.
class SchematicExerciseAnimation extends StatefulWidget {
  final String pattern;
  final Color color;
  const SchematicExerciseAnimation({super.key, required this.pattern, required this.color});

  @override
  State<SchematicExerciseAnimation> createState() => _SchematicExerciseAnimationState();
}

class _SchematicExerciseAnimationState extends State<SchematicExerciseAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _phaseLabel(double t) {
    if (t < 0.15) return 'START';
    if (t < 0.45) return 'MOVE';
    if (t < 0.6) return 'PEAK';
    return 'RETURN';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // A smooth 0->1->0 cycle so the motion eases out and back,
        // matching a natural "up, pause, down" rep tempo.
        final t = _controller.value;
        final cyclePos = t < 0.6 ? (t / 0.6) : (1 - (t - 0.6) / 0.4);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: CustomPaint(
                painter: _StickFigurePainter(pattern: widget.pattern, progress: cyclePos.clamp(0, 1), color: widget.color),
              ),
            ),
            const SizedBox(height: 8),
            Text(_phaseLabel(t),
                style: TextStyle(color: widget.color, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
          ],
        );
      },
    );
  }
}

class _StickFigurePainter extends CustomPainter {
  final String pattern;
  final double progress; // 0 = start pose, 1 = peak pose
  final Color color;
  _StickFigurePainter({required this.pattern, required this.progress, required this.color});

  void _arrow(Canvas canvas, Color arrowColor, Offset from, Offset to) {
    final arrowPaint = Paint()
      ..color = arrowColor.withOpacity(0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, arrowPaint);
    final angle = (to - from).direction;
    const headSize = 6.0;
    canvas.drawLine(to, to + Offset.fromDirection(angle + 2.6, headSize), arrowPaint);
    canvas.drawLine(to, to + Offset.fromDirection(angle - 2.6, headSize), arrowPaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final jointPaint = Paint()..color = color;
    final w = size.width, h = size.height;
    final cx = w / 2;

    void head(Offset c) => canvas.drawCircle(c, 10, paint);

    switch (pattern) {
      case MovementPattern.verticalPull:
      case MovementPattern.verticalPush:
        final isPull = pattern == MovementPattern.verticalPull;
        final barY = h * 0.15;
        canvas.drawLine(Offset(cx - 40, barY), Offset(cx + 40, barY), Paint()..color = color..strokeWidth = 6);
        final headC = Offset(cx, (h * 0.45) - (h * 0.18) * (isPull ? progress : 0));
        head(headC);
        final torsoBottom = Offset(cx, headC.dy + 55);
        canvas.drawLine(headC.translate(0, 10), torsoBottom, paint);
        canvas.drawLine(Offset(cx - 25, barY), headC.translate(-8, 0), paint..strokeWidth = 3);
        canvas.drawLine(Offset(cx + 25, barY), headC.translate(8, 0), paint..strokeWidth = 3);
        canvas.drawLine(torsoBottom, torsoBottom.translate(-15, 40), paint..strokeWidth = 3);
        canvas.drawLine(torsoBottom, torsoBottom.translate(15, 40), paint..strokeWidth = 3);
        _arrow(canvas, color, Offset(cx + 55, h * 0.6),
            Offset(cx + 55, h * 0.6 - (h * 0.2) * progress * (isPull ? 1 : -1)));
        break;

      case MovementPattern.horizontalPull:
      case MovementPattern.horizontalPush:
        final shift = (pattern == MovementPattern.horizontalPush ? -1 : 1) * (h * 0.12) * progress;
        final headC = Offset(cx - 30, h * 0.4);
        head(headC);
        final torso = headC.translate(0, 12);
        final torsoEnd = torso.translate(40, 0);
        canvas.drawLine(torso, torsoEnd, paint);
        final armStart = torso.translate(15, 5);
        final armEnd = armStart.translate(30 + shift, 0);
        canvas.drawLine(armStart, armEnd, paint..strokeWidth = 3);
        canvas.drawLine(torsoEnd, torsoEnd.translate(5, 45), paint..strokeWidth = 3);
        canvas.drawCircle(armEnd, 4, jointPaint);
        _arrow(canvas, color, Offset(cx + 20, h * 0.35), Offset(cx + 20 + shift, h * 0.35));
        break;

      case MovementPattern.squat:
        final crouch = (h * 0.18) * progress;
        final headC = Offset(cx, h * 0.25 + crouch);
        head(headC);
        final hip = headC.translate(0, 40 + crouch * 0.6);
        canvas.drawLine(headC.translate(0, 10), hip, paint);
        final kneeBend = 20 * progress;
        final knee = hip.translate(-15, 35 - kneeBend * 0.3);
        final foot = knee.translate(5, 35);
        canvas.drawLine(hip, knee, paint..strokeWidth = 3);
        canvas.drawLine(knee, foot, paint..strokeWidth = 3);
        final knee2 = hip.translate(15, 35 - kneeBend * 0.3);
        final foot2 = knee2.translate(-5, 35);
        canvas.drawLine(hip, knee2, paint..strokeWidth = 3);
        canvas.drawLine(knee2, foot2, paint..strokeWidth = 3);
        _arrow(canvas, color, Offset(cx + 45, h * 0.3), Offset(cx + 45, h * 0.3 + crouch));
        break;

      case MovementPattern.hinge:
        final bend = progress * 0.7;
        final hip = Offset(cx, h * 0.55);
        final headC = hip.translate(-60 * bend, -50 + 10 * bend);
        head(headC);
        canvas.drawLine(headC.translate(6 * bend, 8), hip, paint);
        canvas.drawLine(hip, hip.translate(-10, 45), paint..strokeWidth = 3);
        canvas.drawLine(hip, hip.translate(10, 45), paint..strokeWidth = 3);
        _arrow(canvas, color, Offset(cx - 70, h * 0.35), Offset(cx - 70 - 20 * bend, h * 0.35 + 8 * bend));
        break;

      case MovementPattern.isolationRaise:
        final lift = progress;
        final headC = Offset(cx, h * 0.35);
        head(headC);
        canvas.drawLine(headC.translate(0, 10), headC.translate(0, 60), paint);
        final shoulderY = headC.dy + 15 - 12 * lift;
        canvas.drawLine(Offset(cx, shoulderY), Offset(cx - 35, shoulderY - 10 * lift), paint..strokeWidth = 3);
        canvas.drawLine(Offset(cx, shoulderY), Offset(cx + 35, shoulderY - 10 * lift), paint..strokeWidth = 3);
        _arrow(canvas, color, Offset(cx + 55, h * 0.4), Offset(cx + 55, h * 0.4 - 15 * lift));
        break;

      case MovementPattern.core:
        final headC = Offset(cx - 40, h * 0.5);
        head(headC);
        canvas.drawLine(headC.translate(8, 5), headC.translate(50, 5), paint);
        final legLift = 30 * progress;
        canvas.drawLine(headC.translate(50, 5), headC.translate(85, 5 - legLift), paint..strokeWidth = 3);
        _arrow(canvas, color, Offset(cx + 45, h * 0.55), Offset(cx + 45, h * 0.55 - legLift));
        break;

      case MovementPattern.calf:
        final riseAmt = 15 * progress;
        final headC = Offset(cx, h * 0.35 - riseAmt);
        head(headC);
        canvas.drawLine(headC.translate(0, 10), headC.translate(0, 60 - riseAmt), paint);
        canvas.drawLine(headC.translate(0, 60 - riseAmt), headC.translate(0, 95 - riseAmt), paint..strokeWidth = 3);
        canvas.drawLine(Offset(cx - 12, h * 0.95), Offset(cx + 12, h * 0.95), Paint()..color = color..strokeWidth = 4);
        _arrow(canvas, color, Offset(cx + 30, h * 0.6), Offset(cx + 30, h * 0.6 - riseAmt));
        break;

      case MovementPattern.staticHold:
      default:
        final wobble = (progress - 0.5).abs() < 0.1 ? 2.0 : 0.0;
        final headC = Offset(cx - 40, h * 0.45 + wobble);
        head(headC);
        canvas.drawLine(headC.translate(8, 0), headC.translate(80, 0), paint);
        canvas.drawLine(headC.translate(10, 8), headC.translate(10, 45), paint..strokeWidth = 3);
        canvas.drawLine(headC.translate(75, 8), headC.translate(75, 45), paint..strokeWidth = 3);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _StickFigurePainter oldDelegate) => true;
}
