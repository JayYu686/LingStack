import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/collections/presentation/collection_detail_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/library/presentation/import_resource_screen.dart';
import '../features/mcp/presentation/mcp_server_detail_screen.dart';
import '../features/prompts/presentation/prompt_detail_screen.dart';
import '../features/skills/presentation/skill_detail_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'collection/:id',
            builder: (context, state) => CollectionDetailScreen(
              collectionId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'prompt/:id',
            builder: (context, state) =>
                PromptDetailScreen(resourceId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'skill/:id',
            builder: (context, state) =>
                SkillDetailScreen(resourceId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'mcp/:id',
            builder: (context, state) =>
                McpServerDetailScreen(resourceId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'import',
            builder: (context, state) => const ImportResourceScreen(),
          ),
        ],
      ),
    ],
  );
});
