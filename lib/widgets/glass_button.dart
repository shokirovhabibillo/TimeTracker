import 'dart:ui';
import 'package:flutter/material.dart';

/// A frosted-glass ("liquid glass") pill button — thin gradient rim that
/// simulates light hitting it from the top-left, soft drop shadow below
/// for a floating 3D feel, subtle blur behind the translucent fill.
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
          BoxShadow(color: tint.withOpacity(0.28), blurRadius: 20, offset: const Offset(0, 10)),
          BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [tint.withOpacity(0.22), tint.withOpacity(0.08)],
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    // Thin gradient rim: brighter along the top-left edge
                    // (simulated light source), fading toward the bottom-right.
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white.withOpacity(0.7), tint.withOpacity(0.15), Colors.white.withOpacity(0.05)],
                      stops: const [0.0, 0.5, 1.0],
                    ),
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
      ),
    );
  }
}

/// A frosted-glass circular icon button with the same side-lit 3D look.
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
        boxShadow: [
          BoxShadow(color: tint.withOpacity(0.28), blurRadius: 14, offset: const Offset(0, 6)),
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white.withOpacity(0.55), tint.withOpacity(0.2)],
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                child: Icon(icon, color: tint, size: size * 0.42),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A frosted-glass card container with the same side-lit rim and shadow.
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
        boxShadow: [
          BoxShadow(color: tint.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          // Outer layer paints the gradient "rim" (light hitting the top-left
          // edge, fading toward the bottom-right); the inset inner container
          // holds the actual translucent fill + content — a simple, safe way
          // to fake a gradient border without a custom ShapeBorder subclass.
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white.withOpacity(0.55), tint.withOpacity(0.08)],
              ),
            ),
            padding: const EdgeInsets.all(0.8),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(19.3),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [tint.withOpacity(0.16), tint.withOpacity(0.06)],
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
