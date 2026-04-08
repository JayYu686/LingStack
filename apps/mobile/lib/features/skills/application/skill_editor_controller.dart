import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/skill_editor_models.dart';
import '../../../infrastructure/providers.dart';

final skillEditorControllerProvider = NotifierProvider.autoDispose
    .family<SkillEditorController, SkillEditorState, String>(
      SkillEditorController.new,
    );

class SkillEditorState {
  const SkillEditorState({
    this.loading = true,
    this.saving = false,
    this.draft,
    this.errorMessage,
    this.saveSucceeded = false,
  });

  final bool loading;
  final bool saving;
  final SkillEditorDraft? draft;
  final String? errorMessage;
  final bool saveSucceeded;

  SkillEditorState copyWith({
    bool? loading,
    bool? saving,
    SkillEditorDraft? draft,
    Object? errorMessage = _sentinel,
    bool? saveSucceeded,
  }) {
    return SkillEditorState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      draft: draft ?? this.draft,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      saveSucceeded: saveSucceeded ?? this.saveSucceeded,
    );
  }
}

class SkillEditorController extends Notifier<SkillEditorState> {
  SkillEditorController(this._resourceId);

  final String _resourceId;
  bool _loaded = false;

  @override
  SkillEditorState build() => const SkillEditorState();

  Future<void> ensureLoaded() async {
    if (_loaded) {
      return;
    }
    _loaded = true;
    await _load();
  }

  Future<void> _load() async {
    state = state.copyWith(
      loading: true,
      saveSucceeded: false,
      errorMessage: null,
    );
    try {
      final repository = await ref.read(workspaceRepositoryProvider.future);
      final draft = await repository.loadSkillEditorDraft(_resourceId);
      state = state.copyWith(
        loading: false,
        draft: draft,
        errorMessage: draft == null ? '没有找到这条技能资源。' : null,
      );
    } catch (error) {
      state = state.copyWith(loading: false, errorMessage: '加载技能编辑器失败：$error');
    }
  }

  Future<bool> save(SkillEditorDraft draft) async {
    state = state.copyWith(
      saving: true,
      saveSucceeded: false,
      errorMessage: null,
    );
    try {
      final repository = await ref.read(workspaceRepositoryProvider.future);
      await repository.updateImportedSkill(draft);
      final refreshed = await repository.loadSkillEditorDraft(_resourceId);
      ref.read(catalogRefreshTickProvider.notifier).bump();
      state = state.copyWith(
        saving: false,
        draft: refreshed ?? draft,
        saveSucceeded: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(saving: false, errorMessage: '保存技能失败：$error');
      return false;
    }
  }

  void clearStatus() {
    state = state.copyWith(saveSucceeded: false, errorMessage: null);
  }

  Future<void> reload() async {
    _loaded = false;
    await ensureLoaded();
  }
}

const _sentinel = Object();
