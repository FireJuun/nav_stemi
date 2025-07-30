import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

// Mock classes
class MockRef extends Mock implements Ref {}

class MockActiveDestinationRepository extends Mock
    implements ActiveDestinationRepository {}

class MockGeolocatorRepository extends Mock implements GeolocatorRepository {}

class MockGoogleNavigationRepository extends Mock
    implements GoogleNavigationRepository {}

class MockPermissionsService extends Mock implements PermissionsService {}

class MockNavigationSettingsRepository extends Mock
    implements NavigationSettingsRepository {}

class MockNavigationWaypoint extends Mock implements NavigationWaypoint {}

class MockDestinations extends Mock implements Destinations {}

class MockLatLng extends Mock implements LatLng {}

class MockSimulationOptions extends Mock implements SimulationOptions {}

class FakeNavigationAudioGuidanceSettings extends Fake
    implements NavigationAudioGuidanceSettings {}

class FakeDestinations extends Fake implements Destinations {}

class FakeAppWaypoint extends Fake implements AppWaypoint {}

class FakeSimulationOptions extends Fake implements SimulationOptions {}

class FakeLatLng extends Fake implements LatLng {}

void main() {
  late GoogleNavigationService service;
  late MockRef mockRef;
  late MockActiveDestinationRepository mockActiveDestinationRepository;
  late MockGeolocatorRepository mockGeolocatorRepository;
  late MockGoogleNavigationRepository mockGoogleNavigationRepository;
  late MockPermissionsService mockPermissionsService;
  late MockNavigationSettingsRepository mockNavigationSettingsRepository;

  setUpAll(() {
    registerFallbackValue(FakeNavigationAudioGuidanceSettings());
    registerFallbackValue(FakeDestinations());
    registerFallbackValue(FakeAppWaypoint());
    registerFallbackValue(FakeSimulationOptions());
    registerFallbackValue(FakeLatLng());
    registerFallbackValue(NavigationAudioGuidanceType.alertsAndGuidance);
  });

  setUp(() {
    mockRef = MockRef();
    mockActiveDestinationRepository = MockActiveDestinationRepository();
    mockGeolocatorRepository = MockGeolocatorRepository();
    mockGoogleNavigationRepository = MockGoogleNavigationRepository();
    mockPermissionsService = MockPermissionsService();
    mockNavigationSettingsRepository = MockNavigationSettingsRepository();

    // Setup default behaviors
    when(() => mockRef.read(activeDestinationRepositoryProvider))
        .thenReturn(mockActiveDestinationRepository);
    when(() => mockRef.read(geolocatorRepositoryProvider))
        .thenReturn(mockGeolocatorRepository);
    when(() => mockRef.read(googleNavigationRepositoryProvider))
        .thenReturn(mockGoogleNavigationRepository);
    when(() => mockRef.read(permissionsServiceProvider))
        .thenReturn(mockPermissionsService);
    when(() => mockRef.read(navigationSettingsRepositoryProvider))
        .thenReturn(mockNavigationSettingsRepository);

    // Default navigation settings
    when(() => mockNavigationSettingsRepository.navigationSettings).thenReturn(
      const NavigationSettings(
        simulationSpeedMultiplier: 1,
      ),
    );

    service = GoogleNavigationService(mockRef);
  });

  group('GoogleNavigationService', () {
    group('initialize', () {
      test(
          'should initialize navigation when terms accepted and not initialized',
          () async {
        when(() => mockGoogleNavigationRepository.areTermsAccepted())
            .thenAnswer((_) async => true);
        when(() => mockPermissionsService.initialize())
            .thenAnswer((_) async {});
        when(() => mockGoogleNavigationRepository.isInitialized())
            .thenAnswer((_) async => false);
        when(() => mockGoogleNavigationRepository.initializeNavigationSession())
            .thenAnswer((_) async {});

        await service.initialize();

        verify(() => mockGoogleNavigationRepository.areTermsAccepted())
            .called(1);
        verify(() => mockPermissionsService.initialize()).called(1);
        verify(() => mockGoogleNavigationRepository.isInitialized()).called(1);
        verify(
          () => mockGoogleNavigationRepository.initializeNavigationSession(),
        ).called(1);
      });

      test('should skip initialization when already initialized', () async {
        when(() => mockGoogleNavigationRepository.areTermsAccepted())
            .thenAnswer((_) async => true);
        when(() => mockPermissionsService.initialize())
            .thenAnswer((_) async {});
        when(() => mockGoogleNavigationRepository.isInitialized())
            .thenAnswer((_) async => true);

        await service.initialize();

        verify(() => mockGoogleNavigationRepository.isInitialized()).called(1);
        verifyNever(
          () => mockGoogleNavigationRepository.initializeNavigationSession(),
        );
      });

      test('should show terms dialog when terms not accepted', () async {
        when(() => mockGoogleNavigationRepository.areTermsAccepted())
            .thenAnswer((_) async => false);
        when(
          () => mockGoogleNavigationRepository.showTermsAndConditionsDialog(
            title: any(named: 'title'),
            companyName: any(named: 'companyName'),
            shouldOnlyShowDriverAwarenessDisclaimer:
                any(named: 'shouldOnlyShowDriverAwarenessDisclaimer'),
          ),
        ).thenAnswer((_) async => true);
        when(() => mockPermissionsService.initialize())
            .thenAnswer((_) async {});
        when(() => mockGoogleNavigationRepository.isInitialized())
            .thenAnswer((_) async => false);
        when(() => mockGoogleNavigationRepository.initializeNavigationSession())
            .thenAnswer((_) async {});

        await service.initialize();

        verify(
          () => mockGoogleNavigationRepository.showTermsAndConditionsDialog(
            title: 'Nav STEMI',
            companyName: 'Atrium Health',
          ),
        ).called(1);
      });

      test('should throw exception when terms rejected', () async {
        when(() => mockGoogleNavigationRepository.areTermsAccepted())
            .thenAnswer((_) async => false);
        when(
          () => mockGoogleNavigationRepository.showTermsAndConditionsDialog(
            title: any(named: 'title'),
            companyName: any(named: 'companyName'),
            shouldOnlyShowDriverAwarenessDisclaimer:
                any(named: 'shouldOnlyShowDriverAwarenessDisclaimer'),
          ),
        ).thenAnswer((_) async => false);

        expect(
          () => service.initialize(),
          throwsA(isA<GoogleNavInitializationTermsNotAcceptedException>()),
        );
      });

      test('should initialize simulation when enabled', () async {
        when(() => mockNavigationSettingsRepository.navigationSettings)
            .thenReturn(
          const NavigationSettings(
            shouldSimulateLocation: true,
            simulationSpeedMultiplier: 2,
            simulationStartingLocation: AppWaypoint(
              latitude: 35,
              longitude: -80,
              label: 'Test',
            ),
          ),
        );
        when(() => mockGoogleNavigationRepository.areTermsAccepted())
            .thenAnswer((_) async => true);
        when(() => mockPermissionsService.initialize())
            .thenAnswer((_) async {});
        when(() => mockGoogleNavigationRepository.isInitialized())
            .thenAnswer((_) async => false);
        when(() => mockGoogleNavigationRepository.initializeNavigationSession())
            .thenAnswer((_) async {});
        when(() => mockGoogleNavigationRepository.simulateUserLocation(any()))
            .thenAnswer((_) async {});
        when(
          () => mockGoogleNavigationRepository
              .simulateLocationsAlongExistingRouteWithOptions(any()),
        ).thenAnswer((_) async {});

        await service.initialize();

        verify(() => mockGoogleNavigationRepository.simulateUserLocation(any()))
            .called(1);
        verify(
          () => mockGoogleNavigationRepository
              .simulateLocationsAlongExistingRouteWithOptions(any()),
        ).called(1);
      });
    });

    group('checkTermsAccepted', () {
      test('should pass when terms already accepted', () async {
        when(() => mockGoogleNavigationRepository.areTermsAccepted())
            .thenAnswer((_) async => true);

        await service.checkTermsAccepted();

        verifyNever(
          () => mockGoogleNavigationRepository.showTermsAndConditionsDialog(
            title: any(named: 'title'),
            companyName: any(named: 'companyName'),
            shouldOnlyShowDriverAwarenessDisclaimer:
                any(named: 'shouldOnlyShowDriverAwarenessDisclaimer'),
          ),
        );
      });

      test('should show dialog when terms not accepted', () async {
        when(() => mockGoogleNavigationRepository.areTermsAccepted())
            .thenAnswer((_) async => false);
        when(
          () => mockGoogleNavigationRepository.showTermsAndConditionsDialog(
            title: any(named: 'title'),
            companyName: any(named: 'companyName'),
            shouldOnlyShowDriverAwarenessDisclaimer:
                any(named: 'shouldOnlyShowDriverAwarenessDisclaimer'),
          ),
        ).thenAnswer((_) async => true);

        await service.checkTermsAccepted();

        verify(
          () => mockGoogleNavigationRepository.showTermsAndConditionsDialog(
            title: 'Nav STEMI',
            companyName: 'Atrium Health',
          ),
        ).called(1);
      });
    });

    group('resetTermsAccepted', () {
      test('should reset terms successfully', () async {
        when(() => mockGoogleNavigationRepository.resetTermsAccepted())
            .thenAnswer((_) async {});

        await service.resetTermsAccepted();

        verify(() => mockGoogleNavigationRepository.resetTermsAccepted())
            .called(1);
      });

      test('should throw exception on reset error', () async {
        when(() => mockGoogleNavigationRepository.resetTermsAccepted())
            .thenThrow(const ResetTermsAndConditionsException());

        expect(
          () => service.resetTermsAccepted(),
          throwsA(isA<GoogleNavResetTermsAndConditionsException>()),
        );
      });
    });

    group('isInitialized', () {
      test('should return true when initialized', () async {
        when(() => mockGoogleNavigationRepository.isInitialized())
            .thenAnswer((_) async => true);

        final result = await service.isInitialized();

        expect(result, isTrue);
      });

      test('should return false when not initialized', () async {
        when(() => mockGoogleNavigationRepository.isInitialized())
            .thenAnswer((_) async => false);

        final result = await service.isInitialized();

        expect(result, isFalse);
      });
    });

    group('initializeNavigationSession', () {
      test('should initialize successfully', () async {
        when(() => mockGoogleNavigationRepository.initializeNavigationSession())
            .thenAnswer((_) async {});

        await service.initializeNavigationSession();

        verify(
          () => mockGoogleNavigationRepository.initializeNavigationSession(),
        ).called(1);
      });

      test('should throw LocationPermissionMissingException', () async {
        when(() => mockGoogleNavigationRepository.initializeNavigationSession())
            .thenThrow(
          const SessionInitializationException(
            SessionInitializationError.locationPermissionMissing,
          ),
        );

        expect(
          () => service.initializeNavigationSession(),
          throwsA(isA<LocationPermissionMissingException>()),
        );
      });

      test('should throw GoogleNavInitializationTermsNotAcceptedException',
          () async {
        when(() => mockGoogleNavigationRepository.initializeNavigationSession())
            .thenThrow(
          const SessionInitializationException(
            SessionInitializationError.termsNotAccepted,
          ),
        );

        expect(
          () => service.initializeNavigationSession(),
          throwsA(isA<GoogleNavInitializationTermsNotAcceptedException>()),
        );
      });

      test('should throw GoogleNavInitializationNotAuthorizedException',
          () async {
        when(() => mockGoogleNavigationRepository.initializeNavigationSession())
            .thenThrow(
          const SessionInitializationException(
            SessionInitializationError.notAuthorized,
          ),
        );

        expect(
          () => service.initializeNavigationSession(),
          throwsA(isA<GoogleNavInitializationNotAuthorizedException>()),
        );
      });
    });

    group('cleanup', () {
      test('should cleanup when initialized and guidance running', () async {
        var guidanceRunning = true;
        when(() => mockGoogleNavigationRepository.isInitialized())
            .thenAnswer((_) async => true);
        when(() => mockGoogleNavigationRepository.isGuidanceRunning())
            .thenAnswer((_) async => guidanceRunning);
        when(() => mockGoogleNavigationRepository.stopGuidance())
            .thenAnswer((_) async {
          guidanceRunning = false;
        });
        when(() => mockGoogleNavigationRepository.cleanupNavigationSession())
            .thenAnswer((_) async {});

        await service.cleanup();

        verify(() => mockGoogleNavigationRepository.stopGuidance()).called(1);
        verify(() => mockGoogleNavigationRepository.cleanupNavigationSession())
            .called(1);
      });

      test('should skip cleanup when not initialized', () async {
        when(() => mockGoogleNavigationRepository.isInitialized())
            .thenAnswer((_) async => false);

        await service.cleanup();

        verifyNever(() => mockGoogleNavigationRepository.isGuidanceRunning());
        verifyNever(() => mockGoogleNavigationRepository.stopGuidance());
        verifyNever(
          () => mockGoogleNavigationRepository.cleanupNavigationSession(),
        );
      });

      test('should cleanup without stopping guidance when not running',
          () async {
        when(() => mockGoogleNavigationRepository.isInitialized())
            .thenAnswer((_) async => true);
        when(() => mockGoogleNavigationRepository.isGuidanceRunning())
            .thenAnswer((_) async => false);
        when(() => mockGoogleNavigationRepository.cleanupNavigationSession())
            .thenAnswer((_) async {});

        await service.cleanup();

        verifyNever(() => mockGoogleNavigationRepository.stopGuidance());
        verify(() => mockGoogleNavigationRepository.cleanupNavigationSession())
            .called(1);
      });
    });

    group('linkHospitalInfoToDestination', () {
      test('should create destination and set active destination', () {
        const hospital = Hospital(
          facilityBrandedName: 'Test Hospital',
          facilityAddress: '123 Test St',
          facilityCity: 'Test City',
          facilityState: 'NC',
          facilityZip: 12345,
          latitude: 35,
          longitude: -80,
          county: 'Test County',
          source: 'Test',
          facilityPhone1: '555-1234',
          distanceToAsheboro: 10,
          pciCenter: 1,
        );

        service.linkHospitalInfoToDestination(hospital);

        verify(() => mockActiveDestinationRepository.activeDestination = any())
            .called(1);
      });
    });

    group('setAudioGuidanceType', () {
      test('should set audio guidance successfully', () async {
        when(() => mockGoogleNavigationRepository.setAudioGuidance(any()))
            .thenAnswer((_) async {});
        when(
          () => mockNavigationSettingsRepository.setAudioGuidanceType(
            value: any(named: 'value'),
          ),
        ).thenReturn(null);

        await service.setAudioGuidanceType(
          NavigationAudioGuidanceType.alertsAndGuidance,
        );

        verify(() => mockGoogleNavigationRepository.setAudioGuidance(any()))
            .called(1);
        verify(
          () => mockNavigationSettingsRepository.setAudioGuidanceType(
            value: NavigationAudioGuidanceType.alertsAndGuidance,
          ),
        ).called(1);
      });

      test('should throw exception when session not initialized', () async {
        when(() => mockGoogleNavigationRepository.setAudioGuidance(any()))
            .thenThrow(const SessionNotInitializedException());

        expect(
          () => service.setAudioGuidanceType(
            NavigationAudioGuidanceType.alertsAndGuidance,
          ),
          throwsA(
            isA<GoogleNavSetAudioGuidanceSessionNotInitializedException>(),
          ),
        );
      });
    });

    group('calculateDestinationRoutes', () {
      test('should calculate routes successfully', () async {
        final destination = Destinations(
          waypoints: [],
          displayOptions: NavigationDisplayOptions(),
        );
        when(() => mockActiveDestinationRepository.activeDestination)
            .thenReturn(
          ActiveDestination(
            destination: destination,
            destinationInfo: const Hospital(
              facilityBrandedName: 'Test Hospital',
              facilityAddress: '123 Test St',
              facilityCity: 'Test City',
              facilityState: 'NC',
              facilityZip: 12345,
              latitude: 35,
              longitude: -80,
              county: 'Test County',
              source: 'Test',
              facilityPhone1: '555-1234',
              distanceToAsheboro: 10,
              pciCenter: 1,
            ),
          ),
        );
        when(() => mockGoogleNavigationRepository.setDestinations(any()))
            .thenAnswer((_) async => NavigationRouteStatus.statusOk);

        final result = await service.calculateDestinationRoutes();

        expect(result, isTrue);
        verify(
          () => mockGoogleNavigationRepository.setDestinations(destination),
        ).called(1);
      });

      test('should throw exception when no destination set', () async {
        when(() => mockActiveDestinationRepository.activeDestination)
            .thenReturn(null);

        expect(
          () => service.calculateDestinationRoutes(),
          throwsA(isA<GoogleNavSetDestinationSessionNotInitializedException>()),
        );
      });

      test('should handle various route status errors', () async {
        final destination = Destinations(
          waypoints: [],
          displayOptions: NavigationDisplayOptions(),
        );
        when(() => mockActiveDestinationRepository.activeDestination)
            .thenReturn(
          ActiveDestination(
            destination: destination,
            destinationInfo: const Hospital(
              facilityBrandedName: 'Test Hospital',
              facilityAddress: '123 Test St',
              facilityCity: 'Test City',
              facilityState: 'NC',
              facilityZip: 12345,
              latitude: 35,
              longitude: -80,
              county: 'Test County',
              source: 'Test',
              facilityPhone1: '555-1234',
              distanceToAsheboro: 10,
              pciCenter: 1,
            ),
          ),
        );

        final testCases = [
          (
            NavigationRouteStatus.internalError,
            GoogleNavInternalErrorException
          ),
          (
            NavigationRouteStatus.routeNotFound,
            GoogleNavRouteNotFoundException
          ),
          (NavigationRouteStatus.networkError, GoogleNavNetworkErrorException),
          (
            NavigationRouteStatus.quotaExceeded,
            GoogleNavQuotaExceededException
          ),
        ];

        for (final testCase in testCases) {
          when(() => mockGoogleNavigationRepository.setDestinations(any()))
              .thenAnswer((_) async => testCase.$1);

          expect(
            () => service.calculateDestinationRoutes(),
            throwsA(isA<dynamic>()),
          );
        }
      });
    });

    group('calculateRouteSegments', () {
      test('should return route segments', () async {
        final segments = <RouteSegment>[
          RouteSegment(
            destinationLatLng: const LatLng(latitude: 35, longitude: -80),
            latLngs: [],
            destinationWaypoint: NavigationWaypoint.withLatLngTarget(
              title: 'Test',
              target: const LatLng(latitude: 35, longitude: -80),
            ),
          ),
        ];
        when(() => mockGoogleNavigationRepository.getRouteSegments())
            .thenAnswer((_) async => segments);

        final result = await service.calculateRouteSegments();

        expect(result, equals(segments));
      });

      test('should throw exception when no segments', () async {
        when(() => mockGoogleNavigationRepository.getRouteSegments())
            .thenAnswer((_) async => []);

        expect(
          () => service.calculateRouteSegments(),
          throwsA(isA<GoogleNavRouteSegmentsEmptyException>()),
        );
      });

      test('should throw exception when session not initialized', () async {
        when(() => mockGoogleNavigationRepository.getRouteSegments())
            .thenThrow(const SessionNotInitializedException());

        expect(
          () => service.calculateRouteSegments(),
          throwsA(isA<GoogleNavRouteSegmentsSessionNotInitializedException>()),
        );
      });
    });

    group('clearDestinations', () {
      test('should clear destinations successfully', () async {
        when(() => mockGoogleNavigationRepository.clearDestinations())
            .thenAnswer((_) async {});

        final result = await service.clearDestinations();

        expect(result, isFalse);
        verify(() => mockGoogleNavigationRepository.clearDestinations())
            .called(1);
      });

      test('should throw exception when session not initialized', () async {
        when(() => mockGoogleNavigationRepository.clearDestinations())
            .thenThrow(const SessionNotInitializedException());

        expect(
          () => service.clearDestinations(),
          throwsA(
            isA<GoogleNavClearDestinationSessionNotInitializedException>(),
          ),
        );
      });
    });

    group('startDrivingDirections', () {
      test('should start guidance without simulation', () async {
        when(() => mockGoogleNavigationRepository.startGuidance())
            .thenAnswer((_) async {});
        when(() => mockGoogleNavigationRepository.isGuidanceRunning())
            .thenAnswer((_) async => true);

        await service.startDrivingDirections(includeSimulation: false);

        verify(() => mockGoogleNavigationRepository.startGuidance()).called(1);
        verifyNever(
          () => mockGoogleNavigationRepository
              .simulateLocationsAlongExistingRouteWithOptions(any()),
        );
      });

      test('should start guidance with simulation when enabled', () async {
        when(() => mockNavigationSettingsRepository.navigationSettings)
            .thenReturn(
          const NavigationSettings(
            shouldSimulateLocation: true,
            simulationSpeedMultiplier: 2,
          ),
        );
        when(() => mockGoogleNavigationRepository.startGuidance())
            .thenAnswer((_) async {});
        when(() => mockGoogleNavigationRepository.isGuidanceRunning())
            .thenAnswer((_) async => true);
        when(
          () => mockGoogleNavigationRepository
              .simulateLocationsAlongExistingRouteWithOptions(any()),
        ).thenAnswer((_) async {});

        await service.startDrivingDirections();

        verify(() => mockGoogleNavigationRepository.startGuidance()).called(1);
        verify(
          () => mockGoogleNavigationRepository
              .simulateLocationsAlongExistingRouteWithOptions(any()),
        ).called(1);
      });
    });

    group('stopDrivingDirections', () {
      test('should stop guidance without simulation', () async {
        when(() => mockGoogleNavigationRepository.stopGuidance())
            .thenAnswer((_) async {});
        when(() => mockGoogleNavigationRepository.isGuidanceRunning())
            .thenAnswer((_) async => false);

        await service.stopDrivingDirections(includeSimulation: false);

        verify(() => mockGoogleNavigationRepository.stopGuidance()).called(1);
        verifyNever(() => mockGoogleNavigationRepository.stopSimulation());
      });

      test('should stop guidance with simulation when enabled', () async {
        when(() => mockNavigationSettingsRepository.navigationSettings)
            .thenReturn(
          const NavigationSettings(
            shouldSimulateLocation: true,
          ),
        );
        when(() => mockGoogleNavigationRepository.stopGuidance())
            .thenAnswer((_) async {});
        when(() => mockGoogleNavigationRepository.isGuidanceRunning())
            .thenAnswer((_) async => false);
        when(() => mockGoogleNavigationRepository.stopSimulation())
            .thenAnswer((_) async {});

        await service.stopDrivingDirections();

        verify(() => mockGoogleNavigationRepository.stopGuidance()).called(1);
        verify(() => mockGoogleNavigationRepository.stopSimulation()).called(1);
      });
    });

    group('simulation methods', () {
      test('simulateUserLocation should simulate location', () async {
        const location = AppWaypoint(
          latitude: 35,
          longitude: -80,
          label: 'Test',
        );
        when(() => mockGoogleNavigationRepository.simulateUserLocation(any()))
            .thenAnswer((_) async {});

        await service.simulateUserLocation(location);

        verify(() => mockGoogleNavigationRepository.simulateUserLocation(any()))
            .called(1);
      });

      test('simulateUserLocation should throw when session not initialized',
          () async {
        const location = AppWaypoint(
          latitude: 35,
          longitude: -80,
          label: 'Test',
        );
        when(() => mockGoogleNavigationRepository.simulateUserLocation(any()))
            .thenThrow(const SessionNotInitializedException());

        expect(
          () => service.simulateUserLocation(location),
          throwsA(
            isA<GoogleNavSetUserLocationSessionNotInitializedException>(),
          ),
        );
      });

      test('simulateLocationsAlongExistingRoute should simulate', () async {
        when(() => mockGoogleNavigationRepository.simulateLocationsAlongExistingRoute())
            .thenAnswer((_) async {});

        await service.simulateLocationsAlongExistingRoute();

        verify(() => mockGoogleNavigationRepository.simulateLocationsAlongExistingRoute())
            .called(1);
      });

      test('simulateLocationsAlongExistingRoute should throw when session not initialized',
          () async {
        when(() => mockGoogleNavigationRepository.simulateLocationsAlongExistingRoute())
            .thenThrow(const SessionNotInitializedException());

        expect(
          () => service.simulateLocationsAlongExistingRoute(),
          throwsA(
            isA<GoogleNavSimulateLocationsSessionNotInitializedException>(),
          ),
        );
      });

      test('simulateLocationsAlongExistingRouteWithOptions should simulate', () async {
        final options = SimulationOptions(speedMultiplier: 2);
        when(() => mockGoogleNavigationRepository
                .simulateLocationsAlongExistingRouteWithOptions(options),)
            .thenAnswer((_) async {});

        await service.simulateLocationsAlongExistingRouteWithOptions(options);

        verify(() => mockGoogleNavigationRepository
                .simulateLocationsAlongExistingRouteWithOptions(options),)
            .called(1);
      });

      test('simulateLocationsAlongExistingRouteWithOptions should throw when session not initialized',
          () async {
        final options = SimulationOptions(speedMultiplier: 2);
        when(() => mockGoogleNavigationRepository
                .simulateLocationsAlongExistingRouteWithOptions(options),)
            .thenThrow(const SessionNotInitializedException());

        expect(
          () => service.simulateLocationsAlongExistingRouteWithOptions(options),
          throwsA(
            isA<GoogleNavSimulateLocationsSessionNotInitializedException>(),
          ),
        );
      });

      test('pauseSimulation should pause simulation', () async {
        when(() => mockGoogleNavigationRepository.pauseSimulation())
            .thenAnswer((_) async {});

        await service.pauseSimulation();

        verify(() => mockGoogleNavigationRepository.pauseSimulation())
            .called(1);
      });

      test('pauseSimulation should throw when session not initialized',
          () async {
        when(() => mockGoogleNavigationRepository.pauseSimulation())
            .thenThrow(const SessionNotInitializedException());

        expect(
          () => service.pauseSimulation(),
          throwsA(
            isA<GoogleNavPauseSimulationSessionNotInitializedException>(),
          ),
        );
      });

      test('resumeSimulation should resume simulation', () async {
        when(() => mockGoogleNavigationRepository.resumeSimulation())
            .thenAnswer((_) async {});

        await service.resumeSimulation();

        verify(() => mockGoogleNavigationRepository.resumeSimulation())
            .called(1);
      });

      test('resumeSimulation should throw when session not initialized',
          () async {
        when(() => mockGoogleNavigationRepository.resumeSimulation())
            .thenThrow(const SessionNotInitializedException());

        expect(
          () => service.resumeSimulation(),
          throwsA(
            isA<GoogleNavResumeSimulationSessionNotInitializedException>(),
          ),
        );
      });

      test('stopSimulation should stop simulation', () async {
        when(() => mockGoogleNavigationRepository.stopSimulation())
            .thenAnswer((_) async {});

        await service.stopSimulation();

        verify(() => mockGoogleNavigationRepository.stopSimulation()).called(1);
      });

      test('stopSimulation should throw when session not initialized',
          () async {
        when(() => mockGoogleNavigationRepository.stopSimulation())
            .thenThrow(const SessionNotInitializedException());

        expect(
          () => service.stopSimulation(),
          throwsA(
            isA<GoogleNavStopSimulationSessionNotInitializedException>(),
          ),
        );
      });
    });

    group('startGuidance and stopGuidance', () {
      test('startGuidance should start guidance successfully', () async {
        when(() => mockGoogleNavigationRepository.startGuidance())
            .thenAnswer((_) async {});
        when(() => mockGoogleNavigationRepository.isGuidanceRunning())
            .thenAnswer((_) async => true);

        final result = await service.startGuidance();

        expect(result, isTrue);
        verify(() => mockGoogleNavigationRepository.startGuidance()).called(1);
      });

      test('startGuidance should throw when guidance not running after start',
          () async {
        when(() => mockGoogleNavigationRepository.startGuidance())
            .thenAnswer((_) async {});
        when(() => mockGoogleNavigationRepository.isGuidanceRunning())
            .thenAnswer((_) async => false);

        expect(
          () => service.startGuidance(),
          throwsA(isA<GoogleNavStartGuidanceUnknownError>()),
        );
      });

      test('startGuidance should throw when session not initialized', () async {
        when(() => mockGoogleNavigationRepository.startGuidance())
            .thenThrow(const SessionNotInitializedException());

        expect(
          () => service.startGuidance(),
          throwsA(isA<GoogleNavStartGuidanceSessionNotInitializedException>()),
        );
      });

      test('stopGuidance should stop guidance successfully', () async {
        when(() => mockGoogleNavigationRepository.stopGuidance())
            .thenAnswer((_) async {});
        when(() => mockGoogleNavigationRepository.isGuidanceRunning())
            .thenAnswer((_) async => false);

        final result = await service.stopGuidance();

        expect(result, isFalse);
        verify(() => mockGoogleNavigationRepository.stopGuidance()).called(1);
      });

      test('stopGuidance should throw when guidance still running after stop',
          () async {
        when(() => mockGoogleNavigationRepository.stopGuidance())
            .thenAnswer((_) async {});
        when(() => mockGoogleNavigationRepository.isGuidanceRunning())
            .thenAnswer((_) async => true);

        expect(
          () => service.stopGuidance(),
          throwsA(isA<GoogleNavStopGuidanceUnknownError>()),
        );
      });

      test('stopGuidance should throw when session not initialized', () async {
        when(() => mockGoogleNavigationRepository.stopGuidance())
            .thenThrow(const SessionNotInitializedException());

        expect(
          () => service.stopGuidance(),
          throwsA(isA<GoogleNavStopGuidanceSessionNotInitializedException>()),
        );
      });
    });

    group('calculateDestinationRoutes additional statuses', () {
      test('should handle all route status errors correctly', () async {
        final destination = Destinations(
          waypoints: [],
          displayOptions: NavigationDisplayOptions(),
        );
        when(() => mockActiveDestinationRepository.activeDestination)
            .thenReturn(
          ActiveDestination(
            destination: destination,
            destinationInfo: const Hospital(
              facilityBrandedName: 'Test Hospital',
              facilityAddress: '123 Test St',
              facilityCity: 'Test City',
              facilityState: 'NC',
              facilityZip: 12345,
              latitude: 35,
              longitude: -80,
              county: 'Test County',
              source: 'Test',
              facilityPhone1: '555-1234',
              distanceToAsheboro: 10,
              pciCenter: 1,
            ),
          ),
        );

        final additionalTestCases = [
          (
            NavigationRouteStatus.quotaCheckFailed,
            GoogleNavQuotaCheckFailedException
          ),
          (
            NavigationRouteStatus.apiKeyNotAuthorized,
            GoogleNavApiKeyNotAuthorizedException
          ),
          (
            NavigationRouteStatus.statusCanceled,
            GoogleNavStatusCanceledException
          ),
          (
            NavigationRouteStatus.duplicateWaypointsError,
            GoogleNavDuplicateWaypointsErrorException
          ),
          (
            NavigationRouteStatus.noWaypointsError,
            GoogleNavNoWaypointsErrorException
          ),
          (
            NavigationRouteStatus.locationUnavailable,
            GoogleNavLocationUnavailableException
          ),
          (
            NavigationRouteStatus.waypointError,
            GoogleNavWaypointErrorException
          ),
          (
            NavigationRouteStatus.travelModeUnsupported,
            GoogleNavTravelModeUnsupportedException
          ),
          (
            NavigationRouteStatus.unknown,
            GoogleNavUnknownException
          ),
          (
            NavigationRouteStatus.locationUnknown,
            GoogleNavLocationUnknownException
          ),
        ];

        for (final testCase in additionalTestCases) {
          when(() => mockGoogleNavigationRepository.setDestinations(any()))
              .thenAnswer((_) async => testCase.$1);

          expect(
            () => service.calculateDestinationRoutes(),
            throwsA(isA<dynamic>()),
          );
        }
      });

      test('should throw session not initialized exception', () async {
        final destination = Destinations(
          waypoints: [],
          displayOptions: NavigationDisplayOptions(),
        );
        when(() => mockActiveDestinationRepository.activeDestination)
            .thenReturn(
          ActiveDestination(
            destination: destination,
            destinationInfo: const Hospital(
              facilityBrandedName: 'Test Hospital',
              facilityAddress: '123 Test St',
              facilityCity: 'Test City',
              facilityState: 'NC',
              facilityZip: 12345,
              latitude: 35,
              longitude: -80,
              county: 'Test County',
              source: 'Test',
              facilityPhone1: '555-1234',
              distanceToAsheboro: 10,
              pciCenter: 1,
            ),
          ),
        );
        when(() => mockGoogleNavigationRepository.setDestinations(any()))
            .thenThrow(const SessionNotInitializedException());

        expect(
          () => service.calculateDestinationRoutes(),
          throwsA(isA<GoogleNavSetDestinationSessionNotInitializedException>()),
        );
      });
    });

    group('showTermsAndConditionsDialog', () {
      test('should show driver awareness disclaimer when requested', () async {
        when(
          () => mockGoogleNavigationRepository.showTermsAndConditionsDialog(
            title: any(named: 'title'),
            companyName: any(named: 'companyName'),
            shouldOnlyShowDriverAwarenessDisclaimer: true,
          ),
        ).thenAnswer((_) async => true);

        final result = await service.showTermsAndConditionsDialog(
          shouldOnlyShowDriverAwarenessDisclaimer: true,
        );

        expect(result, isTrue);
        verify(
          () => mockGoogleNavigationRepository.showTermsAndConditionsDialog(
            title: 'Nav STEMI',
            companyName: 'Atrium Health',
            shouldOnlyShowDriverAwarenessDisclaimer: true,
          ),
        ).called(1);
      });
    });
  });
}
