import 'models.dart';

enum SkillSchemaFieldType {
  string,
  integer,
  number,
  booleanType,
  enumeration,
  array,
}

class SkillSchemaFieldDraft {
  const SkillSchemaFieldDraft({
    required this.name,
    required this.type,
    this.description = '',
    this.required = false,
    this.enumOptions = const [],
    this.arrayItemType = SkillSchemaFieldType.string,
  });

  final String name;
  final SkillSchemaFieldType type;
  final String description;
  final bool required;
  final List<String> enumOptions;
  final SkillSchemaFieldType arrayItemType;

  SkillSchemaFieldDraft copyWith({
    String? name,
    SkillSchemaFieldType? type,
    String? description,
    bool? required,
    List<String>? enumOptions,
    SkillSchemaFieldType? arrayItemType,
  }) {
    return SkillSchemaFieldDraft(
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      required: required ?? this.required,
      enumOptions: enumOptions ?? this.enumOptions,
      arrayItemType: arrayItemType ?? this.arrayItemType,
    );
  }
}

class SkillEditorDraft {
  const SkillEditorDraft({
    required this.resourceId,
    required this.isImportedSource,
    required this.title,
    required this.summary,
    required this.scenario,
    required this.primaryCategory,
    required this.tags,
    required this.capabilitySummary,
    required this.inputRequirements,
    required this.usageSteps,
    required this.supportedModels,
    required this.copyPayload,
    required this.exampleCode,
    required this.exampleLanguage,
    required this.schemaFields,
    required this.advancedSchemaJson,
    required this.advancedSchemaMode,
    this.originResourceId,
  });

  final String resourceId;
  final bool isImportedSource;
  final String title;
  final String summary;
  final String scenario;
  final ResourceCategory primaryCategory;
  final List<String> tags;
  final String capabilitySummary;
  final List<String> inputRequirements;
  final List<String> usageSteps;
  final List<String> supportedModels;
  final String copyPayload;
  final String exampleCode;
  final String exampleLanguage;
  final List<SkillSchemaFieldDraft> schemaFields;
  final String advancedSchemaJson;
  final bool advancedSchemaMode;
  final String? originResourceId;

  SkillEditorDraft copyWith({
    String? resourceId,
    bool? isImportedSource,
    String? title,
    String? summary,
    String? scenario,
    ResourceCategory? primaryCategory,
    List<String>? tags,
    String? capabilitySummary,
    List<String>? inputRequirements,
    List<String>? usageSteps,
    List<String>? supportedModels,
    String? copyPayload,
    String? exampleCode,
    String? exampleLanguage,
    List<SkillSchemaFieldDraft>? schemaFields,
    String? advancedSchemaJson,
    bool? advancedSchemaMode,
    String? originResourceId,
  }) {
    return SkillEditorDraft(
      resourceId: resourceId ?? this.resourceId,
      isImportedSource: isImportedSource ?? this.isImportedSource,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      scenario: scenario ?? this.scenario,
      primaryCategory: primaryCategory ?? this.primaryCategory,
      tags: tags ?? this.tags,
      capabilitySummary: capabilitySummary ?? this.capabilitySummary,
      inputRequirements: inputRequirements ?? this.inputRequirements,
      usageSteps: usageSteps ?? this.usageSteps,
      supportedModels: supportedModels ?? this.supportedModels,
      copyPayload: copyPayload ?? this.copyPayload,
      exampleCode: exampleCode ?? this.exampleCode,
      exampleLanguage: exampleLanguage ?? this.exampleLanguage,
      schemaFields: schemaFields ?? this.schemaFields,
      advancedSchemaJson: advancedSchemaJson ?? this.advancedSchemaJson,
      advancedSchemaMode: advancedSchemaMode ?? this.advancedSchemaMode,
      originResourceId: originResourceId ?? this.originResourceId,
    );
  }
}

extension SkillSchemaFieldTypeX on SkillSchemaFieldType {
  String get label => switch (this) {
    SkillSchemaFieldType.string => '字符串',
    SkillSchemaFieldType.integer => '整数',
    SkillSchemaFieldType.number => '数字',
    SkillSchemaFieldType.booleanType => '布尔值',
    SkillSchemaFieldType.enumeration => '枚举',
    SkillSchemaFieldType.array => '数组',
  };
}
