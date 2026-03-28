import 'dart:convert';

enum ResourceType { prompt, skill, mcp }

enum ResourceSource { official, imported }

enum PromptVariableType { text, longText, enumeration, code, booleanType }

enum ResourceDifficulty { beginner, intermediate, advanced }

enum ResourceCategory {
  all,
  development,
  office,
  writing,
  content,
  learning,
  career,
  growth,
  life,
  other,
}

class PromptVariable {
  const PromptVariable({
    required this.name,
    required this.type,
    this.description = '',
    this.defaultValue = '',
    this.options = const [],
  });

  final String name;
  final PromptVariableType type;
  final String description;
  final String defaultValue;
  final List<String> options;

  factory PromptVariable.fromMap(Map<String, dynamic> map) {
    final rawType = (map['type'] as String?) ?? PromptVariableType.text.name;
    final type = PromptVariableType.values.firstWhere(
      (value) => value.name == rawType,
      orElse: () => PromptVariableType.text,
    );
    return PromptVariable(
      name: map['name'] as String? ?? '',
      type: type,
      description: map['description'] as String? ?? '',
      defaultValue: map['defaultValue'] as String? ?? '',
      options: (map['options'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'type': type.name,
    'description': description,
    'defaultValue': defaultValue,
    'options': options,
  };
}

class CatalogResource {
  const CatalogResource({
    required this.id,
    required this.type,
    required this.source,
    required this.title,
    required this.summary,
    required this.scenario,
    required this.primaryCategory,
    required this.difficulty,
    required this.tags,
    required this.primaryActionLabel,
    required this.isFeatured,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final ResourceType type;
  final ResourceSource source;
  final String title;
  final String summary;
  final String scenario;
  final ResourceCategory primaryCategory;
  final ResourceDifficulty difficulty;
  final List<String> tags;
  final String primaryActionLabel;
  final bool isFeatured;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isOfficial => source == ResourceSource.official;
}

class ResourceCollection {
  const ResourceCollection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.iconKey,
    required this.resourceCount,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String iconKey;
  final int resourceCount;
}

class CollectionDetail {
  const CollectionDetail({required this.collection, required this.resources});

  final ResourceCollection collection;
  final List<CatalogResource> resources;
}

class PromptResourceDetail {
  const PromptResourceDetail({
    required this.resource,
    required this.templateBody,
    required this.variables,
    required this.whenToUse,
    required this.avoidWhen,
    required this.exampleInput,
    required this.exampleOutput,
    required this.supportedModels,
  });

  final CatalogResource resource;
  final String templateBody;
  final List<PromptVariable> variables;
  final String whenToUse;
  final String avoidWhen;
  final String exampleInput;
  final String exampleOutput;
  final List<String> supportedModels;
}

class SkillResourceDetail {
  const SkillResourceDetail({
    required this.resource,
    required this.capabilitySummary,
    required this.inputRequirements,
    required this.usageSteps,
    required this.supportedModels,
    required this.copyPayload,
    required this.rawSchema,
    required this.providerAdapters,
    required this.exampleCode,
    required this.exampleLanguage,
  });

  final CatalogResource resource;
  final String capabilitySummary;
  final List<String> inputRequirements;
  final List<String> usageSteps;
  final List<String> supportedModels;
  final String copyPayload;
  final Map<String, dynamic> rawSchema;
  final Map<String, dynamic> providerAdapters;
  final String exampleCode;
  final String exampleLanguage;
}

class McpResourceDetail {
  const McpResourceDetail({
    required this.resource,
    required this.capabilitiesSummary,
    required this.supportedClients,
    required this.requiredEnvVars,
    required this.setupSteps,
    required this.configTemplate,
    required this.safetyNotes,
    required this.transport,
    required this.baseUrl,
  });

  final CatalogResource resource;
  final String capabilitiesSummary;
  final List<String> supportedClients;
  final List<String> requiredEnvVars;
  final List<String> setupSteps;
  final String configTemplate;
  final String safetyNotes;
  final String transport;
  final String baseUrl;
}

class HomeSnapshot {
  const HomeSnapshot({
    required this.query,
    required this.searchResults,
    required this.featuredCollections,
    required this.beginnerResources,
    required this.featuredResources,
    required this.prompts,
    required this.skills,
    required this.mcps,
    required this.favoritePreview,
    required this.importedCount,
    required this.catalogSyncState,
    required this.officialResourceCount,
    required this.collectionCount,
  });

  final String query;
  final List<CatalogResource> searchResults;
  final List<ResourceCollection> featuredCollections;
  final List<CatalogResource> beginnerResources;
  final List<CatalogResource> featuredResources;
  final List<CatalogResource> prompts;
  final List<CatalogResource> skills;
  final List<CatalogResource> mcps;
  final List<CatalogResource> favoritePreview;
  final int importedCount;
  final CatalogSyncState catalogSyncState;
  final int officialResourceCount;
  final int collectionCount;
}

class MyLibrarySnapshot {
  const MyLibrarySnapshot({
    required this.favorites,
    required this.importedResources,
  });

  final List<CatalogResource> favorites;
  final List<CatalogResource> importedResources;
}

class CatalogSyncState {
  const CatalogSyncState({
    required this.version,
    required this.source,
    required this.lastSyncedAt,
  });

  final String version;
  final String source;
  final DateTime lastSyncedAt;

  bool get isRemote => source == 'remote';
}

class ResourceBrowseFilter {
  const ResourceBrowseFilter({
    required this.type,
    this.query = '',
    this.category = ResourceCategory.all,
    this.tag = '',
    this.favoritesOnly = false,
    this.importedOnly = false,
  });

  final ResourceType type;
  final String query;
  final ResourceCategory category;
  final String tag;
  final bool favoritesOnly;
  final bool importedOnly;

  @override
  bool operator ==(Object other) {
    return other is ResourceBrowseFilter &&
        other.type == type &&
        other.query == query &&
        other.category == category &&
        other.tag == tag &&
        other.favoritesOnly == favoritesOnly &&
        other.importedOnly == importedOnly;
  }

  @override
  int get hashCode =>
      Object.hash(type, query, category, tag, favoritesOnly, importedOnly);
}

class ResourceBrowseSnapshot {
  const ResourceBrowseSnapshot({
    required this.resources,
    required this.availableCategories,
    required this.availableTags,
  });

  final List<CatalogResource> resources;
  final List<ResourceCategory> availableCategories;
  final List<String> availableTags;
}

class ImportResourceDraft {
  const ImportResourceDraft({
    required this.type,
    required this.title,
    required this.summary,
    required this.scenario,
    required this.primaryCategory,
    required this.tags,
    required this.primaryContent,
    this.secondaryContent = '',
    this.tertiaryContent = '',
    this.listA = const [],
    this.listB = const [],
  });

  final ResourceType type;
  final String title;
  final String summary;
  final String scenario;
  final ResourceCategory primaryCategory;
  final List<String> tags;
  final String primaryContent;
  final String secondaryContent;
  final String tertiaryContent;
  final List<String> listA;
  final List<String> listB;
}

extension ResourceTypeX on ResourceType {
  String get label => switch (this) {
    ResourceType.prompt => '提示词',
    ResourceType.skill => '技能',
    ResourceType.mcp => 'MCP',
  };

  String get term => switch (this) {
    ResourceType.prompt => 'Prompt',
    ResourceType.skill => 'Skill',
    ResourceType.mcp => 'MCP',
  };

  String get displayName => switch (this) {
    ResourceType.prompt => '提示词',
    ResourceType.skill => '技能',
    ResourceType.mcp => 'MCP 配置',
  };

  String get shortDescription => switch (this) {
    ResourceType.prompt => '现成指令模板，适合先把结果做出来。',
    ResourceType.skill => '把做事方法写清楚，适合同类任务反复复用。',
    ResourceType.mcp => '让 AI 读外部资料、连外部工具，适合需要上下文和实时数据时用。',
  };

  String get beginnerGuide => switch (this) {
    ResourceType.prompt => '先挑一个最接近你手头任务的模板，填几处关键信息就能直接用。',
    ResourceType.skill => '如果你总在重复做同一类事，就先找一条技能，把步骤固定下来。',
    ResourceType.mcp => '先接你已经在用的平台，不要一开始就同时配很多服务。',
  };
}

extension ResourceDifficultyX on ResourceDifficulty {
  String get label => switch (this) {
    ResourceDifficulty.beginner => '新手友好',
    ResourceDifficulty.intermediate => '进阶可用',
    ResourceDifficulty.advanced => '需要基础',
  };
}

extension ResourceSourceX on ResourceSource {
  String get label => switch (this) {
    ResourceSource.official => '官方精选',
    ResourceSource.imported => '我的导入',
  };
}

extension ResourceCategoryX on ResourceCategory {
  String get storageKey => switch (this) {
    ResourceCategory.all => 'all',
    ResourceCategory.development => 'development',
    ResourceCategory.office => 'office',
    ResourceCategory.writing => 'writing',
    ResourceCategory.content => 'content',
    ResourceCategory.learning => 'learning',
    ResourceCategory.career => 'career',
    ResourceCategory.growth => 'growth',
    ResourceCategory.life => 'life',
    ResourceCategory.other => 'other',
  };

  String get label => switch (this) {
    ResourceCategory.all => '全部',
    ResourceCategory.development => '开发编程',
    ResourceCategory.office => '办公协作',
    ResourceCategory.writing => '写作表达',
    ResourceCategory.content => '内容创作',
    ResourceCategory.learning => '学习研究',
    ResourceCategory.career => '求职成长',
    ResourceCategory.growth => '运营增长',
    ResourceCategory.life => '生活效率',
    ResourceCategory.other => '其他',
  };
}

String encodeJson(Object? value) => jsonEncode(value);

DateTime parseDateTime(String raw) => DateTime.parse(raw).toLocal();

String prettyJson(Object? value) {
  const encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(value);
}

ResourceType resourceTypeFromString(String raw) {
  return ResourceType.values.firstWhere(
    (value) => value.name == raw,
    orElse: () => ResourceType.prompt,
  );
}

ResourceSource resourceSourceFromString(String raw) {
  return ResourceSource.values.firstWhere(
    (value) => value.name == raw,
    orElse: () => ResourceSource.official,
  );
}

ResourceDifficulty resourceDifficultyFromString(String raw) {
  return ResourceDifficulty.values.firstWhere(
    (value) => value.name == raw,
    orElse: () => ResourceDifficulty.beginner,
  );
}

ResourceCategory resourceCategoryFromString(String raw) {
  return ResourceCategory.values.firstWhere(
    (value) => value.storageKey == raw || value.name == raw,
    orElse: () => ResourceCategory.other,
  );
}

ResourceCategory inferResourceCategory({
  required String scenario,
  required Iterable<String> tags,
}) {
  final normalizedScenario = scenario.trim().toLowerCase();
  final normalizedTags = tags
      .map((value) => value.trim().toLowerCase())
      .where((value) => value.isNotEmpty)
      .toList();

  bool hasAny(List<String> candidates) {
    return normalizedTags.any(
      (tag) =>
          candidates.any((candidate) => tag.contains(candidate.toLowerCase())),
    );
  }

  if (normalizedScenario.contains('求职成长')) {
    return ResourceCategory.career;
  }

  if (hasAny(const ['论文', '阅读', '研究', '洞察'])) {
    return ResourceCategory.learning;
  }

  if (normalizedScenario.contains('开发提效') ||
      hasAny(const [
        'github',
        'sql',
        '数据库',
        'api',
        '测试',
        '云平台',
        '排障',
        '架构',
        '性能',
      ])) {
    return ResourceCategory.development;
  }

  if (normalizedScenario.contains('内容增长')) {
    if (hasAny(const ['脚本', '标题', '文案', '小红书', '短视频', '社区', '回复'])) {
      return ResourceCategory.content;
    }
    if (hasAny(const ['用户画像', '访谈', '转化', '运营', '客服'])) {
      return ResourceCategory.growth;
    }
    return ResourceCategory.content;
  }

  if (normalizedScenario.contains('办公协作')) {
    if (hasAny(const ['邮件', '润色', '表达', '大纲', '方案'])) {
      return ResourceCategory.writing;
    }
    return ResourceCategory.office;
  }

  if (hasAny(const ['生活', '效率', '日常'])) {
    return ResourceCategory.life;
  }

  return ResourceCategory.other;
}
