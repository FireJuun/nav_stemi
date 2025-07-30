import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:permission_handler/permission_handler.dart';

// Mocks
class MockGeolocatorRepository extends Mock implements GeolocatorRepository {}

class MockGoogleNavigationService extends Mock
    implements GoogleNavigationService {}

class MockPermissionsRepository extends Mock implements PermissionsRepository {}

class MockRef extends Mock implements Ref {}

void main() {
  late PermissionsService service;
  late MockRef mockRef;
  late MockGeolocatorRepository mockGeolocatorRepository;
  late MockGoogleNavigationService mockGoogleNavigationService;
  late MockPermissionsRepository mockPermissionsRepository;

  setUp(() {
    mockRef = MockRef();
    mockGeolocatorRepository = MockGeolocatorRepository();
    mockGoogleNavigationService = MockGoogleNavigationService();
    mockPermissionsRepository = MockPermissionsRepository();

    // Setup provider reads
    when(() => mockRef.read(geolocatorRepositoryProvider))
        .thenReturn(mockGeolocatorRepository);
    when(() => mockRef.read(googleNavigationServiceProvider))
        .thenReturn(mockGoogleNavigationService);
    when(() => mockRef.read(permissionsRepositoryProvider))
        .thenReturn(mockPermissionsRepository);

    service = PermissionsService(mockRef);
  });

  group('PermissionsService', () {
    test('should initialize repositories from ref', () {
      // Verify getters work correctly
      expect(service.geolocatorRepository, equals(mockGeolocatorRepository));
      expect(
        service.googleNavigationService,
        equals(mockGoogleNavigationService),
      );
      expect(service.permissionsRepository, equals(mockPermissionsRepository));
    });

    group('initialize', () {
      test('should check permissions and location on initialize', () async {
        // Arrange
        final mockStatuses = <Permission, PermissionStatus>{
          Permission.locationWhenInUse: PermissionStatus.granted,
          Permission.notification: PermissionStatus.granted,
        };

        when(() => mockPermissionsRepository.checkAppPermissions())
            .thenAnswer((_) async => mockStatuses);
        when(() => mockGoogleNavigationService.checkTermsAccepted())
            .thenAnswer((_) async {});
        when(() => mockGeolocatorRepository.checkLocationEnabled())
            .thenAnswer((_) async => true);
        when(() => mockGeolocatorRepository.getLastKnownPosition())
            .thenAnswer((_) async => null);

        // Act
        await service.initialize();

        // Assert
        verify(() => mockPermissionsRepository.checkAppPermissions()).called(1);
        verify(() => mockGoogleNavigationService.checkTermsAccepted())
            .called(1);
        verify(() => mockGeolocatorRepository.checkLocationEnabled()).called(1);
        verify(() => mockGeolocatorRepository.getLastKnownPosition()).called(1);
      });

      test('should handle errors during initialization', () async {
        // Arrange
        when(() => mockPermissionsRepository.checkAppPermissions())
            .thenThrow(Exception('Permission check failed'));

        // Act & Assert
        await expectLater(
          service.initialize(),
          throwsException,
        );
      });
    });

    group('checkPermissionsOnAppStart', () {
      test('should return granted permissions status', () async {
        // Arrange
        final mockStatuses = <Permission, PermissionStatus>{
          Permission.locationWhenInUse: PermissionStatus.granted,
          Permission.notification: PermissionStatus.granted,
        };

        when(() => mockPermissionsRepository.checkAppPermissions())
            .thenAnswer((_) async => mockStatuses);
        when(() => mockGoogleNavigationService.checkTermsAccepted())
            .thenAnswer((_) async {});

        // Act
        final result = await service.checkPermissionsOnAppStart();

        // Assert
        expect(result.areLocationsPermitted, isTrue);
        expect(result.areNotificationsPermitted, isTrue);
        verify(() => mockGoogleNavigationService.checkTermsAccepted())
            .called(1);
      });

      test('should return denied permissions status', () async {
        // Arrange
        final mockStatuses = <Permission, PermissionStatus>{
          Permission.locationWhenInUse: PermissionStatus.denied,
          Permission.notification: PermissionStatus.denied,
        };

        when(() => mockPermissionsRepository.checkAppPermissions())
            .thenAnswer((_) async => mockStatuses);
        when(() => mockGoogleNavigationService.checkTermsAccepted())
            .thenAnswer((_) async {});

        // Act
        final result = await service.checkPermissionsOnAppStart();

        // Assert
        expect(result.areLocationsPermitted, isFalse);
        expect(result.areNotificationsPermitted, isFalse);
      });

      test('should handle mixed permissions status', () async {
        // Arrange
        final mockStatuses = <Permission, PermissionStatus>{
          Permission.locationWhenInUse: PermissionStatus.granted,
          Permission.notification: PermissionStatus.permanentlyDenied,
        };

        when(() => mockPermissionsRepository.checkAppPermissions())
            .thenAnswer((_) async => mockStatuses);
        when(() => mockGoogleNavigationService.checkTermsAccepted())
            .thenAnswer((_) async {});

        // Act
        final result = await service.checkPermissionsOnAppStart();

        // Assert
        expect(result.areLocationsPermitted, isTrue);
        expect(result.areNotificationsPermitted, isFalse);
      });

      test('should check terms acceptance after permissions', () async {
        // Arrange
        final mockStatuses = <Permission, PermissionStatus>{
          Permission.locationWhenInUse: PermissionStatus.granted,
          Permission.notification: PermissionStatus.granted,
        };

        when(() => mockPermissionsRepository.checkAppPermissions())
            .thenAnswer((_) async => mockStatuses);
        when(() => mockGoogleNavigationService.checkTermsAccepted())
            .thenAnswer((_) async {});

        // Act
        await service.checkPermissionsOnAppStart();

        // Assert
        verifyInOrder([
          () => mockPermissionsRepository.checkAppPermissions(),
          () => mockGoogleNavigationService.checkTermsAccepted(),
        ]);
      });
    });

    group('openAppSettingsPage', () {
      test('should delegate to permissions repository', () async {
        // Arrange
        when(() => mockPermissionsRepository.openAppSettingsPage())
            .thenAnswer((_) async => true);

        // Act
        await service.openAppSettingsPage();

        // Assert
        verify(() => mockPermissionsRepository.openAppSettingsPage()).called(1);
      });

      test('should handle errors when opening settings', () async {
        // Arrange
        when(() => mockPermissionsRepository.openAppSettingsPage())
            .thenThrow(Exception('Failed to open settings'));

        // Act & Assert
        await expectLater(
          service.openAppSettingsPage(),
          throwsException,
        );
      });
    });
  });

  group('permissionsServiceProvider', () {
    test('should provide PermissionsService instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(permissionsServiceProvider);

      expect(service, isA<PermissionsService>());
    });
  });
}
