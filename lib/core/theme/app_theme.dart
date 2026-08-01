import 'package:flutter/material.dart';

/// Extra per-theme attributes that Flutter's [ColorScheme] doesn't have a
/// slot for (a gamified-highlight color, whether neon glow effects should
/// render, and whether the theme wants a "calm" — minimal-animation — feel).
/// Read anywhere via `Theme.of(context).extension<AppThemeExtras>()!`.
class AppThemeExtras extends ThemeExtension<AppThemeExtras> {
  final Color highlightColor; // active-task / success accent
  final Color warningColor; // distraction / error accent
  final bool glowEnabled; // neon box-shadow effects
  final bool calmMode; // disable non-essential animation
  final bool neumorphic; // soft-shadow embossed surfaces (light themes only)
  final double fontScale; // multiplier for elderly-friendly text sizing

  const AppThemeExtras({
    required this.highlightColor,
    required this.warningColor,
    this.glowEnabled = false,
    this.calmMode = false,
    this.neumorphic = false,
    this.fontScale = 1.0,
  });

  @override
  AppThemeExtras copyWith({
    Color? highlightColor,
    Color? warningColor,
    bool? glowEnabled,
    bool? calmMode,
    bool? neumorphic,
    double? fontScale,
  }) {
    return AppThemeExtras(
      highlightColor: highlightColor ?? this.highlightColor,
      warningColor: warningColor ?? this.warningColor,
      glowEnabled: glowEnabled ?? this.glowEnabled,
      calmMode: calmMode ?? this.calmMode,
      neumorphic: neumorphic ?? this.neumorphic,
      fontScale: fontScale ?? this.fontScale,
    );
  }

  @override
  AppThemeExtras lerp(ThemeExtension<AppThemeExtras>? other, double t) {
    if (other is! AppThemeExtras) return this;
    return AppThemeExtras(
      highlightColor: Color.lerp(highlightColor, other.highlightColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      glowEnabled: t < 0.5 ? glowEnabled : other.glowEnabled,
      calmMode: t < 0.5 ? calmMode : other.calmMode,
      neumorphic: t < 0.5 ? neumorphic : other.neumorphic,
      fontScale: fontScale + (other.fontScale - fontScale) * t,
    );
  }
}

/// Which age band a theme was designed for — used to group the picker
/// in Settings and (optionally) to auto-suggest a theme per module.
enum AgeGroup { kids, youth, adult, midAge, elderly }

extension AgeGroupLabel on AgeGroup {
  String get label {
    switch (this) {
      case AgeGroup.kids:
        return '7–12 yosh';
      case AgeGroup.youth:
        return '13–25 yosh';
      case AgeGroup.adult:
        return '26–45 yosh';
      case AgeGroup.midAge:
        return '46–60 yosh';
      case AgeGroup.elderly:
        return '61–70+ yosh';
    }
  }
}

/// One selectable theme: a stable [id] (persisted in the DB), a display
/// [label], the [AgeGroup] it's grouped under, and the built [ThemeData].
class ThemeSpec {
  final String id;
  final String label;
  final String description;
  final AgeGroup group;
  final ThemeData data;

  const ThemeSpec({
    required this.id,
    required this.label,
    required this.description,
    required this.group,
    required this.data,
  });

  AppThemeExtras get extras => data.extension<AppThemeExtras>()!;
}

class AppTheme {
  /// Builds a [ThemeData] from a flat color spec. Kept as one shared
  /// builder so every theme gets consistent component shapes/sizes —
  /// only the palette, brightness and "extras" actually change.
  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color primary,
    required Color secondary,
    required Color tertiary,
    required Color onPrimary,
    required Color textPrimary,
    required Color error,
    required Color highlight,
    required Color warning,
    double borderRadius = 14,
    double buttonHeight = 48,
    double borderWidth = 0,
    double fontScale = 1.0,
    bool glowEnabled = false,
    bool calmMode = false,
    bool neumorphic = false,
    String fontFamily = 'Roboto',
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onPrimary,
      tertiary: tertiary,
      onTertiary: onPrimary,
      error: error,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      textTheme: Typography.material2021(platform: TargetPlatform.android)
          .black
          .apply(fontSizeFactor: fontScale, bodyColor: textPrimary, displayColor: textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: primary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: brightness == Brightness.dark ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: borderWidth > 0
              ? BorderSide(color: textPrimary, width: borderWidth)
              : BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: Size(64, buttonHeight),
          textStyle: TextStyle(fontSize: 16 * fontScale, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withOpacity(0.25),
      ),
      extensions: [
        AppThemeExtras(
          highlightColor: highlight,
          warningColor: warning,
          glowEnabled: glowEnabled,
          calmMode: calmMode,
          neumorphic: neumorphic,
          fontScale: fontScale,
        ),
      ],
    );
  }

