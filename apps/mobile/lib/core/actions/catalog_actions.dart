import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models.dart';
import '../../infrastructure/providers.dart';

Future<void> toggleFavoriteAction(
  BuildContext context,
  WidgetRef ref,
  String resourceId,
) async {
  final repository = await ref.read(workspaceRepositoryProvider.future);
  await repository.toggleFavorite(resourceId);
  ref.read(catalogRefreshTickProvider.notifier).bump();
  if (!context.mounted) {
    return;
  }
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('收藏状态已更新')));
}

Future<void> copyTextAction(
  BuildContext context,
  String text, {
  required String successMessage,
}) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) {
    return;
  }
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(successMessage)));
}

Future<void> invalidateCatalog(WidgetRef ref) async {
  ref.read(catalogRefreshTickProvider.notifier).bump();
  await ref.read(catalogRemoteSyncProvider.future);
  ref.read(catalogRefreshTickProvider.notifier).bump();
}

void openCatalogResource(BuildContext context, CatalogResource resource) {
  switch (resource.type) {
    case ResourceType.prompt:
      context.go('/prompt/${resource.id}');
    case ResourceType.skill:
      context.go('/skill/${resource.id}');
    case ResourceType.mcp:
      context.go('/mcp/${resource.id}');
  }
}
