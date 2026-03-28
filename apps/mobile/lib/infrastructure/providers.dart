import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/models.dart';
import 'database/app_database.dart';
import 'network/sync_api_client.dart';
import 'repositories/workspace_repository.dart';
import 'security/secure_secret_store.dart';

final appDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  return AppDatabase.open();
});

final workspaceRepositoryProvider = FutureProvider<WorkspaceRepository>((
  ref,
) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return WorkspaceRepository(database);
});

final syncApiClientProvider = Provider<SyncApiClient>((ref) => SyncApiClient());

final secureSecretStoreProvider = Provider<SecureSecretStore>(
  (ref) => const SecureSecretStore(FlutterSecureStorage()),
);

final catalogRefreshTickProvider =
    NotifierProvider<CatalogRefreshTickNotifier, int>(
      CatalogRefreshTickNotifier.new,
    );

class CatalogRefreshTickNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() {
    state++;
  }
}

final homeSnapshotProvider = FutureProvider.family<HomeSnapshot, String>((
  ref,
  query,
) async {
  ref.watch(catalogRefreshTickProvider);
  final repository = await ref.watch(workspaceRepositoryProvider.future);
  return repository.loadHomeSnapshot(query: query);
});

final resourceFeedProvider =
    FutureProvider.family<List<CatalogResource>, ResourceBrowseFilter>((
      ref,
      filter,
    ) async {
      ref.watch(catalogRefreshTickProvider);
      final repository = await ref.watch(workspaceRepositoryProvider.future);
      return repository.loadResourceFeed(filter);
    });

final collectionDetailProvider =
    FutureProvider.family<CollectionDetail?, String>((ref, collectionId) async {
      ref.watch(catalogRefreshTickProvider);
      final repository = await ref.watch(workspaceRepositoryProvider.future);
      return repository.loadCollectionDetail(collectionId);
    });

final promptDetailProvider =
    FutureProvider.family<PromptResourceDetail?, String>((
      ref,
      resourceId,
    ) async {
      ref.watch(catalogRefreshTickProvider);
      final repository = await ref.watch(workspaceRepositoryProvider.future);
      return repository.loadPromptDetail(resourceId);
    });

final skillDetailProvider = FutureProvider.family<SkillResourceDetail?, String>(
  (ref, resourceId) async {
    ref.watch(catalogRefreshTickProvider);
    final repository = await ref.watch(workspaceRepositoryProvider.future);
    return repository.loadSkillDetail(resourceId);
  },
);

final mcpDetailProvider = FutureProvider.family<McpResourceDetail?, String>((
  ref,
  resourceId,
) async {
  ref.watch(catalogRefreshTickProvider);
  final repository = await ref.watch(workspaceRepositoryProvider.future);
  return repository.loadMcpDetail(resourceId);
});

final myLibraryProvider = FutureProvider<MyLibrarySnapshot>((ref) async {
  ref.watch(catalogRefreshTickProvider);
  final repository = await ref.watch(workspaceRepositoryProvider.future);
  return repository.loadMyLibrary();
});

final catalogRemoteSyncProvider = FutureProvider<void>((ref) async {
  final repository = await ref.watch(workspaceRepositoryProvider.future);
  final client = ref.watch(syncApiClientProvider);
  try {
    final changed = await repository.refreshOfficialCatalog(client);
    if (changed) {
      ref.read(catalogRefreshTickProvider.notifier).bump();
    }
  } catch (_) {
    // Official catalog falls back to local cache when the sync service is absent.
  }
});
