import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/ai_primitives.dart';
import '../../../core/widgets/ai_surface_card.dart';
import '../../../core/widgets/code_viewer.dart';
import '../../../domain/models.dart';
import '../../../domain/skill_editor_models.dart';
import '../../../domain/skill_schema_codec.dart';
import '../application/skill_editor_controller.dart';

class SkillEditorScreen extends ConsumerStatefulWidget {
  const SkillEditorScreen({super.key, required this.resourceId});

  final String resourceId;

  @override
  ConsumerState<SkillEditorScreen> createState() => _SkillEditorScreenState();
}

class _SkillEditorScreenState extends ConsumerState<SkillEditorScreen> {
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _scenarioController = TextEditingController();
  final _tagsController = TextEditingController();
  final _capabilityController = TextEditingController();
  final _inputRequirementsController = TextEditingController();
  final _usageStepsController = TextEditingController();
  final _supportedModelsController = TextEditingController();
  final _copyPayloadController = TextEditingController();
  final _exampleCodeController = TextEditingController();
  final _exampleLanguageController = TextEditingController();
  final _advancedSchemaController = TextEditingController();

  ResourceCategory _selectedCategory = ResourceCategory.other;
  bool _advancedSchemaMode = false;
  List<SkillSchemaFieldDraft> _schemaFields = const [];
  String? _boundDraftId;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref
          .read(skillEditorControllerProvider(widget.resourceId).notifier)
          .ensureLoaded(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _scenarioController.dispose();
    _tagsController.dispose();
    _capabilityController.dispose();
    _inputRequirementsController.dispose();
    _usageStepsController.dispose();
    _supportedModelsController.dispose();
    _copyPayloadController.dispose();
    _exampleCodeController.dispose();
    _exampleLanguageController.dispose();
    _advancedSchemaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SkillEditorState>(
      skillEditorControllerProvider(widget.resourceId),
      (previous, next) {
        if (!mounted) {
          return;
        }
        if (previous?.saveSucceeded != true && next.saveSucceeded) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('技能已保存，你的版本已经更新。')));
          ref
              .read(skillEditorControllerProvider(widget.resourceId).notifier)
              .clearStatus();
        } else if (next.errorMessage != null &&
            next.errorMessage != previous?.errorMessage) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
        }
      },
    );

    final state = ref.watch(skillEditorControllerProvider(widget.resourceId));
    final draft = state.draft;
    if (draft != null && draft.resourceId != _boundDraftId) {
      _bindDraft(draft);
    }

    if (state.loading) {
      return const Scaffold(body: _SkillEditorLoading());
    }

    if (draft == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('编辑技能')),
        body: const Padding(
          padding: EdgeInsets.all(20),
          child: AiEmptyState(
            icon: Icons.search_off_rounded,
            title: '没有找到这条技能',
            description: '可能这条资源已经被删除，或者本地目录还没有刷新。',
          ),
        ),
      );
    }

    if (!draft.isImportedSource) {
      return Scaffold(
        appBar: AppBar(title: const Text('编辑技能')),
        body: const Padding(
          padding: EdgeInsets.all(20),
          child: AiEmptyState(
            icon: Icons.copy_rounded,
            title: '官方技能不能直接改',
            description: '先从详情页点“复制为我的版本”，再进入编辑器修改。',
          ),
        ),
      );
    }

    final schemaPreview = _buildSchemaPreview();
    final adapterPreview = _buildAdapterPreview();

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑技能'),
        actions: [
          IconButton(
            tooltip: '重新加载',
            onPressed: state.saving
                ? null
                : () => ref
                      .read(
                        skillEditorControllerProvider(
                          widget.resourceId,
                        ).notifier,
                      )
                      .reload(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: FilledButton.icon(
          onPressed: state.saving ? null : _handleSave,
          icon: state.saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_rounded),
          label: Text(state.saving ? '正在保存' : '保存我的技能'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        children: [
          AiSurfaceCard(
            variant: AiCardVariant.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    const AiStatusPill(
                      label: '我的版本',
                      tone: AiStatusTone.success,
                    ),
                    if (draft.originResourceId != null)
                      AiStatusPill(
                        label: '来源：${draft.originResourceId}',
                        tone: AiStatusTone.accent,
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                const AiSectionHeader(
                  data: AiPageHeaderData(
                    eyebrow: '编辑器',
                    title: '把这条技能改成你自己的版本',
                    subtitle: '官方资源保持只读。你现在改的是本地副本，可以按自己的工作流、术语和模型偏好继续沉淀。',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildBasicSection(context),
          const SizedBox(height: 16),
          _buildCapabilitySection(context),
          const SizedBox(height: 16),
          _buildSchemaSection(context),
          const SizedBox(height: 16),
          AiSurfaceCard(
            variant: AiCardVariant.subdued,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AiSectionHeader(
                  data: AiPageHeaderData(
                    eyebrow: '供应商预览',
                    title: 'Schema 会自动映射到主流模型厂商',
                    subtitle: '这里是根据当前输入 Schema 自动生成的适配结果预览，不需要手填。',
                  ),
                ),
                const SizedBox(height: 14),
                CodeViewer(language: 'json', code: adapterPreview),
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
                    eyebrow: 'Schema 预览',
                    title: '保存前再看一眼最终结构',
                    subtitle: '复杂结构会自动走高级 JSON 模式；只支持顶层简单字段时也可以继续用可视化编辑。',
                  ),
                ),
                const SizedBox(height: 14),
                CodeViewer(language: 'json', code: schemaPreview),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicSection(BuildContext context) {
    return AiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionHeader(
            data: AiPageHeaderData(
              eyebrow: '基础信息',
              title: '先把名称、用途和分类写清楚',
              subtitle: '这几项决定了你以后能不能快速搜到这条技能。',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: '技能名称'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _summaryController,
            decoration: const InputDecoration(labelText: '一句话说明'),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _scenarioController,
            decoration: const InputDecoration(labelText: '适用场景'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ResourceCategory>(
            initialValue: _selectedCategory,
            items: ResourceCategory.values
                .where((item) => item != ResourceCategory.all)
                .map(
                  (item) =>
                      DropdownMenuItem(value: item, child: Text(item.label)),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => _selectedCategory = value);
            },
            decoration: const InputDecoration(labelText: '主分类'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _tagsController,
            decoration: const InputDecoration(
              labelText: '标签',
              helperText: '多个标签用逗号分开，例如：GitHub, 代码审查, 工程流程',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapabilitySection(BuildContext context) {
    return AiSurfaceCard(
      variant: AiCardVariant.subdued,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionHeader(
            data: AiPageHeaderData(
              eyebrow: '能力说明',
              title: '把输入、步骤和复制内容整理清楚',
              subtitle: '默认先写给未来的自己看：下次再做同类任务时，能不能一眼知道该怎么用。',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _capabilityController,
            decoration: const InputDecoration(labelText: '能力说明'),
            minLines: 3,
            maxLines: 5,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _inputRequirementsController,
            decoration: const InputDecoration(
              labelText: '输入要求',
              helperText: '每行一条，例如：当前代码上下文 / 目标输出格式',
            ),
            minLines: 3,
            maxLines: 6,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _usageStepsController,
            decoration: const InputDecoration(
              labelText: '使用步骤',
              helperText: '每行一条，例如：先贴材料，再看结论，最后人工复核',
            ),
            minLines: 3,
            maxLines: 6,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _supportedModelsController,
            decoration: const InputDecoration(
              labelText: '支持模型',
              helperText: '多个模型用逗号分开，例如：ChatGPT, Claude, Gemini',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _copyPayloadController,
            decoration: const InputDecoration(labelText: '复制内容'),
            minLines: 5,
            maxLines: 10,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _exampleLanguageController,
            decoration: const InputDecoration(labelText: '示例代码语言'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _exampleCodeController,
            decoration: const InputDecoration(labelText: '示例代码或 JSON'),
            minLines: 5,
            maxLines: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildSchemaSection(BuildContext context) {
    return AiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionHeader(
            data: AiPageHeaderData(
              eyebrow: 'Schema 构建器',
              title: '简单字段可视化编辑，复杂结构直接写 JSON',
              subtitle: '顶层字段支持字符串、整数、数字、布尔、枚举和基础数组。复杂对象会自动切到高级模式。',
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(value: false, label: Text('可视化字段')),
              ButtonSegment<bool>(value: true, label: Text('高级 JSON')),
            ],
            selected: {_advancedSchemaMode},
            onSelectionChanged: (selection) {
              final next = selection.first;
              setState(() {
                _advancedSchemaMode = next;
                if (!next) {
                  _advancedSchemaController.text = prettyJson(
                    buildSkillSchemaFromFields(_schemaFields),
                  );
                }
              });
            },
          ),
          const SizedBox(height: 16),
          if (_advancedSchemaMode)
            TextFormField(
              controller: _advancedSchemaController,
              decoration: const InputDecoration(
                labelText: '高级 JSON Schema',
                helperText: '保存前会做 JSON 校验，不支持无效结构入库。',
              ),
              minLines: 10,
              maxLines: 18,
            )
          else ...[
            for (var index = 0; index < _schemaFields.length; index) ...[
              _SchemaFieldCard(
                key: ValueKey(
                  'schema-field-$index-${_schemaFields[index].name}',
                ),
                field: _schemaFields[index],
                onChanged: (field) {
                  setState(() => _schemaFields[index] = field);
                },
                onDelete: () {
                  setState(() => _schemaFields.removeAt(index));
                },
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _schemaFields = [
                    ..._schemaFields,
                    const SkillSchemaFieldDraft(
                      name: '',
                      type: SkillSchemaFieldType.string,
                    ),
                  ];
                });
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('新增字段'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    final summary = _summaryController.text.trim();
    final capabilitySummary = _capabilityController.text.trim();
    if (title.isEmpty || summary.isEmpty || capabilitySummary.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('技能名称、一句话说明和能力说明不能为空。')));
      return;
    }

    try {
      if (_advancedSchemaMode) {
        _advancedSchemaController.text = normalizeSchemaJson(
          _advancedSchemaController.text,
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Schema JSON 无法解析：$error')));
      return;
    }

    final base = ref
        .read(skillEditorControllerProvider(widget.resourceId))
        .draft;
    if (base == null) {
      return;
    }

    final draft = base.copyWith(
      title: title,
      summary: summary,
      scenario: _scenarioController.text.trim(),
      primaryCategory: _selectedCategory,
      tags: _splitCsv(_tagsController.text),
      capabilitySummary: capabilitySummary,
      inputRequirements: _splitLines(_inputRequirementsController.text),
      usageSteps: _splitLines(_usageStepsController.text),
      supportedModels: _splitCsv(_supportedModelsController.text),
      copyPayload: _copyPayloadController.text,
      exampleCode: _exampleCodeController.text,
      exampleLanguage: _exampleLanguageController.text.trim(),
      schemaFields: _schemaFields,
      advancedSchemaJson: _advancedSchemaController.text,
      advancedSchemaMode: _advancedSchemaMode,
    );

    await ref
        .read(skillEditorControllerProvider(widget.resourceId).notifier)
        .save(draft);
  }

  void _bindDraft(SkillEditorDraft draft) {
    _boundDraftId = draft.resourceId;
    _titleController.text = draft.title;
    _summaryController.text = draft.summary;
    _scenarioController.text = draft.scenario;
    _tagsController.text = draft.tags.join(', ');
    _capabilityController.text = draft.capabilitySummary;
    _inputRequirementsController.text = draft.inputRequirements.join('\n');
    _usageStepsController.text = draft.usageSteps.join('\n');
    _supportedModelsController.text = draft.supportedModels.join(', ');
    _copyPayloadController.text = draft.copyPayload;
    _exampleCodeController.text = draft.exampleCode;
    _exampleLanguageController.text = draft.exampleLanguage;
    _advancedSchemaController.text = draft.advancedSchemaJson;
    _selectedCategory = draft.primaryCategory;
    _advancedSchemaMode = draft.advancedSchemaMode;
    _schemaFields = draft.schemaFields
        .map((field) => field.copyWith())
        .toList(growable: true);
  }

  String _buildSchemaPreview() {
    if (!_advancedSchemaMode) {
      return prettyJson(buildSkillSchemaFromFields(_schemaFields));
    }
    try {
      return normalizeSchemaJson(_advancedSchemaController.text);
    } catch (_) {
      return _advancedSchemaController.text;
    }
  }

  String _buildAdapterPreview() {
    try {
      final schema = _advancedSchemaMode
          ? Map<String, dynamic>.from(
              jsonDecode(normalizeSchemaJson(_advancedSchemaController.text))
                  as Map,
            )
          : buildSkillSchemaFromFields(_schemaFields);
      return prettyJson(buildProviderAdaptersForSchema(schema));
    } catch (_) {
      return prettyJson(const {'error': '当前 JSON Schema 还没有写完整，保存前会再次校验。'});
    }
  }
}

class _SchemaFieldCard extends StatelessWidget {
  const _SchemaFieldCard({
    super.key,
    required this.field,
    required this.onChanged,
    required this.onDelete,
  });

  final SkillSchemaFieldDraft field;
  final ValueChanged<SkillSchemaFieldDraft> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final primitiveTypes = const [
      SkillSchemaFieldType.string,
      SkillSchemaFieldType.integer,
      SkillSchemaFieldType.number,
      SkillSchemaFieldType.booleanType,
    ];

    return AiSurfaceCard(
      variant: AiCardVariant.subdued,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  field.name.trim().isEmpty ? '未命名字段' : field.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: '删除字段',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          TextFormField(
            initialValue: field.name,
            decoration: const InputDecoration(labelText: '字段名'),
            onChanged: (value) => onChanged(field.copyWith(name: value)),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<SkillSchemaFieldType>(
            initialValue: field.type,
            items: SkillSchemaFieldType.values
                .map(
                  (type) =>
                      DropdownMenuItem(value: type, child: Text(type.label)),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              onChanged(field.copyWith(type: value));
            },
            decoration: const InputDecoration(labelText: '字段类型'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: field.description,
            decoration: const InputDecoration(labelText: '字段说明'),
            onChanged: (value) => onChanged(field.copyWith(description: value)),
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('必填字段'),
            value: field.required,
            onChanged: (value) => onChanged(field.copyWith(required: value)),
          ),
          if (field.type == SkillSchemaFieldType.enumeration) ...[
            const SizedBox(height: 12),
            TextFormField(
              initialValue: field.enumOptions.join(', '),
              decoration: const InputDecoration(
                labelText: '枚举选项',
                helperText: '多个选项用逗号分开',
              ),
              onChanged: (value) =>
                  onChanged(field.copyWith(enumOptions: _splitCsv(value))),
            ),
          ],
          if (field.type == SkillSchemaFieldType.array) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<SkillSchemaFieldType>(
              initialValue: primitiveTypes.contains(field.arrayItemType)
                  ? field.arrayItemType
                  : SkillSchemaFieldType.string,
              items: primitiveTypes
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.label)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                onChanged(field.copyWith(arrayItemType: value));
              },
              decoration: const InputDecoration(labelText: '数组元素类型'),
            ),
          ],
        ],
      ),
    );
  }
}

class _SkillEditorLoading extends StatelessWidget {
  const _SkillEditorLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: const [
        AiSkeletonBlock(height: 150),
        SizedBox(height: 16),
        AiSkeletonBlock(height: 260),
        SizedBox(height: 16),
        AiSkeletonBlock(height: 260),
      ],
    );
  }
}

List<String> _splitCsv(String raw) {
  return raw
      .split(',')
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList();
}

List<String> _splitLines(String raw) {
  return raw
      .split('\n')
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList();
}
