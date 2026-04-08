import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/mcp_test_models.dart';
import '../../../domain/models.dart';
import '../../../infrastructure/providers.dart';

final mcpTestControllerProvider = NotifierProvider.autoDispose
    .family<McpTestController, McpTestState, String>(McpTestController.new);

class McpTestState {
  const McpTestState({
    this.loadingProfile = true,
    this.savingProfile = false,
    this.profile,
    this.steps = const {},
    this.errorMessage,
    this.infoMessage,
  });

  final bool loadingProfile;
  final bool savingProfile;
  final McpTestProfile? profile;
  final Map<String, McpTestStepResult> steps;
  final String? errorMessage;
  final String? infoMessage;

  McpTestState copyWith({
    bool? loadingProfile,
    bool? savingProfile,
    McpTestProfile? profile,
    Map<String, McpTestStepResult>? steps,
    Object? errorMessage = _sentinel,
    Object? infoMessage = _sentinel,
  }) {
    return McpTestState(
      loadingProfile: loadingProfile ?? this.loadingProfile,
      savingProfile: savingProfile ?? this.savingProfile,
      profile: profile ?? this.profile,
      steps: steps ?? this.steps,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      infoMessage: identical(infoMessage, _sentinel)
          ? this.infoMessage
          : infoMessage as String?,
    );
  }
}

class McpTestController extends Notifier<McpTestState> {
  McpTestController(this._resourceId);

  final String _resourceId;
  bool _loaded = false;

  static const _probeStepId = 'probe';
  static const _toolsStepId = 'tools';
  static const _resourcesStepId = 'resources';
  static const _promptsStepId = 'prompts';
  static const _customStepId = 'custom';

  @override
  McpTestState build() => const McpTestState();

  Future<void> ensureLoaded({
    required String fallbackBaseUrl,
    required String fallbackTransport,
  }) async {
    if (_loaded) {
      return;
    }
    _loaded = true;
    state = state.copyWith(loadingProfile: true, errorMessage: null);
    try {
      final repository = ref.read(mcpTestRepositoryProvider);
      final profile = await repository.loadProfile(
        resourceId: _resourceId,
        fallbackBaseUrl: fallbackBaseUrl,
        fallbackTransport: fallbackTransport,
      );
      state = state.copyWith(loadingProfile: false, profile: profile);
    } catch (error) {
      state = state.copyWith(
        loadingProfile: false,
        errorMessage: '读取测试配置失败：$error',
      );
    }
  }

  Future<void> saveProfile(McpTestProfile profile) async {
    state = state.copyWith(
      savingProfile: true,
      profile: profile,
      errorMessage: null,
      infoMessage: null,
    );
    try {
      await ref.read(mcpTestRepositoryProvider).saveProfile(profile);
      state = state.copyWith(
        savingProfile: false,
        infoMessage: '测试配置已保存，只保存在当前设备。',
      );
    } catch (error) {
      state = state.copyWith(
        savingProfile: false,
        errorMessage: '保存测试配置失败：$error',
      );
    }
  }

  Future<void> runProbe(McpTestProfile profile) async {
    await saveProfile(profile);
    _setStepLoading(_probeStepId, '初始化与连接探测');
    try {
      final result = await ref.read(mcpTestRepositoryProvider).probe(profile);
      state = state.copyWith(
        steps: {
          ...state.steps,
          _probeStepId: McpTestStepResult(
            id: _probeStepId,
            title: '初始化与连接探测',
            state: result.healthy
                ? McpTestStepState.success
                : McpTestStepState.error,
            statusCode: result.statusCode,
            summary: result.healthy ? '服务已响应 initialize。' : '服务返回异常。',
            body: prettyProbeResult(result),
            error: result.error,
          ),
        },
      );
    } catch (error) {
      _setStepError(_probeStepId, '初始化与连接探测', '$error');
    }
  }

  Future<void> runStandardFlow(McpTestProfile profile) async {
    await saveProfile(profile);
    await _runStandardInvocation(
      profile: profile,
      stepId: _probeStepId,
      title: '初始化与连接探测',
      method: 'initialize',
      params: const {
        'protocolVersion': '2025-06-18',
        'capabilities': {},
        'clientInfo': {'name': 'lingstack-mobile', 'version': '1.1.0'},
      },
      treatAsProbe: true,
    );
    await _runStandardInvocation(
      profile: profile,
      stepId: _toolsStepId,
      title: '列出 tools',
      method: 'tools/list',
      params: const {},
    );
    await _runStandardInvocation(
      profile: profile,
      stepId: _resourcesStepId,
      title: '列出 resources',
      method: 'resources/list',
      params: const {},
    );
    await _runStandardInvocation(
      profile: profile,
      stepId: _promptsStepId,
      title: '列出 prompts',
      method: 'prompts/list',
      params: const {},
    );
  }

