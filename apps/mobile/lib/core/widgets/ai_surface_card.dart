import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_visual_tokens.dart';

enum AiCardVariant { elevated, subdued, accent, code }

class AiSurfaceCard extends StatefulWidget {
  const AiSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.variant = AiCardVariant.elevated,
    this.onTap,
    this.semanticsLabel,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final AiCardVariant variant;
  final VoidCallback? onTap;
  final String? semanticsLabel;
  final double? borderRadius;

  @override
  State<AiSurfaceCard> createState() => _AiSurfaceCardState();
}

class _AiSurfaceCardState extends State<AiSurfaceCard> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final radius = BorderRadius.circular(
      widget.borderRadius ?? tokens.radiusXl,
    );
    final isInteractive = widget.onTap != null;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final decoration = _CardDecoration.resolve(
      tokens: tokens,
      variant: widget.variant,
      hovered: isInteractive && _hovered,
      focused: isInteractive && _focused,
    );

    final content = AnimatedContainer(
      duration: reduceMotion ? Duration.zero : tokens.motionBase,
      curve: Curves.easeOutCubic,
      padding: widget.padding,
      decoration: BoxDecoration(
        gradient: decoration.gradient,
        color: decoration.gradient == null ? decoration.fill : null,
        borderRadius: radius,
        border: Border.all(
          color: decoration.border,
          width: decoration.borderWidth,
        ),
        boxShadow: decoration.shadows,
      ),
      child: widget.child,
    );

    final wrappedContent = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: decoration.blurSigma,
          sigmaY: decoration.blurSigma,
        ),
        child: Material(
          color: Colors.transparent,
          child: isInteractive
              ? InkWell(
                  onTap: widget.onTap,
                  borderRadius: radius,
                  child: content,
                )
              : content,
        ),
      ),
    );

    return Semantics(
      container: true,
      button: isInteractive,
      label: widget.semanticsLabel,
      child: FocusableActionDetector(
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        onShowHoverHighlight: (value) => setState(() => _hovered = value),
        child: wrappedContent,
      ),
    );
  }
}

class _CardDecoration {
  const _CardDecoration({
    required this.fill,
    required this.border,
    required this.borderWidth,
    required this.shadows,
    required this.blurSigma,
    this.gradient,
  });

  final Color fill;
  final Color border;
  final double borderWidth;
  final List<BoxShadow> shadows;
  final double blurSigma;
  final Gradient? gradient;

  static _CardDecoration resolve({
    required AppVisualTokens tokens,
    required AiCardVariant variant,
    required bool hovered,
    required bool focused,
  }) {
    final activeBorder = focused
        ? tokens.accent.withValues(alpha: 0.55)
        : hovered
        ? tokens.accent.withValues(alpha: 0.3)
        : tokens.borderSoft;
    final activeShadows = hovered || focused
        ? [
            BoxShadow(
              color: tokens.shadowStrong,
              blurRadius: 28,
              offset: const Offset(0, 18),
            ),
          ]
        : [
            BoxShadow(
              color: tokens.shadowSoft,
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ];

    return switch (variant) {
      AiCardVariant.elevated => _CardDecoration(
        fill: Colors.white.withValues(alpha: 0.78),
        border: activeBorder,
        borderWidth: focused ? 1.35 : 1,
        shadows: activeShadows,
        blurSigma: tokens.blurSigma,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.92),
            Colors.white.withValues(alpha: 0.72),
          ],
        ),
      ),
      AiCardVariant.subdued => _CardDecoration(
        fill: tokens.backgroundElevated.withValues(alpha: 0.82),
        border: activeBorder,
        borderWidth: focused ? 1.35 : 1,
        shadows: activeShadows,
        blurSigma: tokens.blurSigma - 2,
      ),
      AiCardVariant.accent => _CardDecoration(
        fill: tokens.backgroundAccent,
        border: activeBorder,
        borderWidth: focused ? 1.35 : 1,
        shadows: activeShadows,
        blurSigma: tokens.blurSigma - 4,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.88),
            tokens.accent.withValues(alpha: 0.09),
          ],
        ),
      ),
      AiCardVariant.code => _CardDecoration(
        fill: const Color(0xFF0B1120).withValues(alpha: 0.96),
        border: const Color(0xFF1E293B),
        borderWidth: focused ? 1.35 : 1,
        shadows: activeShadows,
        blurSigma: 4,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111827), Color(0xFF0B1120)],
        ),
      ),
    };
  }
}
