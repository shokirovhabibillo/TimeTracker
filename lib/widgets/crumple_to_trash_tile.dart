import 'package:flutter/material.dart';

/// Wraps any list item to give it a "crumple into a paper ball, fly to
/// the trash, bounce" delete animation instead of an instant vanish.
///
/// Honest scope note: real cloth/paper mesh deformation isn't something
/// Flutter's widget-transform system can do — this approximates the
/// "crumpling" feel with a non-uniform scale + skew + opacity fade into
/// a small ball shape, which is the closest practical equivalent without
/// a custom shader/mesh renderer.
///
/// Usage: call [CrumpleToTrashController.trigger] (obtained via the
/// [controller] callback) instead of removing the item directly. The
/// wrapper plays the full animation, then calls [onFinished]. If
/// [CrumpleToTrashController.undo] is called before that (e.g. from a
/// Snackbar's Undo action) the flight reverses and the item restores.
class CrumpleToTrashTile extends StatefulWidget {
  final Widget child;
  final ValueChanged<CrumpleToTrashController> onControllerReady;
  final VoidCallback onFinished;

  const CrumpleToTrashTile({
    super.key,
    required this.child,
    required this.onControllerReady,
    required this.onFinished,
  });

  @override
  State<CrumpleToTrashTile> createState() => _CrumpleToTrashTileState();
}

class CrumpleToTrashController {
  VoidCallback? _trigger;
  VoidCallback? _undo;
  void trigger() => _trigger?.call();
  void undo() => _undo?.call();
}

class _CrumpleToTrashTileState extends State<CrumpleToTrashTile> with TickerProviderStateMixin {
  late final AnimationController _crumple =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
  late final AnimationController _flight =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
  bool _isDeleting = false;
  bool _isUndoing = false;

  @override
  void initState() {
    super.initState();
    final controller = CrumpleToTrashController();
    controller._trigger = _startDelete;
    controller._undo = _startUndo;
    widget.onControllerReady(controller);
  }

  Future<void> _startDelete() async {
    setState(() => _isDeleting = true);
    await _crumple.forward();
    await _flight.forward();
    // Small settle bounce at the end is handled inside the flight curve.
    if (mounted && !_isUndoing) widget.onFinished();
  }

  Future<void> _startUndo() async {
    _isUndoing = true;
    await _flight.reverse();
    await _crumple.reverse();
    if (mounted) setState(() => _isDeleting = false);
    _isUndoing = false;
  }

  @override
  void dispose() {
    _crumple.dispose();
    _flight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDeleting) return widget.child;

    return AnimatedBuilder(
      animation: Listenable.merge([_crumple, _flight]),
      builder: (context, child) {
        final crumpleT = Curves.easeInCubic.transform(_crumple.value);
        final flightT = Curves.easeIn.transform(_flight.value);

        // Crumple phase: shrink non-uniformly toward a small ball,
        // slight random-feeling skew via sin, fade the sharp edges.
        final ballScale = 1.0 - crumpleT * 0.72;
        final skew = crumpleT * 0.18;

        // Flight phase: arc trajectory (parabola) to the lower-right
        // (toward the row's own trailing edge, where its delete icon
        // sits — "thrown into the trash it came from"), with spin and
        // a shrink-further + slight bounce near landing.
        final dx = flightT * 60;
        final arcHeight = -40 * (4 * flightT * (1 - flightT)); // parabola peak mid-flight
        final dy = flightT * 10 + arcHeight;
        final rotation = flightT * 2.4;
        final flightScale = 1.0 - flightT * 0.5;
        final bounce = flightT > 0.85 ? (1 - ((flightT - 0.85) / 0.15)) * 0.06 : 0.0;

        return Opacity(
          opacity: (1 - flightT).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.rotate(
              angle: rotation,
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..scale(ballScale * flightScale + bounce)
                  ..rotateZ(skew),
                alignment: Alignment.center,
                child: child,
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
