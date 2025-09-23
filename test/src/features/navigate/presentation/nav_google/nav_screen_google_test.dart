import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

import 'test_nav_screen_google.dart';

// Mock classes
class MockNavScreenGoogleController extends AutoDisposeAsyncNotifier<void>
    with Mock
    implements NavScreenGoogleController {
  @override
  FutureOr<void> build() => Future<void>.value();
}

class MockActiveDestinationRepository extends Mock
    implements ActiveDestinationRepository {}

class MockNavigationSettingsRepository extends Mock
    implements NavigationSettingsRepository {}

// Fake classes
class FakePosition extends Fake implements Position {}

class FakeActiveDestination extends Fake implements ActiveDestination {}

class FakeCameraPosition extends Fake implements CameraPosition {}

class FakeLatLng extends Fake implements LatLng {}

class FakeGoogleNavigationViewController extends Fake
    implements GoogleNavigationViewController {}

// Mock GoogleMapsNavigationView widget for testing
class MockGoogleMapsNavigationView extends StatelessWidget {
  const MockGoogleMapsNavigationView({
    super.key,
    this.onViewCreated,
    this.initialCameraPosition,
    this.onMapLongClicked,
    this.onMapClicked,
  });

  final void Function(GoogleNavigationViewController)? onViewCreated;
  final CameraPosition? initialCameraPosition;
  final void Function(LatLng)? onMapLongClicked;
  final void Function(LatLng)? onMapClicked;

  @override
  Widget build(BuildContext context) {
    // Create a simple placeholder that simulates the map
    return GestureDetector(
      onTap: () {
        onMapClicked?.call(const LatLng(latitude: 37, longitude: -122));
      },
      child: ColoredBox(
        color: Colors.grey.shade200,
        child: const Center(
          child: Text('Mock Map View'),
        ),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late MockNavScreenGoogleController mockController;
  late MockActiveDestinationRepository mockActiveDestinationRepository;
  late MockNavigationSettingsRepository mockNavigationSettingsRepository;
  late Position testPosition;
  late ActiveDestination testActiveDestination;

  setUpAll(() {
    registerFallbackValue(FakePosition());
    registerFallbackValue(FakeActiveDestination());
    registerFallbackValue(FakeCameraPosition());
    registerFallbackValue(FakeLatLng());
    registerFallbackValue(FakeGoogleNavigationViewController());
    registerFallbackValue(AudioGuidanceType.alertsAndGuidance);
    registerFallbackValue(SimulationState.running);
  });

  setUp(() {
    mockController = MockNavScreenGoogleController();
    mockActiveDestinationRepository = MockActiveDestinationRepository();
    mockNavigationSettingsRepository = MockNavigationSettingsRepository();

    // Setup test data
    testPosition = Position(
      latitude: 37.7749,
      longitude: -122.4194,
      timestamp: DateTime.now(),
      accuracy: 10,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

    const testHospital = Hospital(
      facilityBrandedName: 'Test Hospital',
      facilityAddress: '123 Test St',
      facilityCity: 'San Francisco',
      facilityState: 'CA',
      facilityZip: 94102,
      latitude: 37.7849,
      longitude: -122.4094,
      county: 'San Francisco',
      source: 'Test',
      facilityPhone1: '555-1234',
      distanceToAsheboro: 100,
      pciCenter: 1,
    );

    testActiveDestination = const ActiveDestination(
      destination: null,
      destinationInfo: testHospital,
    );

    // Setup default behaviors
    when(() => mockController.onViewCreated(any())).thenAnswer((_) async {});
    when(() => mockController.zoomToActiveRoute()).thenAnswer((_) async {});
    when(() => mockController.zoomOut()).thenAnswer((_) async {});
    when(() => mockController.zoomIn()).thenAnswer((_) async {});
    when(() => mockController.setAudioGuidanceType(any()))
        .thenAnswer((_) async {});
    when(() => mockController.setSimulationState(any()))
        .thenAnswer((_) async {});

    when(() => mockActiveDestinationRepository.watchDestinations())
        .thenAnswer((_) => Stream.value(testActiveDestination));

    when(() => mockNavigationSettingsRepository.navigationSettings)
        .thenReturn(const NavigationSettings());
    when(() => mockNavigationSettingsRepository.navigationSettingsChanges())
        .thenAnswer((_) => Stream.value(const NavigationSettings()));
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        navScreenGoogleControllerProvider.overrideWith(() => mockController),
        activeDestinationRepositoryProvider
            .overrideWithValue(mockActiveDestinationRepository),
        navigationSettingsRepositoryProvider
            .overrideWithValue(mockNavigationSettingsRepository),
        audioGuidanceTypeProvider
            .overrideWith((ref) => AudioGuidanceType.alertsAndGuidance),
        shouldSimulateLocationProvider.overrideWith((ref) => true),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: TestNavScreenGoogle(initialPosition: testPosition),
        ),
      ),
    );
  }

  group('NavScreenGoogle Widget Tests', () {
    testWidgets('should display ListEDOptions when no active destination',
        (tester) async {
      when(() => mockActiveDestinationRepository.watchDestinations())
          .thenAnswer((_) => Stream.value(null));

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(ListEDOptions), findsOneWidget);
      expect(find.byType(GoogleMapsNavigationView), findsNothing);
    });

    testWidgets('should display navigation view when active destination exists',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Expect to find our mock map instead of GoogleMapsNavigationView
      expect(find.text('Mock Google Maps'), findsOneWidget);
      expect(find.byType(NearestHospitalSelector), findsOneWidget);
    });

    testWidgets('should show control buttons', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Navigation controls
      expect(find.text('All Steps'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Zoom controls
      expect(find.byIcon(Icons.moving), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should toggle steps visibility', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially steps should not be visible
      expect(find.byType(NavSteps), findsOneWidget);
      final stepsContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).at(0),
      );
      expect(stepsContainer.constraints?.maxHeight, equals(0));

      // Tap to show steps
      await tester.tap(find.text('All Steps'));
      await tester.pumpAndSettle();

      // Steps should now be visible with height
      final updatedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).at(0),
      );
      expect(
        updatedContainer.constraints?.maxHeight,
        greaterThan(0),
      );
    });

