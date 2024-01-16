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
  // final authRepository = ref.watch(authRepositoryProvider);
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: AppRoute.home.name,
        builder: (context, state) => const Home(),
        routes: [
          GoRoute(
            path: 'add',
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
          GoRoute(
            path: 'nav',
            name: AppRoute.nav.name,
            builder: (context, state) => const NavScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: AppRoute.navAddData.name,
                pageBuilder: (context, state) => DialogPage(
                  builder: (_) => const AddDataDialog(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}
