import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

import '../../domain/models.dart';
import 'catalog_seed.dart';
import 'catalog_seed_types.dart';
import 'schema_statements.dart';

class AppDatabase extends GeneratedDatabase {
  AppDatabase._(super.executor);

  static const _databaseFileName = 'ai_catalog_library.db';

  static AppDatabase? _sharedInstance;
  static Future<AppDatabase>? _sharedOpening;

  static Future<AppDatabase> open() {
    final instance = _sharedInstance;
    if (instance != null) {
      return Future.value(instance);
    }
    final opening = _sharedOpening;
    if (opening != null) {
      return opening;
    }
    _sharedOpening = _openShared();
    return _sharedOpening!;
  }

  static Future<AppDatabase> _openShared() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, _databaseFileName));
    try {
      await _repairLegacySchema(file);
      final database = await _openDatabase(file);
      _sharedInstance = database;
      return database;
    } catch (error) {
      await _archiveDatabase(file);
      final rebuilt = await _openDatabase(file);
      _sharedInstance = rebuilt;
      return rebuilt;
    }
  }

  factory AppDatabase.memory() => AppDatabase._(NativeDatabase.memory());

  @override
  int get schemaVersion => 4;

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => const [];

  @override
  Future<void> close() async {
    if (identical(_sharedInstance, this)) {
      _sharedInstance = null;
      _sharedOpening = null;
    }
    await super.close();
  }

  Future<void> bootstrap() async {
    await customStatement('PRAGMA foreign_keys = ON');
    for (final statement in schemaStatements) {
      await customStatement(statement);
    }
    await _ensureCatalogResourceColumns();
    await _backfillPrimaryCategories();

    final officialCount = await _countOfficialResources();
    if (officialCount == 0) {
      await replaceOfficialCatalog(buildOfficialCatalogSeed(), source: 'seed');
    } else {
      final syncState = await _readCatalogSyncStateOrNull();
      if (syncState == null) {
        await _upsertCatalogSyncState(
          version: 'legacy',
          source: 'seed',
          syncedAt: DateTime.now().toUtc(),
        );
      }
    }
  }

  static Future<AppDatabase> _openDatabase(File file) async {
    final database = AppDatabase._(NativeDatabase.createInBackground(file));
    try {
      await database.bootstrap().timeout(const Duration(seconds: 12));
      return database;
    } catch (error) {
      await database.close();
      rethrow;
    }
  }

  static Future<void> _repairLegacySchema(File file) async {
    if (!await file.exists()) {
      return;
    }

    final database = sqlite3.sqlite3.open(file.path);
    try {
      final tables = database
          .select(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'catalog_resources'",
          )
          .isNotEmpty;
      if (!tables) {
        return;
      }

      final columns = database.select('PRAGMA table_info(catalog_resources)');
      final hasPrimaryCategory = columns.any(
        (row) => row['name'] == 'primary_category',
      );
      if (!hasPrimaryCategory) {
        database.execute(
          "ALTER TABLE catalog_resources ADD COLUMN primary_category TEXT NOT NULL DEFAULT 'other'",
        );
      }

      final rows = database.select(
        'SELECT id, scenario, tags_json FROM catalog_resources',
      );
      for (final row in rows) {
        final resourceId = row['id']?.toString() ?? '';
        if (resourceId.isEmpty) {
          continue;
        }
        final scenario = row['scenario']?.toString() ?? '';
        final rawTags = row['tags_json']?.toString() ?? '[]';
        final tags = (jsonDecode(rawTags) as List<dynamic>)
            .map((value) => value.toString())
            .toList();
        final category = inferResourceCategory(scenario: scenario, tags: tags);
        database.execute(
          'UPDATE catalog_resources SET primary_category = ? WHERE id = ?',
          [category.storageKey, resourceId],
        );
      }
    } finally {
      database.dispose();
    }
  }

  static Future<void> _archiveDatabase(File file) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final candidates = [
      file,
      File('${file.path}-wal'),
      File('${file.path}-shm'),
    ];
    for (final candidate in candidates) {
      if (!await candidate.exists()) {
        continue;
      }
      final archived = File('${candidate.path}.bak-$timestamp');
      await candidate.rename(archived.path);
    }
  }

  Future<List<CatalogResource>> listResources({
    ResourceType? type,
    String query = '',
    ResourceCategory category = ResourceCategory.all,
    String tag = '',
    bool favoritesOnly = false,
    bool importedOnly = false,
    bool featuredOnly = false,
    int? limit,
  }) async {
    final sql = StringBuffer('''
      SELECT r.*, CASE WHEN f.resource_id IS NULL THEN 0 ELSE 1 END AS is_favorite
      FROM catalog_resources r
      LEFT JOIN favorite_resources f ON f.resource_id = r.id
    ''');

    final conditions = <String>[];
    final variables = <Variable<Object>>[];
    if (type != null) {
      conditions.add('r.type = ?');
      variables.add(Variable.withString(type.name));
    }
    if (category != ResourceCategory.all) {
      conditions.add('r.primary_category = ?');
      variables.add(Variable.withString(category.storageKey));
    }
    final trimmedTag = tag.trim().toLowerCase();
    if (trimmedTag.isNotEmpty) {
      conditions.add('lower(r.tags_json) LIKE ?');
      variables.add(Variable.withString('%$trimmedTag%'));
    }
    if (favoritesOnly) {
      conditions.add('f.resource_id IS NOT NULL');
    }
    if (importedOnly) {
      conditions.add("r.source = 'imported'");
    }
    if (featuredOnly) {
      conditions.add('r.is_featured = 1');
    }

    final trimmedQuery = query.trim().toLowerCase();
    if (trimmedQuery.isNotEmpty) {
      final pattern = '%$trimmedQuery%';
      conditions.add('''
        (
          lower(r.title) LIKE ? OR
          lower(r.summary) LIKE ? OR
          lower(r.scenario) LIKE ? OR
          lower(r.tags_json) LIKE ?
        )
      ''');
      variables.addAll([
        Variable.withString(pattern),
        Variable.withString(pattern),
        Variable.withString(pattern),
        Variable.withString(pattern),
      ]);
    }

    if (conditions.isNotEmpty) {
      sql.write(' WHERE ${conditions.join(' AND ')}');
    }

    sql.write(
      ' ORDER BY CASE WHEN r.is_featured = 1 THEN 0 ELSE 1 END, r.updated_at DESC, r.title COLLATE NOCASE ASC',
    );
    if (limit != null) {
      sql.write(' LIMIT $limit');
    }

    final rows = await customSelect(sql.toString(), variables: variables).get();
    return rows.map(_mapCatalogResource).toList();
  }

  Future<List<ResourceCollection>> listCollections() async {
    final rows = await customSelect('''
      SELECT c.*, COUNT(i.resource_id) AS resource_count
      FROM resource_collections c
      LEFT JOIN resource_collection_items i ON i.collection_id = c.id
      GROUP BY c.id
      ORDER BY c.sort_order ASC
    ''').get();
    return rows.map(_mapCollection).toList();
  }

  Future<List<ResourceCategory>> listAvailableCategories({
    required ResourceType type,
    bool favoritesOnly = false,
    bool importedOnly = false,
  }) async {
    final resources = await listResources(
      type: type,
      favoritesOnly: favoritesOnly,
      importedOnly: importedOnly,
    );
    final seen = <ResourceCategory>{};
    final categories = <ResourceCategory>[ResourceCategory.all];
    for (final category in ResourceCategory.values) {
      if (category == ResourceCategory.all) {
        continue;
      }
      if (resources.any((resource) => resource.primaryCategory == category) &&
          seen.add(category)) {
        categories.add(category);
      }
    }
    return categories;
  }

  Future<List<String>> listTopTags({
    required ResourceType type,
    ResourceCategory category = ResourceCategory.all,
    bool favoritesOnly = false,
    bool importedOnly = false,
    int limit = 8,
  }) async {
    final resources = await listResources(
      type: type,
      category: category,
      favoritesOnly: favoritesOnly,
      importedOnly: importedOnly,
    );
    final counts = <String, int>{};
    for (final resource in resources) {
      for (final tag in resource.tags) {
        final trimmed = tag.trim();
        if (trimmed.isEmpty) {
          continue;
        }
        counts.update(trimmed, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    final sorted = counts.entries.toList()
      ..sort((left, right) {
        final byCount = right.value.compareTo(left.value);
        if (byCount != 0) {
          return byCount;
        }
        return left.key.compareTo(right.key);
      });
    return sorted.take(limit).map((entry) => entry.key).toList();
  }

  Future<CollectionDetail?> getCollectionDetail(String collectionId) async {
    final collectionRows = await customSelect(
      '''
      SELECT c.*, COUNT(i.resource_id) AS resource_count
      FROM resource_collections c
      LEFT JOIN resource_collection_items i ON i.collection_id = c.id
      WHERE c.id = ?
      GROUP BY c.id
      LIMIT 1
      ''',
      variables: [Variable.withString(collectionId)],
    ).get();
    if (collectionRows.isEmpty) {
      return null;
    }

    final resourceRows = await customSelect(
      '''
      SELECT r.*, CASE WHEN f.resource_id IS NULL THEN 0 ELSE 1 END AS is_favorite
      FROM resource_collection_items i
      INNER JOIN catalog_resources r ON r.id = i.resource_id
      LEFT JOIN favorite_resources f ON f.resource_id = r.id
      WHERE i.collection_id = ?
      ORDER BY i.sort_order ASC
      ''',
      variables: [Variable.withString(collectionId)],
    ).get();

    return CollectionDetail(
      collection: _mapCollection(collectionRows.first),
      resources: resourceRows.map(_mapCatalogResource).toList(),
    );
  }

  Future<PromptResourceDetail?> getPromptDetail(String resourceId) async {
    final rows = await customSelect(
      '''
      SELECT r.*, CASE WHEN f.resource_id IS NULL THEN 0 ELSE 1 END AS is_favorite, d.*
      FROM catalog_resources r
      LEFT JOIN favorite_resources f ON f.resource_id = r.id
      INNER JOIN prompt_resource_details d ON d.resource_id = r.id
      WHERE r.id = ?
      LIMIT 1
      ''',
      variables: [Variable.withString(resourceId)],
    ).get();
    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;
    return PromptResourceDetail(
      resource: _mapCatalogResource(row),
      templateBody: row.read<String>('template_body'),
      variables: _decodePromptVariables(row.read<String>('variables_json')),
      whenToUse: row.read<String>('when_to_use'),
      avoidWhen: row.read<String>('avoid_when'),
      exampleInput: row.read<String>('example_input'),
      exampleOutput: row.read<String>('example_output'),
      supportedModels: _decodeStringList(
        row.read<String>('supported_models_json'),
      ),
    );
  }

  Future<SkillResourceDetail?> getSkillDetail(String resourceId) async {
    final rows = await customSelect(
      '''
      SELECT r.*, CASE WHEN f.resource_id IS NULL THEN 0 ELSE 1 END AS is_favorite, d.*
      FROM catalog_resources r
      LEFT JOIN favorite_resources f ON f.resource_id = r.id
      INNER JOIN skill_resource_details d ON d.resource_id = r.id
      WHERE r.id = ?
      LIMIT 1
      ''',
      variables: [Variable.withString(resourceId)],
    ).get();
    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;
    return SkillResourceDetail(
      resource: _mapCatalogResource(row),
      capabilitySummary: row.read<String>('capability_summary'),
      inputRequirements: _decodeStringList(
        row.read<String>('input_requirements_json'),
      ),
      usageSteps: _decodeStringList(row.read<String>('usage_steps_json')),
      supportedModels: _decodeStringList(
        row.read<String>('supported_models_json'),
      ),
      copyPayload: row.read<String>('copy_payload'),
      rawSchema: Map<String, dynamic>.from(
        jsonDecode(row.read<String>('raw_schema_json')) as Map,
      ),
      providerAdapters: Map<String, dynamic>.from(
        jsonDecode(row.read<String>('provider_adapters_json')) as Map,
      ),
      exampleCode: row.read<String>('example_code'),
      exampleLanguage: row.read<String>('example_language'),
    );
  }

  Future<McpResourceDetail?> getMcpDetail(String resourceId) async {
    final rows = await customSelect(
      '''
      SELECT r.*, CASE WHEN f.resource_id IS NULL THEN 0 ELSE 1 END AS is_favorite, d.*
      FROM catalog_resources r
      LEFT JOIN favorite_resources f ON f.resource_id = r.id
      INNER JOIN mcp_resource_details d ON d.resource_id = r.id
      WHERE r.id = ?
      LIMIT 1
      ''',
      variables: [Variable.withString(resourceId)],
    ).get();
    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;
    return McpResourceDetail(
      resource: _mapCatalogResource(row),
      capabilitiesSummary: row.read<String>('capabilities_summary'),
      supportedClients: _decodeStringList(
        row.read<String>('supported_clients_json'),
      ),
      requiredEnvVars: _decodeStringList(
        row.read<String>('required_env_vars_json'),
      ),
      setupSteps: _decodeStringList(row.read<String>('setup_steps_json')),
      configTemplate: row.read<String>('config_template'),
      safetyNotes: row.read<String>('safety_notes'),
      transport: row.read<String>('transport'),
      baseUrl: row.read<String>('base_url'),
    );
  }

  Future<MyLibrarySnapshot> getMyLibrarySnapshot() async {
    final favorites = await listResources(favoritesOnly: true);
    final imported = await listResources(importedOnly: true);
    return MyLibrarySnapshot(favorites: favorites, importedResources: imported);
  }

  Future<int> countImportedResources() async {
    final row = await customSelect(
      'SELECT COUNT(1) AS count FROM imported_resources',
    ).getSingle();
    return row.read<int>('count');
  }

  Future<int> countOfficialResources() async {
    return _countOfficialResources();
  }

  Future<CatalogSyncState> getCatalogSyncState() async {
    final state = await _readCatalogSyncStateOrNull();
    if (state != null) {
      return state;
    }
    final seed = buildOfficialCatalogSeed();
    return CatalogSyncState(
      version: seed.version,
      source: 'seed',
      lastSyncedAt: parseDateTime(seed.generatedAt),
    );
  }

  Future<String?> getCatalogVersion() async {
    final state = await _readCatalogSyncStateOrNull();
    return state?.version;
  }

  Future<void> replaceOfficialCatalog(
    OfficialCatalogSeed catalog, {
    required String source,
  }) async {
    await transaction(() async {
      await customStatement('DELETE FROM resource_collection_items');
      await customStatement('DELETE FROM resource_collections');
      await customStatement(
        "DELETE FROM prompt_resource_details WHERE resource_id IN (SELECT id FROM catalog_resources WHERE source = 'official')",
      );
      await customStatement(
        "DELETE FROM skill_resource_details WHERE resource_id IN (SELECT id FROM catalog_resources WHERE source = 'official')",
      );
      await customStatement(
        "DELETE FROM mcp_resource_details WHERE resource_id IN (SELECT id FROM catalog_resources WHERE source = 'official')",
      );
      await customStatement(
        "DELETE FROM catalog_resources WHERE source = 'official'",
      );

      for (final resource in catalog.resources) {
        await customStatement(
          '''
          INSERT INTO catalog_resources (
            id, type, source, title, summary, scenario, primary_category,
            difficulty, tags_json, primary_action_label, is_featured,
            created_at, updated_at
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          ''',
          [
            resource.id,
            resource.type.name,
            ResourceSource.official.name,
            resource.title,
            resource.summary,
            resource.scenario,
            resource.primaryCategory.storageKey,
            resource.difficulty.name,
            encodeJson(resource.tags),
            resource.primaryActionLabel,
            resource.isFeatured ? 1 : 0,
            resource.createdAt,
            resource.updatedAt,
          ],
        );
      }

      for (final detail in catalog.promptDetails) {
        await customStatement(
          '''
          INSERT INTO prompt_resource_details (
            resource_id, template_body, variables_json, when_to_use, avoid_when,
            example_input, example_output, supported_models_json
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
          ''',
          [
            detail.resourceId,
            detail.templateBody,
            encodeJson(detail.variables.map((value) => value.toMap()).toList()),
            detail.whenToUse,
            detail.avoidWhen,
            detail.exampleInput,
            detail.exampleOutput,
            encodeJson(detail.supportedModels),
          ],
        );
      }

      for (final detail in catalog.skillDetails) {
        await customStatement(
          '''
          INSERT INTO skill_resource_details (
            resource_id, capability_summary, input_requirements_json, usage_steps_json,
            supported_models_json, copy_payload, raw_schema_json,
            provider_adapters_json, example_code, example_language
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          ''',
          [
            detail.resourceId,
            detail.capabilitySummary,
            encodeJson(detail.inputRequirements),
            encodeJson(detail.usageSteps),
            encodeJson(detail.supportedModels),
            detail.copyPayload,
            encodeJson(detail.rawSchema),
            encodeJson(detail.providerAdapters),
            detail.exampleCode,
            detail.exampleLanguage,
          ],
        );
      }

      for (final detail in catalog.mcpDetails) {
        await customStatement(
          '''
          INSERT INTO mcp_resource_details (
            resource_id, capabilities_summary, supported_clients_json,
            required_env_vars_json, setup_steps_json, config_template,
            safety_notes, transport, base_url
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
          ''',
          [
            detail.resourceId,
            detail.capabilitiesSummary,
            encodeJson(detail.supportedClients),
            encodeJson(detail.requiredEnvVars),
            encodeJson(detail.setupSteps),
            detail.configTemplate,
            detail.safetyNotes,
            detail.transport,
            detail.baseUrl,
          ],
        );
      }

      for (final collection in catalog.collections) {
        await customStatement(
          '''
          INSERT INTO resource_collections (
            id, title, subtitle, description, icon_key, sort_order
          ) VALUES (?, ?, ?, ?, ?, ?)
          ''',
          [
            collection.id,
            collection.title,
            collection.subtitle,
            collection.description,
            collection.iconKey,
            collection.sortOrder,
          ],
        );
      }

      for (final item in catalog.collectionItems) {
        await customStatement(
          '''
          INSERT INTO resource_collection_items (
            collection_id, resource_id, sort_order
          ) VALUES (?, ?, ?)
          ''',
          [item.collectionId, item.resourceId, item.sortOrder],
        );
      }

      await _upsertCatalogSyncState(
        version: catalog.version,
        source: source,
        syncedAt: parseDateTime(catalog.generatedAt).toUtc(),
      );
    });
  }

  Future<void> toggleFavorite(String resourceId) async {
    final existsRow = await customSelect(
      'SELECT COUNT(1) AS count FROM favorite_resources WHERE resource_id = ?',
      variables: [Variable.withString(resourceId)],
    ).getSingle();
    final now = DateTime.now().toUtc().toIso8601String();

    if (existsRow.read<int>('count') > 0) {
      await customStatement(
        'DELETE FROM favorite_resources WHERE resource_id = ?',
        [resourceId],
      );
      return;
    }

    await customStatement(
      'INSERT INTO favorite_resources (resource_id, created_at) VALUES (?, ?)',
      [resourceId, now],
    );
  }

  Future<String> importResource(ImportResourceDraft draft) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final id =
        '${draft.type.name}-imported-${DateTime.now().millisecondsSinceEpoch}';
    final tags = draft.tags.where((value) => value.trim().isNotEmpty).toList();

    await customStatement(
      '''
      INSERT INTO catalog_resources (
        id, type, source, title, summary, scenario, primary_category,
        difficulty, tags_json, primary_action_label, is_featured, created_at,
        updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        id,
        draft.type.name,
        ResourceSource.imported.name,
        draft.title,
        draft.summary,
        draft.scenario,
        draft.primaryCategory.storageKey,
        ResourceDifficulty.beginner.name,
        encodeJson(tags),
        _primaryActionForType(draft.type),
        0,
        now,
        now,
      ],
    );
    await customStatement(
      'INSERT INTO imported_resources (resource_id, created_at) VALUES (?, ?)',
      [id, now],
    );

    switch (draft.type) {
      case ResourceType.prompt:
        final variables = _extractPromptVariables(draft.primaryContent);
        await customStatement(
          '''
          INSERT INTO prompt_resource_details (
            resource_id, template_body, variables_json, when_to_use, avoid_when,
            example_input, example_output, supported_models_json
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
          ''',
          [
            id,
            draft.primaryContent,
            encodeJson(variables.map((value) => value.toMap()).toList()),
            draft.secondaryContent.isEmpty
                ? draft.summary
                : draft.secondaryContent,
            draft.tertiaryContent.isEmpty
                ? '请先按你的真实场景微调后再使用。'
                : draft.tertiaryContent,
            draft.listA.isNotEmpty ? draft.listA.first : '导入后可继续补充示例输入',
            draft.listA.length > 1 ? draft.listA[1] : '导入后可继续补充示例输出',
            encodeJson(const ['ChatGPT', 'Claude', 'Gemini']),
          ],
        );
      case ResourceType.skill:
        await customStatement(
          '''
          INSERT INTO skill_resource_details (
            resource_id, capability_summary, input_requirements_json, usage_steps_json,
            supported_models_json, copy_payload, raw_schema_json,
            provider_adapters_json, example_code, example_language
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          ''',
          [
            id,
            draft.secondaryContent.isEmpty
                ? draft.summary
                : draft.secondaryContent,
            encodeJson(draft.listA),
            encodeJson(draft.listB),
            encodeJson(const ['ChatGPT', 'Claude', 'Gemini']),
            draft.tertiaryContent.isEmpty
                ? draft.primaryContent
                : draft.tertiaryContent,
            encodeJson(_defaultSkillSchema(draft.title)),
            encodeJson(const {
              'openai': true,
              'anthropic': true,
              'gemini': true,
            }),
            draft.primaryContent,
            'text',
          ],
        );
      case ResourceType.mcp:
        await customStatement(
          '''
          INSERT INTO mcp_resource_details (
            resource_id, capabilities_summary, supported_clients_json,
            required_env_vars_json, setup_steps_json, config_template,
            safety_notes, transport, base_url
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
          ''',
          [
            id,
            draft.primaryContent.isEmpty ? draft.summary : draft.primaryContent,
            encodeJson(draft.listA),
            encodeJson(_extractEnvVars(draft.secondaryContent)),
            encodeJson(draft.listB),
            draft.secondaryContent,
            draft.tertiaryContent.isEmpty
                ? '请先在测试环境验证，再接入正式客户端。'
                : draft.tertiaryContent,
            'streamable_http',
            'https://custom.mcp.local/${draft.title.toLowerCase().replaceAll(' ', '-')}',
          ],
        );
    }

    return id;
  }

  Future<void> _ensureCatalogResourceColumns() async {
    if (!await _columnExists('catalog_resources', 'primary_category')) {
      await customStatement(
        "ALTER TABLE catalog_resources ADD COLUMN primary_category TEXT NOT NULL DEFAULT 'other'",
      );
    }
  }

  Future<bool> _columnExists(String table, String column) async {
    final rows = await customSelect('PRAGMA table_info($table)').get();
    return rows.any((row) => row.read<String>('name') == column);
  }

  Future<void> _backfillPrimaryCategories() async {
    final rows = await customSelect('''
      SELECT id, scenario, tags_json
      FROM catalog_resources
      WHERE primary_category IS NULL OR trim(primary_category) = ''
      ''').get();
    for (final row in rows) {
      final category = inferResourceCategory(
        scenario: row.read<String>('scenario'),
        tags: _decodeStringList(row.read<String>('tags_json')),
      );
      await customStatement(
        'UPDATE catalog_resources SET primary_category = ? WHERE id = ?',
        [category.storageKey, row.read<String>('id')],
      );
    }
  }

  Future<int> _countOfficialResources() async {
    final row = await customSelect(
      "SELECT COUNT(1) AS count FROM catalog_resources WHERE source = 'official'",
    ).getSingle();
    return row.read<int>('count');
  }

  Future<CatalogSyncState?> _readCatalogSyncStateOrNull() async {
    final rows = await customSelect('''
      SELECT version, source, last_synced_at
      FROM catalog_sync_state
      WHERE singleton_id = 1
      LIMIT 1
      ''').get();
    if (rows.isEmpty) {
      return null;
    }
    final row = rows.first;
    return CatalogSyncState(
      version: row.read<String>('version'),
      source: row.read<String>('source'),
      lastSyncedAt: parseDateTime(row.read<String>('last_synced_at')),
    );
  }

  Future<void> _upsertCatalogSyncState({
    required String version,
    required String source,
    required DateTime syncedAt,
  }) async {
    await customStatement(
      '''
      INSERT INTO catalog_sync_state (
        singleton_id, version, source, last_synced_at
      ) VALUES (1, ?, ?, ?)
      ON CONFLICT(singleton_id) DO UPDATE SET
        version = excluded.version,
        source = excluded.source,
        last_synced_at = excluded.last_synced_at
      ''',
      [version, source, syncedAt.toIso8601String()],
    );
  }

  CatalogResource _mapCatalogResource(QueryRow row) {
    return CatalogResource(
      id: row.read<String>('id'),
      type: resourceTypeFromString(row.read<String>('type')),
      source: resourceSourceFromString(row.read<String>('source')),
      title: row.read<String>('title'),
      summary: row.read<String>('summary'),
      scenario: row.read<String>('scenario'),
      primaryCategory: resourceCategoryFromString(
        row.read<String>('primary_category'),
      ),
      difficulty: resourceDifficultyFromString(row.read<String>('difficulty')),
      tags: _decodeStringList(row.read<String>('tags_json')),
      primaryActionLabel: row.read<String>('primary_action_label'),
      isFeatured: row.read<int>('is_featured') == 1,
      isFavorite: row.read<int>('is_favorite') == 1,
      createdAt: parseDateTime(row.read<String>('created_at')),
      updatedAt: parseDateTime(row.read<String>('updated_at')),
    );
  }

  ResourceCollection _mapCollection(QueryRow row) {
    return ResourceCollection(
      id: row.read<String>('id'),
      title: row.read<String>('title'),
      subtitle: row.read<String>('subtitle'),
      description: row.read<String>('description'),
      iconKey: row.read<String>('icon_key'),
      resourceCount: row.read<int>('resource_count'),
    );
  }

  List<String> _decodeStringList(String rawJson) {
    return (jsonDecode(rawJson) as List<dynamic>)
        .map((value) => value.toString())
        .toList();
  }

  List<PromptVariable> _decodePromptVariables(String rawJson) {
    return (jsonDecode(rawJson) as List<dynamic>)
        .map(
          (value) =>
              PromptVariable.fromMap(Map<String, dynamic>.from(value as Map)),
        )
        .toList();
  }

  List<PromptVariable> _extractPromptVariables(String templateBody) {
    final matches = RegExp(r'{{\s*([^}]+)\s*}}').allMatches(templateBody);
    final seen = <String>{};
    final values = <PromptVariable>[];
    for (final match in matches) {
      final name = (match.group(1) ?? '').trim();
      if (name.isEmpty || !seen.add(name)) {
        continue;
      }
      values.add(
        PromptVariable(
          name: name,
          type: name.contains('代码')
              ? PromptVariableType.code
              : PromptVariableType.longText,
          description: '导入资源时自动识别到的变量',
        ),
      );
    }
    return values;
  }

  List<String> _extractEnvVars(String configTemplate) {
    final matches = RegExp(r'\$\{([A-Z0-9_]+)\}').allMatches(configTemplate);
    final seen = <String>{};
    return [
      for (final match in matches)
        if (seen.add(match.group(1) ?? '')) match.group(1) ?? '',
    ].where((value) => value.isNotEmpty).toList();
  }

  Map<String, dynamic> _defaultSkillSchema(String title) {
    return {
      'type': 'object',
      'properties': {
        'title': {'type': 'string', 'description': '$title 的标题'},
        'content': {'type': 'string', 'description': '$title 的输入内容'},
      },
      'required': ['content'],
    };
  }

  String _primaryActionForType(ResourceType type) {
    return switch (type) {
      ResourceType.prompt => '填写变量后复制',
      ResourceType.skill => '复制技能内容',
      ResourceType.mcp => '复制配置模板',
    };
  }
}
