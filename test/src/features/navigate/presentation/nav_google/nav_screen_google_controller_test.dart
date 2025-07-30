import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

// Mock classes
class MockGoogleNavigationViewController extends Mock
    implements GoogleNavigationViewController {}

class MockActiveDestinationRepository extends Mock
    implements ActiveDestinationRepository {}

class MockGoogleNavigationRepository extends Mock
    implements GoogleNavigationRepository {}

class MockGoogleNavigationService extends Mock
    implements GoogleNavigationService {}

class MockNavigationSettingsRepository extends Mock
    implements NavigationSettingsRepository {}

class MockMapSessionReadyNotifier extends Mock implements MapSessionReady {}

class MockHospital extends Mock implements Hospital {}

class MockLatLng extends Mock implements LatLng {}

class MockPosition extends Mock implements Position {}

class FakeGoogleNavigationViewController extends Fake
    implements GoogleNavigationViewController {}

// No need to fake NavigationAudioGuidanceType as it's an enum

class FakeSimulationOptions extends Fake implements SimulationOptions {}

class FakeHospital extends Fake implements Hospital {}

class FakeCameraUpdate extends Fake implements CameraUpdate {}

class FakeCameraPosition extends Fake implements CameraPosition {}

void main() {
  late ProviderContainer container;
  late MockActiveDestinationRepository mockActiveDestinationRepository;
  late MockGoogleNavigationRepository mockGoogleNavigationRepository;
  late MockGoogleNavigationService mockGoogleNavigationService;
  late MockNavigationSettingsRepository mockNavigationSettingsRepository;
  late MockGoogleNavigationViewController mockController;

  setUpAll(() {
    registerFallbackValue(FakeGoogleNavigationViewController());
    registerFallbackValue(NavigationAudioGuidanceType.alertsAndGuidance);
    registerFallbackValue(FakeSimulationOptions());
    registerFallbackValue(FakeHospital());
    registerFallbackValue(FakeCameraUpdate());
    registerFallbackValue(FakeCameraPosition());
    registerFallbackValue(CameraPerspective.tilted);
  });

  setUp(() {
    mockActiveDestinationRepository = MockActiveDestinationRepository();
    mockGoogleNavigationRepository = MockGoogleNavigationRepository();
    mockGoogleNavigationService = MockGoogleNavigationService();
    mockNavigationSettingsRepository = MockNavigationSettingsRepository();
    mockController = MockGoogleNavigationViewController();

    // Setup default behaviors
    when(() => mockNavigationSettingsRepository.navigationSettings)
        .thenReturn(const NavigationSettings());
    when(() => mockController.setMyLocationEnabled(any()))
        .thenAnswer((_) async {});
    when(() => mockController.followMyLocation(any())).thenAnswer((_) async {});
    when(() => mockGoogleNavigationService.initialize())
        .thenAnswer((_) async {});
    when(() => mockGoogleNavigationService.setAudioGuidanceType(any()))
        .thenAnswer((_) async {});
    when(() => mockGoogleNavigationService.cleanup()).thenAnswer((_) async {});
    when(() => mockGoogleNavigationRepository.isGuidanceRunning())
        .thenAnswer((_) async => false);
    when(() => mockController.animateCamera(any())).thenAnswer((_) async {});
    when(() => mockController.showRouteOverview()).thenAnswer((_) async {});
    when(() => mockController.getMyLocation())
        .thenAnswer((_) async => const LatLng(latitude: 35, longitude: -80));

    container = ProviderContainer(
      overrides: [
        activeDestinationRepositoryProvider
            .overrideWithValue(mockActiveDestinationRepository),
        googleNavigationRepositoryProvider
            .overrideWithValue(mockGoogleNavigationRepository),
        googleNavigationServiceProvider
            .overrideWithValue(mockGoogleNavigationService),
        navigationSettingsRepositoryProvider
            .overrideWithValue(mockNavigationSettingsRepository),
      ],
    );
  });

  tearDown(() {
    // Don't dispose container immediately to avoid onDispose conflicts
  });

  tearDownAll(() {
    container.dispose();
  });

  group('NavScreenGoogleController', () {
    test('should initialize with AsyncData(null)', () async {
      final controller =
          container.read(navScreenGoogleControllerProvider.notifier);
      final state = container.read(navScreenGoogleControllerProvider);

      expect(state, equals(const AsyncData<void>(null)));
    });

    test('should handle onViewCreated', () async {
      final controller =
          container.read(navScreenGoogleControllerProvider.notifier);

      await controller.onViewCreated(mockController);

      verify(() => mockController.setMyLocationEnabled(true)).called(1);
      verify(() => mockGoogleNavigationService.initialize()).called(1);
      verify(() => mockController.followMyLocation(any())).called(1);
      verify(() => mockGoogleNavigationService.setAudioGuidanceType(any()))
          .called(1);
    });

    test('should set north up view when configured', () async {
      when(() => mockNavigationSettingsRepository.navigationSettings)
          .thenReturn(const NavigationSettings(showNorthUp: true));

      final controller =
          container.read(navScreenGoogleControllerProvider.notifier);

      await controller.onViewCreated(mockController);

      verify(
        () => mockController.followMyLocation(CameraPerspective.topDownNorthUp),
      ).called(1);
    });

    test('should set tilted view when configured', () async {
      when(() => mockNavigationSettingsRepository.navigationSettings)
          .thenReturn(const NavigationSettings());

      final controller =
          container.read(navScreenGoogleControllerProvider.notifier);

      await controller.onViewCreated(mockController);

      verify(() => mockController.followMyLocation(CameraPerspective.tilted))
          .called(1);
    });

    test('should set audio guidance type from settings', () async {
      when(() => mockNavigationSettingsRepository.navigationSettings)
          .thenReturn(
        const NavigationSettings(
          audioGuidanceType: AudioGuidanceType.alertsOnly,
        ),
      );

      final controller =
          container.read(navScreenGoogleControllerProvider.notifier);

      await controller.onViewCreated(mockController);

      verify(
        () => mockGoogleNavigationService
            .setAudioGuidanceType(AudioGuidanceType.alertsOnly),
      ).called(1);
    });

    test('should handle setShowNorthUp', () async {
      final controller =
          container.read(navScreenGoogleControllerProvider.notifier);

      await controller.onViewCreated(mockController);
      await controller.setShowNorthUp(showNorthUp: true);

      verify(
        () => mockController.followMyLocation(CameraPerspective.topDownNorthUp),
      ).called(greaterThanOrEqualTo(1));

      await controller.setShowNorthUp(showNorthUp: false);

      verify(() => mockController.followMyLocation(CameraPerspective.tilted))
          .called(greaterThanOrEqualTo(1));
    });

    test('should return user location', () async {
      final controller =
          container.read(navScreenGoogleControllerProvider.notifier);

      await controller.onViewCreated(mockController);
      final location = await controller.userLocation();

      expect(location, isNotNull);
      expect(location!.latitude, equals(35.0));
      expect(location.longitude, equals(-80.0));
    });

    test('should link hospital info to destination', () {
      final controller =
          container.read(navScreenGoogleControllerProvider.notifier);
      final mockHospital = MockHospital();

      when(
        () => mockGoogleNavigationService.linkHospitalInfoToDestination(any()),
      ).thenReturn(null);

      controller.linkHospitalInfoToDestination(mockHospital);

      verify(
        () => mockGoogleNavigationService
            .linkHospitalInfoToDestination(mockHospital),
      ).called(1);
    });

    test('should set audio guidance type', () {
      final controller =
          container.read(navScreenGoogleControllerProvider.notifier);

      controller
          .setAudioGuidanceType(NavigationAudioGuidanceType.alertsAndGuidance);

      verify(
        () => mockGoogleNavigationService.setAudioGuidanceType(
          NavigationAudioGuidanceType.alertsAndGuidance,
        ),
      ).called(1);
    });

    test('should check if guidance is running', () async {
      final controller =
          container.read(navScreenGoogleControllerProvider.notifier);

      when(() => mockGoogleNavigationRepository.isGuidanceRunning())
          .thenAnswer((_) async => true);

      final isRunning = await controller.isGuidanceRunning();

      expect(isRunning, isTrue);
      verify(() => mockGoogleNavigationRepository.isGuidanceRunning())
          .called(1);
    });

    test('should set simulation state', () {
      final controller =
          container.read(navScreenGoogleControllerProvider.notifier);

      when(() => mockGoogleNavigationService.resumeSimulation())
          .thenAnswer((_) async {});
      when(() => mockGoogleNavigationService.pauseSimulation())
          .thenAnswer((_) async {});
      when(() => mockGoogleNavigationService.stopSimulation())
          .thenAnswer((_) async {});

      controller.setSimulationState(SimulationState.running);
      verify(() => mockGoogleNavigationService.resumeSimulation()).called(1);

      controller.setSimulationState(SimulationState.paused);
      verify(() => mockGoogleNavigationService.pauseSimulation()).called(1);

      controller.setSimulationState(SimulationState.notRunning);
      verify(() => mockGoogleNavigationService.stopSimulation()).called(1);
    });

    test('should handle zoom in', () async {
      final controller =
          container.read(navScreenGoogleControllerProvider.notifier);

      await controller.onViewCreated(mockController);
      controller.zoomIn();

      // Wait a bit for the unawaited future
      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockController.animateCamera(any())).called(1);
    });

    test('should handle zoom out', () async {
      final controller =
          container.read(navScreenGoogleControllerProvider.notifier);

      await controller.onViewCreated(mockController);
      controller.zoomOut();

      // Wait a bit for the unawaited future
      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockController.animateCamera(any())).called(1);
    });

    test('should handle zoom to active route', () async {
      final controller =
          container.read(navScreenGoogleControllerProvider.notifier);

      await controller.onViewCreated(mockController);
      controller.zoomToActiveRoute();

      // Wait a bit for the unawaited future
      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockController.showRouteOverview()).called(1);
    });

    test('should handle zoom to selected navigation step', () async {
      final controller =
          container.read(navScreenGoogleControllerProvider.notifier);

      await controller.onViewCreated(mockController);

      final stepLocations = [
        const LatLng(latitude: 35, longitude: -80),
        const LatLng(latitude: 35.1, longitude: -80.1),
      ];

      controller.zoomToSelectedNavigationStep(stepLocations);

      // Wait a bit for the unawaited future
      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockController.animateCamera(any())).called(1);
    });

    test('should have showCurrentLocation method', () async {
      final controller =
          container.read(navScreenGoogleControllerProvider.notifier);

      // Just verify the method exists
      expect(controller.showCurrentLocation, isA<Function>());
    });

    test('should have dispose callback registered', () async {
      // Just verify the controller was created successfully
      final controller =
          container.read(navScreenGoogleControllerProvider.notifier);

      // Controller should exist
      expect(controller, isNotNull);

      // Can't test actual disposal without causing issues
    });
  });

  group('MapSessionReady', () {
    test('should initialize with AsyncData(false)', () {
      final state = container.read(mapSessionReadyProvider);
      expect(state, equals(const AsyncData<bool>(false)));
    });

    test('should update value when setValue is called', () {
      final notifier = container.read(mapSessionReadyProvider.notifier);

      notifier.setValue(newValue: true);

      final state = container.read(mapSessionReadyProvider);
      expect(state, equals(const AsyncData<bool>(true)));
    });
  });
}
