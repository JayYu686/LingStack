import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/actions/catalog_actions.dart';
import '../../../core/widgets/ai_primitives.dart';
import '../../../core/widgets/ai_surface_card.dart';
import '../../../core/widgets/code_viewer.dart';
import '../../../domain/models.dart';
import '../../../infrastructure/providers.dart';

class McpServerDetailScreen extends ConsumerWidget {
  const McpServerDetailScreen({super.key, required this.resourceId});

  final String resourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(mcpDetailProvider(resourceId));

    return detail.when(
      data: (data) {
        if (data == null) {
          return const Scaffold(body: Center(child: Text('没有找到这条 MCP 资源。')));
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('MCP 详情'),
            actions: [
              IconButton(
                onPressed: () =>
                    toggleFavoriteAction(context, ref, data.resource.id),
                icon: Icon(
                  data.resource.isFavorite
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                ),
                tooltip: data.resource.isFavorite ? '取消收藏' : '加入收藏',
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => copyTextAction(
                      context,
                      data.configTemplate,
                      successMessage: 'MCP 配置模板已复制',
                    ),
                    icon: const Icon(Icons.content_copy_rounded),
                    label: const Text('复制模板'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        context.go('/mcp/${data.resource.id}/test'),
                    icon: const Icon(Icons.wifi_tethering_rounded),
                    label: const Text('测试连接'),
                  ),
                ),
              ],
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            children: [
              _McpHero(detail: data),
              const SizedBox(height: 16),
              _ResourceQualitySection(resource: data.resource),
              const SizedBox(height: 16),
              AiSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AiSectionHeader(
                      data: AiPageHeaderData(
                        eyebrow: '适配平台',
                        title: '这条 MCP 适合连接什么',
                        subtitle: '先确认它适配哪些客户端、传输方式和风险级别，再决定是否接入。',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(data.capabilitiesSummary),
                    const SizedBox(height: 18),
                    Text(
                      '适配客户端',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: data.supportedClients
                          .map((client) => AiStatusPill(label: client))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Text('传输方式', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(_transportLabel(data.transport)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AiSurfaceCard(
                variant: AiCardVariant.subdued,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AiSectionHeader(
                      data: AiPageHeaderData(
                        eyebrow: '接入步骤',
                        title: '按顺序完成配置会更稳',
                        subtitle: '先准备权限和环境变量，再把模板放进支持 MCP 的客户端里。',
                      ),
                    ),
                    const SizedBox(height: 14),
                    AiStepRail(steps: data.setupSteps),
                    if (data.requiredEnvVars.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Text(
                        '需要准备的环境变量',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: data.requiredEnvVars
                            .map(
                              (value) => AiStatusPill(
                                label: value,
                                tone: AiStatusTone.warning,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const AiSectionHeader(
                data: AiPageHeaderData(
                  eyebrow: '配置模板',
                  title: '复制后直接改成你的环境变量',
                  subtitle: '这是最适合直接粘贴到 MCP 客户端配置里的区域。',
                ),
              ),
              const SizedBox(height: 12),
              CodeViewer(language: 'json', code: data.configTemplate),
              const SizedBox(height: 16),
              AiSurfaceCard(
                variant: AiCardVariant.subdued,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AiSectionHeader(
                      data: AiPageHeaderData(
                        eyebrow: '安全提醒',
                        title: '接入前先确认权限边界',
                        subtitle: 'MCP 最容易出问题的不是配置本身，而是权限开得太大。',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(data.safetyNotes),
                    const SizedBox(height: 16),
                    Text('参考地址', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    SelectableText(data.baseUrl),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const _McpDetailLoading(),
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text('MCP 详情加载失败：$error'))),
    );
  }
}

class _McpHero extends StatelessWidget {
  const _McpHero({required this.detail});

  final McpResourceDetail detail;

  @override
  Widget build(BuildContext context) {
    return AiSurfaceCard(
      variant: AiCardVariant.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AiStatusPill(
                label: detail.resource.source.label,
                tone: detail.resource.isOfficial
                    ? AiStatusTone.success
                    : AiStatusTone.warning,
              ),
              AiStatusPill(label: detail.resource.difficulty.label),
              AiStatusPill(
                label: _riskLabel(detail.resource.difficulty),
                tone: _riskTone(detail.resource.difficulty),
              ),
              AiStatusPill(
                label: detail.resource.qualityTier.label,
                tone:
                    detail.resource.qualityTier ==
                        ResourceQualityTier.experimental
                    ? AiStatusTone.warning
                    : detail.resource.qualityTier ==
                          ResourceQualityTier.verified
                    ? AiStatusTone.success
                    : AiStatusTone.accent,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            detail.resource.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(detail.resource.summary),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: detail.resource.tags
                .map((tag) => AiStatusPill(label: tag))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _McpDetailLoading extends StatelessWidget {
  const _McpDetailLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        children: const [
          AiSkeletonBlock(height: 170),
          SizedBox(height: 16),
          AiSkeletonBlock(height: 240),
          SizedBox(height: 16),
          AiSkeletonBlock(height: 280),
        ],
      ),
    );
  }
}

class _ResourceQualitySection extends StatelessWidget {
  const _ResourceQualitySection({required this.resource});

  final CatalogResource resource;

  @override
  Widget build(BuildContext context) {
    return AiSurfaceCard(
      variant: AiCardVariant.subdued,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionHeader(
            data: AiPageHeaderData(
              eyebrow: '适用边界',
              title: '先看用途和风险，再决定要不要连',
              subtitle: 'MCP 真正容易出问题的通常不是模板，而是接入边界和权限范围。',
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AiMetricPill(label: '质量分', value: '${resource.qualityScore}'),
              AiStatusPill(label: resource.qualityTier.label),
              if (resource.verifiedAt != null)
                AiStatusPill(
                  label:
                      '最近验证 ${resource.verifiedAt!.year}-${resource.verifiedAt!.month.toString().padLeft(2, '0')}-${resource.verifiedAt!.day.toString().padLeft(2, '0')}',
                  tone: AiStatusTone.neutral,
                ),
            ],
          ),
          if (resource.useCases.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text('适合什么', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ...resource.useCases.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('• $item'),
              ),
            ),
          ],
          if (resource.avoidCases.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text('不适合什么', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ...resource.avoidCases.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('• $item'),
              ),
            ),
          ],
          if (resource.qualityReasons.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text('为什么给这个质量级别', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ...resource.qualityReasons.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('• $item'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _transportLabel(String transport) {
  return switch (transport) {
    'streamable_http' => '流式 HTTP',
    'sse' => '服务端事件流',
    'stdio' => '本地命令行进程',
    'websocket' => 'WebSocket',
    _ => transport,
  };
}

String _riskLabel(ResourceDifficulty difficulty) {
  return switch (difficulty) {
    ResourceDifficulty.beginner => '风险较低',
    ResourceDifficulty.intermediate => '需要留意权限',
    ResourceDifficulty.advanced => '高权限，谨慎接入',
  };
}

AiStatusTone _riskTone(ResourceDifficulty difficulty) {
  return switch (difficulty) {
    ResourceDifficulty.beginner => AiStatusTone.success,
    ResourceDifficulty.intermediate => AiStatusTone.warning,
    ResourceDifficulty.advanced => AiStatusTone.warning,
  };
}
