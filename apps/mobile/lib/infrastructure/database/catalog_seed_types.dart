import '../../domain/models.dart';

class OfficialCatalogSeed {
  const OfficialCatalogSeed({
    required this.version,
    required this.generatedAt,
    required this.resources,
    required this.promptDetails,
    required this.skillDetails,
    required this.mcpDetails,
    required this.collections,
    required this.collectionItems,
  });

  final String version;
  final String generatedAt;
  final List<SeedCatalogResource> resources;
  final List<SeedPromptDetail> promptDetails;
  final List<SeedSkillDetail> skillDetails;
  final List<SeedMcpDetail> mcpDetails;
  final List<SeedCollection> collections;
  final List<SeedCollectionItem> collectionItems;

  bool get hasUsableContent {
    if (resources.isEmpty) {
      return false;
    }

    final resourceIds = resources.map((resource) => resource.id).toSet();
    final promptIds = resources
        .where((resource) => resource.type == ResourceType.prompt)
        .map((resource) => resource.id)
        .toSet();
    final skillIds = resources
        .where((resource) => resource.type == ResourceType.skill)
        .map((resource) => resource.id)
        .toSet();
    final mcpIds = resources
        .where((resource) => resource.type == ResourceType.mcp)
        .map((resource) => resource.id)
        .toSet();

    final promptDetailsValid = promptDetails.every(
      (detail) => promptIds.contains(detail.resourceId),
    );
    final skillDetailsValid = skillDetails.every(
      (detail) => skillIds.contains(detail.resourceId),
    );
    final mcpDetailsValid = mcpDetails.every(
      (detail) => mcpIds.contains(detail.resourceId),
    );
    final collectionsValid = collections.every(
      (collection) => collection.id.isNotEmpty,
    );
    final collectionItemsValid = collectionItems.every(
      (item) =>
          item.collectionId.isNotEmpty && resourceIds.contains(item.resourceId),
    );

    return promptDetailsValid &&
        skillDetailsValid &&
        mcpDetailsValid &&
        collectionsValid &&
        collectionItemsValid;
  }