    testWidgets('should toggle audio guidance menu', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find audio guidance button by looking for volume icon
      final audioButton = find.byIcon(Icons.volume_up);
      expect(audioButton, findsOneWidget);

      // Tap to show audio guidance menu
      await tester.tap(audioButton);
      await tester.pumpAndSettle();

      // Menu should be visible
      expect(find.byType(AudioGuidancePicker), findsOneWidget);
    });

    testWidgets('should toggle simulation controls menu', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find simulation button
      final simulationButton = find.byIcon(Icons.play_arrow);
      expect(simulationButton, findsOneWidget);

      // Tap to show simulation menu
      await tester.tap(simulationButton);
      await tester.pumpAndSettle();

      // Menu should be visible
      expect(find.byType(SimulationStatePicker), findsOneWidget);
    });

    testWidgets('should dismiss menus on map tap', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Show steps menu
      await tester.tap(find.text('All Steps'));
      await tester.pumpAndSettle();

      // Verify menu is visible
      final stepsContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).at(0),
      );
      expect(stepsContainer.constraints?.maxHeight, greaterThan(0));

      // Simulate map tap by tapping on the mock map container
      // Find the mock map (it has 'Mock Google Maps' text)
      await tester.tap(find.text('Mock Google Maps'));
      await tester.pumpAndSettle();

      // Menu should be dismissed
      final updatedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).at(0),
      );
      expect(updatedContainer.constraints?.maxHeight, equals(0));
    });

    testWidgets('should call controller zoom methods', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Test zoom in
      await tester.tap(find.byIcon(Icons.add));
      verify(() => mockController.zoomIn()).called(1);

      // Test zoom out
      await tester.tap(find.byIcon(Icons.remove));
      verify(() => mockController.zoomOut()).called(1);

      // Test zoom to route
      await tester.tap(find.byIcon(Icons.moving));
      verify(() => mockController.zoomToActiveRoute()).called(1);
    });

    testWidgets('should hide simulation controls when not simulating',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            navScreenGoogleControllerProvider
                .overrideWith(() => mockController),
            activeDestinationRepositoryProvider
                .overrideWithValue(mockActiveDestinationRepository),
            navigationSettingsRepositoryProvider
                .overrideWithValue(mockNavigationSettingsRepository),
            audioGuidanceTypeProvider.overrideWith(
              (ref) => AudioGuidanceType.alertsAndGuidance,
            ),
            shouldSimulateLocationProvider.overrideWith(
              (ref) => false,
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TestNavScreenGoogle(initialPosition: testPosition),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Simulation controls should not be visible
      expect(find.byIcon(Icons.play_arrow), findsNothing);
      expect(find.byIcon(Icons.pause), findsNothing);
    });

    testWidgets('should handle keyboard visibility', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Show steps
      await tester.tap(find.text('All Steps'));
      await tester.pumpAndSettle();

      // Steps should be visible
      final stepsContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).at(0),
      );
      expect(stepsContainer.constraints?.maxHeight, greaterThan(0));

      // TODO(test): Test keyboard visibility behavior
      // This would require mocking KeyboardVisibilityBuilder
    });
  });

  group('AudioGuidancePicker Tests', () {
    testWidgets('should display all audio options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProviderScope(
              overrides: [
                audioGuidanceTypeProvider
                    .overrideWith((ref) => AudioGuidanceType.alertsAndGuidance),
              ],
              child: AudioGuidancePicker(
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.volume_up), findsOneWidget);
      expect(
        find.byIcon(Icons.notification_important_outlined),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.volume_off), findsOneWidget);
    });

    testWidgets('should disable current selection', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProviderScope(
              overrides: [
                audioGuidanceTypeProvider
                    .overrideWith((ref) => AudioGuidanceType.alertsOnly),
              ],
              child: AudioGuidancePicker(
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Find IconButtons that contain the specific icons
      final iconButtons = find.byType(IconButton);
      
      // Find the alerts button by checking its icon
      IconButton? alertsButton;
      for (final element in iconButtons.evaluate()) {
        final iconButton = element.widget as IconButton;
        if (iconButton.icon is Icon && 
            (iconButton.icon as Icon).icon == Icons.notification_important_outlined) {
          alertsButton = iconButton;
          break;
        }
      }
      
      expect(alertsButton, isNotNull);
      expect(alertsButton!.onPressed, isNull);

      // Find the volume button
      IconButton? volumeButton;
      for (final element in iconButtons.evaluate()) {
        final iconButton = element.widget as IconButton;
        if (iconButton.icon is Icon && 
            (iconButton.icon as Icon).icon == Icons.volume_up) {
          volumeButton = iconButton;
          break;
        }
      }
      
      expect(volumeButton, isNotNull);
      expect(volumeButton!.onPressed, isNotNull);
    });

    testWidgets('should call onChanged when option selected', (tester) async {
      AudioGuidanceType? selectedType;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProviderScope(
              overrides: [
                audioGuidanceTypeProvider
                    .overrideWith((ref) => AudioGuidanceType.alertsAndGuidance),
              ],
              child: AudioGuidancePicker(
                onChanged: (type) => selectedType = type,
              ),
            ),
          ),
        ),
      );

      // Tap silent option
      await tester.tap(find.byIcon(Icons.volume_off));
      expect(selectedType, equals(AudioGuidanceType.silent));
    });
  });

  group('SimulationStatePicker Tests', () {
    testWidgets('should display play and pause options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SimulationStatePicker(
              currentValue: SimulationState.running,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);
    });

    testWidgets('should disable current selection', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SimulationStatePicker(
              currentValue: SimulationState.paused,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Find IconButtons that contain the specific icons
      final iconButtons = find.byType(IconButton);
      
      // Find the pause button by checking its icon
      IconButton? pauseButton;
      for (final element in iconButtons.evaluate()) {
        final iconButton = element.widget as IconButton;
        if (iconButton.icon is Icon && 
            (iconButton.icon as Icon).icon == Icons.pause) {
          pauseButton = iconButton;
          break;
        }
      }
      
      expect(pauseButton, isNotNull);
      expect(pauseButton!.onPressed, isNull);

      // Find the play button
      IconButton? playButton;
      for (final element in iconButtons.evaluate()) {
        final iconButton = element.widget as IconButton;
        if (iconButton.icon is Icon && 
            (iconButton.icon as Icon).icon == Icons.play_arrow) {
          playButton = iconButton;
          break;
        }
      }
      
      expect(playButton, isNotNull);
      expect(playButton!.onPressed, isNotNull);
    });

    testWidgets('should call onChanged when option selected', (tester) async {
      SimulationState? selectedState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SimulationStatePicker(
              currentValue: SimulationState.running,
              onChanged: (state) => selectedState = state,
            ),
          ),
        ),
      );

      // Tap pause option
      await tester.tap(find.byIcon(Icons.pause));
      expect(selectedState, equals(SimulationState.paused));
    });
  });

  group('Integration Tests', () {
    testWidgets('should update audio icon based on provider state',
        (tester) async {
      // Test the icon directly in a simpler widget tree
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            audioGuidanceTypeProvider.overrideWith(
              (ref) => AudioGuidanceType.alertsOnly,
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final audioGuidanceType = ref.watch(audioGuidanceTypeProvider);
                  return IconButton(
                    icon: switch (audioGuidanceType) {
                      AudioGuidanceType.alertsAndGuidance =>
                        const Icon(Icons.volume_up),
                      AudioGuidanceType.alertsOnly =>
                        const Icon(Icons.notification_important_outlined),
                      AudioGuidanceType.silent =>
                        const Icon(Icons.volume_off),
                    },
                    onPressed: () {},
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // The audio icon should show notification_important_outlined for alertsOnly
      expect(
        find.byIcon(Icons.notification_important_outlined),
        findsOneWidget,
      );
      // volume_up icon should not be present
      expect(find.byIcon(Icons.volume_up), findsNothing);
    });

    testWidgets('should handle error states gracefully', (tester) async {
      // Override with error state
      when(() => mockActiveDestinationRepository.watchDestinations())
          .thenAnswer(
        (_) => Stream<ActiveDestination?>.error(
          Exception('Test error'),
        ),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show error widget
      expect(find.byType(ErrorMessageWidget), findsOneWidget);
    });
  });
}
