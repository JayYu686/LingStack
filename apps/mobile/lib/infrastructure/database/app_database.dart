import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

import '../../domain/models.dart';
import '../../domain/skill_editor_models.dart';
import '../../domain/skill_schema_codec.dart';
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
  int get schemaVersion => 6;

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
    await _ensurePromptDetailColumns();
    await _backfillPrimaryCategories();
    await _backfillResourceQuality();
    await _backfillPromptDetails();

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
      final hasOriginResourceID = columns.any(
        (row) => row['name'] == 'origin_resource_id',
      );
      if (!hasOriginResourceID) {
        database.execute(
          'ALTER TABLE catalog_resources ADD COLUMN origin_resource_id TEXT',
        );
      }
      final hasQualityTier = columns.any(
        (row) => row['name'] == 'quality_tier',
      );
      if (!hasQualityTier) {
        database.execute(
          "ALTER TABLE catalog_resources ADD COLUMN quality_tier TEXT NOT NULL DEFAULT 'community'",
        );
      }
      final hasQualityScore = columns.any(
        (row) => row['name'] == 'quality_score',
      );
      if (!hasQualityScore) {
        database.execute(
          'ALTER TABLE catalog_resources ADD COLUMN quality_score INTEGER NOT NULL DEFAULT 60',
        );
      }
      final hasQualityReasons = columns.any(
        (row) => row['name'] == 'quality_reasons_json',
      );
      if (!hasQualityReasons) {
        database.execute(
          "ALTER TABLE catalog_resources ADD COLUMN quality_reasons_json TEXT NOT NULL DEFAULT '[]'",
        );
      }
      final hasUseCases = columns.any((row) => row['name'] == 'use_cases_json');
      if (!hasUseCases) {
        database.execute(
          "ALTER TABLE catalog_resources ADD COLUMN use_cases_json TEXT NOT NULL DEFAULT '[]'",
        );
      }
      final hasAvoidCases = columns.any(
        (row) => row['name'] == 'avoid_cases_json',
      );
      if (!hasAvoidCases) {
        database.execute(
          "ALTER TABLE catalog_resources ADD COLUMN avoid_cases_json TEXT NOT NULL DEFAULT '[]'",
        );
      }
      final hasVerifiedAt = columns.any((row) => row['name'] == 'verified_at');
      if (!hasVerifiedAt) {
        database.execute(
          'ALTER TABLE catalog_resources ADD COLUMN verified_at TEXT',
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
    ResourceQualityTier? qualityTier,
    ResourceSortMode sortMode = ResourceSortMode.recommended,
    bool favoritesOnly = false,
    bool importedOnly = false,
    bool featuredOnly = false,
    int? limit,
  }) async {
    final sql = StringBuffer('''
      SELECT
        r.*,
        CASE WHEN f.resource_id IS NULL THEN 0 ELSE 1 END AS is_favorite,
        u.use_count AS prompt_use_count,
        u.last_used_at AS prompt_last_used_at
      FROM catalog_resources r
      LEFT JOIN favorite_resources f ON f.resource_id = r.id
      LEFT JOIN prompt_usage_records u ON u.resource_id = r.id
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
    if (qualityTier != null) {
      conditions.add('r.quality_tier = ?');
      variables.add(Variable.withString(qualityTier.storageKey));
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

    final orderBy = switch (sortMode) {
      ResourceSortMode.recommended =>
        'CASE WHEN r.is_featured = 1 THEN 0 ELSE 1 END, '
            'CASE r.quality_tier '
            "WHEN 'featured' THEN 0 "
            "WHEN 'verified' THEN 1 "
            "WHEN 'community' THEN 2 "
            'ELSE 3 END, '
            'r.quality_score DESC, r.updated_at DESC, r.title COLLATE NOCASE ASC',
      ResourceSortMode.easiestToUse =>
        'CASE r.difficulty '
            "WHEN 'beginner' THEN 0 "
            "WHEN 'intermediate' THEN 1 "
            'ELSE 2 END, '
            'r.quality_score DESC, r.updated_at DESC, r.title COLLATE NOCASE ASC',
      ResourceSortMode.recentlyUsed =>
        'CASE WHEN u.last_used_at IS NULL THEN 1 ELSE 0 END, '
            'u.last_used_at DESC, r.quality_score DESC, r.updated_at DESC',
    };
    sql.write(' ORDER BY $orderBy');
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
    ResourceQualityTier? qualityTier,
    bool favoritesOnly = false,
    bool importedOnly = false,
  }) async {
    final resources = await listResources(
      type: type,
      qualityTier: qualityTier,
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
    ResourceQualityTier? qualityTier,
    bool favoritesOnly = false,
    bool importedOnly = false,
    int limit = 8,
  }) async {
    final resources = await listResources(
      type: type,
      category: category,
      qualityTier: qualityTier,
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

  Future<List<ResourceQualityTier>> listAvailableQualityTiers({
    required ResourceType type,
    bool favoritesOnly = false,
    bool importedOnly = false,
  }) async {
    final resources = await listResources(
      type: type,
      favoritesOnly: favoritesOnly,
      importedOnly: importedOnly,
    );
    final seen = <ResourceQualityTier>{};
    final tiers = <ResourceQualityTier>[];
    for (final tier in ResourceQualityTier.values) {
      if (resources.any((resource) => resource.qualityTier == tier) &&
          seen.add(tier)) {
        tiers.add(tier);
      }
    }
    return tiers;
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
      helperNotes: _decodeStringList(row.read<String>('helper_notes_json')),
      requiredVariableNames: _decodeStringList(
        row.read<String>('required_variable_names_json'),
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

  Future<PromptUsageRecord?> loadPromptUsage(String resourceId) async {
    final rows = await customSelect(
      '''
      SELECT resource_id, last_values_json, copied_at, last_used_at, use_count
      FROM prompt_usage_records
      WHERE resource_id = ?
      LIMIT 1
      ''',
      variables: [Variable.withString(resourceId)],
    ).get();
    if (rows.isEmpty) {
      return null;
    }
    final row = rows.first;
    return PromptUsageRecord(
      resourceId: row.read<String>('resource_id'),
      lastValues: _decodeStringMap(row.read<String>('last_values_json')),
      copiedAt: parseDateTimeOrNull(row.readNullable<String>('copied_at')),
      lastUsedAt: parseDateTimeOrNull(row.readNullable<String>('last_used_at')),
      useCount: row.read<int>('use_count'),
    );
  }

  Future<void> savePromptUsage({
    required String resourceId,
    required Map<String, String> lastValues,
    bool markCopied = false,
  }) async {
    final existing = await loadPromptUsage(resourceId);
    final now = DateTime.now().toUtc().toIso8601String();
    final useCount = markCopied
        ? (existing?.useCount ?? 0) + 1
        : (existing?.useCount ?? 0);
    await customStatement(
      '''
      INSERT INTO prompt_usage_records (
        resource_id, last_values_json, copied_at, last_used_at, use_count
      ) VALUES (?, ?, ?, ?, ?)
      ON CONFLICT(resource_id) DO UPDATE SET
        last_values_json = excluded.last_values_json,
        copied_at = excluded.copied_at,
        last_used_at = excluded.last_used_at,
        use_count = excluded.use_count
      ''',
      [
        resourceId,
        encodeJson(lastValues),
        markCopied ? now : existing?.copiedAt?.toUtc().toIso8601String(),
        now,
        useCount,
      ],
    );
  }

  Future<List<CatalogResource>> listRecentlyUsedPrompts({int limit = 6}) {
    return listResources(
      type: ResourceType.prompt,
      sortMode: ResourceSortMode.recentlyUsed,
      limit: limit,
    );
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
            quality_tier, quality_score, quality_reasons_json, use_cases_json,
            avoid_cases_json, verified_at, origin_resource_id, created_at, updated_at
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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
            resource.qualityTier.storageKey,
            resource.qualityScore,
            encodeJson(resource.qualityReasons),
            encodeJson(resource.useCases),
            encodeJson(resource.avoidCases),
            resource.verifiedAt,
            null,
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
            example_input, example_output, supported_models_json,
            helper_notes_json, required_variable_names_json
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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
            encodeJson(detail.helperNotes),
            encodeJson(detail.requiredVariableNames),
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
        difficulty, tags_json, primary_action_label, is_featured,
        quality_tier, quality_score, quality_reasons_json, use_cases_json,
        avoid_cases_json, verified_at, origin_resource_id, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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
        ResourceQualityTier.community.storageKey,
        62,
        encodeJson(const ['本地导入资源，等待你继续打磨和验证。']),
        encodeJson(_defaultUseCasesForType(draft.type)),
        encodeJson(_defaultAvoidCasesForType(draft.type)),
        null,
        null,
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
            example_input, example_output, supported_models_json,
            helper_notes_json, required_variable_names_json
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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
            encodeJson(variables.map(_defaultPromptHelperNote).toList()),
            encodeJson(
              variables
                  .where((value) => value.defaultValue.trim().isEmpty)
                  .map((value) => value.name)
                  .toList(),
            ),
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

  Future<SkillEditorDraft?> getSkillEditorDraft(String resourceId) async {
    final detail = await getSkillDetail(resourceId);
    if (detail == null) {
      return null;
    }
    return buildSkillEditorDraftFromDetail(detail);
  }

  Future<String> duplicateOfficialSkill(String resourceId) async {
    final detail = await getSkillDetail(resourceId);
    if (detail == null) {
      throw StateError('Skill resource not found: $resourceId');
    }
    if (!detail.resource.isOfficial) {
      throw StateError('Only official skills can be duplicated');
    }

    final now = DateTime.now().toUtc().toIso8601String();
    final copiedId = 'skill-imported-${DateTime.now().millisecondsSinceEpoch}';

    await transaction(() async {
      await customStatement(
        '''
        INSERT INTO catalog_resources (
          id, type, source, title, summary, scenario, primary_category,
          difficulty, tags_json, primary_action_label, is_featured,
          quality_tier, quality_score, quality_reasons_json, use_cases_json,
          avoid_cases_json, verified_at, origin_resource_id, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          copiedId,
          ResourceType.skill.name,
          ResourceSource.imported.name,
          detail.resource.title,
          detail.resource.summary,
          detail.resource.scenario,
          detail.resource.primaryCategory.storageKey,
          detail.resource.difficulty.name,
          encodeJson(detail.resource.tags),
          _primaryActionForType(ResourceType.skill),
          0,
          detail.resource.qualityTier.storageKey,
          detail.resource.qualityScore,
          encodeJson(detail.resource.qualityReasons),
          encodeJson(detail.resource.useCases),
          encodeJson(detail.resource.avoidCases),
          detail.resource.verifiedAt?.toUtc().toIso8601String(),
          resourceId,
          now,
          now,
        ],
      );
      await customStatement(
        'INSERT INTO imported_resources (resource_id, created_at) VALUES (?, ?)',
        [copiedId, now],
      );
      await customStatement(
        '''
        INSERT INTO skill_resource_details (
          resource_id, capability_summary, input_requirements_json, usage_steps_json,
          supported_models_json, copy_payload, raw_schema_json,
          provider_adapters_json, example_code, example_language
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          copiedId,
          detail.capabilitySummary,
          encodeJson(detail.inputRequirements),
          encodeJson(detail.usageSteps),
          encodeJson(detail.supportedModels),
          detail.copyPayload,
          encodeJson(detail.rawSchema),
          encodeJson(buildProviderAdaptersForSchema(detail.rawSchema)),
          detail.exampleCode,
          detail.exampleLanguage,
        ],
      );
    });

    return copiedId;
  }

  Future<void> updateImportedSkill(SkillEditorDraft draft) async {
    final resourceRows = await customSelect(
      '''
      SELECT source, type
      FROM catalog_resources
      WHERE id = ?
      LIMIT 1
      ''',
      variables: [Variable.withString(draft.resourceId)],
    ).get();
    if (resourceRows.isEmpty) {
      throw StateError('Skill resource not found: ${draft.resourceId}');
    }
    final resourceRow = resourceRows.first;
    if (resourceRow.read<String>('source') != ResourceSource.imported.name ||
        resourceRow.read<String>('type') != ResourceType.skill.name) {
      throw StateError('Only imported skills can be updated');
    }

    final normalizedTags = draft.tags
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
    final normalizedInputs = draft.inputRequirements
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    final normalizedSteps = draft.usageSteps
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    final normalizedModels = draft.supportedModels
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
    final rawSchema = draft.advancedSchemaMode
        ? jsonDecode(normalizeSchemaJson(draft.advancedSchemaJson))
              as Map<String, dynamic>
        : buildSkillSchemaFromFields(draft.schemaFields);
    final providerAdapters = buildProviderAdaptersForSchema(rawSchema);
    final now = DateTime.now().toUtc().toIso8601String();

    await transaction(() async {
      await customStatement(
        '''
        UPDATE catalog_resources
        SET title = ?, summary = ?, scenario = ?, primary_category = ?,
            tags_json = ?, updated_at = ?
        WHERE id = ?
        ''',
        [
          draft.title.trim(),
          draft.summary.trim(),
          draft.scenario.trim(),
          draft.primaryCategory.storageKey,
          encodeJson(normalizedTags),
          now,
          draft.resourceId,
        ],
      );
      await customStatement(
        '''
        UPDATE skill_resource_details
        SET capability_summary = ?, input_requirements_json = ?, usage_steps_json = ?,
            supported_models_json = ?, copy_payload = ?, raw_schema_json = ?,
            provider_adapters_json = ?, example_code = ?, example_language = ?
        WHERE resource_id = ?
        ''',
        [
          draft.capabilitySummary.trim(),
          encodeJson(normalizedInputs),
          encodeJson(normalizedSteps),
          encodeJson(normalizedModels),
          draft.copyPayload,
          encodeJson(rawSchema),
          encodeJson(providerAdapters),
          draft.exampleCode,
          draft.exampleLanguage.trim().isEmpty
              ? 'json'
              : draft.exampleLanguage.trim(),
          draft.resourceId,
        ],
      );
    });
  }

  Future<void> _ensureCatalogResourceColumns() async {
    if (!await _columnExists('catalog_resources', 'primary_category')) {
      await customStatement(
        "ALTER TABLE catalog_resources ADD COLUMN primary_category TEXT NOT NULL DEFAULT 'other'",
      );
    }
    if (!await _columnExists('catalog_resources', 'origin_resource_id')) {
      await customStatement(
        'ALTER TABLE catalog_resources ADD COLUMN origin_resource_id TEXT',
      );
    }
    if (!await _columnExists('catalog_resources', 'quality_tier')) {
      await customStatement(
        "ALTER TABLE catalog_resources ADD COLUMN quality_tier TEXT NOT NULL DEFAULT 'community'",
      );
    }
    if (!await _columnExists('catalog_resources', 'quality_score')) {
      await customStatement(
        'ALTER TABLE catalog_resources ADD COLUMN quality_score INTEGER NOT NULL DEFAULT 60',
      );
    }
    if (!await _columnExists('catalog_resources', 'quality_reasons_json')) {
      await customStatement(
        "ALTER TABLE catalog_resources ADD COLUMN quality_reasons_json TEXT NOT NULL DEFAULT '[]'",
      );
    }
    if (!await _columnExists('catalog_resources', 'use_cases_json')) {
      await customStatement(
        "ALTER TABLE catalog_resources ADD COLUMN use_cases_json TEXT NOT NULL DEFAULT '[]'",
      );
    }
    if (!await _columnExists('catalog_resources', 'avoid_cases_json')) {
      await customStatement(
        "ALTER TABLE catalog_resources ADD COLUMN avoid_cases_json TEXT NOT NULL DEFAULT '[]'",
      );
    }
    if (!await _columnExists('catalog_resources', 'verified_at')) {
      await customStatement(
        'ALTER TABLE catalog_resources ADD COLUMN verified_at TEXT',
      );
    }
  }

  Future<void> _ensurePromptDetailColumns() async {
    if (!await _columnExists('prompt_resource_details', 'helper_notes_json')) {
      await customStatement(
        "ALTER TABLE prompt_resource_details ADD COLUMN helper_notes_json TEXT NOT NULL DEFAULT '[]'",
      );
    }
    if (!await _columnExists(
      'prompt_resource_details',
      'required_variable_names_json',
    )) {
      await customStatement(
        "ALTER TABLE prompt_resource_details ADD COLUMN required_variable_names_json TEXT NOT NULL DEFAULT '[]'",
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

  Future<void> _backfillResourceQuality() async {
    final rows = await customSelect('''
      SELECT id, is_featured, difficulty
      FROM catalog_resources
      WHERE trim(COALESCE(quality_tier, '')) = ''
         OR quality_score IS NULL
         OR trim(COALESCE(quality_reasons_json, '')) = ''
    ''').get();
    for (final row in rows) {
      final isFeatured = row.read<int>('is_featured') == 1;
      final difficulty = resourceDifficultyFromString(
        row.read<String>('difficulty'),
      );
      final tier = isFeatured
          ? ResourceQualityTier.featured
          : difficulty == ResourceDifficulty.beginner
          ? ResourceQualityTier.verified
          : ResourceQualityTier.community;
      final score = switch (tier) {
        ResourceQualityTier.featured => 90,
        ResourceQualityTier.verified => 80,
        ResourceQualityTier.community => 68,
        ResourceQualityTier.experimental => 52,
      };
      await customStatement(
        '''
        UPDATE catalog_resources
        SET quality_tier = ?, quality_score = ?, quality_reasons_json = ?,
            use_cases_json = ?, avoid_cases_json = ?, verified_at = COALESCE(verified_at, updated_at)
        WHERE id = ?
        ''',
        [
          tier.storageKey,
          score,
          encodeJson(const ['已完成本地目录结构化整理']),
          encodeJson(const ['适合先从当前任务入手筛选']),
          encodeJson(const ['不建议在目标不清晰时直接照搬']),
          row.read<String>('id'),
        ],
      );
    }
  }

  Future<void> _backfillPromptDetails() async {
    final rows = await customSelect('''
      SELECT resource_id, variables_json, helper_notes_json, required_variable_names_json
      FROM prompt_resource_details
    ''').get();
    for (final row in rows) {
      final variables = _decodePromptVariables(
        row.read<String>('variables_json'),
      );
      final helperNotes = row.read<String>('helper_notes_json');
      final requiredNames = row.read<String>('required_variable_names_json');
      final nextHelperNotes = helperNotes.trim().isEmpty || helperNotes == '[]'
          ? variables.map(_defaultPromptHelperNote).toList()
          : _decodeStringList(helperNotes);
      final nextRequired = requiredNames.trim().isEmpty || requiredNames == '[]'
          ? variables
                .where((variable) => variable.defaultValue.trim().isEmpty)
                .map((variable) => variable.name)
                .toList()
          : _decodeStringList(requiredNames);
      await customStatement(
        '''
        UPDATE prompt_resource_details
        SET helper_notes_json = ?, required_variable_names_json = ?
        WHERE resource_id = ?
        ''',
        [
          encodeJson(nextHelperNotes),
          encodeJson(nextRequired),
          row.read<String>('resource_id'),
        ],
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
      qualityTier: resourceQualityTierFromString(
        row.read<String>('quality_tier'),
      ),
      qualityScore: row.read<int>('quality_score'),
      qualityReasons: _decodeStringList(
        row.read<String>('quality_reasons_json'),
      ),
      useCases: _decodeStringList(row.read<String>('use_cases_json')),
      avoidCases: _decodeStringList(row.read<String>('avoid_cases_json')),
      verifiedAt: parseDateTimeOrNull(row.readNullable<String>('verified_at')),
      originResourceId: row.readNullable<String>('origin_resource_id'),
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

  Map<String, String> _decodeStringMap(String rawJson) {
    return (jsonDecode(rawJson) as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, value.toString()),
    );
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

  List<String> _defaultUseCasesForType(ResourceType type) {
    return switch (type) {
      ResourceType.prompt => const ['适合先做出第一版结果', '适合按任务快速复制使用'],
      ResourceType.skill => const ['适合沉淀重复任务方法', '适合后续同类任务直接复用'],
      ResourceType.mcp => const ['适合连接外部工具和数据', '适合给 AI 增加实时上下文'],
    };
  }

  List<String> _defaultAvoidCasesForType(ResourceType type) {
    return switch (type) {
      ResourceType.prompt => const ['不适合需求还没想清楚时直接套用'],
      ResourceType.skill => const ['不适合还没稳定下来的工作流'],
      ResourceType.mcp => const ['不适合还没有权限或网关时直接接入'],
    };
  }

  String _defaultPromptHelperNote(PromptVariable variable) {
    return switch (variable.type) {
      PromptVariableType.code => '代码变量建议直接粘贴原始代码。',
      PromptVariableType.enumeration => '枚举变量优先从给定选项里选，输出会更稳定。',
      PromptVariableType.booleanType => '布尔变量只需要开或关，不需要额外解释。',
      PromptVariableType.longText => '长文本变量尽量只保留必要上下文。',
      PromptVariableType.text => '文本变量尽量具体，少用模糊描述。',
    };
  }
}
