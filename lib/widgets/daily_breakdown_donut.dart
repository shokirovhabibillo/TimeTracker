import 'package:flutter/material.dart';

import '../data/models/task_model.dart';

class DailyBreakdownDonut extends StatelessWidget {
  final Map<String, Duration> breakdown;
  const DailyBreakdownDonut({super.key, required this.breakdown});

  static const Map<String, Color> _colors = {
    TaskCategory.work: Color(0xFF3B82F6),
    TaskCategory.study: Color(0xFF8B5CF6),
    TaskCategory.meal: Color(0xFF22C55E),
    TaskCategory.sleep: Color(0xFF6366F1),
    TaskCategory.habit: Color(0xFFF59E0B),
    TaskCategory.laborLeave: Color(0xFFEF4444),
    TaskCategory.privilegedLeave: Color(0xFFEC4899),
    TaskCategory.annualLeave: Color(0xFF10B981),
    TaskCategory.idpDevelopment: Color(0xFFF97316),
    TaskCategory.custom: Color(0xFF64748B),
  };

  @override
  Widget build(BuildContext context) {
    final total = breakdown.values.fold<Duration>(Duration.zero, (a, b) => a + b);
    if (total.inMinutes == 0) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text("Bugun uchun reja yo'q", style: TextStyle(color: Theme.of(context).hintColor)),
        ),
      );
    }

    final entries = breakdown.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(180, 180),
                painter: _DonutPainter(entries: entries, total: total, colors: _colors),
              ),
              Text('${entries.length}\nturkum', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: entries.map((e) {
            final pct = (e.value.inMinutes / total.inMinutes * 100).round();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: _colors[e.key] ?? Colors.grey, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('${TaskCategory.label(e.key)} $pct%', style: const TextStyle(fontSize: 12)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<MapEntry<String, Duration>> entries;
  final Duration total;
  final Map<String, Color> colors;
  _DonutPainter({required this.entries, required this.total, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 10;
    var startAngle = -3.14159265 / 2;
    for (final e in entries) {
      final sweep = (e.value.inMinutes / total.inMinutes) * 2 * 3.14159265;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep - 0.03,
        false,
        Paint()
          ..color = colors[e.key] ?? Colors.grey
          ..style = PaintingStyle.stroke
          ..strokeWidth = 22
          ..strokeCap = StrokeCap.round,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => true;
}
