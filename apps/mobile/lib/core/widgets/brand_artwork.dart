import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/models.dart';
import '../theme/app_visual_tokens.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/branding/lingstack-mark.svg',
      width: size,
      height: size,
    );
  }
}

class BrandBadge extends StatelessWidget {
  const BrandBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.86)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BrandMark(size: 34),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '灵感栈',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'LingStack',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: tokens.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HeroArtwork extends StatelessWidget {
  const HeroArtwork({super.key, this.height = 280});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/illustrations/hero-orbit.svg',
      height: height,
      fit: BoxFit.contain,
    );
  }
}

class ResourceTypeArtwork extends StatelessWidget {
  const ResourceTypeArtwork({super.key, required this.type, this.height = 108});

  final ResourceType type;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(_assetFor(type), height: height, fit: BoxFit.cover);
  }

  String _assetFor(ResourceType type) {
    switch (type) {
      case ResourceType.prompt:
        return 'assets/illustrations/prompt-card.svg';
      case ResourceType.skill:
        return 'assets/illustrations/skill-card.svg';
      case ResourceType.mcp:
        return 'assets/illustrations/mcp-card.svg';
    }
  }
}
