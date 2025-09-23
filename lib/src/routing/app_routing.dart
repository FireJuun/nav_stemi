import 'package:firebase_ui_auth/firebase_ui_auth.dart' show AuthAction;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_stemi/nav_stemi.dart';
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
  goTo,
  nav,
  navGoTo,
  navInfo,
  navAddData,
  signIn,
  phoneInput,
  smsCodeInput,
}

/// returns the GoRouter instance that defines all the routes in the app
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final shellNavNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shellNav');
  final shellAddDataNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shellAddData');

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    navigatorKey: rootNavigatorKey,
    onException: (_, GoRouterState state, GoRouter router) {
      // If handling a link from Firebase authentication, exit early.
      if (state.matchedLocation == '/link') {
        return;
      }

      router.go('/404', extra: state.uri.toString());
    },
    // Add redirect logic for phone authentication
    redirect: (context, state) async {
      final user = ref.read(authRepositoryProvider).currentUser;

      if (state.matchedLocation == '/link') {
        return null;
      }

      final isAuthRoute = state.matchedLocation.contains('/auth');

      // Redirect to phone input if not authenticated and not on auth routes
      if (user == null && !isAuthRoute) {
        return '/auth';
      }

      // Redirect away from auth routes if already authenticated
      if (user != null && isAuthRoute) {
        return '/';
      }

      return null; // No redirect needed
    },
    // Add refreshListenable for reactive updates
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authRepositoryProvider).authStateChanges(),
    ),
    routes: [
      GoRoute(
        path: '/404',
        builder: (BuildContext context, GoRouterState state) {
          return const NotFoundScreen();
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          /// currently matches logo backgrounds
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
          final scaffoldBackgroundColor =
              isDarkMode ? null : const Color(0xFFE3E2E2);

          return Theme(
            data: Theme.of(context).copyWith(
              scaffoldBackgroundColor: scaffoldBackgroundColor,
              textButtonTheme: const TextButtonThemeData(style: ButtonStyle()),
            ),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/auth',
            builder: (context, state) => const PhoneSignInScreen(),
            routes: [
              GoRoute(
                path: 'phone-input',
                name: AppRoute.phoneInput.name,
                builder: (context, state) {
                  final extra = state.extra;
                  final action = extra is (AuthAction?, Object)
                      ? extra.$1
                      : extra as AuthAction?;

                  return PhoneLoginScreen(action: action);
                },
                routes: [
                  GoRoute(
                    path: 'sms-code-input',
                    name: AppRoute.smsCodeInput.name,
                    builder: (context, state) {
                      final extra = state.extra! as (AuthAction?, Object);

                      return SMSInputScreen(
                        flowKey: extra.$2,
                        action: extra.$1,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/',
        name: AppRoute.home.name,
        builder: (context, state) => Consumer(
          builder: (context, ref, _) {
            /// required to pass the active destination to the nav screen
            ref.watch(activeDestinationProvider);
            return const Home();
          },
        ),
        routes: [
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
          /// Listens for changes to active destination and time metrics.
          /// These should clear when you go back to the home screen.
          return Consumer(
            builder: (context, ref, _) {
              ref

                /// ensure permissions + know current location
                ..watch(permissionsServiceProvider)
                ..watch(geolocatorRepositoryProvider)

                /// know active destination, restart nav if it changes
                ..watch(activeDestinationProvider)
                ..watch(activeDestinationSyncServiceProvider)

                /// sync timer with add info screen
                ..watch(startStopTimerServiceProvider)

                /// ensure google nav providers are available
                ..watch(googleNavigationServiceProvider)
                ..watch(googleNavigationRepositoryProvider)

                /// Initialize blank FHIR resources when first navigating
                /// to the Nav or Add Data screens
                ..read(fhirInitServiceProvider).initializeBlankResources();

              /// The UI shell
              return ScaffoldWithNestedNavigation(
                navigationShell: navigationShell,
              );
            },
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
                pageBuilder: (context, state) {
                  return _fadeTransition(
                    context,
                    state,
                    const NavScreen(),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'go',
                    name: AppRoute.navGoTo.name,
                    pageBuilder: (context, state) => DialogPage(
                      builder: (_) => const GoToDialog(),
                    ),
                  ),
                  GoRoute(
                    path: 'info',
                    name: AppRoute.navInfo.name,
                    pageBuilder: (context, state) {
                      final hospitalInfo = state.extra;
                      assert(
                        hospitalInfo != null,
                        'Hospital info not provided',
                      );
                      assert(
                        hospitalInfo is Hospital,
                        'Hospital info provided, but as the wrong type',
                      );

                      return DialogPage(
                        builder: (_) =>
                            DestinationInfoDialog(hospitalInfo! as Hospital),
                      );
                    },
                  ),
                ],
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
                    _fadeTransition(context, state, const AddDataScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

// spec: https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/transition_animations.dart
Page<dynamic> _fadeTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      // Change the opacity of the screen using a Curve based on the animation's
      // value
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}
