import 'package:flutter/material.dart';

/// 2 / 8 / 17-rasmlardagi klassik "ramka" uslubidagi tugma.
/// Uchlari o'tkir/qirrali, ichki gradient bilan 3D (bosilganda botadi).
///
/// Ishlatish:
/// OrnateButton(
///   label: "Boshlash",
///   icon: Icons.play_arrow_rounded,
///   onPressed: () {},
///   palette: OrnatePalette.gold,   // yoki OrnatePalette.sapphire
/// )
enum OrnatePalette { gold, sapphire, emerald }

class _PaletteColors {
  final List<Color> gradient;
  final Color border;
  final Color borderDark;
  final Color textColor;
  final Color glow;
  const _PaletteColors(this.gradient, this.border, this.borderDark,
      this.textColor, this.glow);
}

const Map<OrnatePalette, _PaletteColors> _palettes = {
  OrnatePalette.gold: _PaletteColors(
    [Color(0xFFFCE9B0), Color(0xFFE8B84B), Color(0xFFB9832A)],
    Color(0xFF8A5A17),
    Color(0xFF4A2E0B),
    Color(0xFF3A2308),
    Color(0x66E8B84B),
  ),
  OrnatePalette.sapphire: _PaletteColors(
    [Color(0xFF6FA8DC), Color(0xFF1F5C99), Color(0xFF0D3A66)],
    Color(0xFF0A2C4D),
    Color(0xFF04182C),
    Color(0xFFEAF3FF),
    Color(0x662E75B6),
  ),
  OrnatePalette.emerald: _PaletteColors(
    [Color(0xFF7FD8B8), Color(0xFF1E9E75), Color(0xFF0E6E52)],
    Color(0xFF0A4A38),
    Color(0xFF042E22),
    Color(0xFFF0FFF8),
    Color(0x661D9E75),
  ),
};

class OrnateButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final OrnatePalette palette;
  final double width;
  final double height;
  final double fontSize;

  const OrnateButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.palette = OrnatePalette.gold,
    this.width = 260,
    this.height = 58,
    this.fontSize = 16,
  });

  @override
  State<OrnateButton> createState() => _OrnateButtonState();
}

class _OrnateButtonState extends State<OrnateButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = _palettes[widget.palette]!;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            boxShadow: _pressed
                ? [
                    BoxShadow(
                      color: colors.glow,
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: colors.glow,
                      blurRadius: 14,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: CustomPaint(
            painter: _OrnateFramePainter(colors: colors, pressed: _pressed),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: colors.textColor, size: widget.fontSize + 4),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: colors.textColor,
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.35),
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrnateFramePainter extends CustomPainter {
  final _PaletteColors colors;
  final bool pressed;
  _OrnateFramePainter({required this.colors, required this.pressed});

  // Uchlari qirrali, o'rtasi tekis ramka (2-rasmdagi shaklga o'xshash)
  Path _framePath(Size size) {
    final w = size.width;
    final h = size.height;
    final tip = h * 0.55; // uch qismning chiqib turishi
    final notch = h * 0.28; // uchdagi ichkariga botish

    final path = Path();
    path.moveTo(tip, 0);
    path.lineTo(w - tip, 0);
    path.lineTo(w - tip + notch * 0.5, h * 0.5);
    path.lineTo(w - tip, h);
    path.lineTo(tip, h);
    path.lineTo(tip - notch * 0.5, h * 0.5);
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final outer = _framePath(size);

    // 3D gradient fill (bosilganda tepa-past rangi teskari bo'ladi -> botgandek)
    final grad = LinearGradient(
      begin: pressed ? Alignment.bottomCenter : Alignment.topCenter,
      end: pressed ? Alignment.topCenter : Alignment.bottomCenter,
      colors: colors.gradient,
    );
    final fillPaint = Paint()
      ..shader = grad.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(outer, fillPaint);

    // Tashqi qalin border
    final outerBorder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..color = colors.borderDark;
    canvas.drawPath(outer, outerBorder);

    // Ichki nozik border (2-rasmdagi ikkinchi chiziq effekti)
    final inset = size.height * 0.16;
    final innerRect = Rect.fromLTWH(
        inset, inset * 0.6, size.width - inset * 2, size.height - inset * 1.2);
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = colors.border.withOpacity(0.9);
    canvas.drawRRect(
        RRect.fromRectAndRadius(innerRect, const Radius.circular(4)), innerPaint);

    // Tepadagi yaltiroq chiziq -> 3D/glossy hissi
    if (!pressed) {
      final glossPaint = Paint()
        ..shader = LinearGradient(
          colors: [Colors.white.withOpacity(0.55), Colors.white.withOpacity(0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.5));
      canvas.save();
      canvas.clipPath(outer);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.45), glossPaint);
      canvas.restore();
    }

    // 8 va 17-rasmdagi kabi burchak bezaklari (kichik romb+nuqta)
    _drawCornerOrnament(canvas, Offset(size.height * 0.55, size.height / 2), colors);
    _drawCornerOrnament(
        canvas, Offset(size.width - size.height * 0.55, size.height / 2), colors);
  }

  void _drawCornerOrnament(Canvas canvas, Offset center, _PaletteColors colors) {
    final r = center.dy * 0.32;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = colors.borderDark;
    // Romb
    final diamond = Path()
      ..moveTo(center.dx, center.dy - r)
      ..lineTo(center.dx + r, center.dy)
      ..lineTo(center.dx, center.dy + r)
      ..lineTo(center.dx - r, center.dy)
      ..close();
    canvas.drawPath(diamond, paint);
    // Markazdagi nuqta
    canvas.drawCircle(center, r * 0.28, Paint()..color = colors.borderDark);
  }

  @override
  bool shouldRepaint(covariant _OrnateFramePainter oldDelegate) =>
      oldDelegate.pressed != pressed || oldDelegate.colors != colors;
}
