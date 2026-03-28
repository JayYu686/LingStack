import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/app_visual_tokens.dart';
import 'ai_surface_card.dart';

class AiPageHeaderData {
  const AiPageHeaderData({
    required this.title,
    required this.subtitle,
    this.eyebrow,
  });

  final String title;
  final String subtitle;
  final String? eyebrow;
}

enum AiLoadingState { idle, loading, success, error }

enum AiStatusTone { neutral, accent, success, warning }

class AiSectionHeader extends StatelessWidget {
  const AiSectionHeader({
    super.key,
    required this.data,
    this.trailing,
    this.large = false,
  });

  final AiPageHeaderData data;
  final Widget? trailing;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data.eyebrow != null) ...[
                Text(
                  data.eyebrow!,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: tokens.accent,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Text(
                data.title,
                style: large
                    ? Theme.of(context).textTheme.headlineLarge
                    : Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                data.subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

class AiCommandBar extends StatefulWidget {
  const AiCommandBar({
    super.key,
    required this.controller,
    required this.hintText,
    this.compactHintText,
    this.onValueChanged,
    this.onSubmitted,
    this.leading = Icons.search_rounded,
    this.state = AiLoadingState.idle,
    this.semanticsLabel,
  });

  final TextEditingController controller;
  final String hintText;
  final String? compactHintText;
  final ValueChanged<TextEditingValue>? onValueChanged;
  final ValueChanged<String>? onSubmitted;
  final IconData leading;
  final AiLoadingState state;
  final String? semanticsLabel;

  @override
  State<AiCommandBar> createState() => _AiCommandBarState();
}

class _AiCommandBarState extends State<AiCommandBar> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocus);
    widget.controller.addListener(_handleTextChanged);
    _hasText = widget.controller.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocus)
      ..dispose();
    widget.controller.removeListener(_handleTextChanged);
    super.dispose();
  }

  void _handleFocus() {
    setState(() => _focused = _focusNode.hasFocus);
  }

  void _handleTextChanged() {
    widget.onValueChanged?.call(widget.controller.value);
    final next = widget.controller.text.trim().isNotEmpty;
    if (next != _hasText) {
      setState(() => _hasText = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 430;
    final tight = width < 390;
    final resolvedHint = tight && widget.compactHintText != null
        ? widget.compactHintText!
        : widget.hintText;

    return Semantics(
      textField: true,
      label: widget.semanticsLabel ?? resolvedHint,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.radiusXl),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: tokens.blurSigma + 2,
            sigmaY: tokens.blurSigma + 2,
          ),
          child: AnimatedContainer(
            duration: reduceMotion ? Duration.zero : tokens.motionBase,
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 14 : 16,
              vertical: compact ? 12 : 13,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(tokens.radiusXl),
              border: Border.all(
                color: _focused
                    ? tokens.accent.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.78),
                width: _focused ? 1.15 : 0.95,
              ),
              boxShadow: [
                BoxShadow(
                  color: tokens.shadowSoft.withValues(
                    alpha: _focused ? 0.28 : 0.18,
                  ),
                  blurRadius: _focused ? 26 : 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 14,
                  right: 14,
                  top: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0),
                            Colors.white.withValues(alpha: 0.58),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      widget.leading,
                      size: compact ? 22 : 24,
                      color: _focused
                          ? tokens.textPrimary
                          : tokens.textSecondary,
                    ),
                    SizedBox(width: compact ? 10 : 12),
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        onSubmitted: widget.onSubmitted,
                        cursorColor: tokens.textPrimary,
                        textInputAction: TextInputAction.search,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: tight ? 14 : 15,
                          height: 1.25,
                          color: tokens.textPrimary,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: resolvedHint,
                          hintMaxLines: 1,
                          hintStyle: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontSize: tight ? 13.5 : 14.5,
                                color: tokens.textMuted.withValues(alpha: 0.9),
                                height: 1.25,
                              ),
                        ),
                      ),
                    ),
                    if (_hasText || widget.state == AiLoadingState.loading)
                      const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: reduceMotion
                          ? Duration.zero
                          : tokens.motionBase,
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: _buildTrailingAction(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrailingAction(BuildContext context) {
    final tokens = context.tokens;
    if (widget.state == AiLoadingState.loading) {
      return SizedBox(
        key: const ValueKey('loading'),
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: tokens.accent),
      );
    }

    if (_hasText) {
      return IconButton(
        key: const ValueKey('clear'),
        visualDensity: VisualDensity.compact,
        tooltip: '清空搜索',
        onPressed: () {
          widget.controller.clear();
          _focusNode.requestFocus();
        },
        icon: Icon(Icons.close_rounded, color: tokens.textSecondary),
      );
    }

    return const SizedBox.shrink(key: ValueKey('idle'));
  }
}

