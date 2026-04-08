import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../theme/app_visual_tokens.dart';
import 'ai_primitives.dart';
import 'ai_surface_card.dart';

class ResourceCard extends StatelessWidget {
  const ResourceCard({
    super.key,
    required this.resource,
    required this.onTap,
    required this.onFavoriteToggle,
    this.compact = false,
  });

  final CatalogResource resource;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final primaryUseCase = resource.useCases.isEmpty
        ? null
        : resource.useCases.first;
    return MergeSemantics(
      child: AiSurfaceCard(
        onTap: onTap,
        semanticsLabel: '${resource.title}，${resource.type.label}资源',
        padding: EdgeInsets.all(compact ? 16 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AiStatusPill(
                        label: resource.type.label,
                        tone: _typeTone(resource.type),
                      ),
                      AiStatusPill(
                        label: resource.qualityTier.label,
                        tone: _qualityTone(resource.qualityTier),
                      ),
                      AiStatusPill(
                        label: resource.difficulty.label,
                        tone: AiStatusTone.neutral,
                      ),
                      if (resource.isOfficial)
                        const AiStatusPill(
                          label: '官方资源',
                          tone: AiStatusTone.success,
                        )
                      else
                        const AiStatusPill(
                          label: '我的导入',
                          tone: AiStatusTone.warning,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Semantics(
                  button: true,
                  label: resource.isFavorite ? '取消收藏' : '加入收藏',
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onFavoriteToggle,
                    icon: Icon(
                      resource.isFavorite
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: resource.isFavorite
                          ? tokens.accent
                          : tokens.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              resource.title,
              maxLines: compact ? 1 : 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              resource.summary,
              maxLines: compact ? 2 : 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (primaryUseCase != null) ...[
              const SizedBox(height: 12),
              Text(
                '适合：$primaryUseCase',
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
              ),
            ],
            if (resource.avoidCases.isNotEmpty && !compact) ...[
              const SizedBox(height: 8),
              Text(
                '不适合：${resource.avoidCases.first}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
              ),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetaChip(
                  icon: Icons.track_changes_rounded,
                  label: resource.scenario,
                ),
                ...resource.tags
                    .take(compact ? 2 : 3)
                    .map(
                      (tag) => _MetaChip(icon: Icons.sell_outlined, label: tag),
                    ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    resource.primaryActionLabel,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: tokens.accent),
                  ),
                ),
                Text(
                  '${resource.qualityScore}',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: tokens.textSecondary),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, color: tokens.accent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(tokens.radiusPill),
        border: Border.all(color: tokens.borderSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: tokens.textMuted),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

AiStatusTone _typeTone(ResourceType type) {
  return switch (type) {
    ResourceType.prompt => AiStatusTone.accent,
    ResourceType.skill => AiStatusTone.success,
    ResourceType.mcp => AiStatusTone.warning,
  };
}

AiStatusTone _qualityTone(ResourceQualityTier tier) {
  return switch (tier) {
    ResourceQualityTier.featured => AiStatusTone.accent,
    ResourceQualityTier.verified => AiStatusTone.success,
    ResourceQualityTier.community => AiStatusTone.neutral,
    ResourceQualityTier.experimental => AiStatusTone.warning,
  };
}
