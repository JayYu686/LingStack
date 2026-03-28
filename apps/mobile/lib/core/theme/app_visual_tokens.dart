import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

@immutable
class AppVisualTokens extends ThemeExtension<AppVisualTokens> {
  const AppVisualTokens({
    required this.backgroundBase,
    required this.backgroundElevated,
    required this.backgroundAccent,
    required this.backgroundTop,
    required this.backgroundBottom,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.success,
    required this.warning,
    required this.borderSoft,
    required this.borderStrong,
    required this.shadowSoft,
    required this.shadowStrong,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusXl,
    required this.radiusPill,
    required this.spacingSm,
    required this.spacingMd,
    required this.spacingLg,
    required this.spacingXl,
    required this.blurSigma,
    required this.motionFast,
    required this.motionBase,
    required this.motionSlow,
  });

  final Color backgroundBase;
  final Color backgroundElevated;
  final Color backgroundAccent;
  final Color backgroundTop;
  final Color backgroundBottom;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color success;
  final Color warning;
  final Color borderSoft;
  final Color borderStrong;
  final Color shadowSoft;
  final Color shadowStrong;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;
  final double radiusPill;
  final double spacingSm;
  final double spacingMd;
  final double spacingLg;
  final double spacingXl;
  final double blurSigma;
  final Duration motionFast;
  final Duration motionBase;
  final Duration motionSlow;

  LinearGradient get backgroundGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundTop, backgroundBase, backgroundBottom],
  );

  @override
  AppVisualTokens copyWith({
    Color? backgroundBase,
    Color? backgroundElevated,
    Color? backgroundAccent,
    Color? backgroundTop,
    Color? backgroundBottom,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? success,
    Color? warning,
    Color? borderSoft,
    Color? borderStrong,
    Color? shadowSoft,
    Color? shadowStrong,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? radiusPill,
    double? spacingSm,
    double? spacingMd,
    double? spacingLg,
    double? spacingXl,
    double? blurSigma,
    Duration? motionFast,
    Duration? motionBase,
    Duration? motionSlow,
  }) {
    return AppVisualTokens(
      backgroundBase: backgroundBase ?? this.backgroundBase,
      backgroundElevated: backgroundElevated ?? this.backgroundElevated,
      backgroundAccent: backgroundAccent ?? this.backgroundAccent,
      backgroundTop: backgroundTop ?? this.backgroundTop,
      backgroundBottom: backgroundBottom ?? this.backgroundBottom,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      borderSoft: borderSoft ?? this.borderSoft,
      borderStrong: borderStrong ?? this.borderStrong,
      shadowSoft: shadowSoft ?? this.shadowSoft,
      shadowStrong: shadowStrong ?? this.shadowStrong,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusXl: radiusXl ?? this.radiusXl,
      radiusPill: radiusPill ?? this.radiusPill,
      spacingSm: spacingSm ?? this.spacingSm,
      spacingMd: spacingMd ?? this.spacingMd,
      spacingLg: spacingLg ?? this.spacingLg,
      spacingXl: spacingXl ?? this.spacingXl,
      blurSigma: blurSigma ?? this.blurSigma,
      motionFast: motionFast ?? this.motionFast,
      motionBase: motionBase ?? this.motionBase,
      motionSlow: motionSlow ?? this.motionSlow,
    );
  }

  @override
  AppVisualTokens lerp(ThemeExtension<AppVisualTokens>? other, double t) {
    if (other is! AppVisualTokens) {
      return this;
    }
    return AppVisualTokens(
      backgroundBase: Color.lerp(backgroundBase, other.backgroundBase, t)!,
      backgroundElevated: Color.lerp(
        backgroundElevated,
        other.backgroundElevated,
        t,
      )!,
      backgroundAccent: Color.lerp(
        backgroundAccent,
        other.backgroundAccent,
        t,
      )!,
      backgroundTop: Color.lerp(backgroundTop, other.backgroundTop, t)!,
      backgroundBottom: Color.lerp(
        backgroundBottom,
        other.backgroundBottom,
        t,
      )!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      borderSoft: Color.lerp(borderSoft, other.borderSoft, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      shadowSoft: Color.lerp(shadowSoft, other.shadowSoft, t)!,
      shadowStrong: Color.lerp(shadowStrong, other.shadowStrong, t)!,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t)!,
      radiusXl: lerpDouble(radiusXl, other.radiusXl, t)!,
      radiusPill: lerpDouble(radiusPill, other.radiusPill, t)!,
      spacingSm: lerpDouble(spacingSm, other.spacingSm, t)!,
      spacingMd: lerpDouble(spacingMd, other.spacingMd, t)!,
      spacingLg: lerpDouble(spacingLg, other.spacingLg, t)!,
      spacingXl: lerpDouble(spacingXl, other.spacingXl, t)!,
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t)!,
      motionFast: t < 0.5 ? motionFast : other.motionFast,
      motionBase: t < 0.5 ? motionBase : other.motionBase,
      motionSlow: t < 0.5 ? motionSlow : other.motionSlow,
    );
  }
}

extension AppVisualTokensBuildContextX on BuildContext {
  AppVisualTokens get tokens => Theme.of(this).extension<AppVisualTokens>()!;
}
