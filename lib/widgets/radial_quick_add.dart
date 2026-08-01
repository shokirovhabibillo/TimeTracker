import 'dart:math';
import 'package:flutter/material.dart';

class RadialAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const RadialAction({required this.icon, required this.label, required this.onTap});
}

/// A FAB that fans a ring of smaller action buttons out around it when
/// tapped, and collapses them back when tapped again or an action fires.
class RadialQuickAddButton extends StatefulWidget {
  final List<RadialAction> actions;
  const RadialQuickAddButton({super.key, required this.actions});

  @override
  State<RadialQuickAddButton> createState() => _RadialQuickAddButtonState();
}

class _RadialQuickAddButtonState extends State<RadialQuickAddButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
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

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          if (_open)
            GestureDetector(
              onTap: _toggle,
              child: Container(color: Colors.transparent),
            ),
          ...List.generate(n, (i) {
            // Fan the actions across a quarter-circle above-left of the FAB.
            final angle = (pi / 2) * (i + 1) / (n + 1);
            final radius = 90.0;
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = _controller.value;
                final dx = -radius * sin(angle) * t;
                final dy = -radius * cos(angle) * t;
                return Positioned(
                  right: 8 - dx,
                  bottom: 8 - dy,
                  child: Opacity(opacity: t, child: child),
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
                duration: const Duration(milliseconds: 250),
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
    return Tooltip(
      message: action.label,
      child: Material(
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
    );
  }
}
