import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    final themeRepository = ref.watch(themeRepositoryProvider);
    final appTheme = useStream(themeRepository.appThemeChanges);
    return MaterialApp.router(
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'app',
      onGenerateTitle: (BuildContext context) => 'nav STEMI'.hardcoded,
      themeMode: appTheme.data?.themeMode,
      theme: themeRepository.lightTheme,
      darkTheme: themeRepository.darkTheme,
    );
  }
}
