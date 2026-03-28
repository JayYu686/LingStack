import 'dart:async';

import 'package:flutter/widgets.dart';

class CommittedSearchController {
  CommittedSearchController({
    required this.onCommit,
    this.onStateChanged,
    this.debounce = const Duration(milliseconds: 400),
  });

  final ValueChanged<String> onCommit;
  final VoidCallback? onStateChanged;
  final Duration debounce;

  String _rawInput = '';
  String _committedQuery = '';
  bool _isComposing = false;
  Timer? _debounceTimer;

  String get rawInput => _rawInput;

  String get committedQuery => _committedQuery;

  bool get isComposing => _isComposing;

  void handleValueChanged(TextEditingValue value) {
    _rawInput = value.text;
    _isComposing = value.composing.isValid && !value.composing.isCollapsed;
    onStateChanged?.call();

    final trimmed = value.text.trim();
    if (_isComposing) {
      _debounceTimer?.cancel();
      return;
    }

    if (trimmed.isEmpty) {
      _debounceTimer?.cancel();
      _commit('');
      return;
    }

    _schedule(trimmed);
  }

  void submit([String? rawValue]) {
    _debounceTimer?.cancel();
    final resolved = (rawValue ?? _rawInput).trim();
    _isComposing = false;
    onStateChanged?.call();
    _commit(resolved);
  }

  void dispose() {
    _debounceTimer?.cancel();
  }

  void _schedule(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () => _commit(query));
  }

  void _commit(String query) {
    if (_committedQuery == query) {
      return;
    }
    _committedQuery = query;
    onCommit(query);
  }
}
