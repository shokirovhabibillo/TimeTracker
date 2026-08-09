import 'dart:ui';
import 'package:flutter/material.dart';

/// A frosted-glass ("glassmorphism") pill button — translucent
/// background, subtle blur, soft glow underneath. Use for prominent
/// call-to-action buttons where extra visual flair fits.
class GlassButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color tint;
  final double width;

  const GlassButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.tint = Colors.white,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: tint.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: tint.withOpacity(0.16),
            child: InkWell(
              onTap: onPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: tint.withOpacity(0.4), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: tint),
                      const SizedBox(width: 8),
                    ],
                    Text(label, style: TextStyle(color: tint, fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A frosted-glass circular icon button — for compact action icons.
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color tint;
  final double size;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tint = Colors.white,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: tint.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: tint.withOpacity(0.18),
            child: InkWell(
              onTap: onPressed,
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: tint.withOpacity(0.4))),
                child: Icon(icon, color: tint, size: size * 0.42),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A frosted-glass card container — for dashboard-style cards.
class GlassCard extends StatelessWidget {
  final Widget child;
  final Color tint;
  final EdgeInsets padding;

  const GlassCard({
    super.key,
    required this.child,
    this.tint = Colors.white,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: tint.withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: tint.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tint.withOpacity(0.35), width: 1),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
