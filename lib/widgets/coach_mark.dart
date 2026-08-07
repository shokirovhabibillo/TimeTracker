import 'package:flutter/material.dart';

/// Tracks which coach-mark keys have already been shown, persisted for
/// the app session (a simple static set — resets on app restart, which
/// is fine since occasionally re-showing a hint isn't harmful).
class CoachMarkTracker {
  static final Set<String> _shown = {};
  static bool hasShown(String key) => _shown.contains(key);
  static void markShown(String key) => _shown.add(key);
}

/// Wraps [child] with a one-time explanatory bubble (with a pointing
/// arrow) the first time it's built — tap the bubble to dismiss it.
/// Use a unique, stable [id] per button/feature.
class CoachMark extends StatefulWidget {
  final String id;
  final String message;
  final Widget child;
  final bool bubbleAbove;

  const CoachMark({
    super.key,
    required this.id,
    required this.message,
    required this.child,
    this.bubbleAbove = true,
  });

  @override
  State<CoachMark> createState() => _CoachMarkState();
}

class _CoachMarkState extends State<CoachMark> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    if (!CoachMarkTracker.hasShown(widget.id)) {
      _visible = true;
      CoachMarkTracker.markShown(widget.id);
    }
  }

  void _dismiss() => setState(() => _visible = false);

  Widget _bubble() {
    return GestureDetector(
      onTap: _dismiss,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12)),
            Icon(widget.bubbleAbove ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return widget.child;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widget.bubbleAbove ? [_bubble(), widget.child] : [widget.child, _bubble()],
    );
  }
}
