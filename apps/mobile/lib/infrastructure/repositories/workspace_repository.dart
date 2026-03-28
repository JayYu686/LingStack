import '../../domain/models.dart';
import '../database/app_database.dart';
import '../network/sync_api_client.dart';

class WorkspaceRepository {
  const WorkspaceRepository(this._database);

  final AppDatabase _database;

  Future<HomeSnapshot> loadHomeSnapshot({String query = ''}) async {
    final trimmedQuery = query.trim();
    final featuredCollectionsFuture = _database.listCollections();
    final beginnerResourcesFuture = _database.getCollectionDetail(
      'starter-pack',
    );
    final featuredResourcesFuture = _database.listResources(
      featuredOnly: true,
      limit: 9,
    );
    final promptsFuture = _database.listResources(
      type: ResourceType.prompt,
      limit: 8,
    );
    final skillsFuture = _database.listResources(
      type: ResourceType.skill,
      limit: 8,
    );
    final mcpsFuture = _database.listResources(
      type: ResourceType.mcp,
      limit: 8,
    );
    final favoritePreviewFuture = _database.listResources(
      favoritesOnly: true,
      limit: 4,
    );
    final importedCountFuture = _database.countImportedResources();
    final catalogSyncStateFuture = _database.getCatalogSyncState();
    final officialResourceCountFuture = _database.countOfficialResources();
    final searchResultsFuture = trimmedQuery.isEmpty
        ? Future.value(const <CatalogResource>[])
        : _database.listResources(query: trimmedQuery, limit: 16);

    final featuredCollections = await featuredCollectionsFuture;
    final beginnerResources = await beginnerResourcesFuture;
    final featuredResources = await featuredResourcesFuture;
    final prompts = await promptsFuture;
    final skills = await skillsFuture;
    final mcps = await mcpsFuture;
    final favoritePreview = await favoritePreviewFuture;
    final importedCount = await importedCountFuture;
    final catalogSyncState = await catalogSyncStateFuture;
    final officialResourceCount = await officialResourceCountFuture;
    final searchResults = await searchResultsFuture;

    return HomeSnapshot(
      query: query,
      searchResults: searchResults,
      featuredCollections: featuredCollections,
      beginnerResources: beginnerResources?.resources ?? const [],
      featuredResources: featuredResources,
      prompts: prompts,
      skills: skills,
      mcps: mcps,
      favoritePreview: favoritePreview,
      importedCount: importedCount,
      catalogSyncState: catalogSyncState,
      officialResourceCount: officialResourceCount,
      collectionCount: featuredCollections.length,
    );
  }

  Future<List<CatalogResource>> loadResourceFeed(ResourceBrowseFilter filter) {
    return _database.listResources(
      type: filter.type,
      query: filter.query,
      category: filter.category,
      tag: filter.tag,
      favoritesOnly: filter.favoritesOnly,
      importedOnly: filter.importedOnly,
    );
  }

  Future<ResourceBrowseSnapshot> loadResourceBrowseSnapshot(
    ResourceBrowseFilter filter,
  ) async {
    final resourcesFuture = _database.listResources(
      type: filter.type,
      query: filter.query,
      category: filter.category,
      tag: filter.tag,
      favoritesOnly: filter.favoritesOnly,
      importedOnly: filter.importedOnly,
    );
    final availableCategoriesFuture = _database.listAvailableCategories(
      type: filter.type,
      favoritesOnly: filter.favoritesOnly,
      importedOnly: filter.importedOnly,
    );
    final availableTagsFuture = _database.listTopTags(
      type: filter.type,
      category: filter.category,
      favoritesOnly: filter.favoritesOnly,
      importedOnly: filter.importedOnly,
    );

    final resources = await resourcesFuture;
    final availableCategories = await availableCategoriesFuture;
    final availableTags = await availableTagsFuture;

    return ResourceBrowseSnapshot(
      resources: resources,
      availableCategories: availableCategories,
      availableTags: availableTags,
    );
  }

  Future<CollectionDetail?> loadCollectionDetail(String collectionId) {
    return _database.getCollectionDetail(collectionId);
  }

  Future<PromptResourceDetail?> loadPromptDetail(String resourceId) {
    return _database.getPromptDetail(resourceId);
  }

  Future<SkillResourceDetail?> loadSkillDetail(String resourceId) {
    return _database.getSkillDetail(resourceId);
  }

  Future<McpResourceDetail?> loadMcpDetail(String resourceId) {
    return _database.getMcpDetail(resourceId);
  }

  Future<MyLibrarySnapshot> loadMyLibrary() {
    return _database.getMyLibrarySnapshot();
  }

  Future<void> toggleFavorite(String resourceId) {
    return _database.toggleFavorite(resourceId);
  }

  Future<String> importResource(ImportResourceDraft draft) {
    return _database.importResource(draft);
  }

  Future<bool> refreshOfficialCatalog(SyncApiClient client) async {
    final localState = await _database.getCatalogSyncState();
    final remoteCatalog = await client.fetchCatalogBootstrap();
    if (!remoteCatalog.hasUsableContent) {
      return false;
    }
    if (remoteCatalog.version == localState.version && localState.isRemote) {
      return false;
    }
    await _database.replaceOfficialCatalog(remoteCatalog, source: 'remote');
    return true;
  }

  Future<CatalogSyncState> loadCatalogSyncState() {
    return _database.getCatalogSyncState();
  }
}