  Future<void> runCustom(McpTestProfile profile) async {
    await saveProfile(profile);
    _setStepLoading(_customStepId, '自定义 JSON-RPC 调用');
    try {
      final result = await ref
          .read(mcpTestRepositoryProvider)
          .invoke(
            profile: profile,
            method: profile.customMethod.trim(),
            paramsJson: profile.customParamsJson.trim(),
          );
      final ok =
          result.error.isEmpty &&
          result.statusCode >= 200 &&
          result.statusCode < 300;
      state = state.copyWith(
        steps: {
          ...state.steps,
          _customStepId: McpTestStepResult(
            id: _customStepId,
            title: '自定义 JSON-RPC 调用',
            state: ok ? McpTestStepState.success : McpTestStepState.error,
            statusCode: result.statusCode,
            summary: ok ? '调用成功。' : '调用失败。',
            body: result.body == null ? '' : prettyJson(result.body),
            error: result.error,
          ),
        },
      );
    } catch (error) {
      _setStepError(_customStepId, '自定义 JSON-RPC 调用', '$error');
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, infoMessage: null);
  }

  Future<void> _runStandardInvocation({
    required McpTestProfile profile,
    required String stepId,
    required String title,
    required String method,
    required Map<String, dynamic> params,
    bool treatAsProbe = false,
  }) async {
    _setStepLoading(stepId, title);
    try {
      if (treatAsProbe) {
        final result = await ref.read(mcpTestRepositoryProvider).probe(profile);
        final ok =
            result.error.isEmpty &&
            result.statusCode >= 200 &&
            result.statusCode < 300;
        state = state.copyWith(
          steps: {
            ...state.steps,
            stepId: McpTestStepResult(
              id: stepId,
              title: title,
              state: ok ? McpTestStepState.success : McpTestStepState.error,
              statusCode: result.statusCode,
              summary: ok ? '初始化成功。' : '初始化失败。',
              body: prettyProbeResult(result),
              error: result.error,
            ),
          },
        );
        return;
      }

      final result = await ref
          .read(mcpTestRepositoryProvider)
          .invoke(
            profile: profile,
            method: method,
            paramsJson: jsonEncode(params),
          );
      final ok =
          result.error.isEmpty &&
          result.statusCode >= 200 &&
          result.statusCode < 300;
      state = state.copyWith(
        steps: {
          ...state.steps,
          stepId: McpTestStepResult(
            id: stepId,
            title: title,
            state: ok ? McpTestStepState.success : McpTestStepState.error,
            statusCode: result.statusCode,
            summary: ok ? '$method 已返回结果。' : '$method 返回异常。',
            body: result.body == null ? '' : prettyJson(result.body),
            error: result.error,
          ),
        },
      );
    } catch (error) {
      _setStepError(stepId, title, '$error');
    }
  }

  void _setStepLoading(String id, String title) {
    final previous = state.steps[id];
    state = state.copyWith(
      steps: {
        ...state.steps,
        id: (previous ?? McpTestStepResult(id: id, title: title)).copyWith(
          state: McpTestStepState.loading,
          error: '',
        ),
      },
    );
  }

  void _setStepError(String id, String title, String error) {
    final previous = state.steps[id];
    state = state.copyWith(
      steps: {
        ...state.steps,
        id: (previous ?? McpTestStepResult(id: id, title: title)).copyWith(
          state: McpTestStepState.error,
          summary: '请求失败。',
          error: error,
        ),
      },
    );
  }
}

String prettyProbeResult(McpProbeResult result) {
  return prettyJson({
    'healthy': result.healthy,
    'statusCode': result.statusCode,
    if (result.protocolVersion.trim().isNotEmpty)
      'protocolVersion': result.protocolVersion,
    if (result.serverInfo.isNotEmpty) 'serverInfo': result.serverInfo,
    if (result.capabilities.isNotEmpty) 'capabilities': result.capabilities,
    if (result.bodyPreview.trim().isNotEmpty) 'bodyPreview': result.bodyPreview,
    if (result.error.trim().isNotEmpty) 'error': result.error,
  });
}

const _sentinel = Object();
