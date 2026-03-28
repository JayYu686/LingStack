import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/models.dart';
import 'package:mobile/infrastructure/database/app_database.dart';

void main() {
  group('catalog database', () {
    test('bootstraps official resources and collections', () async {
      final database = AppDatabase.memory();
      addTearDown(database.close);

      await database.bootstrap();

      final prompts = await database.listResources(type: ResourceType.prompt);
      final skills = await database.listResources(type: ResourceType.skill);
      final mcps = await database.listResources(type: ResourceType.mcp);
      final collections = await database.listCollections();

      expect(prompts.length, greaterThanOrEqualTo(100));
      expect(skills.length, greaterThanOrEqualTo(100));
      expect(mcps.length, greaterThanOrEqualTo(100));
      expect(collections.length, 8);
      expect(
        prompts.every(
          (resource) => resource.primaryCategory != ResourceCategory.all,
        ),
        isTrue,
      );
    });

    test('supports import and favorite locally', () async {
      final database = AppDatabase.memory();
      addTearDown(database.close);

      await database.bootstrap();

      final resourceId = await database.importResource(
        const ImportResourceDraft(
          type: ResourceType.prompt,
          primaryCategory: ResourceCategory.writing,
          title: '我的提示词',
          summary: '本地导入的 Prompt',
          scenario: '个人整理',
          tags: ['我的', '测试'],
          primaryContent: '请根据 {{主题}} 生成摘要。',
          secondaryContent: '适合快速做摘要',
          tertiaryContent: '不适合替代最终人工审核',
          listA: ['主题：本周项目进展', '输出：三行摘要'],
        ),
      );

      await database.toggleFavorite(resourceId);

      final prompt = await database.getPromptDetail(resourceId);
      final library = await database.getMyLibrarySnapshot();

      expect(prompt, isNotNull);
      expect(prompt!.resource.isOfficial, isFalse);
      expect(prompt.resource.primaryCategory, ResourceCategory.writing);
      expect(prompt.variables.map((value) => value.name), contains('主题'));
      expect(
        library.importedResources.map((value) => value.id),
        contains(resourceId),
      );
      expect(library.favorites.map((value) => value.id), contains(resourceId));
    });
  });
}
