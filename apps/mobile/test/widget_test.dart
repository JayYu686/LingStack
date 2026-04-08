import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/domain/mcp_test_models.dart';
import 'package:mobile/features/home/presentation/home_screen.dart';
import 'package:mobile/features/mcp/presentation/mcp_server_detail_screen.dart';
import 'package:mobile/features/mcp/presentation/mcp_test_screen.dart';
import 'package:mobile/features/prompts/presentation/prompt_detail_screen.dart';
import 'package:mobile/features/skills/presentation/skill_detail_screen.dart';
import 'package:mobile/infrastructure/database/app_database.dart';
import 'package:mobile/infrastructure/network/sync_api_client.dart';
import 'package:mobile/infrastructure/providers.dart';
import 'package:mobile/infrastructure/security/secure_secret_store.dart';

void main() {
  Future<AppDatabase> setUpDatabase() async {
    final database = AppDatabase.memory();
    await database.bootstrap();
    addTearDown(database.close);
    return database;
  }

  Widget buildHarness(
    Widget child,
    AppDatabase database, {
    List overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWith((ref) async => database),
        ...overrides,
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: child,
        ),
      ),
    );
  }

  Future<void> pumpLoaded(
    WidgetTester tester,
    Widget child,
    AppDatabase database, {
    List overrides = const [],
  }) async {
    await tester.pumpWidget(
      buildHarness(child, database, overrides: overrides),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('首页会展示新的资源定位和质量入口', (tester) async {
    final database = await setUpDatabase();

    await pumpLoaded(tester, const HomeScreen(), database);

    expect(find.text('常用提示词、技能和工具配置，统一收在这里'), findsOneWidget);
    expect(find.text('先看新手入口'), findsOneWidget);
    expect(find.text('本周精选'), findsOneWidget);
    expect(find.text('已验证资源'), findsOneWidget);
    expect(find.text('适合先上手'), findsOneWidget);
  });

  testWidgets('提示词页支持质量筛选和排序切片', (tester) async {
    final database = await setUpDatabase();

    await pumpLoaded(tester, const HomeScreen(), database);

    await tester.tap(find.text('提示词').last);
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('全部质量'), findsOneWidget);
    expect(find.text('开发编程'), findsWidgets);
    expect(find.text('推荐优先'), findsOneWidget);
    expect(find.text('适合先上手'), findsWidgets);
  });

  testWidgets('提示词工作台会拦住缺少必填变量的复制', (tester) async {
    final database = await setUpDatabase();

    await pumpLoaded(
      tester,
      const PromptDetailScreen(resourceId: 'prompt-code-review'),
      database,
    );

    expect(find.text('复制可用版本'), findsNothing);
    expect(find.text('先补齐必填变量再复制'), findsOneWidget);
    expect(find.text('检查渲染结果'), findsOneWidget);
  });

  testWidgets('技能详情页支持只读浏览和复制为我的版本', (tester) async {
    final database = await setUpDatabase();

    await pumpLoaded(
      tester,
      const SkillDetailScreen(resourceId: 'skill-prompt-scorer'),
      database,
    );

    expect(find.text('技能详情'), findsOneWidget);
    expect(find.text('复制内容'), findsOneWidget);
    expect(find.text('复制为我的版本'), findsOneWidget);
    expect(find.text('高级信息'), findsOneWidget);
  });

  testWidgets('MCP 测试页会显示测试配置和探测入口', (tester) async {
    final database = await setUpDatabase();
    final overrides = [
      syncApiClientProvider.overrideWith((ref) => _FakeSyncApiClient()),
      secureSecretStoreProvider.overrideWith(
        (ref) => _MemorySecureSecretStore(),
      ),
    ];

    await pumpLoaded(
      tester,
      const McpTestScreen(resourceId: 'mcp-github'),
      database,
      overrides: overrides,
    );

    expect(find.text('测试 MCP 连接'), findsOneWidget);
    expect(find.text('先确认连得上，再看能列出什么'), findsOneWidget);
    expect(find.text('测试配置'), findsOneWidget);
    expect(find.text('保存测试配置'), findsOneWidget);
  });

  testWidgets('MCP 详情页提供测试入口', (tester) async {
    final database = await setUpDatabase();

    await pumpLoaded(
      tester,
      const McpServerDetailScreen(resourceId: 'mcp-github'),
      database,
    );

    expect(find.text('测试连接'), findsOneWidget);
    expect(find.text('复制模板'), findsOneWidget);
  });
}

class _FakeSyncApiClient extends SyncApiClient {
  @override
  Future<McpProbeResult> probeMcp(Map<String, dynamic> payload) async {
    return const McpProbeResult(
      healthy: true,
      statusCode: 200,
      bodyPreview: '{"result":"ok"}',
      capabilities: {'tools': true},
      protocolVersion: '2025-06-18',
      serverInfo: {'name': 'fake'},
    );
  }

  @override
  Future<McpInvokeResult> invokeMcpTest(Map<String, dynamic> payload) async {
    return const McpInvokeResult(
      statusCode: 200,
      body: {'ok': true},
      error: '',
    );
  }
}

class _MemorySecureSecretStore extends SecureSecretStore {
  _MemorySecureSecretStore() : super(const FlutterSecureStorage());

  final Map<String, String> _values = {};

  @override
  Future<void> writeSecret(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<String?> readSecret(String key) async => _values[key];
}
