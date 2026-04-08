import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/actions/catalog_actions.dart';
import '../../../core/widgets/ai_primitives.dart';
import '../../../core/widgets/ai_surface_card.dart';
import '../../../core/widgets/code_viewer.dart';
import '../../../domain/models.dart';
import '../../../domain/prompt_workbench_models.dart';
import '../../../features/prompts/application/prompt_workbench_controller.dart';

class PromptDetailScreen extends ConsumerStatefulWidget {
  const PromptDetailScreen({super.key, required this.resourceId});

  final String resourceId;

  @override
  ConsumerState<PromptDetailScreen> createState() => _PromptDetailScreenState();
}

class _PromptDetailScreenState extends ConsumerState<PromptDetailScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref
          .read(promptWorkbenchControllerProvider(widget.resourceId).notifier)
          .ensureLoaded(),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PromptWorkbenchState>(
      promptWorkbenchControllerProvider(widget.resourceId),
      (previous, next) {
        if (!mounted) {
          return;
        }
        if (next.infoMessage != null &&
            next.infoMessage != previous?.infoMessage) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(next.infoMessage!)));
          ref
              .read(
                promptWorkbenchControllerProvider(widget.resourceId).notifier,
              )
              .clearMessages();
        } else if (next.errorMessage != null &&
            next.errorMessage != previous?.errorMessage) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
        }
      },
    );

    final state = ref.watch(
      promptWorkbenchControllerProvider(widget.resourceId),
    );
    final detail = state.detail;

    if (detail != null) {
      _syncControllers(detail, state.values);
    }

    if (state.loading) {
      return const Scaffold(body: _PromptDetailLoading());
    }

    if (detail == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('提示词详情')),
        body: const Padding(
          padding: EdgeInsets.all(20),
          child: AiEmptyState(
            icon: Icons.search_off_rounded,
            title: '没有找到这条提示词',
            description: '可能这条资源已经被删除，或者目录还没有刷新到最新版本。',
          ),
        ),
      );
    }

    final missingRequired = state.missingRequired;

    return Scaffold(
      appBar: AppBar(
        title: const Text('提示词详情'),
        actions: [
          IconButton(
            onPressed: () =>
                toggleFavoriteAction(context, ref, detail.resource.id),
            icon: Icon(
              detail.resource.isFavorite
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
            ),
            tooltip: detail.resource.isFavorite ? '取消收藏' : '加入收藏',
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: FilledButton.icon(
          onPressed: state.copying || !state.canCopy
              ? null
              : () async {
                  await copyTextAction(
                    context,
                    state.rendered,
                    successMessage: '已复制可用版本',
                  );
                  await ref
                      .read(
                        promptWorkbenchControllerProvider(
                          widget.resourceId,
                        ).notifier,
                      )
                      .markCopied();
                },
          icon: state.copying
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.content_copy_rounded),
          label: Text(state.canCopy ? '复制可用版本' : '先补齐必填变量再复制'),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 980;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            children: [
              _PromptHero(detail: detail, usage: state.usage),
              const SizedBox(height: 16),
              if (missingRequired.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AiSurfaceCard(
                    variant: AiCardVariant.subdued,
                    child: MergeSemantics(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '还有这些必填项没填：${missingRequired.join('、')}。补齐后才能复制最终版本。',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _VariableWorkbench(
                        detail: detail,
                        controllers: _controllers,
                        values: state.values,
                        onChanged: _updateValue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PreviewPanel(detail: detail, state: state),
                    ),
                  ],
                )
              else ...[
                _VariableWorkbench(
                  detail: detail,
                  controllers: _controllers,
                  values: state.values,
                  onChanged: _updateValue,
                ),
                const SizedBox(height: 16),
                _PreviewPanel(detail: detail, state: state),
              ],
              const SizedBox(height: 16),
              AiSurfaceCard(
                variant: AiCardVariant.subdued,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AiSectionHeader(
                      data: AiPageHeaderData(
                        eyebrow: '适用边界',
                        title: '什么时候适合用，什么时候不要硬套',
                        subtitle: '先确认适用场景，再决定是否直接复制。',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('适合场景', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(detail.whenToUse),
                    const SizedBox(height: 16),
                    Text(
                      '不适合场景',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(detail.avoidWhen),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('参考示例'),
                subtitle: const Text('需要时再看别人是怎么输入和输出的。'),
                childrenPadding: const EdgeInsets.only(bottom: 16),
                children: [
                  AiSurfaceCard(
                    variant: AiCardVariant.subdued,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '示例输入',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        SelectableText(detail.exampleInput),
                        const SizedBox(height: 16),
                        Text(
                          '示例输出',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        SelectableText(detail.exampleOutput),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _syncControllers(
    PromptResourceDetail detail,
    Map<String, String> values,
  ) {
    for (final variable in detail.variables) {
      final controller = _controllers.putIfAbsent(
        variable.name,
        () => TextEditingController(),
      );
      final nextText = values[variable.name] ?? variable.defaultValue;
      if (controller.text != nextText) {
        controller.text = nextText;
      }
    }
  }

  void _updateValue(String name, String value) {
    ref
        .read(promptWorkbenchControllerProvider(widget.resourceId).notifier)
        .updateValue(name, value);
  }
}

class _PromptHero extends StatelessWidget {
  const _PromptHero({required this.detail, required this.usage});

  final PromptResourceDetail detail;
  final PromptUsageRecord? usage;

  @override
  Widget build(BuildContext context) {
    return AiSurfaceCard(
      variant: AiCardVariant.accent,
      child: MergeSemantics(
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
                AiStatusPill(
                  label: detail.resource.difficulty.label,
                  tone: AiStatusTone.neutral,
                ),
                AiStatusPill(
                  label: detail.resource.qualityTier.label,
                  tone:
                      detail.resource.qualityTier ==
                          ResourceQualityTier.experimental
                      ? AiStatusTone.warning
                      : AiStatusTone.accent,
                ),
                if (detail.resource.verifiedAt != null)
                  AiStatusPill(
                    label:
                        '最近验证 ${detail.resource.verifiedAt!.year}-${detail.resource.verifiedAt!.month.toString().padLeft(2, '0')}-${detail.resource.verifiedAt!.day.toString().padLeft(2, '0')}',
                    tone: AiStatusTone.neutral,
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
              children: [
                AiMetricPill(
                  label: '质量分',
                  value: '${detail.resource.qualityScore}',
                ),
                AiMetricPill(label: '复制次数', value: '${usage?.useCount ?? 0}'),
                AiStatusPill(
                  label: detail.resource.scenario,
                  tone: AiStatusTone.accent,
                ),
              ],
            ),
            if (detail.resource.qualityReasons.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text('为什么推荐', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...detail.resource.qualityReasons.map(
                (reason) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(reason)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VariableWorkbench extends StatelessWidget {
  const _VariableWorkbench({
    required this.detail,
    required this.controllers,
    required this.values,
    required this.onChanged,
  });

  final PromptResourceDetail detail;
  final Map<String, TextEditingController> controllers;
  final Map<String, String> values;
  final void Function(String name, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    return AiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionHeader(
            data: AiPageHeaderData(
              eyebrow: '步骤 1',
              title: '填写关键信息',
              subtitle: '只填和当前任务直接相关的变量，不需要先理解模板结构。',
            ),
          ),
          const SizedBox(height: 14),
          ...detail.variables.map((variable) {
            final controller = controllers[variable.name]!;
            final required = detail.requiredVariableNames.contains(
              variable.name,
            );
            final helperText = variable.description.trim().isNotEmpty
                ? variable.description
                : null;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: MergeSemantics(
                child: Semantics(
                  textField: true,
                  label: '${variable.name}${required ? '，必填' : '，选填'}',
                  child: _PromptVariableField(
                    variable: variable,
                    controller: controller,
                    helperText: helperText,
                    currentValue: values[variable.name] ?? '',
                    required: required,
                    onChanged: (value) => onChanged(variable.name, value),
                  ),
                ),
              ),
            );
          }),
          if (detail.helperNotes.isNotEmpty) ...[
            const SizedBox(height: 6),
            AiSurfaceCard(
              variant: AiCardVariant.subdued,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('填写建议', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  ...detail.helperNotes.map(
                    (note) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.tips_and_updates_rounded, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(note)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PromptVariableField extends StatelessWidget {
  const _PromptVariableField({
    required this.variable,
    required this.controller,
    required this.helperText,
    required this.currentValue,
    required this.required,
    required this.onChanged,
  });

  final PromptVariable variable;
  final TextEditingController controller;
  final String? helperText;
  final String currentValue;
  final bool required;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = '${variable.name}${required ? ' *' : ''}';
    switch (variable.type) {
      case PromptVariableType.enumeration:
        final current = currentValue.isEmpty
            ? (variable.options.isNotEmpty ? variable.options.first : '')
            : currentValue;
        return DropdownButtonFormField<String>(
          initialValue: variable.options.contains(current) ? current : null,
          items: variable.options
              .map(
                (value) =>
                    DropdownMenuItem<String>(value: value, child: Text(value)),
              )
              .toList(),
          decoration: InputDecoration(labelText: label, helperText: helperText),
          onChanged: (value) => onChanged(value ?? ''),
        );
      case PromptVariableType.booleanType:
        return SwitchListTile.adaptive(
          value: currentValue == 'true',
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          subtitle: helperText == null ? null : Text(helperText!),
          onChanged: (value) => onChanged(value ? 'true' : 'false'),
        );
      case PromptVariableType.code:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            if (helperText != null) ...[
              const SizedBox(height: 6),
              Text(helperText!),
            ],
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              minLines: 6,
              maxLines: 10,
              onChanged: onChanged,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontFamily: 'JetBrainsMono'),
              decoration: const InputDecoration(
                hintText: '直接粘贴代码内容',
                alignLabelWithHint: true,
              ),
            ),
          ],
        );
      case PromptVariableType.longText:
        return TextField(
          controller: controller,
          minLines: 4,
          maxLines: 6,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            helperText: helperText,
            alignLabelWithHint: true,
          ),
        );
      case PromptVariableType.text:
        return TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(labelText: label, helperText: helperText),
        );
    }
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({required this.detail, required this.state});

  final PromptResourceDetail detail;
  final PromptWorkbenchState state;

  @override
  Widget build(BuildContext context) {
    return AiSurfaceCard(
      variant: AiCardVariant.subdued,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionHeader(
            data: AiPageHeaderData(
              eyebrow: '步骤 2',
              title: '检查渲染结果',
              subtitle: '复制前先看一眼最终版本，确认语气、输入和限制条件都对。',
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: detail.resource.useCases
                .map(
                  (value) =>
                      AiStatusPill(label: value, tone: AiStatusTone.neutral),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          CodeViewer(language: 'markdown', code: state.rendered),
          if (detail.resource.avoidCases.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('不建议这样用', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...detail.resource.avoidCases.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.block_rounded, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PromptDetailLoading extends StatelessWidget {
  const _PromptDetailLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        children: const [
          AiSkeletonBlock(height: 220),
          SizedBox(height: 16),
          AiSkeletonBlock(height: 320),
          SizedBox(height: 16),
          AiSkeletonBlock(height: 320),
        ],
      ),
    );
  }
}
