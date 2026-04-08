import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/models.dart';
import 'package:mobile/infrastructure/database/app_database.dart';

void main() {
  group('catalog database', () {
    test('bootstraps official resources with quality metadata and collections', () async {
      final database = AppDatabase.memory();
      addTearDown(database.close);

      await database.bootstrap();

      final prompts = await database.listResources(type: ResourceType.prompt);
      final skills = await database.listResources(type: ResourceType.skill);
      final mcps = await database.listResources(type: ResourceType.mcp);
      final collections = await database.listCollections();

      expect(prompts.length, greaterThanOrEqualTo(260));
      expect(skills.length, greaterThanOrEqualTo(206));
      expect(mcps.length, greaterThanOrEqualTo(166));
      expect(collections.length, 16);
      expect(
        prompts.every(
          (resource) => resource.primaryCategory != ResourceCategory.all,
        ),
        isTrue,
      );
      expect(
        prompts.every((resource) => resource.qualityReasons.isNotEmpty),
        isTrue,
      );
      expect(
        prompts.any(
          (resource) => resource.qualityTier == ResourceQualityTier.featured,
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
      expect(prompt.helperNotes, isNotEmpty);
      expect(
        library.importedResources.map((value) => value.id),
        contains(resourceId),
      );
      expect(library.favorites.map((value) => value.id), contains(resourceId));
    });

    test('tracks prompt usage and recent prompts', () async {
      final database = AppDatabase.memory();
      addTearDown(database.close);

      await database.bootstrap();

      await database.savePromptUsage(
        resourceId: 'prompt-code-review',
        lastValues: const {'代码语言': 'Go', '代码片段': 'func main() {}'},
        markCopied: true,
      );

      final usage = await database.loadPromptUsage('prompt-code-review');
      final recent = await database.listRecentlyUsedPrompts(limit: 3);

      expect(usage, isNotNull);
      expect(usage!.useCount, 1);
      expect(usage.lastValues['代码语言'], 'Go');
      expect(recent.map((value) => value.id), contains('prompt-code-review'));
    });

    test('duplicates official skill and updates imported copy', () async {
      final database = AppDatabase.memory();
      addTearDown(database.close);

      await database.bootstrap();

      final importedId = await database.duplicateOfficialSkill(
        'skill-prompt-scorer',
      );
      final draft = await database.getSkillEditorDraft(importedId);
      expect(draft, isNotNull);
      expect(draft!.isImportedSource, isTrue);
      expect(draft.originResourceId, 'skill-prompt-scorer');

      await database.updateImportedSkill(
        draft.copyWith(
          title: '我的提示词评分器',
          summary: '改成自己的评分标准',
          tags: const ['评分', '本地版本'],
        ),
      );

      final updated = await database.getSkillDetail(importedId);
      expect(updated, isNotNull);
      expect(updated!.resource.source, ResourceSource.imported);
      expect(updated.resource.title, '我的提示词评分器');
      expect(updated.resource.originResourceId, 'skill-prompt-scorer');
      expect(updated.resource.tags, contains('本地版本'));
    });
  });
}
