import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class AppProgressBar extends StatelessWidget {
  final double value; // 0..1
  final Color color;
  final double height;
  final bool glow;

  const AppProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 10,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(height),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0, 1),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(height),
                boxShadow: glow ? AppTheme.neonGlow(color, intensity: 0.7) : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
