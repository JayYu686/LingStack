import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/actions/catalog_actions.dart';
import '../../../core/widgets/ai_primitives.dart';
import '../../../core/widgets/ai_surface_card.dart';
import '../../../domain/models.dart';
import '../../../infrastructure/providers.dart';

class ImportResourceScreen extends ConsumerStatefulWidget {
  const ImportResourceScreen({super.key});

  @override
  ConsumerState<ImportResourceScreen> createState() =>
      _ImportResourceScreenState();
}

class _ImportResourceScreenState extends ConsumerState<ImportResourceScreen> {
  final _formKey = GlobalKey<FormState>();
  ResourceType _type = ResourceType.prompt;
  ResourceCategory _category = ResourceCategory.other;
  bool _isSubmitting = false;

  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _scenarioController = TextEditingController();
  final _tagsController = TextEditingController();
  final _primaryController = TextEditingController();
  final _secondaryController = TextEditingController();
  final _tertiaryController = TextEditingController();
  final _listAController = TextEditingController();
  final _listBController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _scenarioController.dispose();
    _tagsController.dispose();
    _primaryController.dispose();
    _secondaryController.dispose();
    _tertiaryController.dispose();
    _listAController.dispose();
    _listBController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('导入我的资源')),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: AiSurfaceCard(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          variant: AiCardVariant.elevated,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '保存后会进入“我的”资源库，后面可以和官方资源一起搜索、筛选和收藏。',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(_isSubmitting ? '保存中...' : '保存到我的资源'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
          children: [
            const AiReveal(
              index: 0,
              child: AiSectionHeader(
                data: AiPageHeaderData(
                  eyebrow: '创建向导',
                  title: '把你常用的资源收进自己的库',
                  subtitle: '先选资源类型和分类，再补标题、用途和正文。后面你就能和官方目录一起统一搜索、复制和收藏。',
                ),
                large: true,
              ),
            ),
            const SizedBox(height: 16),
            const AiReveal(index: 1, child: _TypeOverviewCard()),
            const SizedBox(height: 16),
            AiReveal(
              index: 2,
              child: _TypeChooser(
                value: _type,
                onChanged: (value) => setState(() => _type = value),
              ),
            ),
            const SizedBox(height: 16),
            AiReveal(index: 3, child: _CurrentTypeCard(type: _type)),
            const SizedBox(height: 20),
            AiReveal(
              index: 4,
              child: _WizardSection(
                eyebrow: '步骤 1',
                title: '先补基础信息',
                subtitle: '这部分决定资源在搜索和筛选里怎么被理解。标题像动作，说明像一句价值主张。',
                child: Column(
                  children: [
                    _buildField(
                      controller: _titleController,
                      label: '标题',
                      helperText: '例如：代码审查提示词、周报生成技能、GitHub MCP 模板',
                      validator: _required,
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _summaryController,
                      label: '一句话说明',
                      helperText: '一句话说清它最核心的价值。',
                      maxLines: 3,
                      validator: _required,
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _scenarioController,
                      label: '适合场景',
                      helperText: '例如：代码审查、会议纪要、内容运营、数据库排查',
                      validator: _required,
                    ),
                    const SizedBox(height: 14),
                    _buildCategoryField(),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _tagsController,
                      label: '标签',
                      helperText: '多个标签用英文逗号分隔，例如：开发,审查,效率',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            AiReveal(
              index: 5,
              child: _WizardSection(
                eyebrow: '步骤 2',
                title: '再补正文和使用说明',
                subtitle: _typeSectionSubtitle(_type),
                child: _buildTypeSpecificFields(),
              ),
            ),
            const SizedBox(height: 20),
            AiReveal(
              index: 6,
              child: AiSurfaceCard(
                variant: AiCardVariant.subdued,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AiSectionHeader(
                      data: AiPageHeaderData(
                        eyebrow: '提交前检查',
                        title: '确保别人一看就知道它怎么用',
                        subtitle: '尤其是你未来的自己。写清用途、步骤和边界，比堆技术细节更重要。',
                      ),
                    ),
                    const SizedBox(height: 14),
                    AiStepRail(steps: _reviewSteps(_type)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSpecificFields() {
    return switch (_type) {
      ResourceType.prompt => Column(
        children: [
          _buildField(
            controller: _primaryController,
            label: '提示词模板',
            maxLines: 10,
            helperText: '支持 {{变量名}} 这种占位符格式，保存后会自动识别变量。',
            validator: _required,
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _secondaryController,
            label: '什么时候用',
            maxLines: 3,
            helperText: '例如：当你需要快速生成 PR 审查意见时。',
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _tertiaryController,
            label: '不适合什么场景',
            maxLines: 3,
            helperText: '例如：涉及真实生产变更时，不能直接照抄结果。',
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _listAController,
            label: '示例输入',
            maxLines: 2,
            helperText: '如果还没想好可以先留空。',
          ),
          const SizedBox(height: 14),
          _buildField(controller: _listBController, label: '示例输出', maxLines: 2),
        ],
      ),
      ResourceType.skill => Column(
        children: [
          _buildField(
            controller: _primaryController,
            label: '示例内容或能力包内容',
            maxLines: 8,
            helperText: '这里会作为默认复制内容，也会出现在示例区。',
            validator: _required,
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _secondaryController,
            label: '这个技能能帮你什么',
            maxLines: 3,
            helperText: '先说清价值，不要一上来只贴 Schema。',
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _tertiaryController,
            label: '复制内容',
            maxLines: 6,
            helperText: '如果不填，就默认复制上面的示例内容。',
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _listAController,
            label: '你需要准备什么',
            maxLines: 4,
            helperText: '一行写一条，例如：用户原话、岗位描述、数据库 DSN',
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _listBController,
            label: '怎么用',
            maxLines: 5,
            helperText: '一行写一步，例如：贴入内容、选择模型、复制结果',
          ),
        ],
      ),
      ResourceType.mcp => Column(
        children: [
          _buildField(
            controller: _primaryController,
            label: '这个 MCP 能帮你什么',
            maxLines: 4,
            helperText: '例如：读取 GitHub 仓库、同步文档、连接只读数据库',
            validator: _required,
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _secondaryController,
            label: '配置模板',
            maxLines: 10,
            helperText: r'可以直接粘贴 JSON 模板，环境变量会自动从 ${VAR_NAME} 里提取。',
            validator: _required,
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _tertiaryController,
            label: '安全提醒',
            maxLines: 3,
            helperText: '例如：仅建议只读访问，不要直接给生产写权限。',
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _listAController,
            label: '适配客户端',
            maxLines: 3,
            helperText: '多个客户端用英文逗号分隔，例如：Claude Desktop,Cherry Studio,Cline',
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _listBController,
            label: '接入步骤',
            maxLines: 5,
            helperText: '一行写一步。',
          ),
        ],
      ),
    };
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? helperText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Semantics(
      textField: true,
      label: label,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(labelText: label, helperText: helperText),
      ),
    );
  }

  Widget _buildCategoryField() {
    return DropdownButtonFormField<ResourceCategory>(
      initialValue: _category,
      decoration: const InputDecoration(
        labelText: '资源分类',
        helperText: '先选一个大类，后面就能在顶部分类里快速找到它。',
      ),
      items: ResourceCategory.values
          .where((category) => category != ResourceCategory.all)
          .map(
            (category) => DropdownMenuItem<ResourceCategory>(
              value: category,
              child: Text(category.label),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _category = value);
        }
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repository = await ref.read(workspaceRepositoryProvider.future);
      final resourceId = await repository.importResource(
        ImportResourceDraft(
          type: _type,
          title: _titleController.text.trim(),
          summary: _summaryController.text.trim(),
          scenario: _scenarioController.text.trim(),
          primaryCategory: _category,
          tags: _splitComma(_tagsController.text),
          primaryContent: _primaryController.text.trim(),
          secondaryContent: _secondaryController.text.trim(),
          tertiaryContent: _tertiaryController.text.trim(),
          listA: _type == ResourceType.mcp
              ? _splitComma(_listAController.text)
              : _splitLines(_listAController.text),
          listB: _splitLines(_listBController.text),
        ),
      );
      invalidateCatalog(ref);
      if (!mounted) {
        return;
      }
      if (_type == ResourceType.prompt) {
        context.go('/prompt/$resourceId');
      } else if (_type == ResourceType.skill) {
        context.go('/skill/$resourceId');
      } else {
        context.go('/mcp/$resourceId');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  List<String> _splitComma(String raw) {
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

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '这里不能为空';
    }
    return null;
  }
}

class _TypeOverviewCard extends StatelessWidget {
  const _TypeOverviewCard();

  @override
  Widget build(BuildContext context) {
    return AiSurfaceCard(
      variant: AiCardVariant.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionHeader(
            data: AiPageHeaderData(
              eyebrow: '先理解分类',
              title: '提示词、技能和 MCP 的区别',
              subtitle:
                  '选对类型比一次填很多字段更重要。实在不确定时，先问自己：这是拿来复制的、拿来复用的，还是拿来连接外部工具的？',
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              AiStatusPill(label: '提示词：直接复制给 AI'),
              AiStatusPill(label: '技能：沉淀成复用能力'),
              AiStatusPill(label: 'MCP：连接外部工具和数据'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeChooser extends StatelessWidget {
  const _TypeChooser({required this.value, required this.onChanged});

  final ResourceType value;
  final ValueChanged<ResourceType> onChanged;

  @override
  Widget build(BuildContext context) {
    return AiSurfaceCard(
      variant: AiCardVariant.subdued,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiSectionHeader(
            data: AiPageHeaderData(
              eyebrow: '类型选择',
              title: '先决定你要收进来的是什么',
              subtitle: '这一项会决定下面字段怎么变化。',
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _TypeHintCard(
                key: const Key('import-type-prompt'),
                icon: Icons.auto_awesome_rounded,
                title: '提示词',
                description: '适合直接复制到 AI 客户端里使用。',
                selected: value == ResourceType.prompt,
                onTap: () => onChanged(ResourceType.prompt),
              ),
              _TypeHintCard(
                key: const Key('import-type-skill'),
                icon: Icons.bolt_rounded,
                title: '技能',
                description: '适合沉淀成可复用的能力包。',
                selected: value == ResourceType.skill,
                onTap: () => onChanged(ResourceType.skill),
              ),
              _TypeHintCard(
                key: const Key('import-type-mcp'),
                icon: Icons.hub_rounded,
                title: 'MCP',
                description: '适合保存外部工具或数据连接配置。',
                selected: value == ResourceType.mcp,
                onTap: () => onChanged(ResourceType.mcp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeHintCard extends StatelessWidget {
  const _TypeHintCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: AiSurfaceCard(
        variant: selected ? AiCardVariant.accent : AiCardVariant.elevated,
        padding: const EdgeInsets.all(16),
        onTap: onTap,
        semanticsLabel: '$title 类型选择',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const Spacer(),
                if (selected)
                  const AiStatusPill(label: '当前选择', tone: AiStatusTone.accent),
              ],
            ),
            const SizedBox(height: 10),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _CurrentTypeCard extends StatelessWidget {
  const _CurrentTypeCard({required this.type});

  final ResourceType type;

  @override
  Widget build(BuildContext context) {
    return AiSurfaceCard(
      variant: AiCardVariant.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '当前选择：${type.displayName}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(_typeImportHint(type)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _typeExamples(
              type,
            ).map((item) => AiStatusPill(label: item)).toList(),
          ),
        ],
      ),
    );
  }
}

class _WizardSection extends StatelessWidget {
  const _WizardSection({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AiSectionHeader(
            data: AiPageHeaderData(
              eyebrow: eyebrow,
              title: title,
              subtitle: subtitle,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

String _typeImportHint(ResourceType type) {
  return switch (type) {
    ResourceType.prompt => '适合保存你常用的模板、提问框架和变量占位符内容。',
    ResourceType.skill => '适合保存能力说明、使用步骤和需要重复复用的工作流模板。',
    ResourceType.mcp => '适合保存 MCP 服务器配置、环境变量和接入说明。',
  };
}

String _typeSectionSubtitle(ResourceType type) {
  return switch (type) {
    ResourceType.prompt => '写清模板正文、使用边界和示例，后面复制时会更稳。',
    ResourceType.skill => '优先补价值、准备项和步骤，高级 Schema 可以放后面慢慢补。',
    ResourceType.mcp => '重点写清配置模板、接入步骤和安全边界，不要只留一个链接。',
  };
}

List<String> _typeExamples(ResourceType type) {
  return switch (type) {
    ResourceType.prompt => const ['代码审查模板', '会议纪要模板', '简历优化模板'],
    ResourceType.skill => const ['周报生成技能', 'PR 评分技能', '访谈整理技能'],
    ResourceType.mcp => const ['GitHub MCP', 'Notion MCP', '数据库只读 MCP'],
  };
}

List<String> _reviewSteps(ResourceType type) {
  return switch (type) {
    ResourceType.prompt => const [
      '确认标题能让你三秒内知道这条提示词是做什么的。',
      '确认变量名是具体的，例如“报错信息”“目标岗位”，而不是“变量 1”。',
      '确认“不适合什么场景”已经写清，避免以后误用。',
    ],
    ResourceType.skill => const [
      '先看“这个技能能帮你什么”，确保价值说明比技术字段更清楚。',
      '使用前准备和使用步骤最好一行一条，方便以后直接照着走。',
      '复制内容要和你真实会粘贴出去的内容一致。',
    ],
    ResourceType.mcp => const [
      '确认配置模板里敏感信息都写成环境变量，不要把密钥直接写进去。',
      '确认适配客户端和接入步骤已经足够让未来的你直接复现。',
      '确认安全提醒已经写明权限边界，例如只读、测试环境优先。',
    ],
  };
}
