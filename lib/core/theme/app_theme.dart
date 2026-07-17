import 'package:flutter/material.dart';

/// Monochrome base + one soft accent. All screens pull colors from
/// Theme.of(context) — never hardcode in widgets.
abstract final class AppTheme {
  static const accent = Color(0xFFF2A0B4); // soft ruffian pink

  static ThemeData get light => _base(Brightness.light);
  static ThemeData get dark => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
      // keep surfaces near-monochrome; the seed only tints interactive bits
      surface: brightness == Brightness.dark
          ? const Color(0xFF121212)
          : const Color(0xFFFAFAFA),
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        elevation: 0,
        centerTitle: false,
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
