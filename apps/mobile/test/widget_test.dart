import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/home/presentation/home_screen.dart';
import 'package:mobile/features/library/presentation/import_resource_screen.dart';
import 'package:mobile/features/mcp/presentation/mcp_server_detail_screen.dart';
import 'package:mobile/features/prompts/presentation/prompt_detail_screen.dart';
import 'package:mobile/features/skills/presentation/skill_detail_screen.dart';
import 'package:mobile/infrastructure/database/app_database.dart';
import 'package:mobile/infrastructure/providers.dart';

void main() {
  Future<AppDatabase> setUpDatabase() async {
    final database = AppDatabase.memory();
    await database.bootstrap();
    addTearDown(database.close);
    return database;
  }

  Widget buildHarness(Widget child, AppDatabase database) {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWith((ref) async => database)],
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
    AppDatabase database,
  ) async {
    await tester.pumpWidget(buildHarness(child, database));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
  }

  Future<void> pumpLoadedAtSize(
    WidgetTester tester,
    Widget child,
    AppDatabase database,
    Size size,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpLoaded(tester, child, database);
  }

  Future<void> scrollToText(WidgetTester tester, String text) async {
    await tester.scrollUntilVisible(
      find.text(text),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  Future<void> scrollDownForForm(WidgetTester tester) async {
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -420));
    await tester.pumpAndSettle();
  }

  testWidgets('首页首屏会展示 AI 资源定位和主操作入口', (tester) async {
    final database = await setUpDatabase();

    await pumpLoaded(tester, const HomeScreen(), database);

    expect(find.text('常用提示词、技能和工具配置，统一收在这里'), findsOneWidget);
    expect(find.text('先看新手入门'), findsOneWidget);
    expect(find.text('先找一条提示词'), findsOneWidget);
    expect(find.text('导入我的资源'), findsOneWidget);
    await scrollToText(tester, '这三类资源分别解决什么');
    expect(find.text('这三类资源分别解决什么'), findsOneWidget);
  });

  testWidgets('首页适配主流手机宽度', (tester) async {
    final database = await setUpDatabase();
    const sizes = <Size>[
      Size(320, 740),
      Size(360, 800),
      Size(375, 812),
      Size(390, 844),
      Size(430, 932),
    ];

    for (final size in sizes) {
      await pumpLoadedAtSize(
        tester,
        HomeScreen(key: ValueKey('home-${size.width}')),
        database,
        size,
      );

      expect(find.text('先看新手入门'), findsOneWidget);
      expect(find.text('首页').last, findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('提示词、技能和 MCP 一级页都有中文解释和筛选', (tester) async {
    final database = await setUpDatabase();

    await pumpLoaded(tester, const HomeScreen(), database);

    await tester.tap(find.text('提示词').last);
    await tester.pumpAndSettle();
    expect(find.text('适合马上复制使用。先选场景，再填几个关键信息。'), findsOneWidget);
    expect(find.text('开发编程'), findsWidgets);
    expect(find.text('只看收藏'), findsOneWidget);

    await tester.tap(find.text('技能').last);
    await tester.pumpAndSettle();
    expect(find.text('把常做的事整理成固定方法，后面同类任务直接复用。'), findsOneWidget);
    expect(find.text('办公协作'), findsWidgets);
    expect(find.text('只看我导入的'), findsOneWidget);

    await tester.tap(find.text('MCP').last);
    await tester.pumpAndSettle();
    expect(
      find.text('给 AI 接上 GitHub、文档、数据库这类外部工具。先从你已经在用的平台开始。'),
      findsOneWidget,
    );
    expect(find.text('先看这些更容易上手'), findsOneWidget);
  });

  testWidgets('提示词详情默认先展示填写与预览工作台', (tester) async {
    final database = await setUpDatabase();

    await pumpLoaded(
      tester,
      const PromptDetailScreen(resourceId: 'prompt-code-review'),
      database,
    );

    expect(find.text('填写关键变量'), findsOneWidget);
    await scrollToText(tester, '检查渲染结果');
    expect(find.text('检查渲染结果'), findsOneWidget);
    expect(find.text('复制这条提示词'), findsOneWidget);
  });

  testWidgets('技能详情默认折叠高级信息', (tester) async {
    final database = await setUpDatabase();

    await pumpLoaded(
      tester,
      const SkillDetailScreen(resourceId: 'skill-prompt-scorer'),
      database,
    );

    expect(find.text('这条技能能帮你做什么'), findsOneWidget);
    await scrollToText(tester, '高级信息');
    expect(find.text('高级信息'), findsOneWidget);
    expect(find.text('输入 Schema'), findsNothing);

    await tester.tap(find.text('高级信息'));
    await tester.pumpAndSettle();

    expect(find.text('输入 Schema'), findsOneWidget);
  });

  testWidgets('MCP 详情页会先展示用途、步骤和配置模板', (tester) async {
    final database = await setUpDatabase();

    await pumpLoaded(
      tester,
      const McpServerDetailScreen(resourceId: 'mcp-github'),
      database,
    );

    expect(find.text('这条 MCP 适合连接什么'), findsOneWidget);
    await scrollToText(tester, '按顺序完成配置更稳');
    expect(find.text('按顺序完成配置更稳'), findsOneWidget);
    expect(find.text('复制配置模板'), findsOneWidget);
  });

  testWidgets('导入页切换资源类型时字段说明会同步变化', (tester) async {
    final database = await setUpDatabase();

    await pumpLoaded(
      tester,
      const ImportResourceScreen(key: ValueKey('import-screen-skill')),
      database,
    );
    await scrollDownForForm(tester);
    expect(find.byKey(const Key('import-type-skill')), findsOneWidget);
    expect(find.text('资源分类'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('import-type-skill')));
    await tester.tap(find.byKey(const Key('import-type-skill')));
    await tester.pumpAndSettle();
    await scrollToText(tester, '当前选择：技能');
    expect(find.text('当前选择：技能'), findsOneWidget);
    await scrollToText(tester, '示例内容或能力包内容');
    expect(find.text('示例内容或能力包内容'), findsOneWidget);
    expect(find.text('这个技能能帮你什么'), findsOneWidget);

    await pumpLoaded(
      tester,
      const ImportResourceScreen(key: ValueKey('import-screen-mcp')),
      database,
    );
    await scrollDownForForm(tester);
    expect(find.byKey(const Key('import-type-mcp')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('import-type-mcp')));
    await tester.tap(find.byKey(const Key('import-type-mcp')));
    await tester.pumpAndSettle();
    await scrollToText(tester, '当前选择：MCP 配置');
    expect(find.text('当前选择：MCP 配置'), findsOneWidget);
    await scrollToText(tester, '配置模板');
    expect(find.text('配置模板'), findsOneWidget);
    expect(find.text('安全提醒'), findsOneWidget);
  });
}
