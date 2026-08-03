import 'package:flutter/material.dart';

class RadialAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const RadialAction({required this.icon, required this.label, required this.onTap});
}

/// A FAB that fans a vertical stack of labeled action buttons upward when
/// tapped, and collapses them back when tapped again or an action fires.
/// Each bubble has a fixed, generous gap so they never crowd each other.
class RadialQuickAddButton extends StatefulWidget {
  final List<RadialAction> actions;
  const RadialQuickAddButton({super.key, required this.actions});

  @override
  State<RadialQuickAddButton> createState() => _RadialQuickAddButtonState();
}

class _RadialQuickAddButtonState extends State<RadialQuickAddButton>
    with SingleTickerProviderStateMixin {
  static const double _bubbleGap = 62; // vertical spacing between bubble centers
  static const double _bubbleDiameter = 48;

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
  bool _open = false;

  void _toggle() {
    setState(() => _open = !_open);
    if (_open) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _runAction(VoidCallback action) {
    _toggle();
    action();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final n = widget.actions.length;
    final stackHeight = 56 + n * _bubbleGap + 24;

    return SizedBox(
      width: 220,
      height: stackHeight,
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          if (_open)
            Positioned.fill(
              child: GestureDetector(onTap: _toggle, child: Container(color: Colors.transparent)),
            ),
          ...List.generate(n, (i) {
            // Bubble i sits (i+1) gaps above the FAB center once fully open.
            final targetOffset = 56.0 + (i + 1) * _bubbleGap - _bubbleDiameter / 2;
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = Curves.easeOutBack.transform(_controller.value);
                return Positioned(
                  right: 4, // aligns the action circle's center with the FAB's center
                  bottom: targetOffset * t.clamp(0, 1),
                  child: Opacity(opacity: _controller.value, child: child),
                );
              },
              child: _ActionBubble(action: widget.actions[i], onTap: () => _runAction(widget.actions[i].onTap)),
            );
          }),
          Positioned(
            right: 0,
            bottom: 0,
            child: FloatingActionButton(
              onPressed: _toggle,
              backgroundColor: scheme.primary,
              child: AnimatedRotation(
                turns: _open ? 0.125 : 0,
                duration: const Duration(milliseconds: 220),
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBubble extends StatelessWidget {
  final RadialAction action;
  final VoidCallback onTap;
  const _ActionBubble({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6)],
          ),
          child: Text(action.label, style: TextStyle(fontSize: 12, color: scheme.onSurface)),
        ),
        const SizedBox(width: 8),
        Material(
          color: scheme.secondary,
          shape: const CircleBorder(),
          elevation: 3,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(action.icon, color: scheme.onSecondary, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
