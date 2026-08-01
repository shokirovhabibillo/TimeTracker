import 'package:flutter/material.dart';

/// Soft "pressed into the surface" look — a light shadow on the top-left
/// and a darker shadow on the bottom-right, both matching the background
/// color so the element reads as embossed rather than floating.
/// Works best on flat, light theme backgrounds.
class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool pressed;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.pressed = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final isDark = ThemeData.estimateBrightnessForColor(bg) == Brightness.dark;
    final lightShadow = isDark ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.9);
    final darkShadow = isDark ? Colors.black.withOpacity(0.6) : Colors.black.withOpacity(0.12);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: pressed
            ? [] // flattened when "pressed" — reads as pushed in
            : [
                BoxShadow(color: darkShadow, offset: const Offset(6, 6), blurRadius: 12),
                BoxShadow(color: lightShadow, offset: const Offset(-6, -6), blurRadius: 12),
              ],
      ),
      child: child,
    );
  }
}

/// Tappable neumorphic button — flattens (looks pressed) on tap-down.
class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const NeumorphicButton({
    super.key,
    required this.child,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    this.borderRadius = 16,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: NeumorphicContainer(
        padding: widget.padding,
        borderRadius: widget.borderRadius,
        pressed: _pressed,
        child: widget.child,
      ),
    );
  }
}
