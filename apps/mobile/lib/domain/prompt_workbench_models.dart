import 'models.dart';
import 'prompt_renderer.dart';

class PromptWorkbenchState {
  const PromptWorkbenchState({
    this.loading = true,
    this.copying = false,
    this.detail,
    this.usage,
    this.values = const {},
    this.rendered = '',
    this.missingRequired = const [],
    this.errorMessage,
    this.infoMessage,
  });

  final bool loading;
  final bool copying;
  final PromptResourceDetail? detail;
  final PromptUsageRecord? usage;
  final Map<String, String> values;
  final String rendered;
  final List<String> missingRequired;
  final String? errorMessage;
  final String? infoMessage;

  bool get canCopy => detail != null && missingRequired.isEmpty;

  PromptWorkbenchState copyWith({
    bool? loading,
    bool? copying,
    PromptResourceDetail? detail,
    PromptUsageRecord? usage,
    Map<String, String>? values,
    String? rendered,
    List<String>? missingRequired,
    Object? errorMessage = _sentinel,
    Object? infoMessage = _sentinel,
  }) {
    return PromptWorkbenchState(
      loading: loading ?? this.loading,
      copying: copying ?? this.copying,
      detail: detail ?? this.detail,
      usage: usage ?? this.usage,
      values: values ?? this.values,
      rendered: rendered ?? this.rendered,
      missingRequired: missingRequired ?? this.missingRequired,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      infoMessage: identical(infoMessage, _sentinel)
          ? this.infoMessage
          : infoMessage as String?,
    );
  }
}

PromptWorkbenchState buildPromptWorkbenchState({
  required PromptResourceDetail detail,
  PromptUsageRecord? usage,
  Map<String, String> values = const {},
  bool loading = false,
  bool copying = false,
  String? errorMessage,
  String? infoMessage,
}) {
  final resolvedValues = {
    for (final variable in detail.variables)
      variable.name:
          values[variable.name] ??
          usage?.lastValues[variable.name] ??
          variable.defaultValue,
  };

  final missingRequired = detail.requiredVariableNames
      .where((name) => (resolvedValues[name] ?? '').trim().isEmpty)
      .toList();
  final rendered = sanitizeRenderedPrompt(
    renderPromptTemplate(detail.templateBody, resolvedValues),
  );

  return PromptWorkbenchState(
    loading: loading,
    copying: copying,
    detail: detail,
    usage: usage,
    values: resolvedValues,
    rendered: rendered,
    missingRequired: missingRequired,
    errorMessage: errorMessage,
    infoMessage: infoMessage,
  );
}

const _sentinel = Object();
