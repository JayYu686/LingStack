import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/ai_primitives.dart';
import '../../../core/widgets/ai_surface_card.dart';
import '../../../core/widgets/code_viewer.dart';
import '../../../domain/mcp_test_models.dart';
import '../../../domain/models.dart';
import '../../../infrastructure/providers.dart';
import '../application/mcp_test_controller.dart';

class McpTestScreen extends ConsumerStatefulWidget {
  const McpTestScreen({super.key, required this.resourceId});

  final String resourceId;

  @override
  ConsumerState<McpTestScreen> createState() => _McpTestScreenState();
}

class _McpTestScreenState extends ConsumerState<McpTestScreen> {
  final _baseUrlController = TextEditingController();
  final _bearerTokenController = TextEditingController();
  final _customMethodController = TextEditingController();
  final _customParamsController = TextEditingController(text: '{}');

  final List<_HeaderEditor> _headers = [];
  String? _boundProfileResourceId;
  bool _scheduledProfileLoad = false;

  @override
  void dispose() {
    _baseUrlController.dispose();
    _bearerTokenController.dispose();
    _customMethodController.dispose();
    _customParamsController.dispose();
    for (final header in _headers) {
      header.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<McpTestState>(mcpTestControllerProvider(widget.resourceId), (
      previous,
      next,
    ) {
      if (!mounted) {
        return;
      }
      if (next.infoMessage != null &&
          next.infoMessage != previous?.infoMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.infoMessage!)));
        ref
            .read(mcpTestControllerProvider(widget.resourceId).notifier)
            .clearMessages();
      } else if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    final detailAsync = ref.watch(mcpDetailProvider(widget.resourceId));
    final testState = ref.watch(mcpTestControllerProvider(widget.resourceId));

    return detailAsync.when(
      loading: () => const Scaffold(body: _McpTestLoading()),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('测试 MCP 连接')),
        body: Center(child: Text('加载 MCP 详情失败：$error')),
      ),
      data: (detail) {
        if (detail == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('测试 MCP 连接')),
            body: const Padding(
              padding: EdgeInsets.all(20),
              child: AiEmptyState(
                icon: Icons.search_off_rounded,
                title: '没有找到这条 MCP 资源',
                description: '可能这条资源已经被删除，或者本地目录还没有刷新。',
              ),
            ),
          );
        }
        if (!_scheduledProfileLoad) {
          _scheduledProfileLoad = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            ref
                .read(mcpTestControllerProvider(widget.resourceId).notifier)
                .ensureLoaded(
                  fallbackBaseUrl: detail.transport == 'streamable_http'
                      ? detail.baseUrl
                      : '',
                  fallbackTransport: 'streamable_http',
                );
          });
        }

        final profile = testState.profile;
        if (profile != null && profile.resourceId != _boundProfileResourceId) {
          _bindProfile(profile);
        }

        final originalTransport = detail.transport;
        return Scaffold(
          appBar: AppBar(title: const Text('测试 MCP 连接')),
          body: testState.loadingProfile
              ? const _McpTestLoading()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
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
                                label: '远程 HTTP 测试',
                                tone: AiStatusTone.accent,
                              ),
                              AiStatusPill(label: detail.resource.title),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const AiSectionHeader(
                            data: AiPageHeaderData(
                              eyebrow: '连接检查',
                              title: '先确认连得上，再看能列出什么',
                              subtitle:
                                  '这里不会在手机上拉起 stdio 或 SSE 服务，只测试你已经部署出来的远程 Streamable HTTP 地址。',
                            ),
                          ),
                          if (originalTransport != 'streamable_http') ...[
                            const SizedBox(height: 16),
                            const AiEmptyState(
                              icon: Icons.info_outline_rounded,
                              title: '这条资源原始传输方式不是远程 HTTP',
                              description:
                                  '如果你已经把它包装成了 HTTP 网关，把测试地址填到下面再测；手机端不会直接拉起本地命令行进程。',
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AiSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AiSectionHeader(
                            data: AiPageHeaderData(
                              eyebrow: '测试配置',
                              title: '把地址、鉴权和请求头先填好',
                              subtitle: '这些信息只保存在当前设备，不会写回官方目录，也不会进同步数据库。',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _baseUrlController,
                            decoration: const InputDecoration(
                              labelText: '测试地址',
                              helperText: '例如：https://your-gateway.example/mcp',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _bearerTokenController,
                            decoration: const InputDecoration(
                              labelText: 'Bearer Token',
                              helperText: '没有的话可以先留空',
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                '自定义 Header',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Spacer(),
                              OutlinedButton.icon(
                                onPressed: _addHeader,
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('新增'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_headers.isEmpty)
                            const Text('当前没有额外请求头。')
                          else
                            for (var index = 0; index < _headers.length; index)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller:
                                            _headers[index].keyController,
                                        decoration: const InputDecoration(
                                          labelText: 'Header 名称',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller:
                                            _headers[index].valueController,
                                        decoration: const InputDecoration(
                                          labelText: 'Header 值',
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: '删除 Header',
                                      onPressed: () => _removeHeader(index),
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              FilledButton.icon(
                                onPressed: testState.savingProfile
                                    ? null
                                    : () => ref
                                          .read(
                                            mcpTestControllerProvider(
                                              widget.resourceId,
                                            ).notifier,
                                          )
                                          .saveProfile(_buildProfile(detail)),
                                icon: testState.savingProfile
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.save_rounded),
                                label: const Text('保存测试配置'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => ref
                                    .read(
                                      mcpTestControllerProvider(
                                        widget.resourceId,
                                      ).notifier,
                                    )
                                    .runProbe(_buildProfile(detail)),
                                icon: const Icon(
                                  Icons.health_and_safety_rounded,
                                ),
                                label: const Text('只跑探测'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => ref
                                    .read(
                                      mcpTestControllerProvider(
                                        widget.resourceId,
                                      ).notifier,
                                    )
                                    .runStandardFlow(_buildProfile(detail)),
                                icon: const Icon(Icons.playlist_play_rounded),
                                label: const Text('跑完整检查'),
                              ),
                            ],
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
                              eyebrow: '自定义调用',
                              title: '最后再试你自己的 JSON-RPC 方法',
                              subtitle: '适合确认某个服务端方法到底能不能打通。',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _customMethodController,
                            decoration: const InputDecoration(
                              labelText: '方法名',
                              helperText:
                                  '例如：tools/list、resources/list、prompts/list',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _customParamsController,
                            decoration: const InputDecoration(
                              labelText: '参数 JSON',
                            ),
                            minLines: 6,
                            maxLines: 10,
                          ),
                          const SizedBox(height: 12),
                          FilledButton.tonalIcon(
                            onPressed: () => ref
                                .read(
                                  mcpTestControllerProvider(
                                    widget.resourceId,
                                  ).notifier,
                                )
                                .runCustom(_buildProfile(detail)),
                            icon: const Icon(Icons.terminal_rounded),
                            label: const Text('发送自定义调用'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const AiSectionHeader(
                      data: AiPageHeaderData(
                        eyebrow: '测试结果',
                        title: '每一步单独给结果，不会整页一起转圈',
                        subtitle: '如果某一步失败，也能继续看前面已经成功的返回结果。',
                      ),
                    ),
                    const SizedBox(height: 14),
                    ..._resultOrder.map((stepId) {
                      final step =
                          testState.steps[stepId] ??
                          McpTestStepResult(
                            id: stepId,
                            title: _titleForStep(stepId),
                            state: McpTestStepState.idle,
                          );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _StepResultCard(step: step),
                      );
                    }),
                  ],
                ),
        );
      },
    );
  }

  McpTestProfile _buildProfile(McpResourceDetail detail) {
    return McpTestProfile(
      resourceId: widget.resourceId,
      baseUrl: _baseUrlController.text.trim(),
      transport: 'streamable_http',
      bearerToken: _bearerTokenController.text,
      headers: {
        for (final header in _headers)
          if (header.keyController.text.trim().isNotEmpty)
            header.keyController.text.trim(): header.valueController.text
                .trim(),
      },
      customMethod: _customMethodController.text.trim(),
      customParamsJson: _customParamsController.text.trim().isEmpty
          ? '{}'
          : _customParamsController.text.trim(),
    );
  }

  void _bindProfile(McpTestProfile profile) {
    _boundProfileResourceId = profile.resourceId;
    _baseUrlController.text = profile.baseUrl;
    _bearerTokenController.text = profile.bearerToken;
    _customMethodController.text = profile.customMethod;
    _customParamsController.text = profile.customParamsJson;
    for (final header in _headers) {
      header.dispose();
    }
    _headers
      ..clear()
      ..addAll(
        profile.headers.entries.map(
          (entry) => _HeaderEditor(entry.key, entry.value),
        ),
      );
    if (_headers.isEmpty) {
      _headers.add(_HeaderEditor('', ''));
    }
  }

  void _addHeader() {
    setState(() => _headers.add(_HeaderEditor('', '')));
  }

  void _removeHeader(int index) {
    setState(() {
      _headers.removeAt(index).dispose();
      if (_headers.isEmpty) {
        _headers.add(_HeaderEditor('', ''));
      }
    });
  }
}

class _StepResultCard extends StatelessWidget {
  const _StepResultCard({required this.step});

  final McpTestStepResult step;

  @override
  Widget build(BuildContext context) {
    final tone = switch (step.state) {
      McpTestStepState.success => AiStatusTone.success,
      McpTestStepState.error => AiStatusTone.warning,
      McpTestStepState.loading => AiStatusTone.accent,
      McpTestStepState.unsupported => AiStatusTone.warning,
      McpTestStepState.idle => AiStatusTone.neutral,
    };

    final statusLabel = switch (step.state) {
      McpTestStepState.success => '成功',
      McpTestStepState.error => '失败',
      McpTestStepState.loading => '进行中',
      McpTestStepState.unsupported => '不支持',
      McpTestStepState.idle => '未开始',
    };

    return AiSurfaceCard(
      variant: AiCardVariant.subdued,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  step.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              AiStatusPill(label: statusLabel, tone: tone),
            ],
          ),
          const SizedBox(height: 10),
          if (step.summary.trim().isNotEmpty) Text(step.summary),
          if (step.statusCode != null) ...[
            const SizedBox(height: 8),
            Text('HTTP 状态码：${step.statusCode}'),
          ],
          if (step.error.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              step.error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          if (step.body.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            CodeViewer(language: 'json', code: step.body),
          ],
        ],
      ),
    );
  }
}

class _HeaderEditor {
  _HeaderEditor(String key, String value)
    : keyController = TextEditingController(text: key),
      valueController = TextEditingController(text: value);

  final TextEditingController keyController;
  final TextEditingController valueController;

  void dispose() {
    keyController.dispose();
    valueController.dispose();
  }
}

class _McpTestLoading extends StatelessWidget {
  const _McpTestLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: const [
        AiSkeletonBlock(height: 170),
        SizedBox(height: 16),
        AiSkeletonBlock(height: 260),
        SizedBox(height: 16),
        AiSkeletonBlock(height: 220),
      ],
    );
  }
}

const _resultOrder = ['probe', 'tools', 'resources', 'prompts', 'custom'];

String _titleForStep(String stepId) {
  return switch (stepId) {
    'probe' => '初始化与连接探测',
    'tools' => '列出 tools',
    'resources' => '列出 resources',
    'prompts' => '列出 prompts',
    'custom' => '自定义 JSON-RPC 调用',
    _ => stepId,
  };
}
