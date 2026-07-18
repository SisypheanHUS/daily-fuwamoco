import 'package:flutter/material.dart';

/// Warm cozy palette (Daily FUWAMOCO): cream/warm-white base, pastel
/// blue/pink/yellow accents, no dark/high-contrast surfaces — the brief is
/// explicitly light-only ("avoid dark UI"). Plain `static const` fields, not
/// a ThemeExtension: screens need direct access to specific named pastels
/// (not just ColorScheme's structural roles), and a full extension is more
/// machinery than a light-only palette earns.
abstract final class AppTheme {
  static const warmWhite = Color(0xFFFFFCF7);
  static const cream = Color(0xFFF6EFE1);
  static const creamDeep = Color(0xFFEFE4CE);
  static const blue = Color(0xFFD9E8EF);
  static const blueDeep = Color(0xFFAECFDC);
  static const pink = Color(0xFFF6DCE1);
  static const pinkDeep = Color(0xFFEBB7C3);
  static const yellow = Color(0xFFFBE7AE);
  static const yellowDeep = Color(0xFFF3D584);
  static const ink = Color(0xFF3B342B);
  static const inkSoft = Color(0xFF8A8171);
  static const inkFaint = Color(0xFFC3BAA9);

  static const accent = pinkDeep;

  static ThemeData get light => _base(Brightness.light);
  static ThemeData get dark => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
      surface: brightness == Brightness.dark ? ink : warmWhite,
    );
    final base = ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: 'Plus Jakarta Sans',
    );
    // Derive the app bar title from the theme's own text style so the font
    // family stays declared in one place (ThemeData.fontFamily above).
    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
      ),
    );
  }
}

/// Spacing scale — the only spacing values allowed in layout code.
abstract final class Gap {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

/// Corner-radius scale, matching the mockups' rounded-card system.
abstract final class Corners {
  static const sm = 16.0;
  static const md = 22.0;
  static const lg = 28.0;
}
