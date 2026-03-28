import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../infrastructure/providers.dart';
import 'router.dart';

class AIDeveloperApp extends ConsumerWidget {
  const AIDeveloperApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(catalogRemoteSyncProvider);
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: '灵感栈',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: router,
    );
  }
}
