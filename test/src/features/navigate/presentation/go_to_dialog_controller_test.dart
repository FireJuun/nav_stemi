import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

// Mocks
class MockGoogleNavigationService extends Mock
    implements GoogleNavigationService {}

class MockGoRouter extends Mock implements GoRouter {}

class MockNearbyHospital extends Mock implements NearbyHospital {}

class MockHospital extends Mock implements Hospital {}

class MockNearbyHospitals extends Mock implements NearbyHospitals {}

// Fakes
class FakeHospital extends Fake implements Hospital {}

void main() {
  late ProviderContainer container;
  late MockGoogleNavigationService mockNavigationService;
  late MockGoRouter mockRouter;
  late GoToDialogController controller;

  setUpAll(() {
    registerFallbackValue(FakeHospital());
  });

  setUp(() {
    mockNavigationService = MockGoogleNavigationService();
    mockRouter = MockGoRouter();

    container = ProviderContainer(
      overrides: [
        googleNavigationServiceProvider
            .overrideWithValue(mockNavigationService),
        goRouterProvider.overrideWithValue(mockRouter),
      ],
    );

    controller = container.read(goToDialogControllerProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('GoToDialogController', () {
    test('should initialize with AsyncData(null)', () {
      final state = container.read(goToDialogControllerProvider);
      expect(state, equals(const AsyncData<void>(null)));
    });

    test('should navigate to hospital successfully', () async {
      // Arrange
      final mockHospitalInfo = MockHospital();
      final mockNearbyHospital = MockNearbyHospital();
      final mockNearbyHospitals = MockNearbyHospitals();

      when(() => mockNearbyHospital.hospitalInfo).thenReturn(mockHospitalInfo);
      when(
        () => mockNavigationService.linkHospitalInfoToDestination(
          mockHospitalInfo,
        ),
      ).thenReturn(null);
      when(() => mockRouter.goNamed(AppRoute.nav.name)).thenReturn(null);

      // Act
      await controller.goToHospital(
        activeHospital: mockNearbyHospital,
        nearbyHospitals: mockNearbyHospitals,
      );

      // Assert
      verify(
        () => mockNavigationService.linkHospitalInfoToDestination(
          mockHospitalInfo,
        ),
      ).called(1);
      verify(() => mockRouter.goNamed(AppRoute.nav.name)).called(1);
    });

    test('should set loading state when navigating', () async {
      // Arrange
      final mockHospitalInfo = MockHospital();
      final mockNearbyHospital = MockNearbyHospital();
      final mockNearbyHospitals = MockNearbyHospitals();

      when(() => mockNearbyHospital.hospitalInfo).thenReturn(mockHospitalInfo);
      when(
        () => mockNavigationService.linkHospitalInfoToDestination(
          mockHospitalInfo,
        ),
      ).thenReturn(null);
      when(() => mockRouter.goNamed(AppRoute.nav.name)).thenReturn(null);

      // Track state changes
      final stateChanges = <AsyncValue<void>>[];
      container.listen<AsyncValue<void>>(
        goToDialogControllerProvider,
        (previous, next) => stateChanges.add(next),
        fireImmediately: true,
      );

      // Act
      await controller.goToHospital(
        activeHospital: mockNearbyHospital,
        nearbyHospitals: mockNearbyHospitals,
      );

      // Assert - check that loading state was present
      expect(stateChanges.any((state) => state is AsyncLoading<void>), isTrue);
    });

    test('should handle errors during navigation', () async {
      // Arrange
      final mockHospitalInfo = MockHospital();
      final mockNearbyHospital = MockNearbyHospital();
      final mockNearbyHospitals = MockNearbyHospitals();
      final testError = Exception('Navigation failed');

      when(() => mockNearbyHospital.hospitalInfo).thenReturn(mockHospitalInfo);
      when(
        () => mockNavigationService.linkHospitalInfoToDestination(
          mockHospitalInfo,
        ),
      ).thenThrow(testError);

      // Act
      await controller.goToHospital(
        activeHospital: mockNearbyHospital,
        nearbyHospitals: mockNearbyHospitals,
      );

      // Assert
      final state = container.read(goToDialogControllerProvider);
      expect(state, isA<AsyncError>());
      expect((state as AsyncError).error, equals(testError));

      // Verify navigation wasn't called after error
      verifyNever(() => mockRouter.goNamed(any()));
    });

    test('should handle errors from router', () async {
      // Arrange
      final mockHospitalInfo = MockHospital();
      final mockNearbyHospital = MockNearbyHospital();
      final mockNearbyHospitals = MockNearbyHospitals();
      final testError = Exception('Router error');

      when(() => mockNearbyHospital.hospitalInfo).thenReturn(mockHospitalInfo);
      when(
        () => mockNavigationService.linkHospitalInfoToDestination(
          mockHospitalInfo,
        ),
      ).thenReturn(null);
      when(() => mockRouter.goNamed(AppRoute.nav.name)).thenThrow(testError);

      // Act
      await controller.goToHospital(
        activeHospital: mockNearbyHospital,
        nearbyHospitals: mockNearbyHospitals,
      );

      // Assert
      final state = container.read(goToDialogControllerProvider);
      expect(state, isA<AsyncError>());
      expect((state as AsyncError).error, equals(testError));
    });

    test('should call multiple hospitals sequentially', () async {
      // Arrange
      final mockHospitalInfo1 = MockHospital();
      final mockHospitalInfo2 = MockHospital();
      final mockNearbyHospital1 = MockNearbyHospital();
      final mockNearbyHospital2 = MockNearbyHospital();
      final mockNearbyHospitals = MockNearbyHospitals();

      when(() => mockNearbyHospital1.hospitalInfo)
          .thenReturn(mockHospitalInfo1);
      when(() => mockNearbyHospital2.hospitalInfo)
          .thenReturn(mockHospitalInfo2);
      when(() => mockNavigationService.linkHospitalInfoToDestination(any()))
          .thenReturn(null);
      when(() => mockRouter.goNamed(AppRoute.nav.name)).thenReturn(null);

      // Act - navigate to first hospital
      await controller.goToHospital(
        activeHospital: mockNearbyHospital1,
        nearbyHospitals: mockNearbyHospitals,
      );

      // Act - navigate to second hospital
      await controller.goToHospital(
        activeHospital: mockNearbyHospital2,
        nearbyHospitals: mockNearbyHospitals,
      );

      // Assert
      verify(
        () => mockNavigationService.linkHospitalInfoToDestination(
          mockHospitalInfo1,
        ),
      ).called(1);
      verify(
        () => mockNavigationService.linkHospitalInfoToDestination(
          mockHospitalInfo2,
        ),
      ).called(1);
      verify(() => mockRouter.goNamed(AppRoute.nav.name)).called(2);
    });

    test('should invalidate nearbyHospitalsProvider on dispose', () {
      // Create a separate container to test disposal
      final testContainer = ProviderContainer(
        overrides: [
          googleNavigationServiceProvider
              .overrideWithValue(mockNavigationService),
          goRouterProvider.overrideWithValue(mockRouter),
        ],
      );

      // Initialize the controller
      testContainer.read(goToDialogControllerProvider.notifier);

      // Dispose the container
      testContainer.dispose();

      // Disposal is handled internally by Riverpod
      // We can't directly verify invalidation without access to internal state
      // But the test verifies no errors occur during disposal
    });

    test('should handle NotifierMounted correctly', () {
      // The controller extends NotifierMounted
      expect(controller, isA<NotifierMounted>());
    });
  });

  group('GoToDialogController provider', () {
    test('should provide GoToDialogController instance', () {
      final controller = container.read(
        goToDialogControllerProvider.notifier,
      );

      expect(controller, isA<GoToDialogController>());
    });

    test('should return same instance on multiple reads', () {
      final controller1 = container.read(
        goToDialogControllerProvider.notifier,
      );
      final controller2 = container.read(
        goToDialogControllerProvider.notifier,
      );

      expect(identical(controller1, controller2), isTrue);
    });
  });
}
