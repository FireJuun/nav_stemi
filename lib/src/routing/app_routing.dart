import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:nav_stemi/src/features/add_data/presentation/add_data_dialog.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_routing.g.dart';

/// Original source: Andrea Bizzotto
/// https://github.com/bizz84/complete-flutter-course

/// All the supported routes in the app.
/// By using an enum, we route by name using this syntax:
/// ```dart
/// context.goNamed(AppRoute.home.name)
/// ```
enum AppRoute {
  home,
  homeAddData,
  goTo,
  nav,
  navAddData,
}

/// returns the GoRouter instance that defines all the routes in the app
@Riverpod(keepAlive: true)
GoRouter goRouter(GoRouterRef ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final shellNavNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shellNav');
  final shellAddDataNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shellAddData');

  // final authRepository = ref.watch(authRepositoryProvider);
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    navigatorKey: rootNavigatorKey,
    routes: [
      GoRoute(
        path: '/',
        name: AppRoute.home.name,
        builder: (context, state) => const Home(),
        routes: [
          GoRoute(
            path: 'data',
            name: AppRoute.homeAddData.name,
            pageBuilder: (context, state) => DialogPage(
              builder: (_) => const AddDataDialog(),
            ),
          ),
          GoRoute(
            path: 'go',
            name: AppRoute.goTo.name,
            pageBuilder: (context, state) => DialogPage(
              builder: (_) => const GoToDialog(),
            ),
          ),
        ],
      ),
      // Stateful nested navigation based on:
      // https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // the UI shell
          return ScaffoldWithNestedNavigation(
            navigationShell: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: shellNavNavigatorKey,
            routes: [
              /// Go
              GoRoute(
                path: '/nav',
                name: AppRoute.nav.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: NavScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellAddDataNavigatorKey,
            routes: [
              GoRoute(
                path: '/add',
                name: AppRoute.navAddData.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: AddDataScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}
