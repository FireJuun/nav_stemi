import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

// Mocks
class MockNavigationSettingsRepository extends Mock
    implements NavigationSettingsRepository {}

class MockAppWaypoint extends Mock implements AppWaypoint {}

// Fakes
class FakeAppWaypoint extends Fake implements AppWaypoint {}

void main() {
  late ProviderContainer container;
  late MockNavigationSettingsRepository mockRepository;
  late NavigationSettingsViewController controller;

  setUpAll(() {
    registerFallbackValue(FakeAppWaypoint());
    registerFallbackValue(AudioGuidanceType.alertsOnly);
  });

  setUp(() {
    mockRepository = MockNavigationSettingsRepository();
    container = ProviderContainer(
      overrides: [
        navigationSettingsRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    controller = container.read(
      navigationSettingsViewControllerProvider.notifier,
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('NavigationSettingsViewController', () {
    test('should initialize with AsyncData(null)', () {
      final state = container.read(navigationSettingsViewControllerProvider);
      expect(state, equals(const AsyncData<void>(null)));
    });

    test('should call setShowNorthUp on repository', () {
      // Arrange
      when(() => mockRepository.setShowNorthUp(value: true)).thenReturn(null);

      // Act
      controller.setShowNorthUp(value: true);

      // Assert
      verify(() => mockRepository.setShowNorthUp(value: true)).called(1);
    });

    test('should call setShowNorthUp with false', () {
      // Arrange
      when(() => mockRepository.setShowNorthUp(value: false)).thenReturn(null);

      // Act
      controller.setShowNorthUp(value: false);

      // Assert
      verify(() => mockRepository.setShowNorthUp(value: false)).called(1);
    });

    test('should call setAudioGuidanceType on repository', () {
      // Arrange
      when(
        () => mockRepository.setAudioGuidanceType(
          value: AudioGuidanceType.alertsAndGuidance,
        ),
      ).thenReturn(null);

      // Act
      controller.setAudioGuidanceType(
        value: AudioGuidanceType.alertsAndGuidance,
      );

      // Assert
      verify(
        () => mockRepository.setAudioGuidanceType(
          value: AudioGuidanceType.alertsAndGuidance,
        ),
      ).called(1);
    });

    test('should handle all AudioGuidanceType values', () {
      // Test all enum values
      for (final type in AudioGuidanceType.values) {
        when(() => mockRepository.setAudioGuidanceType(value: type))
            .thenReturn(null);

        controller.setAudioGuidanceType(value: type);

        verify(() => mockRepository.setAudioGuidanceType(value: type))
            .called(1);
      }
    });

    test('should call setShouldSimulateLocation on repository', () {
      // Arrange
      when(() => mockRepository.setShouldSimulateLocation(value: true))
          .thenReturn(null);

      // Act
      controller.setShouldSimulateLocation(value: true);

      // Assert
      verify(() => mockRepository.setShouldSimulateLocation(value: true))
          .called(1);
    });

    test('should call setShouldSimulateLocation with false', () {
      // Arrange
      when(() => mockRepository.setShouldSimulateLocation(value: false))
          .thenReturn(null);

      // Act
      controller.setShouldSimulateLocation(value: false);

      // Assert
      verify(() => mockRepository.setShouldSimulateLocation(value: false))
          .called(1);
    });

    test('should call setSimulationSpeedMultiplier on repository', () {
      // Arrange
      const speedMultiplier = 2.5;
      when(
        () => mockRepository.setSimulationSpeedMultiplier(
          value: speedMultiplier,
        ),
      ).thenReturn(null);

      // Act
      controller.setSimulationSpeedMultiplier(value: speedMultiplier);

      // Assert
      verify(
        () => mockRepository.setSimulationSpeedMultiplier(
          value: speedMultiplier,
        ),
      ).called(1);
    });

    test('should handle different speed multiplier values', () {
      // Test various speed multipliers
      final speeds = [0.5, 1.0, 1.5, 2.0, 3.0, 5.0];
      for (final speed in speeds) {
        when(() => mockRepository.setSimulationSpeedMultiplier(value: speed))
            .thenReturn(null);

        controller.setSimulationSpeedMultiplier(value: speed);

        verify(() => mockRepository.setSimulationSpeedMultiplier(value: speed))
            .called(1);
      }
    });

    test('should call setSimulationStartingLocation on repository', () {
      // Arrange
      final mockWaypoint = MockAppWaypoint();
      when(
        () => mockRepository.setSimulationStartingLocation(
          value: mockWaypoint,
        ),
      ).thenReturn(null);

      // Act
      controller.setSimulationStartingLocation(value: mockWaypoint);

      // Assert
      verify(
        () => mockRepository.setSimulationStartingLocation(
          value: mockWaypoint,
        ),
      ).called(1);
    });

    test('should handle multiple calls to setSimulationStartingLocation', () {
      // Arrange
      final waypoint1 = MockAppWaypoint();
      final waypoint2 = MockAppWaypoint();

      when(
        () => mockRepository.setSimulationStartingLocation(
          value: any(named: 'value'),
        ),
      ).thenReturn(null);

      // Act
      controller.setSimulationStartingLocation(value: waypoint1);
      controller.setSimulationStartingLocation(value: waypoint2);

      // Assert
      verify(
        () => mockRepository.setSimulationStartingLocation(value: waypoint1),
      ).called(1);
      verify(
        () => mockRepository.setSimulationStartingLocation(value: waypoint2),
      ).called(1);
    });

    test('should have unmounted tracking via NotifierMounted', () {
      // The controller extends NotifierMounted, which provides mounted state tracking
      // This test verifies the mixin is properly integrated
      expect(controller, isA<NotifierMounted>());
    });

    test('should dispose properly', () {
      // Create a new container to test disposal
      final testContainer = ProviderContainer(
        overrides: [
          navigationSettingsRepositoryProvider
              .overrideWithValue(mockRepository),
        ],
      );

      // Read the controller to initialize it
      final testController = testContainer.read(
        navigationSettingsViewControllerProvider.notifier,
      );

      // Verify it's initialized
      expect(testController, isNotNull);

      // Dispose the container
      testContainer.dispose();

      // After disposal, the controller should be unmounted
      // Note: We can't directly test the unmounted state due to encapsulation,
      // but the dispose process should complete without errors
    });
  });

  group('NavigationSettingsViewController provider', () {
    test('should provide NavigationSettingsViewController instance', () {
      final controller = container.read(
        navigationSettingsViewControllerProvider.notifier,
      );

      expect(controller, isA<NavigationSettingsViewController>());
    });

    test('should return same instance on multiple reads', () {
      final controller1 = container.read(
        navigationSettingsViewControllerProvider.notifier,
      );
      final controller2 = container.read(
        navigationSettingsViewControllerProvider.notifier,
      );

      expect(identical(controller1, controller2), isTrue);
    });
  });
}
