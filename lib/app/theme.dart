import 'package:flutter/material.dart';

/// Minimal, premium, intelligent visual identity.
/// Light and dark are designed separately — never a naive inversion.
class AppTheme {
  const AppTheme._();

  // Brand accents shared by both themes.
  static const Color accent = Color(0xFF3B5BFF);
  static const Color accentDark = Color(0xFF8FA6FF);
  static const Color success = Color(0xFF22B573);
  static const Color warning = Color(0xFFF5A623);
  static const Color danger = Color(0xFFE5484D);

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: accent,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE3E9FF),
      onPrimaryContainer: Color(0xFF1B2A6B),
      secondary: Color(0xFF5B6B8C),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFE8ECF5),
      onSecondaryContainer: Color(0xFF1B2438),
      tertiary: Color(0xFF7A5CFF),
      onTertiary: Colors.white,
      error: danger,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF101828),
      surfaceContainerHighest: Color(0xFFF1F4FA),
      onSurfaceVariant: Color(0xFF475467),
      outline: Color(0xFFD5DBE8),
      shadow: Color(0x1A101828),
    );
    return _build(scheme, bg: const Color(0xFFF7F8FC));
  }

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: accentDark,
      onPrimary: Color(0xFF0B1030),
      primaryContainer: Color(0xFF24306B),
      onPrimaryContainer: Color(0xFFE3E9FF),
      secondary: Color(0xFF9AA7C7),
      onSecondary: Color(0xFF0B1030),
      secondaryContainer: Color(0xFF1D2742),
      onSecondaryContainer: Color(0xFFE8ECF5),
      tertiary: Color(0xFFB9A8FF),
      onTertiary: Color(0xFF0B1030),
      error: Color(0xFFFF8A8A),
      onError: Color(0xFF2A0B0B),
      surface: Color(0xFF141C30),
      onSurface: Color(0xFFE8ECF5),
      surfaceContainerHighest: Color(0xFF1B2440),
      onSurfaceVariant: Color(0xFFA9B4CE),
      outline: Color(0xFF2E3A5C),
      shadow: Color(0x66000000),
    );
    return _build(scheme, bg: const Color(0xFF0C1220));
  }

  static ThemeData _build(ColorScheme scheme, {required Color bg}) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
