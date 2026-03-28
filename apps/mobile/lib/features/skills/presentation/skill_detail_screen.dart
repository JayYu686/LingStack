import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/actions/catalog_actions.dart';
import '../../../core/widgets/ai_primitives.dart';
import '../../../core/widgets/ai_surface_card.dart';
import '../../../core/widgets/code_viewer.dart';
import '../../../domain/models.dart';
import '../../../domain/tool_spec_compiler.dart';
import '../../../infrastructure/providers.dart';

class SkillDetailScreen extends ConsumerWidget {
  const SkillDetailScreen({super.key, required this.resourceId});

  final String resourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(skillDetailProvider(resourceId));

    return detail.when(
      data: (data) {
        if (data == null) {
          return const Scaffold(body: Center(child: Text('没有找到这条技能资源。')));
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('技能详情'),
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
            child: FilledButton.icon(
              onPressed: () => copyTextAction(
                context,
                data.copyPayload,
                successMessage: '技能内容已复制',
              ),
              icon: const Icon(Icons.content_copy_rounded),
              label: const Text('复制这条技能'),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            children: [
              _SkillHero(detail: data),
              const SizedBox(height: 16),
              AiSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AiSectionHeader(
                      data: AiPageHeaderData(
                        eyebrow: '价值',
                        title: '这条技能能帮你做什么',
                        subtitle: '先看价值和输入准备，再决定要不要接到你的工作流里。',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(data.capabilitySummary),
                    const SizedBox(height: 18),
                    Text(
                      '使用前需要准备',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    ...data.inputRequirements.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 3),
                              child: Icon(Icons.check_circle_rounded, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(item)),
                          ],
                        ),
                      ),
                    ),
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
                        eyebrow: '步骤',
                        title: '怎么接，怎么用',
                        subtitle: '先按顺序走通一遍，再决定是否沉淀成你自己的版本。',
                      ),
                    ),
                    const SizedBox(height: 14),
                    AiStepRail(steps: data.usageSteps),
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
                        eyebrow: '复制内容',
                        title: '先看一眼你将要复制什么',
                        subtitle: '如果这份内容符合你的使用习惯，就可以直接复制走。',
                      ),
                    ),
                    const SizedBox(height: 14),
                    SelectableText(data.copyPayload),
                    const SizedBox(height: 16),
                    Text('适用模型', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: data.supportedModels
                          .map((model) => AiStatusPill(label: model))
                          .toList(),
                    ),
                  ],
                ),
              ),
              if (data.exampleCode.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                const AiSectionHeader(
                  data: AiPageHeaderData(
                    eyebrow: '调用示例',
                    title: '接入时可以参考这段示例',
                    subtitle: '这块和普通说明卡分开，方便你直接复制或对照阅读。',
                  ),
                ),
                const SizedBox(height: 12),
                CodeViewer(
                  language: data.exampleLanguage,
                  code: data.exampleCode,
                ),
              ],
              const SizedBox(height: 16),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('高级信息'),
                subtitle: const Text('如果你要把它接到 Agent、工具调用或系统提示里，再展开这里。'),
                childrenPadding: const EdgeInsets.only(bottom: 16),
                children: [
                  AiSurfaceCard(
                    variant: AiCardVariant.subdued,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '输入 Schema',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        SelectableText(prettyJson(data.rawSchema)),
                        const SizedBox(height: 16),
                        Text(
                          '供应商适配',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        SelectableText(prettyJson(data.providerAdapters)),
                        const SizedBox(height: 16),
                        Text(
                          'OpenAI 工具定义',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        SelectableText(
                          prettyJson(SkillSpecCompiler.openAI(data)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const _SkillDetailLoading(),
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text('技能加载失败：$error'))),
    );
  }
}

class _SkillHero extends StatelessWidget {
  const _SkillHero({required this.detail});

  final SkillResourceDetail detail;

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
                label: detail.resource.scenario,
                tone: AiStatusTone.accent,
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

class _SkillDetailLoading extends StatelessWidget {
  const _SkillDetailLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        children: const [
          AiSkeletonBlock(height: 170),
          SizedBox(height: 16),
          AiSkeletonBlock(height: 220),
          SizedBox(height: 16),
          AiSkeletonBlock(height: 220),
        ],
      ),
    );
  }
}
