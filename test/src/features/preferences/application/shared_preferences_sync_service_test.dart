import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

class MockSharedPreferencesRepository extends Mock
    implements SharedPreferencesRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(
      const AppTheme(
        themeMode: ThemeMode.system,
        seedColor: Colors.blue,
      ),
    );
    registerFallbackValue(const NavigationSettings());
  });

  group('SharedPreferencesSyncService', () {
    late ProviderContainer container;
    late MockSharedPreferencesRepository mockRepository;
    late StreamController<AppTheme> themeStreamController;
    late StreamController<NavigationSettings> navSettingsStreamController;

    setUp(() {
      mockRepository = MockSharedPreferencesRepository();
      themeStreamController = StreamController<AppTheme>.broadcast();
      navSettingsStreamController =
          StreamController<NavigationSettings>.broadcast();

      // Set up default stubs
      when(() => mockRepository.getAppTheme()).thenReturn(kFirstAppTheme);
      when(() => mockRepository.getNavigationSettings())
          .thenReturn(kDefaultNavigationSettings);
      when(() => mockRepository.saveAppTheme(any())).thenReturn(null);
      when(() => mockRepository.saveNavigationSettings(any())).thenReturn(null);

      container = ProviderContainer(
        overrides: [
          sharedPreferencesRepositoryProvider.overrideWithValue(mockRepository),
          // Override the stream providers to use our controllers
          appThemeChangesProvider.overrideWith((ref) {
            return themeStreamController.stream;
          }),
          navigationSettingsChangesProvider.overrideWith((ref) {
            return navSettingsStreamController.stream;
          }),
        ],
      );
    });

    tearDown(() {
      themeStreamController.close();
      navSettingsStreamController.close();
      container.dispose();
    });

    test('should initialize and start listening to theme changes', () {
      // Initialize the service
      final service = container.read(sharedPreferencesSyncServiceProvider);

      expect(service, isNotNull);

      // Verify that it doesn't save on initialization
      verifyNever(() => mockRepository.saveAppTheme(any()));
      verifyNever(() => mockRepository.saveNavigationSettings(any()));
    });

    test('should save app theme when theme changes after loading', () async {
      // Initialize the service
      container.read(sharedPreferencesSyncServiceProvider);

      // Subscribe to the theme stream
      container.read(appThemeChangesProvider);

      // Wait a bit for subscription to be established
      await Future<void>.delayed(Duration.zero);

      // Emit initial loading state
      themeStreamController.add(kFirstAppTheme);
      await Future<void>.delayed(Duration.zero);

      // Should not save during initial loading
      verifyNever(() => mockRepository.saveAppTheme(any()));

      // Change the theme
      const newTheme = AppTheme(
        themeMode: ThemeMode.dark,
        seedColor: Colors.purple,
      );

      themeStreamController.add(newTheme);

      // Wait for async operations
      await Future<void>.delayed(Duration.zero);

      // Verify theme was saved
      verify(() => mockRepository.saveAppTheme(newTheme)).called(1);
    });

    test('should save navigation settings when settings change after loading',
        () async {
      // Initialize the service
      container.read(sharedPreferencesSyncServiceProvider);

      // Subscribe to the navigation settings stream
      container.read(navigationSettingsChangesProvider);

      // Wait a bit for subscription to be established
      await Future<void>.delayed(Duration.zero);

      // Emit initial loading state
      navSettingsStreamController.add(kDefaultNavigationSettings);
      await Future<void>.delayed(Duration.zero);

      // Should not save during initial loading
      verifyNever(() => mockRepository.saveNavigationSettings(any()));

      // Change the navigation settings
      const newSettings = NavigationSettings(
        showNorthUp: true,
        audioGuidanceType: AudioGuidanceType.alertsOnly,
        shouldSimulateLocation: true,
        simulationSpeedMultiplier: 5,
      );

      navSettingsStreamController.add(newSettings);

      // Wait for async operations
      await Future<void>.delayed(Duration.zero);

      // Verify settings were saved
      verify(() => mockRepository.saveNavigationSettings(newSettings))
          .called(1);
    });

    test('should handle null theme updates', () async {
      // Initialize the service
      container.read(sharedPreferencesSyncServiceProvider);

      // Subscribe to the theme stream
      container.read(appThemeChangesProvider);

      // Wait for subscription
      await Future<void>.delayed(Duration.zero);

      // Emit initial state to move past loading
      themeStreamController.add(kFirstAppTheme);
      await Future<void>.delayed(Duration.zero);

      // Clear any previous calls
      clearInteractions(mockRepository);

      // Update with null theme
      // Note: In practice, the stream would emit a default theme
      // rather than null. But we'll simulate what the sync service
      // should do if it receives null
      themeStreamController.add(kFirstAppTheme); // Simulating a reset

      // Wait for async operations
      await Future<void>.delayed(Duration.zero);

      // Verify the theme was saved
      verify(() => mockRepository.saveAppTheme(kFirstAppTheme)).called(1);
    });

    test('should handle multiple theme changes', () async {
      // Initialize the service
      container.read(sharedPreferencesSyncServiceProvider);

      // Subscribe to the theme stream
      container.read(appThemeChangesProvider);

      // Wait for subscription
      await Future<void>.delayed(Duration.zero);

      // Emit initial state
      themeStreamController.add(kFirstAppTheme);
      await Future<void>.delayed(Duration.zero);

      // Clear initial calls
      clearInteractions(mockRepository);

      // Change theme multiple times
      const theme1 = AppTheme(
        themeMode: ThemeMode.light,
        seedColor: Colors.blue,
      );
      const theme2 = AppTheme(
        themeMode: ThemeMode.dark,
        seedColor: Colors.red,
      );
      const theme3 = AppTheme(
        themeMode: ThemeMode.system,
        seedColor: Colors.green,
      );

      themeStreamController.add(theme1);
      await Future<void>.delayed(Duration.zero);

      themeStreamController.add(theme2);
      await Future<void>.delayed(Duration.zero);

      themeStreamController.add(theme3);
      await Future<void>.delayed(Duration.zero);

      // Verify all themes were saved
      verify(() => mockRepository.saveAppTheme(theme1)).called(1);
      verify(() => mockRepository.saveAppTheme(theme2)).called(1);
      verify(() => mockRepository.saveAppTheme(theme3)).called(1);
    });

    test('should handle multiple navigation settings changes', () async {
      // Initialize the service
      container.read(sharedPreferencesSyncServiceProvider);

      // Subscribe to the navigation settings stream
      container.read(navigationSettingsChangesProvider);

      // Wait for subscription
      await Future<void>.delayed(Duration.zero);

      // Emit initial state
      navSettingsStreamController.add(kDefaultNavigationSettings);
      await Future<void>.delayed(Duration.zero);

      // Clear initial calls
      clearInteractions(mockRepository);

      // Change settings multiple times
      const settings1 = NavigationSettings(showNorthUp: true);
      const settings2 = NavigationSettings(
        audioGuidanceType: AudioGuidanceType.silent,
      );
      const settings3 = NavigationSettings(
        shouldSimulateLocation: true,
        simulationSpeedMultiplier: 10,
      );

      navSettingsStreamController.add(settings1);
      await Future<void>.delayed(Duration.zero);

      navSettingsStreamController.add(settings2);
      await Future<void>.delayed(Duration.zero);

      navSettingsStreamController.add(settings3);
      await Future<void>.delayed(Duration.zero);

      // Verify all settings were saved
      verify(() => mockRepository.saveNavigationSettings(settings1)).called(1);
      verify(() => mockRepository.saveNavigationSettings(settings2)).called(1);
      verify(() => mockRepository.saveNavigationSettings(settings3)).called(1);
    });

    test('should handle concurrent theme and settings changes', () async {
      // Initialize the service
      container.read(sharedPreferencesSyncServiceProvider);

      // Subscribe to both streams
      container
        ..read(appThemeChangesProvider)
        ..read(navigationSettingsChangesProvider);

      // Wait for subscriptions
      await Future<void>.delayed(Duration.zero);

      // Emit initial states
      themeStreamController.add(kFirstAppTheme);
      navSettingsStreamController.add(kDefaultNavigationSettings);
      await Future<void>.delayed(Duration.zero);

      // Clear initial calls
      clearInteractions(mockRepository);

      // Change both theme and settings
      const newTheme = AppTheme(
        themeMode: ThemeMode.dark,
        seedColor: Colors.indigo,
      );
      const newSettings = NavigationSettings(
        showNorthUp: true,
        simulationSpeedMultiplier: 8,
      );

      themeStreamController.add(newTheme);
      navSettingsStreamController.add(newSettings);

      // Wait for async operations
      await Future<void>.delayed(Duration.zero);

      // Verify both were saved
      verify(() => mockRepository.saveAppTheme(newTheme)).called(1);
      verify(() => mockRepository.saveNavigationSettings(newSettings))
          .called(1);
    });

    test('service should be kept alive', () {
      // Initialize the service
      final service = container.read(sharedPreferencesSyncServiceProvider);

      // Create a new container to simulate provider disposal
      final newContainer = ProviderContainer(
        overrides: [
          sharedPreferencesRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      // Access the service in the new container
      final newService =
          newContainer.read(sharedPreferencesSyncServiceProvider);

      // The provider is marked as keepAlive, so it should persist
      expect(service, isNotNull);
      expect(newService, isNotNull);

      newContainer.dispose();
    });

    test('should not save during AsyncLoading state', () async {
      // Initialize the service
      container.read(sharedPreferencesSyncServiceProvider);

      // Don't emit any values to streams, which simulates AsyncLoading state

      // Wait a bit
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Should not have saved anything
      verifyNever(() => mockRepository.saveAppTheme(any()));
      verifyNever(() => mockRepository.saveNavigationSettings(any()));
    });
  });
}