  static final List<ThemeSpec> all = [
    // --- Bolalar: Quvnoq Dunyo ---
    ThemeSpec(
      id: 'kids_playful',
      label: 'Quvnoq Dunyo',
      description: "Yorqin, quvnoq — bolalar uchun",
      group: AgeGroup.kids,
      data: _build(
        brightness: Brightness.light,
        background: const Color(0xFFFFF8E1),
        surface: Colors.white,
        primary: const Color(0xFFFF6B35),
        secondary: const Color(0xFF4ECDC4),
        tertiary: const Color(0xFFFFE66D),
        onPrimary: Colors.white,
        textPrimary: const Color(0xFF2D3436),
        error: const Color(0xFFFF4757),
        highlight: const Color(0xFF2ED573),
        warning: const Color(0xFFFF4757),
        borderRadius: 20,
        buttonHeight: 52,
      ),
    ),

    // --- Yoshlar: Neon HUD / Cyberpunk / Gaming RGB ---
    ThemeSpec(
      id: 'youth_neon_hud',
      label: 'Neon HUD',
      description: 'Qorong\'u, elektr-moviy — yoshlar uchun',
      group: AgeGroup.youth,
      data: _build(
        brightness: Brightness.dark,
        background: const Color(0xFF0A0A0F),
        surface: const Color(0xFF14171C),
        primary: const Color(0xFF00F0FF),
        secondary: const Color(0xFF7B2CBF),
        tertiary: const Color(0xFF39FF14),
        onPrimary: Colors.black,
        textPrimary: Colors.white,
        error: const Color(0xFFFF0055),
        highlight: const Color(0xFF39FF14),
        warning: const Color(0xFFFF0055),
        fontFamily: 'RobotoMono',
        glowEnabled: true,
      ),
    ),
    ThemeSpec(
      id: 'youth_cyberpunk',
      label: 'Cyberpunk',
      description: "Binafsha-pushti neon",
      group: AgeGroup.youth,
      data: _build(
        brightness: Brightness.dark,
        background: const Color(0xFF0D0221),
        surface: const Color(0xFF1A0E33),
        primary: const Color(0xFFFF3864),
        secondary: const Color(0xFF261447),
        tertiary: const Color(0xFFF9C80E),
        onPrimary: Colors.white,
        textPrimary: Colors.white,
        error: const Color(0xFFFF3864),
        highlight: const Color(0xFF2DE2E6),
        warning: const Color(0xFFFF3864),
        fontFamily: 'RobotoMono',
        glowEnabled: true,
      ),
    ),
    ThemeSpec(
      id: 'youth_gaming_rgb',
      label: 'Gaming RGB',
      description: 'Yashil-qora, raqamli effekt',
      group: AgeGroup.youth,
      data: _build(
        brightness: Brightness.dark,
        background: const Color(0xFF0F0F0F),
        surface: const Color(0xFF1A1A1A),
        primary: const Color(0xFF00FF88),
        secondary: const Color(0xFFFF0055),
        tertiary: const Color(0xFF00CCFF),
        onPrimary: Colors.black,
        textPrimary: Colors.white,
        error: const Color(0xFFFF0055),
        highlight: const Color(0xFF00FF88),
        warning: const Color(0xFFFF0055),
        fontFamily: 'RobotoMono',
        glowEnabled: true,
      ),
    ),

    // --- Kattalar: Minimalist / Business Blue / Sokin Yashil ---
    ThemeSpec(
      id: 'adult_minimalist',
      label: 'Minimalist',
      description: "Yorug', sokin — universal",
      group: AgeGroup.adult,
      data: _build(
        brightness: Brightness.light,
        background: const Color(0xFFF8F9FA),
        surface: Colors.white,
        primary: const Color(0xFF1E293B),
        secondary: const Color(0xFF15803D),
        tertiary: const Color(0xFF64748B),
        onPrimary: Colors.white,
        textPrimary: const Color(0xFF1E293B),
        error: const Color(0xFFDC2626),
        highlight: const Color(0xFF15803D),
        warning: const Color(0xFFDC2626),
      ),
    ),
    ThemeSpec(
      id: 'adult_business_blue',
      label: 'Business Blue',
      description: 'Jiddiy, aniq',
      group: AgeGroup.adult,
      data: _build(
        brightness: Brightness.light,
        background: const Color(0xFFF1F5F9),
        surface: Colors.white,
        primary: const Color(0xFF1E3A5F),
        secondary: const Color(0xFF3B82F6),
        tertiary: const Color(0xFF94A3B8),
        onPrimary: Colors.white,
        textPrimary: const Color(0xFF1E3A5F),
        error: const Color(0xFFB91C1C),
        highlight: const Color(0xFF059669),
        warning: const Color(0xFFB91C1C),
      ),
    ),
    ThemeSpec(
      id: 'adult_calm_green',
      label: 'Sokin Yashil',
      description: 'Tabiat, ko\'z charchamaydi',
      group: AgeGroup.adult,
      data: _build(
        brightness: Brightness.light,
        background: const Color(0xFFF0FDF4),
        surface: Colors.white,
        primary: const Color(0xFF14532D),
        secondary: const Color(0xFF16A34A),
        tertiary: const Color(0xFF86EFAC),
        onPrimary: Colors.white,
        textPrimary: const Color(0xFF14532D),
        error: const Color(0xFF991B1B),
        highlight: const Color(0xFF16A34A),
        warning: const Color(0xFF991B1B),
        calmMode: true,
      ),
    ),

    // --- O'rta yosh: Klassik Qog'oz / Yumshoq Kontrast ---
    ThemeSpec(
      id: 'midage_classic_paper',
      label: 'Klassik Qog\'oz',
      description: 'Kraft-qog\'oz, aniq va tushunarli',
      group: AgeGroup.midAge,
      data: _build(
        brightness: Brightness.light,
        background: const Color(0xFFF5F0E8),
        surface: Colors.white,
        primary: const Color(0xFF2C3E50),
        secondary: const Color(0xFF8B4513),
        tertiary: const Color(0xFFD4C5B0),
        onPrimary: Colors.white,
        textPrimary: const Color(0xFF1A1A1A),
        error: const Color(0xFFC0392B),
        highlight: const Color(0xFF8B4513),
        warning: const Color(0xFFC0392B),
        fontScale: 1.1,
        calmMode: true,
        neumorphic: true,
      ),
    ),
    ThemeSpec(
      id: 'midage_soft_contrast',
      label: 'Yumshoq Kontrast',
      description: "Yuqori kontrast, ko'zga yumshoq",
      group: AgeGroup.midAge,
      data: _build(
        brightness: Brightness.light,
        background: const Color(0xFFF3F4F6),
        surface: Colors.white,
        primary: const Color(0xFF1E3A8A),
        secondary: const Color(0xFF3B82F6),
        tertiary: const Color(0xFF9CA3AF),
        onPrimary: Colors.white,
        textPrimary: const Color(0xFF111827),
        error: const Color(0xFFDC2626),
        highlight: const Color(0xFF1E3A8A),
        warning: const Color(0xFFDC2626),
        fontScale: 1.1,
        calmMode: true,
        neumorphic: true,
      ),
    ),

    // --- Keksalar: Aniq Kontrast (maxsus) ---
    ThemeSpec(
      id: 'elderly_clear_contrast',
      label: 'Aniq Kontrast',
      description: 'Eng katta shrift, AAA kontrast',
      group: AgeGroup.elderly,
      data: _build(
        brightness: Brightness.light,
        background: Colors.white,
        surface: const Color(0xFFF9F9F9),
        primary: const Color(0xFF006400),
        secondary: const Color(0xFF000000),
        tertiary: const Color(0xFFCC0000),
        onPrimary: Colors.white,
        textPrimary: Colors.black,
        error: const Color(0xFFCC0000),
        highlight: const Color(0xFF006400),
        warning: const Color(0xFFCC0000),
        borderRadius: 16,
        buttonHeight: 64,
        borderWidth: 2,
        fontScale: 1.4,
        calmMode: true,
      ),
    ),

    // --- Qur'on moduli uchun maxsus mikro-tema (yosh guruhidan tashqari) ---
    ThemeSpec(
      id: 'quran_tranquility',
      label: 'Tinchlik (Qur\'on)',
      description: "Sokin, hurmatli — Qur'on moduli uchun",
      group: AgeGroup.adult,
      data: _build(
        brightness: Brightness.light,
        background: const Color(0xFFFAFAF5),
        surface: Colors.white,
        primary: const Color(0xFF1B5E20),
        secondary: const Color(0xFFC8A951),
        tertiary: const Color(0xFFE8E4D9),
        onPrimary: Colors.white,
        textPrimary: const Color(0xFF212121),
        error: const Color(0xFFB91C1C),
        highlight: const Color(0xFFC8A951),
        warning: const Color(0xFFB91C1C),
        calmMode: true,
      ),
    ),
  ];

  static ThemeSpec specById(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => all.firstWhere((t) => t.id == 'youth_neon_hud'));

  static ThemeData themeById(String id) => specById(id).data;

  /// Neon glow shadow — only meaningful for themes with glowEnabled.
  static List<BoxShadow> neonGlow(Color color, {double intensity = 0.6}) => [
        BoxShadow(color: color.withOpacity(intensity), blurRadius: 16, spreadRadius: 1),
      ];
}
