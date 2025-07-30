import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

class MockGoogleNavigationService extends Mock
    implements GoogleNavigationService {}

class FakeMapSessionReadyNotifier extends MapSessionReady {
  FakeMapSessionReadyNotifier(this._value);

  final AsyncValue<bool> _value;

  @override
  AsyncValue<bool> build() => _value;
}

void main() {
  group('NavDrawer', () {
    Widget createTestWidget() {
      return const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            endDrawer: NavDrawer(),
          ),
        ),
      );
    }

    testWidgets('should display drawer header with Nav STEMI text',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      // Open the drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openEndDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Nav STEMI'), findsOneWidget);
    });

    testWidgets('should apply secondary color to drawer header',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Open the drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openEndDrawer();
      await tester.pumpAndSettle();

      final drawerHeader =
          tester.widget<DrawerHeader>(find.byType(DrawerHeader));
      final decoration = drawerHeader.decoration! as BoxDecoration;
      final theme = Theme.of(tester.element(find.byType(DrawerHeader)));
      expect(decoration.color, theme.colorScheme.secondary);
    });

    testWidgets('should display ShowNavSteps widget', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Open the drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openEndDrawer();
      await tester.pumpAndSettle();

      expect(find.byType(ShowNavSteps), findsOneWidget);
    });

    testWidgets('should display NavigationSettingsView widget', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Open the drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openEndDrawer();
      await tester.pumpAndSettle();

      expect(find.byType(NavigationSettingsView), findsOneWidget);
    });

    testWidgets('should have zero padding on ListView', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Open the drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openEndDrawer();
      await tester.pumpAndSettle();

      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.padding, EdgeInsets.zero);
    });
  });

  group('ShowNavSteps', () {
    late MockGoogleNavigationService mockGoogleNavigationService;

    setUp(() {
      mockGoogleNavigationService = MockGoogleNavigationService();
      when(() => mockGoogleNavigationService.startDrivingDirections())
          .thenAnswer((_) async => Future.value());
      when(() => mockGoogleNavigationService.stopDrivingDirections())
          .thenAnswer((_) async => Future.value());
    });

    Widget createTestWidget({
      AsyncValue<bool>? mapSessionReady,
    }) {
      return ProviderScope(
        overrides: [
          googleNavigationServiceProvider
              .overrideWithValue(mockGoogleNavigationService),
          if (mapSessionReady != null)
            mapSessionReadyProvider.overrideWith(
                () => FakeMapSessionReadyNotifier(mapSessionReady),),
        ],
        child: const MaterialApp(
          home: Scaffold(
            endDrawer: NavDrawer(),
            body: Center(child: Text('Body')),
          ),
        ),
      );
    }

    testWidgets('should show loading when map session is loading',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          mapSessionReady: const AsyncValue<bool>.loading(),
        ),
      );
      await tester.pump();
      // Open the drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openEndDrawer();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show empty when map session is not ready',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          mapSessionReady: const AsyncValue<bool>.data(false),
        ),
      );

      // Open the drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openEndDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Start Navigation'), findsNothing);
      expect(find.text('Stop Navigation'), findsNothing);
    });

    testWidgets('should show navigation controls when map session is ready',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          mapSessionReady: const AsyncValue<bool>.data(true),
        ),
      );

      // Open the drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openEndDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Start Navigation'), findsOneWidget);
      expect(find.text('Stop Navigation'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('should start navigation and close drawer when start tapped',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          mapSessionReady: const AsyncValue<bool>.data(true),
        ),
      );

      // Open the drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openEndDrawer();
      await tester.pumpAndSettle();

      // Tap start navigation
      await tester.tap(find.text('Start Navigation'));
      await tester.pumpAndSettle();

      verify(() => mockGoogleNavigationService.startDrivingDirections())
          .called(1);
      expect(scaffoldState.isEndDrawerOpen, isFalse);
    });

    testWidgets('should stop navigation and close drawer when stop tapped',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          mapSessionReady: const AsyncValue<bool>.data(true),
        ),
      );

      // Open the drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openEndDrawer();
      await tester.pumpAndSettle();

      // Tap stop navigation
      await tester.tap(find.text('Stop Navigation'));
      await tester.pumpAndSettle();

      verify(() => mockGoogleNavigationService.stopDrivingDirections())
          .called(1);
      expect(scaffoldState.isEndDrawerOpen, isFalse);
    });

    testWidgets('should apply secondary color to icons and text',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          mapSessionReady: const AsyncValue<bool>.data(true),
        ),
      );

      // Open the drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openEndDrawer();
      await tester.pumpAndSettle();

      final theme = Theme.of(tester.element(find.byType(ShowNavSteps)));
      final expectedColor = theme.colorScheme.secondary;

      // Check icon colors
      final playIcon = tester.widget<Icon>(find.byIcon(Icons.play_arrow));
      expect(playIcon.color, expectedColor);

      final stopIcon = tester.widget<Icon>(find.byIcon(Icons.stop));
      expect(stopIcon.color, expectedColor);

      // Check text styles
      final startText = tester.widget<Text>(find.text('Start Navigation'));
      expect(startText.style?.color, expectedColor);

      final stopText = tester.widget<Text>(find.text('Stop Navigation'));
      expect(stopText.style?.color, expectedColor);
    });

    testWidgets('should show error when map session has error', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          mapSessionReady: AsyncValue<bool>.error(
            Exception('Map error'),
            StackTrace.current,
          ),
        ),
      );

      await tester.pump();

      // Open the drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openEndDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Exception: Map error'), findsOneWidget);
    });
  });
}
