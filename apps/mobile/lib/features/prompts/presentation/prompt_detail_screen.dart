import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/actions/catalog_actions.dart';
import '../../../core/widgets/ai_primitives.dart';
import '../../../core/widgets/ai_surface_card.dart';
import '../../../domain/models.dart';
import '../../../domain/prompt_renderer.dart';
import '../../../infrastructure/providers.dart';

class PromptDetailScreen extends ConsumerStatefulWidget {
  const PromptDetailScreen({super.key, required this.resourceId});

  final String resourceId;

  @override
  ConsumerState<PromptDetailScreen> createState() => _PromptDetailScreenState();
}

class _PromptDetailScreenState extends ConsumerState<PromptDetailScreen> {
  final Map<String, String> _values = <String, String>{};

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(promptDetailProvider(widget.resourceId));

    return detail.when(
      data: (data) {
        if (data == null) {
          return const Scaffold(body: Center(child: Text('没有找到这条提示词。')));
        }

        for (final variable in data.variables) {
          _values.putIfAbsent(variable.name, () => variable.defaultValue);
        }

        final rendered = renderPromptTemplate(data.templateBody, _values);

        return Scaffold(
          appBar: AppBar(
            title: const Text('提示词详情'),
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
              onPressed: () =>
                  copyTextAction(context, rendered, successMessage: '提示词已复制'),
              icon: const Icon(Icons.content_copy_rounded),
              label: const Text('复制这条提示词'),
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 980;
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                children: [
                  _PromptHero(detail: data),
                  const SizedBox(height: 16),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _VariableWorkbench(
                            variables: data.variables,
                            values: _values,
                            onChanged: (name, value) {
                              setState(() {
                                _values[name] = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: _PreviewPanel(rendered: rendered)),
                      ],
                    )
                  else ...[
                    _VariableWorkbench(
                      variables: data.variables,
                      values: _values,
                      onChanged: (name, value) {
                        setState(() {
                          _values[name] = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _PreviewPanel(rendered: rendered),
                  ],
                  const SizedBox(height: 16),
                  AiSurfaceCard(
                    variant: AiCardVariant.subdued,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AiSectionHeader(
                          data: AiPageHeaderData(
                            eyebrow: '使用边界',
                            title: '什么时候用，什么时候别用',
                            subtitle: '先看清适用场景，再决定是否直接复制。',
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '适合场景',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(data.whenToUse),
                        const SizedBox(height: 16),
                        Text(
                          '不适合场景',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(data.avoidWhen),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text('参考示例'),
                    subtitle: const Text('先完成变量填写；需要时再看别人是怎么输入和输出的。'),
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
                            SelectableText(data.exampleInput),
                            const SizedBox(height: 16),
                            Text(
                              '示例输出',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 10),
                            SelectableText(data.exampleOutput),
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
      },
      loading: () => const _PromptDetailLoading(),
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text('提示词加载失败：$error'))),
    );
  }
}

class _PromptHero extends StatelessWidget {
  const _PromptHero({required this.detail});

  final PromptResourceDetail detail;

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
              AiStatusPill(
                label: detail.resource.difficulty.label,
                tone: AiStatusTone.neutral,
              ),
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
            children: detail.supportedModels
                .map(
                  (model) =>
                      AiStatusPill(label: model, tone: AiStatusTone.neutral),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _VariableWorkbench extends StatelessWidget {
  const _VariableWorkbench({
    required this.variables,
    required this.values,
    required this.onChanged,
  });

  final List<PromptVariable> variables;
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
              title: '填写关键变量',
              subtitle: '你不需要理解模板结构，只要把当前任务的关键信息填进去即可。',
            ),
          ),
          const SizedBox(height: 14),
          ...variables.map(
            (variable) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _VariableField(
                variable: variable,
                initialValue: values[variable.name] ?? '',
                onChanged: (value) => onChanged(variable.name, value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VariableField extends StatelessWidget {
  const _VariableField({
    required this.variable,
    required this.initialValue,
    required this.onChanged,
  });

  final PromptVariable variable;
  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final maxLines = switch (variable.type) {
      PromptVariableType.text => 1,
      PromptVariableType.enumeration => 1,
      PromptVariableType.booleanType => 1,
      PromptVariableType.longText => 4,
      PromptVariableType.code => 8,
    };
    return Semantics(
      textField: true,
      label: variable.name,
      child: TextFormField(
        initialValue: initialValue,
        maxLines: maxLines,
        style: variable.type == PromptVariableType.code
            ? const TextStyle(fontFamily: 'JetBrainsMono')
            : null,
        decoration: InputDecoration(
          labelText: variable.name,
          helperText: variable.description.isEmpty
              ? null
              : variable.description,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({required this.rendered});

  final String rendered;

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
              subtitle: '这里展示最终会被复制出去的完整提示词内容。',
            ),
          ),
          const SizedBox(height: 14),
          SelectableText(rendered),
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
        children: [
          AiSurfaceCard(
            variant: AiCardVariant.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AiSkeletonBlock(height: 24, width: 120),
                SizedBox(height: 14),
                AiSkeletonBlock(height: 32),
                SizedBox(height: 10),
                AiSkeletonBlock(height: 16),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const AiSkeletonBlock(height: 220),
          const SizedBox(height: 16),
          const AiSkeletonBlock(height: 220),
        ],
      ),
    );
  }
}
