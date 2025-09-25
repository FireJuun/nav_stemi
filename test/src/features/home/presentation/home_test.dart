import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

class MockPermissionsService extends Mock implements PermissionsService {}

class MockFhirInitService extends Mock implements FhirInitService {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late GoRouter testRouter;
  late MockPermissionsService mockPermissionsService;
  late MockFhirInitService mockFhirInitService;
  late MockNavigatorObserver mockNavigatorObserver;
  final navigatedRoutes = <String>[];

  setUp(() {
    mockPermissionsService = MockPermissionsService();
    mockFhirInitService = MockFhirInitService();
    mockNavigatorObserver = MockNavigatorObserver();
    navigatedRoutes.clear();

    // Create test router
    testRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const Home(),
        ),
        GoRoute(
          path: '/add-data',
          name: AppRoute.navAddData.name,
          builder: (context, state) {
            navigatedRoutes.add(AppRoute.navAddData.name);
            return const Scaffold(body: Text('Add Data'));
          },
        ),
        GoRoute(
          path: '/go-to',
          name: AppRoute.goTo.name,
          builder: (context, state) {
            navigatedRoutes.add(AppRoute.goTo.name);
            return const Scaffold(body: Text('Go To'));
          },
        ),
      ],
      observers: [mockNavigatorObserver],
    );

    // Default stubs
    when(() => mockPermissionsService.checkPermissionsOnAppStart()).thenAnswer(
      (_) async => (
        areLocationsPermitted: true,
        areNotificationsPermitted: true,
      ),
    );
    when(() => mockPermissionsService.openAppSettingsPage())
        .thenAnswer((_) async {});
    when(() => mockFhirInitService.initializeBlankResources())
        .thenAnswer((_) async {});
  });

  Widget createTestWidget({
    required Widget child,
    List<Override> overrides = const [],
    AsyncValue<AppUser?>? authState,
    GoRouter? router,
  }) {
    return ProviderScope(
      overrides: [
        permissionsServiceProvider.overrideWithValue(mockPermissionsService),
        fhirInitServiceProvider.overrideWithValue(mockFhirInitService),
        if (authState != null)
          authStateChangesProvider.overrideWith(
            (ref) => Stream.value(authState.value),
          ),
        ...overrides,
      ],
      child: router != null
          ? MaterialApp.router(
              routerConfig: router,
            )
          : MaterialApp(
              home: child,
            ),
    );
  }

  group('Home Widget Tests', () {
    testWidgets('should display app bar with title and profile icon',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const Home(),
          router: testRouter,
        ),
      );

      // Wait for build to complete
      await tester.pump();

      // Check app bar title
      expect(find.text('nav - STEMI'), findsOneWidget);
    });

    testWidgets('should display instructions text', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const Home(),
          router: testRouter,
        ),
      );

      expect(find.text('Click `Go` to begin'), findsOneWidget);
      expect(find.text('Click `Add Data`\nto pre-enter info'), findsOneWidget);
    });

    testWidgets('should display GO and Add Data buttons', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const Home(),
          router: testRouter,
        ),
      );

      expect(find.text('+ GO'), findsOneWidget);
      expect(find.text('Add Data'), findsOneWidget);
    });

    testWidgets('should navigate to add data screen when button pressed',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const Home(),
          router: testRouter,
        ),
      );

      await tester.tap(find.text('Add Data'));
      await tester.pumpAndSettle();

      expect(navigatedRoutes, contains(AppRoute.navAddData.name));
      expect(find.text('Add Data'), findsOneWidget); // Screen title
    });

    testWidgets('should navigate to go to screen when GO button pressed',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const Home(),
          router: testRouter,
        ),
      );

      await tester.tap(find.text('+ GO'));
      await tester.pumpAndSettle();

      expect(navigatedRoutes, contains(AppRoute.goTo.name));
      expect(find.text('Go To'), findsOneWidget); // Screen title
    });

    testWidgets('should show auth dialog when profile icon pressed',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const Home(),
          router: testRouter,
        ),
      );

      await tester.tap(find.byKey(Home.profileIconButtonKey));
      await tester.pumpAndSettle();

      // Should show auth dialog
      expect(find.byType(UserProfileDialog), findsOneWidget);
    });

    testWidgets('should show permission error when location permission missing',
        (tester) async {
      when(() => mockPermissionsService.checkPermissionsOnAppStart())
          .thenAnswer(
        (_) async => (
          areLocationsPermitted: false,
          areNotificationsPermitted: true,
        ),
      );

      await tester.pumpWidget(
        createTestWidget(
          child: const Home(),
          router: testRouter,
        ),
      );
      await tester.pump();

      // Should show error message
      expect(
        find.text('Error: Missing the following permissions:'),
        findsOneWidget,
      );
      expect(find.text('• Location'), findsOneWidget);

      // Should show open settings button
      expect(find.text('Open App\nSettings'), findsOneWidget);

      // GO button should be disabled
      final goButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, '+ GO'),
      );
      expect(goButton.onPressed, isNull);
    });

    testWidgets('should show loading indicator when auth state is loading',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const Home(),
          router: testRouter,
          authState: const AsyncLoading<AppUser?>(),
        ),
      );

      // Loading indicator in app bar profile icon
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });

    testWidgets('should call openAppSettingsPage when settings button pressed',
        (tester) async {
      when(() => mockPermissionsService.checkPermissionsOnAppStart())
          .thenAnswer(
        (_) async => (
          areLocationsPermitted: false,
          areNotificationsPermitted: true,
        ),
      );

      await tester.pumpWidget(
        createTestWidget(
          child: const Home(),
          router: testRouter,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Open App\nSettings'));
      await tester.pumpAndSettle();

      verify(() => mockPermissionsService.openAppSettingsPage()).called(1);
    });

    testWidgets('should handle notification permission error', (tester) async {
      when(() => mockPermissionsService.checkPermissionsOnAppStart())
          .thenAnswer(
        (_) async => (
          areLocationsPermitted: true,
          areNotificationsPermitted: false,
        ),
      );

      await tester.pumpWidget(
        createTestWidget(
          child: const Home(),
          router: testRouter,
        ),
      );
      await tester.pump();

      expect(
        find.text('Error: Missing the following permissions:'),
        findsOneWidget,
      );
      expect(find.text('• Notifications'), findsOneWidget);
    });

    testWidgets('should handle both permissions missing', (tester) async {
      when(() => mockPermissionsService.checkPermissionsOnAppStart())
          .thenAnswer(
        (_) async => (
          areLocationsPermitted: false,
          areNotificationsPermitted: false,
        ),
      );

      await tester.pumpWidget(
        createTestWidget(
          child: const Home(),
          router: testRouter,
        ),
      );
      await tester.pump();

      expect(
        find.text('Error: Missing the following permissions:'),
        findsOneWidget,
      );
      expect(find.text('• Location'), findsOneWidget);
      expect(find.text('• Notifications'), findsOneWidget);
    });

    testWidgets('should check permissions on app resume', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const Home(),
          router: testRouter,
        ),
      );

      // Simulate app lifecycle change
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      verify(() => mockPermissionsService.checkPermissionsOnAppStart())
          .called(2); // Once on init, once on resume
    });

    testWidgets('should display login status indicator', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const Home(),
          router: testRouter,
        ),
      );

      expect(find.byType(LoginStatusIndicator), findsOneWidget);
    });

    testWidgets(
      'should initialize FHIR resources when logged in user presses GO',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            child: const Home(),
            router: testRouter,
            authState: AsyncData<AppUser?>(
              ServiceAccountUser(
                email: 'test@example.com',
                client: MockClient((_) async => http.Response('', 200)),
              ),
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('+ GO'));
        await tester.pumpAndSettle();

        verify(() => mockFhirInitService.initializeBlankResources()).called(1);
        expect(navigatedRoutes, contains(AppRoute.goTo.name));
      },
    );

    testWidgets('should display drawer when menu icon tapped', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const Home(),
          router: testRouter,
        ),
      );

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.byType(NavDrawer), findsOneWidget);
    });
  });

  group('LoginStatusIndicator Widget Tests', () {
    testWidgets('should show login prompt when not authenticated',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Scaffold(
            body: LoginStatusIndicator(
              onShowEncountersPressed: () {},
            ),
          ),
          authState: const AsyncData<AppUser?>(null),
        ),
      );

      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      expect(find.text('Login for full features'), findsOneWidget);
    });

    testWidgets('should show encounters button when authenticated',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Scaffold(
            body: LoginStatusIndicator(
              onShowEncountersPressed: () {},
            ),
          ),
          authState: AsyncData<AppUser?>(
            ServiceAccountUser(
              email: 'test@example.com',
              client: MockClient((_) async => http.Response('', 200)),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(
        find.byKey(LoginStatusIndicator.viewPriorEncountersButtonKey),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('should call callback when encounters button pressed',
        (tester) async {
      var callbackCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          child: Scaffold(
            body: LoginStatusIndicator(
              onShowEncountersPressed: () {
                callbackCalled = true;
              },
            ),
          ),
          authState: AsyncData<AppUser?>(
            ServiceAccountUser(
              email: 'test@example.com',
              client: MockClient((_) async => http.Response('', 200)),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester
          .tap(find.byKey(LoginStatusIndicator.viewPriorEncountersButtonKey));
      await tester.pump();

      expect(callbackCalled, isTrue);
    });

    testWidgets('should show loading state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Scaffold(
            body: LoginStatusIndicator(
              onShowEncountersPressed: () {},
            ),
          ),
          authState: const AsyncLoading<AppUser?>(),
        ),
      );

      await tester.pump();

      expect(find.byKey(LoginStatusIndicator.loginActionsKey), findsOneWidget);
    });

    testWidgets('should show error state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Scaffold(
            body: LoginStatusIndicator(
              onShowEncountersPressed: () {},
            ),
          ),
          authState: AsyncError<AppUser?>(
            Exception('Auth error'),
            StackTrace.empty,
          ),
        ),
      );

      // Should show login prompt on error
      expect(find.text('Login for full features'), findsOneWidget);
    });
  });
}
