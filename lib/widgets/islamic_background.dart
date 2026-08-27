import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 6 va 10-rasmlardan ilhomlangan fon: burchaklarda gulli medalyon/rozetka,
/// tagida chuqur rangli gradient. Ikki tayyor rang varianti mavjud.
///
/// Ishlatish:
/// Scaffold(
///   body: IslamicBackground(
///     palette: BackgroundPalette.navyGold, // yoki BackgroundPalette.softPastel
///     child: YourScreenContent(),
///   ),
/// )
enum BackgroundPalette { navyGold, softPastel }

class _BgColors {
  final List<Color> baseGradient;
  final Color motifPrimary;
  final Color motifSecondary;
  final Color motifAccent;
  const _BgColors(
      this.baseGradient, this.motifPrimary, this.motifSecondary, this.motifAccent);
}

const Map<BackgroundPalette, _BgColors> _bgPalettes = {
  // 6-rasm uslubi: to'q ko'k fon, tilla va firuza gullar
  BackgroundPalette.navyGold: _BgColors(
    [Color(0xFF0B1F3A), Color(0xFF123A5E), Color(0xFF0B1F3A)],
    Color(0xFFE8C468),
    Color(0xFF4FB3A9),
    Color(0xFFF3E3B0),
  ),
  // 10-rasm uslubi: oq fon, moviy-firuza-jigarrang gullar
  BackgroundPalette.softPastel: _BgColors(
    [Color(0xFFFDFCFA), Color(0xFFF7F4EE), Color(0xFFFDFCFA)],
    Color(0xFF3E7CB1),
    Color(0xFF7BB8C7),
    Color(0xFFB4674E),
  ),
};

class IslamicBackground extends StatelessWidget {
  final Widget child;
  final BackgroundPalette palette;

  const IslamicBackground({
    super.key,
    required this.child,
    this.palette = BackgroundPalette.navyGold,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _bgPalettes[palette]!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors.baseGradient,
        ),
      ),
      child: CustomPaint(
        painter: _IslamicPatternPainter(colors: colors),
        child: child,
      ),
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  final _BgColors colors;
  _IslamicPatternPainter({required this.colors});

  // Sakkiz qirrali rozetka (gul-yulduz) chizadi -> 5/6-rasmlardagi motif
  void _drawRosette(Canvas canvas, Offset center, double radius, double opacity) {
    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = colors.motifPrimary.withOpacity(opacity);
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = colors.motifSecondary.withOpacity(opacity * 0.9);
    final dotPaint = Paint()..color = colors.motifAccent.withOpacity(opacity);

    // Tashqi 8 qirrali yulduz
    final path = Path();
    const points = 8;
    for (int i = 0; i < points * 2; i++) {
      final isOuter = i.isEven;
      final r = isOuter ? radius : radius * 0.55;
      final angle = (math.pi / points) * i - math.pi / 2;
      final p = Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, outerPaint);

    // Ichki doira qatlamlari
    canvas.drawCircle(center, radius * 0.62, innerPaint);
    canvas.drawCircle(center, radius * 0.34, innerPaint);
    canvas.drawCircle(center, radius * 0.08, dotPaint);

    // Atrofdagi kichik gulbarglar
    for (int i = 0; i < 8; i++) {
      final angle = (math.pi / 4) * i;
      final petalCenter = Offset(
        center.dx + radius * 0.8 * math.cos(angle),
        center.dy + radius * 0.8 * math.sin(angle),
      );
      canvas.drawCircle(petalCenter, radius * 0.05, dotPaint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Yuqori-chap va pastki-o'ng burchaklarda katta rozetka (6/10-rasm kompozitsiyasi)
    _drawRosette(canvas, Offset(size.width * 0.06, size.height * 0.05),
        size.width * 0.42, 0.16);
    _drawRosette(canvas, Offset(size.width * 0.98, size.height * 1.0),
        size.width * 0.5, 0.14);

    // Markazda juda xira, katta rozetka (1-rasmdagi kabi fon detali)
    _drawRosette(canvas, Offset(size.width * 0.5, size.height * 0.42),
        size.width * 0.6, 0.05);

    // Yon tomonlarga tarqalgan mayda yulduzchalar (3-rasm uslubi - to'r effekt)
    final rnd = math.Random(7);
    for (int i = 0; i < 14; i++) {
      final dx = rnd.nextDouble() * size.width;
      final dy = rnd.nextDouble() * size.height;
      _drawRosette(canvas, Offset(dx, dy), size.width * 0.05, 0.05);
    }
  }

  @override
  bool shouldRepaint(covariant _IslamicPatternPainter oldDelegate) => false;
}
