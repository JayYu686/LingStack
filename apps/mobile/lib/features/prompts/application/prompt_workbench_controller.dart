import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/prompt_workbench_models.dart';
import '../../../infrastructure/providers.dart';

final promptWorkbenchControllerProvider = NotifierProvider.autoDispose
    .family<PromptWorkbenchController, PromptWorkbenchState, String>(
      PromptWorkbenchController.new,
    );

class PromptWorkbenchController extends Notifier<PromptWorkbenchState> {
  PromptWorkbenchController(this._resourceId);

  final String _resourceId;
  bool _loaded = false;

  @override
  PromptWorkbenchState build() => const PromptWorkbenchState();

  Future<void> ensureLoaded() async {
    if (_loaded) {
      return;
    }
    _loaded = true;
    await reload();
  }

  Future<void> reload() async {
    state = state.copyWith(
      loading: true,
      errorMessage: null,
      infoMessage: null,
    );
    try {
      final repository = await ref.read(workspaceRepositoryProvider.future);
      final detail = await repository.loadPromptDetail(_resourceId);
      if (detail == null) {
        state = state.copyWith(loading: false, errorMessage: '没有找到这条提示词资源。');
        return;
      }
      final usage = await repository.loadPromptUsage(_resourceId);
      state = buildPromptWorkbenchState(detail: detail, usage: usage);
    } catch (error) {
      state = state.copyWith(loading: false, errorMessage: '加载提示词工作台失败：$error');
    }
  }

  Future<void> updateValue(String name, String value) async {
    final detail = state.detail;
    if (detail == null) {
      return;
    }
    final nextValues = {...state.values, name: value};
    state = buildPromptWorkbenchState(
      detail: detail,
      usage: state.usage,
      values: nextValues,
    );
    final repository = await ref.read(workspaceRepositoryProvider.future);
    await repository.savePromptUsage(
      resourceId: _resourceId,
      lastValues: nextValues,
    );
  }

  Future<bool> markCopied() async {
    final detail = state.detail;
    if (detail == null || state.missingRequired.isNotEmpty) {
      return false;
    }
    state = state.copyWith(
      copying: true,
      errorMessage: null,
      infoMessage: null,
    );
    try {
      final repository = await ref.read(workspaceRepositoryProvider.future);
      await repository.savePromptUsage(
        resourceId: _resourceId,
        lastValues: state.values,
        markCopied: true,
      );
      final usage = await repository.loadPromptUsage(_resourceId);
      state = buildPromptWorkbenchState(
        detail: detail,
        usage: usage,
        values: state.values,
        infoMessage: '已记录这次使用。',
      );
      ref.read(catalogRefreshTickProvider.notifier).bump();
      return true;
    } catch (error) {
      state = state.copyWith(
        copying: false,
        errorMessage: '保存提示词使用记录失败：$error',
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, infoMessage: null);
  }
}
