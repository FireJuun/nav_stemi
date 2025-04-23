import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    final themeRepository = ref.watch(themeRepositoryProvider);
    final appTheme = ref.watch(appThemeChangesProvider);

    return MaterialApp.router(
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'app',
      onGenerateTitle: (BuildContext context) => 'nav STEMI'.hardcoded,
      themeMode: appTheme.value?.themeMode,
      theme: themeRepository.lightTheme,
      darkTheme: themeRepository.darkTheme,
    );
  }
}