  factory OfficialCatalogSeed.fromMap(Map<String, dynamic> map) {
    return OfficialCatalogSeed(
      version: map['version'] as String? ?? 'unknown',
      generatedAt: map['generatedAt'] as String? ?? '',
      resources: (map['resources'] as List<dynamic>? ?? const [])
          .map(
            (value) => SeedCatalogResource.fromMap(
              Map<String, dynamic>.from(value as Map),
            ),
          )
          .toList(),
      promptDetails: (map['promptDetails'] as List<dynamic>? ?? const [])
          .map(
            (value) => SeedPromptDetail.fromMap(
              Map<String, dynamic>.from(value as Map),
            ),
          )
          .toList(),
      skillDetails: (map['skillDetails'] as List<dynamic>? ?? const [])
          .map(
            (value) => SeedSkillDetail.fromMap(
              Map<String, dynamic>.from(value as Map),
            ),
          )
          .toList(),
      mcpDetails: (map['mcpDetails'] as List<dynamic>? ?? const [])
          .map(
            (value) =>
                SeedMcpDetail.fromMap(Map<String, dynamic>.from(value as Map)),
          )
          .toList(),
      collections: (map['collections'] as List<dynamic>? ?? const [])
          .map(
            (value) =>
                SeedCollection.fromMap(Map<String, dynamic>.from(value as Map)),
          )
          .toList(),
      collectionItems: (map['collectionItems'] as List<dynamic>? ?? const [])
          .map(
            (value) => SeedCollectionItem.fromMap(
              Map<String, dynamic>.from(value as Map),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'version': version,
    'generatedAt': generatedAt,
    'resources': resources.map((value) => value.toMap()).toList(),
    'promptDetails': promptDetails.map((value) => value.toMap()).toList(),
    'skillDetails': skillDetails.map((value) => value.toMap()).toList(),
    'mcpDetails': mcpDetails.map((value) => value.toMap()).toList(),
    'collections': collections.map((value) => value.toMap()).toList(),
    'collectionItems': collectionItems.map((value) => value.toMap()).toList(),
  };
}

class SeedCatalogResource {
  const SeedCatalogResource({
    required this.id,
    required this.type,
    required this.title,
    required this.summary,
    required this.scenario,
    required this.primaryCategory,
    required this.difficulty,
    required this.tags,
    required this.primaryActionLabel,
    required this.isFeatured,
    this.qualityTier = ResourceQualityTier.community,
    this.qualityScore = 60,
    this.qualityReasons = const [],
    this.useCases = const [],
    this.avoidCases = const [],
    this.verifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final ResourceType type;
  final String title;
  final String summary;
  final String scenario;
  final ResourceCategory primaryCategory;
  final ResourceDifficulty difficulty;
  final List<String> tags;
  final String primaryActionLabel;
  final bool isFeatured;
  final ResourceQualityTier qualityTier;
  final int qualityScore;
  final List<String> qualityReasons;
  final List<String> useCases;
  final List<String> avoidCases;
  final String? verifiedAt;
  final String createdAt;
  final String updatedAt;

  SeedCatalogResource copyWith({
    String? id,
    ResourceType? type,
    String? title,
    String? summary,
    String? scenario,
    ResourceCategory? primaryCategory,
    ResourceDifficulty? difficulty,
    List<String>? tags,
    String? primaryActionLabel,
    bool? isFeatured,
    ResourceQualityTier? qualityTier,
    int? qualityScore,
    List<String>? qualityReasons,
    List<String>? useCases,
    List<String>? avoidCases,
    String? verifiedAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return SeedCatalogResource(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      scenario: scenario ?? this.scenario,
      primaryCategory: primaryCategory ?? this.primaryCategory,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      primaryActionLabel: primaryActionLabel ?? this.primaryActionLabel,
      isFeatured: isFeatured ?? this.isFeatured,
      qualityTier: qualityTier ?? this.qualityTier,
      qualityScore: qualityScore ?? this.qualityScore,
      qualityReasons: qualityReasons ?? this.qualityReasons,
      useCases: useCases ?? this.useCases,
      avoidCases: avoidCases ?? this.avoidCases,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory SeedCatalogResource.fromMap(Map<String, dynamic> map) {
    return SeedCatalogResource(
      id: map['id'] as String? ?? '',
      type: resourceTypeFromString(map['type'] as String? ?? 'prompt'),
      title: map['title'] as String? ?? '',
      summary: map['summary'] as String? ?? '',
      scenario: map['scenario'] as String? ?? '',
      primaryCategory: resourceCategoryFromString(
        map['primaryCategory'] as String? ?? 'other',
      ),
      difficulty: resourceDifficultyFromString(
        map['difficulty'] as String? ?? 'beginner',
      ),
      tags: (map['tags'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(),
      primaryActionLabel: map['primaryActionLabel'] as String? ?? '',
      isFeatured: map['isFeatured'] as bool? ?? false,
      qualityTier: resourceQualityTierFromString(
        map['qualityTier'] as String? ?? 'community',
      ),
      qualityScore: (map['qualityScore'] as num?)?.toInt() ?? 60,
      qualityReasons: (map['qualityReasons'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(),
      useCases: (map['useCases'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(),
      avoidCases: (map['avoidCases'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(),
      verifiedAt: map['verifiedAt'] as String?,
      createdAt: map['createdAt'] as String? ?? '',
      updatedAt: map['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.name,
    'title': title,
    'summary': summary,
    'scenario': scenario,
    'primaryCategory': primaryCategory.storageKey,
    'difficulty': difficulty.name,
    'tags': tags,
    'primaryActionLabel': primaryActionLabel,
    'isFeatured': isFeatured,
    'qualityTier': qualityTier.storageKey,
    'qualityScore': qualityScore,
    'qualityReasons': qualityReasons,
    'useCases': useCases,
    'avoidCases': avoidCases,
    'verifiedAt': verifiedAt,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

class SeedPromptDetail {
  const SeedPromptDetail({
    required this.resourceId,
    required this.templateBody,
    required this.variables,
    required this.whenToUse,
    required this.avoidWhen,
    required this.exampleInput,
    required this.exampleOutput,
    required this.supportedModels,
    this.helperNotes = const [],
    this.requiredVariableNames = const [],
  });

  final String resourceId;
  final String templateBody;
  final List<PromptVariable> variables;
  final String whenToUse;
  final String avoidWhen;
  final String exampleInput;
  final String exampleOutput;
  final List<String> supportedModels;
  final List<String> helperNotes;
  final List<String> requiredVariableNames;

  factory SeedPromptDetail.fromMap(Map<String, dynamic> map) {
    return SeedPromptDetail(
      resourceId: map['resourceId'] as String? ?? '',
      templateBody: map['templateBody'] as String? ?? '',
      variables: (map['variables'] as List<dynamic>? ?? const [])
          .map(
            (value) =>
                PromptVariable.fromMap(Map<String, dynamic>.from(value as Map)),
          )
          .toList(),
      whenToUse: map['whenToUse'] as String? ?? '',
      avoidWhen: map['avoidWhen'] as String? ?? '',
      exampleInput: map['exampleInput'] as String? ?? '',
      exampleOutput: map['exampleOutput'] as String? ?? '',
      supportedModels: (map['supportedModels'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(),
      helperNotes: (map['helperNotes'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(),
      requiredVariableNames:
          (map['requiredVariableNames'] as List<dynamic>? ?? const [])
              .map((value) => value.toString())
              .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'resourceId': resourceId,
    'templateBody': templateBody,
    'variables': variables.map((value) => value.toMap()).toList(),
    'whenToUse': whenToUse,
    'avoidWhen': avoidWhen,
    'exampleInput': exampleInput,
    'exampleOutput': exampleOutput,
    'supportedModels': supportedModels,
    'helperNotes': helperNotes,
    'requiredVariableNames': requiredVariableNames,
  };
}

class SeedSkillDetail {
  const SeedSkillDetail({
    required this.resourceId,
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

  final String resourceId;
  final String capabilitySummary;
  final List<String> inputRequirements;
  final List<String> usageSteps;
  final List<String> supportedModels;
  final String copyPayload;
  final Map<String, dynamic> rawSchema;
  final Map<String, dynamic> providerAdapters;
  final String exampleCode;
  final String exampleLanguage;

  factory SeedSkillDetail.fromMap(Map<String, dynamic> map) {
    return SeedSkillDetail(
      resourceId: map['resourceId'] as String? ?? '',
      capabilitySummary: map['capabilitySummary'] as String? ?? '',
      inputRequirements:
          (map['inputRequirements'] as List<dynamic>? ?? const [])
              .map((value) => value.toString())
              .toList(),
      usageSteps: (map['usageSteps'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(),
      supportedModels: (map['supportedModels'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(),
      copyPayload: map['copyPayload'] as String? ?? '',
      rawSchema: Map<String, dynamic>.from(
        map['rawSchema'] as Map? ?? const <String, dynamic>{},
      ),
      providerAdapters: Map<String, dynamic>.from(
        map['providerAdapters'] as Map? ?? const <String, dynamic>{},
      ),
      exampleCode: map['exampleCode'] as String? ?? '',
      exampleLanguage: map['exampleLanguage'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'resourceId': resourceId,
    'capabilitySummary': capabilitySummary,
    'inputRequirements': inputRequirements,
    'usageSteps': usageSteps,
    'supportedModels': supportedModels,
    'copyPayload': copyPayload,
    'rawSchema': rawSchema,
    'providerAdapters': providerAdapters,
    'exampleCode': exampleCode,
    'exampleLanguage': exampleLanguage,
  };
}

class SeedMcpDetail {
  const SeedMcpDetail({
    required this.resourceId,
    required this.capabilitiesSummary,
    required this.supportedClients,
    required this.requiredEnvVars,
    required this.setupSteps,
    required this.configTemplate,
    required this.safetyNotes,
    required this.transport,
    required this.baseUrl,
  });

  final String resourceId;
  final String capabilitiesSummary;
  final List<String> supportedClients;
  final List<String> requiredEnvVars;
  final List<String> setupSteps;
  final String configTemplate;
  final String safetyNotes;
  final String transport;
  final String baseUrl;

  factory SeedMcpDetail.fromMap(Map<String, dynamic> map) {
    return SeedMcpDetail(
      resourceId: map['resourceId'] as String? ?? '',
      capabilitiesSummary: map['capabilitiesSummary'] as String? ?? '',
      supportedClients: (map['supportedClients'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(),
      requiredEnvVars: (map['requiredEnvVars'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(),
      setupSteps: (map['setupSteps'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(),
      configTemplate: map['configTemplate'] as String? ?? '',
      safetyNotes: map['safetyNotes'] as String? ?? '',
      transport: map['transport'] as String? ?? '',
      baseUrl: map['baseUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'resourceId': resourceId,
    'capabilitiesSummary': capabilitiesSummary,
    'supportedClients': supportedClients,
    'requiredEnvVars': requiredEnvVars,
    'setupSteps': setupSteps,
    'configTemplate': configTemplate,
    'safetyNotes': safetyNotes,
    'transport': transport,
    'baseUrl': baseUrl,
  };
}

class SeedCollection {
  const SeedCollection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.iconKey,
    required this.sortOrder,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String iconKey;
  final int sortOrder;

  factory SeedCollection.fromMap(Map<String, dynamic> map) {
    return SeedCollection(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
      description: map['description'] as String? ?? '',
      iconKey: map['iconKey'] as String? ?? '',
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'description': description,
    'iconKey': iconKey,
    'sortOrder': sortOrder,
  };
}

class SeedCollectionItem {
  const SeedCollectionItem({
    required this.collectionId,
    required this.resourceId,
    required this.sortOrder,
  });

  final String collectionId;
  final String resourceId;
  final int sortOrder;

  factory SeedCollectionItem.fromMap(Map<String, dynamic> map) {
    return SeedCollectionItem(
      collectionId: map['collectionId'] as String? ?? '',
      resourceId: map['resourceId'] as String? ?? '',
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'collectionId': collectionId,
    'resourceId': resourceId,
    'sortOrder': sortOrder,
  };
}

class PromptSeedBundle {
  const PromptSeedBundle({required this.resource, required this.detail});

  final SeedCatalogResource resource;
  final SeedPromptDetail detail;
}

class SkillSeedBundle {
  const SkillSeedBundle({required this.resource, required this.detail});

  final SeedCatalogResource resource;
  final SeedSkillDetail detail;
}

class McpSeedBundle {
  const McpSeedBundle({required this.resource, required this.detail});

  final SeedCatalogResource resource;
  final SeedMcpDetail detail;
}

PromptSeedBundle buildPromptSeed({
  required String id,
  required String title,
  required String summary,
  required String scenario,
  required ResourceDifficulty difficulty,
  required List<String> tags,
  ResourceCategory? primaryCategory,
  required String templateBody,
  required List<PromptVariable> variables,
  required String whenToUse,
  required String avoidWhen,
  required String exampleInput,
  required String exampleOutput,
  required String stamp,
  bool featured = false,
  List<String> helperNotes = const [],
  List<String> requiredVariableNames = const [],
}) {
  return PromptSeedBundle(
    resource: SeedCatalogResource(
      id: id,
      type: ResourceType.prompt,
      title: title,
      summary: summary,
      scenario: scenario,
      primaryCategory:
          primaryCategory ??
          inferResourceCategory(scenario: scenario, tags: tags),
      difficulty: difficulty,
      tags: tags,
      primaryActionLabel: '填写变量后复制',
      isFeatured: featured,
      createdAt: stamp,
      updatedAt: stamp,
    ),
    detail: SeedPromptDetail(
      resourceId: id,
      templateBody: templateBody,
      variables: variables,
      whenToUse: whenToUse,
      avoidWhen: avoidWhen,
      exampleInput: exampleInput,
      exampleOutput: exampleOutput,
      supportedModels: const ['ChatGPT', 'Claude', 'Gemini', 'DeepSeek'],
      helperNotes: helperNotes,
      requiredVariableNames: requiredVariableNames,
    ),
  );
}

SkillSeedBundle buildSkillSeed({
  required String id,
  required String title,
  required String summary,
  required String scenario,
  required ResourceDifficulty difficulty,
  required List<String> tags,
  ResourceCategory? primaryCategory,
  required String capabilitySummary,
  required List<String> inputRequirements,
  required List<String> usageSteps,
  required List<String> supportedModels,
  required String copyPayload,
  required Map<String, dynamic> rawSchema,
  required Map<String, dynamic> providerAdapters,
  required String exampleCode,
  required String exampleLanguage,
  required String stamp,
  bool featured = false,
}) {
  return SkillSeedBundle(
    resource: SeedCatalogResource(
      id: id,
      type: ResourceType.skill,
      title: title,
      summary: summary,
      scenario: scenario,
      primaryCategory:
          primaryCategory ??
          inferResourceCategory(scenario: scenario, tags: tags),
      difficulty: difficulty,
      tags: tags,
      primaryActionLabel: '复制技能内容',
      isFeatured: featured,
      createdAt: stamp,
      updatedAt: stamp,
    ),
    detail: SeedSkillDetail(
      resourceId: id,
      capabilitySummary: capabilitySummary,
      inputRequirements: inputRequirements,
      usageSteps: usageSteps,
      supportedModels: supportedModels,
      copyPayload: copyPayload,
      rawSchema: rawSchema,
      providerAdapters: providerAdapters,
      exampleCode: exampleCode,
      exampleLanguage: exampleLanguage,
    ),
  );
}

McpSeedBundle buildMcpSeed({
  required String id,
  required String title,
  required String summary,
  required String scenario,
  required ResourceDifficulty difficulty,
  required List<String> tags,
  ResourceCategory? primaryCategory,
  required String capabilitiesSummary,
  required List<String> supportedClients,
  required List<String> requiredEnvVars,
  required List<String> setupSteps,
  required String configTemplate,
  required String safetyNotes,
  required String transport,
  required String baseUrl,
  required String stamp,
  bool featured = false,
}) {
  return McpSeedBundle(
    resource: SeedCatalogResource(
      id: id,
      type: ResourceType.mcp,
      title: title,
      summary: summary,
      scenario: scenario,
      primaryCategory:
          primaryCategory ??
          inferResourceCategory(scenario: scenario, tags: tags),
      difficulty: difficulty,
      tags: tags,
      primaryActionLabel: '复制配置模板',
      isFeatured: featured,
      createdAt: stamp,
      updatedAt: stamp,
    ),
    detail: SeedMcpDetail(
      resourceId: id,
      capabilitiesSummary: capabilitiesSummary,
      supportedClients: supportedClients,
      requiredEnvVars: requiredEnvVars,
      setupSteps: setupSteps,
      configTemplate: configTemplate,
      safetyNotes: safetyNotes,
      transport: transport,
      baseUrl: baseUrl,
    ),
  );
}

List<SeedCollectionItem> buildCollectionItems(
  String collectionId,
  List<String> resourceIds,
) {
  return resourceIds
      .asMap()
      .entries
      .map(
        (entry) => SeedCollectionItem(
          collectionId: collectionId,
          resourceId: entry.value,
          sortOrder: entry.key,
        ),
      )
      .toList();
}