class AiMetricPill extends StatelessWidget {
  const AiMetricPill({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(tokens.radiusPill),
        border: Border.all(color: tokens.borderSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: tokens.textPrimary),
          ),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class AiStatusPill extends StatelessWidget {
  const AiStatusPill({
    super.key,
    required this.label,
    this.tone = AiStatusTone.neutral,
  });

  final String label;
  final AiStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = switch (tone) {
      AiStatusTone.neutral => (
        fill: Colors.white.withValues(alpha: 0.76),
        text: tokens.textSecondary,
      ),
      AiStatusTone.accent => (
        fill: tokens.accent.withValues(alpha: 0.12),
        text: tokens.accent,
      ),
      AiStatusTone.success => (
        fill: tokens.success.withValues(alpha: 0.12),
        text: tokens.success,
      ),
      AiStatusTone.warning => (
        fill: tokens.warning.withValues(alpha: 0.14),
        text: tokens.warning,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.fill,
        borderRadius: BorderRadius.circular(tokens.radiusPill),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: colors.text),
      ),
    );
  }
}

class AiStepRail extends StatelessWidget {
  const AiStepRail({super.key, required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      children: steps.asMap().entries.map((entry) {
        final isLast = entry.key == steps.length - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: tokens.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: tokens.accent.withValues(alpha: 0.2),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${entry.key + 1}',
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: tokens.accent),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 1.5,
                      height: 28,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      color: tokens.borderSoft,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(entry.value),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class AiSkeletonBlock extends StatelessWidget {
  const AiSkeletonBlock({
    super.key,
    required this.height,
    this.width,
    this.radius,
  });

  final double height;
  final double? width;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: tokens.borderSoft.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(radius ?? 14),
      ),
    );
  }
}

class AiEmptyState extends StatelessWidget {
  const AiEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AiSurfaceCard(
      variant: AiCardVariant.subdued,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tokens.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: tokens.accent),
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(description),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

class AiReveal extends StatefulWidget {
  const AiReveal({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = const Offset(0, 0.06),
  });

  final Widget child;
  final int index;
  final Offset offset;

  @override
  State<AiReveal> createState() => _AiRevealState();
}

class _AiRevealState extends State<AiReveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final reduceMotion =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (reduceMotion) {
        if (mounted) {
          setState(() => _visible = true);
        }
        return;
      }
      await Future<void>.delayed(Duration(milliseconds: 50 * widget.index));
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return AnimatedOpacity(
      duration: reduceMotion ? Duration.zero : tokens.motionSlow,
      curve: Curves.easeOutCubic,
      opacity: _visible ? 1 : 0,
      child: AnimatedScale(
        duration: reduceMotion ? Duration.zero : tokens.motionSlow,
        curve: Curves.easeOutCubic,
        scale: _visible ? 1 : 0.985,
        child: AnimatedSlide(
          duration: reduceMotion ? Duration.zero : tokens.motionSlow,
          curve: Curves.easeOutCubic,
          offset: _visible ? Offset.zero : widget.offset,
          child: widget.child,
        ),
      ),
    );
  }
}
