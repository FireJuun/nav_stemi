import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

// Mock classes
class MockNavigationSettingsRepository extends Mock
    implements NavigationSettingsRepository {}

class MockNavigationSettingsViewController
    extends AutoDisposeAsyncNotifier<void>
    with Mock
    implements NavigationSettingsViewController {
  @override
  FutureOr<void> build() => Future<void>.value();
}

class MockNavScreenGoogleController extends AutoDisposeAsyncNotifier<void>
    with Mock
    implements NavScreenGoogleController {
  @override
  FutureOr<void> build() => Future<void>.value();

  @override
  AsyncValue<void> get state => const AsyncValue<void>.data(null);
}

// Fake classes
class FakeAppWaypoint extends Fake implements AppWaypoint {}

void main() {
  late MockNavigationSettingsRepository mockRepository;
  late MockNavigationSettingsViewController mockViewController;
  late MockNavScreenGoogleController mockNavController;
  late NavigationSettings testSettings;

  setUpAll(() {
    registerFallbackValue(AudioGuidanceType.alertsAndGuidance);
    registerFallbackValue(FakeAppWaypoint());
  });

  setUp(() {
    mockRepository = MockNavigationSettingsRepository();
    mockViewController = MockNavigationSettingsViewController();
    mockNavController = MockNavScreenGoogleController();

    testSettings = const NavigationSettings(
      simulationSpeedMultiplier: 1,
    );

    // Setup default behaviors
    when(() => mockRepository.navigationSettingsChanges())
        .thenAnswer((_) => Stream.value(testSettings));
    when(() => mockRepository.navigationSettings).thenReturn(testSettings);

    when(
      () => mockViewController.setShowNorthUp(value: any(named: 'value')),
    ).thenAnswer((_) async {});
    when(
      () => mockViewController.setAudioGuidanceType(
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockViewController.setShouldSimulateLocation(
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockViewController.setSimulationSpeedMultiplier(
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});

    when(
      () => mockNavController.setShowNorthUp(
        showNorthUp: any(named: 'showNorthUp'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockNavController.setAudioGuidanceType(any()))
        .thenAnswer((_) async {});
  });

  Widget createTestWidget({
    NavigationSettings? overrideSettings,
    bool includeNavController = false,
  }) {
    return ProviderScope(
      overrides: [
        navigationSettingsRepositoryProvider.overrideWithValue(mockRepository),
        navigationSettingsViewControllerProvider
            .overrideWith(() => mockViewController),
        if (overrideSettings != null)
          navigationSettingsChangesProvider
              .overrideWith((ref) => Stream.value(overrideSettings)),
        if (includeNavController)
          navScreenGoogleControllerProvider
              .overrideWith(() => mockNavController),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: Center(
            child: NavigationSettingsView(),
          ),
        ),
      ),
    );
  }

  group('NavigationSettingsView Widget Tests', () {
    testWidgets('should display all main sections', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Navigation Settings'), findsOneWidget);
      expect(find.text('Show North Up'), findsOneWidget);
      expect(find.text('Audio Guidance'), findsOneWidget);
      expect(find.text('Simulator Settings'), findsOneWidget);
      expect(find.text('Simulate Location'), findsOneWidget);
    });

    testWidgets('should display correct initial switch states', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final northUpSwitch = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Show North Up'),
      );
      expect(northUpSwitch.value, isFalse); // Default is false

      final simulateSwitch = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Simulate Location'),
      );
      expect(simulateSwitch.value, isFalse);
    });

    testWidgets('should display audio guidance segmented button',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SegmentedButton<AudioGuidanceType>), findsOneWidget);

      // Check all segments are present
      expect(find.text('Alerts & Guidance'), findsOneWidget);
      expect(find.text('Alerts Only'), findsOneWidget);
      expect(find.text('Silent'), findsOneWidget);
    });

    testWidgets('should toggle Show North Up and call controller',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(SwitchListTile, 'Show North Up'));
      await tester.pumpAndSettle();

      verify(() => mockViewController.setShowNorthUp(value: true)).called(1);
    });

    testWidgets('should update show north up preference when toggled',
        (tester) async {
      // Start with showNorthUp false
      final updatedSettings = testSettings.copyWith(showNorthUp: false);
      when(() => mockRepository.navigationSettings).thenReturn(updatedSettings);
      when(() => mockRepository.navigationSettingsChanges())
          .thenAnswer((_) => Stream.value(updatedSettings));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify initial state
      final switchTile = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Show North Up'),
      );
      expect(switchTile.value, false);

      // Toggle the switch
      await tester.tap(find.widgetWithText(SwitchListTile, 'Show North Up'));
      await tester.pumpAndSettle();

      // Verify the view controller was called
      verify(() => mockViewController.setShowNorthUp(value: true)).called(1);
    });

    testWidgets('should change audio guidance type', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alerts Only'));
      await tester.pumpAndSettle();

      verify(
        () => mockViewController.setAudioGuidanceType(
          value: AudioGuidanceType.alertsOnly,
        ),
      ).called(1);
    });

    testWidgets('should update audio guidance preference when changed',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify initial state (alertsAndGuidance is default)
      final segmentedButton = tester.widget<SegmentedButton<AudioGuidanceType>>(
        find.byType(SegmentedButton<AudioGuidanceType>),
      );
      expect(segmentedButton.selected, {AudioGuidanceType.alertsAndGuidance});

      // Change to Silent
      await tester.tap(find.text('Silent'));
      await tester.pumpAndSettle();

      // Verify the view controller was called
      verify(
        () => mockViewController.setAudioGuidanceType(
          value: AudioGuidanceType.silent,
        ),
      ).called(1);
    });

    testWidgets('should toggle simulate location', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester
          .tap(find.widgetWithText(SwitchListTile, 'Simulate Location'));
      await tester.pumpAndSettle();

      verify(() => mockViewController.setShouldSimulateLocation(value: true))
          .called(1);
    });

    testWidgets('should show simulation controls when enabled', (tester) async {
      final settingsWithSimulation = testSettings.copyWith(
        shouldSimulateLocation: true,
      );

      await tester.pumpWidget(
        createTestWidget(overrideSettings: settingsWithSimulation),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavSimulationSlider), findsOneWidget);
      expect(find.byType(SimulationStartingLocationPicker), findsOneWidget);
      expect(find.text('Simulation Driving\nSpeed Multiplier'), findsOneWidget);
      expect(find.text('Simulation Starting Location'), findsOneWidget);
    });

    testWidgets('should hide simulation controls when disabled',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(NavSimulationSlider), findsNothing);
      expect(find.byType(SimulationStartingLocationPicker), findsNothing);
    });

    testWidgets('should handle loading state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            navigationSettingsRepositoryProvider
                .overrideWithValue(mockRepository),
            navigationSettingsViewControllerProvider
                .overrideWith(() => mockViewController),
            navigationSettingsChangesProvider
                .overrideWith((ref) => const Stream.empty()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: NavigationSettingsView(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle error state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            navigationSettingsRepositoryProvider
                .overrideWithValue(mockRepository),
            navigationSettingsViewControllerProvider
                .overrideWith(() => mockViewController),
            navigationSettingsChangesProvider.overrideWith(
              (ref) => Stream<NavigationSettings>.error(
                Exception('Test error'),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: NavigationSettingsView(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ErrorMessageWidget), findsOneWidget);
    });
  });

  group('NavSimulationSlider Tests', () {
    testWidgets('should display initial value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavSimulationSlider(
              initialValue: 2.5,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('2.5'), findsOneWidget);
    });

    testWidgets('should update value when dragged', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavSimulationSlider(
              initialValue: 1,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      // Drag slider to the right
      await tester.drag(slider, const Offset(100, 0));
      await tester.pumpAndSettle();

      // Value should have increased
      expect(find.text('1.0'), findsNothing);
    });

    testWidgets('should call onChanged when drag ends', (tester) async {
      double? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavSimulationSlider(
              initialValue: 1,
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      final slider = find.byType(Slider);

      // Drag and release
      await tester.drag(slider, const Offset(100, 0));
      await tester.pumpAndSettle();

      expect(changedValue, isNotNull);
      expect(changedValue, greaterThan(1.0));
    });

    testWidgets('should truncate values to one decimal place', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavSimulationSlider(
              initialValue: 2.3456789,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('2.3'), findsOneWidget);
    });

    testWidgets('should have max value of 5', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavSimulationSlider(
              initialValue: 1,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.max, equals(5.0));
    });
  });

  group('SimulationStartingLocationPicker Tests', () {
    testWidgets('should display dropdown menu', (tester) async {
      when(
        () => mockRepository.setSimulationStartingLocation(
          value: any(named: 'value'),
        ),
      ).thenReturn(null);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            navigationSettingsRepositoryProvider
                .overrideWithValue(mockRepository),
            simulationStartingLocationProvider.overrideWith((ref) => null),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SimulationStartingLocationPicker(),
            ),
          ),
        ),
      );

      expect(find.text('Simulation Starting Location'), findsOneWidget);
      expect(find.byType(DropdownMenu<AppWaypoint?>), findsOneWidget);
    });

    testWidgets('should call repository when location selected',
        (tester) async {
      when(
        () => mockRepository.setSimulationStartingLocation(
          value: any(named: 'value'),
        ),
      ).thenReturn(null);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            navigationSettingsRepositoryProvider
                .overrideWithValue(mockRepository),
            simulationStartingLocationProvider.overrideWith((ref) => null),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SimulationStartingLocationPicker(),
            ),
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(DropdownMenu<AppWaypoint?>));
      await tester.pumpAndSettle();

      // Select first location
      final firstLocation = simulationLocations.first;
      await tester.tap(find.text(firstLocation.label).last);
      await tester.pumpAndSettle();

      verify(
        () => mockRepository.setSimulationStartingLocation(
          value: firstLocation,
        ),
      ).called(1);
    });
  });
}
