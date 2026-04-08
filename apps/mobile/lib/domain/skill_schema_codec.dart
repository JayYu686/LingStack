import 'dart:convert';

import 'models.dart';
import 'skill_editor_models.dart';

const Map<String, bool> _defaultProviderAdapters = {
  'openai': true,
  'anthropic': true,
  'gemini': true,
};

SkillEditorDraft buildSkillEditorDraftFromDetail(SkillResourceDetail detail) {
  final schemaFields = tryParseSimpleSkillSchema(detail.rawSchema);
  return SkillEditorDraft(
    resourceId: detail.resource.id,
    isImportedSource: detail.resource.source == ResourceSource.imported,
    originResourceId: detail.resource.originResourceId,
    title: detail.resource.title,
    summary: detail.resource.summary,
    scenario: detail.resource.scenario,
    primaryCategory: detail.resource.primaryCategory,
    tags: detail.resource.tags,
    capabilitySummary: detail.capabilitySummary,
    inputRequirements: detail.inputRequirements,
    usageSteps: detail.usageSteps,
    supportedModels: detail.supportedModels,
    copyPayload: detail.copyPayload,
    exampleCode: detail.exampleCode,
    exampleLanguage: detail.exampleLanguage,
    schemaFields: schemaFields ?? const [],
    advancedSchemaJson: prettyJson(detail.rawSchema),
    advancedSchemaMode: schemaFields == null,
  );
}

List<SkillSchemaFieldDraft>? tryParseSimpleSkillSchema(
  Map<String, dynamic> schema,
) {
  if ((schema['type'] as String?) != 'object') {
    return null;
  }
  if (schema.containsKey(r'$ref') ||
      schema.containsKey('oneOf') ||
      schema.containsKey('anyOf') ||
      schema.containsKey('allOf') ||
      schema.containsKey('patternProperties')) {
    return null;
  }

  final properties = schema['properties'];
  if (properties is! Map) {
    return null;
  }
  final required = ((schema['required'] as List?) ?? const [])
      .map((value) => value.toString())
      .toSet();
  final fields = <SkillSchemaFieldDraft>[];

  for (final entry in properties.entries) {
    final property = entry.value;
    if (property is! Map) {
      return null;
    }
    if (property.containsKey(r'$ref') ||
        property.containsKey('oneOf') ||
        property.containsKey('anyOf') ||
        property.containsKey('allOf') ||
        property.containsKey('patternProperties')) {
      return null;
    }

    final rawType = property['type'] as String?;
    final description = property['description'] as String? ?? '';
    if (rawType == null || rawType.isEmpty) {
      return null;
    }

    if (rawType == 'string' && property['enum'] is List) {
      fields.add(
        SkillSchemaFieldDraft(
          name: entry.key.toString(),
          type: SkillSchemaFieldType.enumeration,
          description: description,
          required: required.contains(entry.key),
          enumOptions: (property['enum'] as List)
              .map((value) => value.toString())
              .toList(),
        ),
      );
      continue;
    }

    if (rawType == 'array') {
      final items = property['items'];
      if (items is! Map) {
        return null;
      }
      final itemType = items['type'] as String?;
      final parsedItemType = switch (itemType) {
        'string' => SkillSchemaFieldType.string,
        'integer' => SkillSchemaFieldType.integer,
        'number' => SkillSchemaFieldType.number,
        'boolean' => SkillSchemaFieldType.booleanType,
        _ => null,
      };
      if (parsedItemType == null) {
        return null;
      }
      fields.add(
        SkillSchemaFieldDraft(
          name: entry.key.toString(),
          type: SkillSchemaFieldType.array,
          description: description,
          required: required.contains(entry.key),
          arrayItemType: parsedItemType,
        ),
      );
      continue;
    }

    final fieldType = switch (rawType) {
      'string' => SkillSchemaFieldType.string,
      'integer' => SkillSchemaFieldType.integer,
      'number' => SkillSchemaFieldType.number,
      'boolean' => SkillSchemaFieldType.booleanType,
      _ => null,
    };
    if (fieldType == null) {
      return null;
    }
    fields.add(
      SkillSchemaFieldDraft(
        name: entry.key.toString(),
        type: fieldType,
        description: description,
        required: required.contains(entry.key),
      ),
    );
  }

  return fields;
}

Map<String, dynamic> buildSkillSchemaFromFields(
  List<SkillSchemaFieldDraft> fields,
) {
  final requiredFields = <String>[];
  final properties = <String, dynamic>{};

  for (final field in fields) {
    final name = field.name.trim();
    if (name.isEmpty) {
      continue;
    }
    if (field.required) {
      requiredFields.add(name);
    }
    properties[name] = buildSkillSchemaProperty(field);
  }

  return {
    'type': 'object',
    'properties': properties,
    if (requiredFields.isNotEmpty) 'required': requiredFields,
  };
}

Map<String, dynamic> buildSkillSchemaProperty(SkillSchemaFieldDraft field) {
  final description = field.description.trim();
  return switch (field.type) {
    SkillSchemaFieldType.string => {
      'type': 'string',
      if (description.isNotEmpty) 'description': description,
    },
    SkillSchemaFieldType.integer => {
      'type': 'integer',
      if (description.isNotEmpty) 'description': description,
    },
    SkillSchemaFieldType.number => {
      'type': 'number',
      if (description.isNotEmpty) 'description': description,
    },
    SkillSchemaFieldType.booleanType => {
      'type': 'boolean',
      if (description.isNotEmpty) 'description': description,
    },
    SkillSchemaFieldType.enumeration => {
      'type': 'string',
      'enum': field.enumOptions
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(),
      if (description.isNotEmpty) 'description': description,
    },
    SkillSchemaFieldType.array => {
      'type': 'array',
      'items': {
        'type': switch (field.arrayItemType) {
          SkillSchemaFieldType.string => 'string',
          SkillSchemaFieldType.integer => 'integer',
          SkillSchemaFieldType.number => 'number',
          SkillSchemaFieldType.booleanType => 'boolean',
          SkillSchemaFieldType.enumeration => 'string',
          SkillSchemaFieldType.array => 'string',
        },
      },
      if (description.isNotEmpty) 'description': description,
    },
  };
}

Map<String, dynamic> buildProviderAdaptersForSchema(Map<String, dynamic> _) {
  return Map<String, dynamic>.from(_defaultProviderAdapters);
}

String normalizeSchemaJson(String raw) {
  final decoded = jsonDecode(raw) as Object?;
  return prettyJson(decoded);
}
