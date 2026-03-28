import 'package:flutter/material.dart';

import 'app_visual_tokens.dart';

class AppTheme {
  static ThemeData light() {
    const backgroundBase = Color(0xFFF6F8FB);
    const backgroundElevated = Color(0xFFFDFEFF);
    const backgroundAccent = Color(0xFFF3F5FF);
    const backgroundTop = Color(0xFFF8FAFD);
    const backgroundBottom = Color(0xFFEFF3FA);
    const textPrimary = Color(0xFF0F172A);
    const textSecondary = Color(0xFF475569);
    const textMuted = Color(0xFF64748B);
    const accent = Color(0xFF6366F1);
    const success = Color(0xFF10B981);
    const warning = Color(0xFFF59E0B);
    const borderSoft = Color(0xFFDCE4F1);
    const borderStrong = Color(0xFFB8C6DB);
    const shadowSoft = Color(0x1A33507A);
    const shadowStrong = Color(0x2633507A);

    const tokens = AppVisualTokens(
      backgroundBase: backgroundBase,
      backgroundElevated: backgroundElevated,
      backgroundAccent: backgroundAccent,
      backgroundTop: backgroundTop,
      backgroundBottom: backgroundBottom,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      textMuted: textMuted,
      accent: accent,
      success: success,
      warning: warning,
      borderSoft: borderSoft,
      borderStrong: borderStrong,
      shadowSoft: shadowSoft,
      shadowStrong: shadowStrong,
      radiusMd: 18,
      radiusLg: 24,
      radiusXl: 32,
      radiusPill: 999,
      spacingSm: 8,
      spacingMd: 12,
      spacingLg: 20,
      spacingXl: 28,
      blurSigma: 14,
      motionFast: Duration(milliseconds: 120),
      motionBase: Duration(milliseconds: 220),
      motionSlow: Duration(milliseconds: 320),
    );

    final scheme =
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.light,
        ).copyWith(
          primary: accent,
          secondary: success,
          surface: backgroundElevated,
          onSurface: textPrimary,
          onPrimary: Colors.white,
          outline: borderSoft,
          shadow: shadowSoft,
        );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: backgroundBase,
      fontFamily: 'IBMPlexSans',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 36,
          fontWeight: FontWeight.w700,
          height: 1.0,
          letterSpacing: -1.4,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.08,
          letterSpacing: -0.9,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.12,
          letterSpacing: -0.5,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.22,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.55,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.18,
          color: textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.84),
        hintStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 14,
          color: textMuted,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          borderSide: BorderSide(color: borderSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          borderSide: BorderSide(color: borderSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          borderSide: const BorderSide(color: accent, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        selectedColor: accent.withValues(alpha: 0.12),
        disabledColor: Colors.white.withValues(alpha: 0.55),
        side: const BorderSide(color: borderSoft),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusPill),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.92),
        indicatorColor: accent.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? textPrimary : textSecondary,
          );
        }),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: accent.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusLg),
          ),
          textStyle: const TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: borderSoft),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusLg),
          ),
          textStyle: const TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: textSecondary,
          hoverColor: accent.withValues(alpha: 0.08),
          focusColor: accent.withValues(alpha: 0.12),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: textPrimary,
        contentTextStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 14,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderSoft,
        thickness: 1,
        space: 1,
      ),
      extensions: const [tokens],
    );

    return base;
  }
}
