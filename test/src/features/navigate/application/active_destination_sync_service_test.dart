import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

// Mocks

class MockPermissionsRepository extends Mock implements PermissionsRepository {}

class MockGoogleNavigationService extends Mock
    implements GoogleNavigationService {}

class MockActiveDestination extends Mock implements ActiveDestination {}

class MockProviderSubscription<T> extends Mock
    implements ProviderSubscription<T> {}

// Fakes
class FakeActiveDestination extends Fake implements ActiveDestination {}

void main() {
  late ActiveDestinationSyncService service;
  late ProviderContainer container;

  late MockPermissionsRepository mockPermissionsRepository;
  late MockGoogleNavigationService mockGoogleNavigationService;
  late MockProviderSubscription<AsyncValue<bool?>> mockBoolSubscription;
  late MockProviderSubscription<AsyncValue<ActiveDestination?>>
      mockDestinationSubscription;

  setUpAll(() {
    registerFallbackValue(const AsyncData<bool?>(null));
    registerFallbackValue(const AsyncData<ActiveDestination?>(null));
    registerFallbackValue(FakeActiveDestination());
  });

  setUp(() {
    mockPermissionsRepository = MockPermissionsRepository();
    mockGoogleNavigationService = MockGoogleNavigationService();

    // Setup provider reads

    container = ProviderContainer(
      overrides: [
        activeDestinationProvider.overrideWith(
          (ref) => const Stream.empty(),
        ),
        googleNavigationServiceProvider
            .overrideWithValue(mockGoogleNavigationService),
        permissionsRepositoryProvider
            .overrideWithValue(mockPermissionsRepository),
      ],
    );
  });

  group('ActiveDestinationSyncService', () {
    group('startNavigationIfInitialized', () {
      test('should start navigation when all conditions are met', () async {
        // Arrange
        service = container.read(activeDestinationSyncServiceProvider);

        when(() => mockPermissionsRepository.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(() => mockGoogleNavigationService.isInitialized())
            .thenAnswer((_) async => true);
        when(() => mockGoogleNavigationService.calculateDestinationRoutes())
            .thenAnswer((_) async => true);
        when(() => mockGoogleNavigationService.startDrivingDirections())
            .thenAnswer((_) async {});

        // Act
        await service.startNavigationIfInitialized();

        // Assert
        verify(() => mockGoogleNavigationService.calculateDestinationRoutes())
            .called(1);
        verify(() => mockGoogleNavigationService.startDrivingDirections())
            .called(1);
      });

      test('should not start navigation when location is disabled', () async {
        // Arrange
        service = container.read(activeDestinationSyncServiceProvider);

        when(() => mockPermissionsRepository.isLocationServiceEnabled())
            .thenAnswer((_) async => false);
        when(() => mockGoogleNavigationService.isInitialized())
            .thenAnswer((_) async => true);

        // Act
        await service.startNavigationIfInitialized();

        // Assert
        verifyNever(
            () => mockGoogleNavigationService.calculateDestinationRoutes(),);
        verifyNever(() => mockGoogleNavigationService.startDrivingDirections());
      });

      test('should not start navigation when not initialized', () async {
        // Arrange
        service = container.read(activeDestinationSyncServiceProvider);

        when(() => mockPermissionsRepository.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(() => mockGoogleNavigationService.isInitialized())
            .thenAnswer((_) async => false);

        // Act
        await service.startNavigationIfInitialized();

        // Assert
        verifyNever(
            () => mockGoogleNavigationService.calculateDestinationRoutes(),);
        verifyNever(() => mockGoogleNavigationService.startDrivingDirections());
      });

      test('should handle errors gracefully', () async {
        // Arrange
        service = container.read(activeDestinationSyncServiceProvider);

        when(() => mockPermissionsRepository.isLocationServiceEnabled())
            .thenThrow(Exception('Location service error'));

        // Act & Assert
        await expectLater(
          service.startNavigationIfInitialized(),
          throwsException,
        );
      });
    });
  });

  group('activeDestinationSyncServiceProvider', () {
    test('should provide ActiveDestinationSyncService instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(activeDestinationSyncServiceProvider);

      expect(service, isA<ActiveDestinationSyncService>());
    });
  });
}
