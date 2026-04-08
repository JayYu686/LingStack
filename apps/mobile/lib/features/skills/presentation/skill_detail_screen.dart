import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/actions/catalog_actions.dart';
import '../../../core/widgets/ai_primitives.dart';
import '../../../core/widgets/ai_surface_card.dart';
import '../../../core/widgets/code_viewer.dart';
import '../../../domain/models.dart';
import '../../../domain/tool_spec_compiler.dart';
import '../../../infrastructure/providers.dart';

class SkillDetailScreen extends ConsumerStatefulWidget {
  const SkillDetailScreen({super.key, required this.resourceId});

  final String resourceId;

  @override
  ConsumerState<SkillDetailScreen> createState() => _SkillDetailScreenState();
}

class _SkillDetailScreenState extends ConsumerState<SkillDetailScreen> {
  bool _processingPrimaryAction = false;

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(skillDetailProvider(widget.resourceId));

    return detail.when(
      data: (data) {
        if (data == null) {
          return const Scaffold(body: Center(child: Text('没有找到这条技能资源。')));
        }
        final isImported = data.resource.source == ResourceSource.imported;
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
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => copyTextAction(
                      context,
                      data.copyPayload,
                      successMessage: '技能内容已复制',
                    ),
                    icon: const Icon(Icons.content_copy_rounded),
                    label: const Text('复制内容'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _processingPrimaryAction
                        ? null
                        : () => _handlePrimaryAction(data, isImported),
                    icon: _processingPrimaryAction
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            isImported
                                ? Icons.edit_rounded
                                : Icons.copy_all_rounded,
                          ),
                    label: Text(isImported ? '编辑技能' : '复制为我的版本'),
                  ),
                ),
              ],
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            children: [
              _SkillHero(detail: data),
              const SizedBox(height: 16),
              _ResourceQualitySection(resource: data.resource),
              const SizedBox(height: 16),
              AiSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AiSectionHeader(
                      data: AiPageHeaderData(
                        eyebrow: '价值',
                        title: '这条技能能帮你做什么',
                        subtitle: '先看它解决的问题和需要准备什么，再决定要不要接到自己的工作流里。',
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
                        subtitle: '先按顺序走通一遍，再决定要不要沉淀成你自己的版本。',
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
                    title: '接入时可以参考这一段',
                    subtitle: '这块和普通说明分开，方便你直接复制或对照阅读。',
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
                subtitle: const Text('如果你要接到 Agent、工具调用或系统提示里，再展开这里。'),
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

  Future<void> _handlePrimaryAction(
    SkillResourceDetail detail,
    bool isImported,
  ) async {
    setState(() => _processingPrimaryAction = true);
    try {
      if (isImported) {
        if (!mounted) {
          return;
        }
        context.go('/skill/${detail.resource.id}/edit');
        return;
      }

      final repository = await ref.read(workspaceRepositoryProvider.future);
      final newId = await repository.duplicateOfficialSkill(detail.resource.id);
      ref.read(catalogRefreshTickProvider.notifier).bump();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已复制到“我的资源”，现在可以继续编辑。')));
      context.go('/skill/$newId/edit');
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('处理失败：$error')));
    } finally {
      if (mounted) {
        setState(() => _processingPrimaryAction = false);
      }
    }
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
              title: '先看适合什么，再决定要不要接入',
              subtitle: '这块把适用场景、不适合的情况和质量判断放在一起，避免拿错模板。',
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
