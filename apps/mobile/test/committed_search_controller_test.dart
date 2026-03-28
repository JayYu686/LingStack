import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/search/committed_search_controller.dart';

void main() {
  test('中文输入法 composing 期间不会提交搜索', () {
    fakeAsync((async) {
      final commits = <String>[];
      final controller = CommittedSearchController(
        onCommit: commits.add,
        debounce: const Duration(milliseconds: 400),
      );
      addTearDown(controller.dispose);

      controller.handleValueChanged(
        const TextEditingValue(
          text: '代',
          composing: TextRange(start: 0, end: 1),
        ),
      );
      async.elapse(const Duration(milliseconds: 600));

      expect(commits, isEmpty);
    });
  });

  test('停止输入后会在防抖时间后提交搜索', () {
    fakeAsync((async) {
      final commits = <String>[];
      final controller = CommittedSearchController(
        onCommit: commits.add,
        debounce: const Duration(milliseconds: 400),
      );
      addTearDown(controller.dispose);

      controller.handleValueChanged(const TextEditingValue(text: '代码审查'));
      async.elapse(const Duration(milliseconds: 350));
      expect(commits, isEmpty);

      async.elapse(const Duration(milliseconds: 60));
      expect(commits, ['代码审查']);
    });
  });

  test('回车会立即提交搜索', () {
    fakeAsync((async) {
      final commits = <String>[];
      final controller = CommittedSearchController(
        onCommit: commits.add,
        debounce: const Duration(milliseconds: 400),
      );
      addTearDown(controller.dispose);

      controller.handleValueChanged(const TextEditingValue(text: '简历优化'));
      controller.submit();

      expect(commits, ['简历优化']);
      async.elapse(const Duration(milliseconds: 500));
      expect(commits, ['简历优化']);
    });
  });
}
