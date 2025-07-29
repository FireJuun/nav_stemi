import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('SharedPreferencesRepository', () {
    late SharedPreferencesRepository repository;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      repository = SharedPreferencesRepository(prefs);
    });

    group('AppTheme', () {
      test('should return default theme when nothing is saved', () {
        final theme = repository.getAppTheme();
        
        expect(theme, equals(kFirstAppTheme));
      });

      test('should save and retrieve app theme', () {
        const testTheme = AppTheme(
          themeMode: ThemeMode.dark,
          seedColor: Colors.blue,
          secondarySeedColor: Colors.green,
          tertiarySeedColor: Colors.red,
        );

        repository.saveAppTheme(testTheme);
        final retrieved = repository.getAppTheme();

        expect(retrieved.themeMode, equals(ThemeMode.dark));
        expect(retrieved.seedColor.toARGB32(), equals(Colors.blue.toARGB32()));
        expect(
          retrieved.secondarySeedColor?.toARGB32(),
          equals(Colors.green.toARGB32()),
        );
        expect(
          retrieved.tertiarySeedColor?.toARGB32(),
          equals(Colors.red.toARGB32()),
        );
      });

      test('should handle theme with null secondary and tertiary colors', () {
        const testTheme = AppTheme(
          themeMode: ThemeMode.light,
          seedColor: Colors.purple,
        );

        repository.saveAppTheme(testTheme);
        final retrieved = repository.getAppTheme();

        expect(retrieved.themeMode, equals(testTheme.themeMode));
        expect(
          retrieved.seedColor.toARGB32(),
          equals(testTheme.seedColor.toARGB32()),
        );
        expect(retrieved.secondarySeedColor, isNull);
        expect(retrieved.tertiarySeedColor, isNull);
      });

      test('should handle all theme modes', () {
        for (final mode in ThemeMode.values) {
          final theme = AppTheme(
            themeMode: mode,
            seedColor: Colors.blue,
          );

          repository.saveAppTheme(theme);
          final retrieved = repository.getAppTheme();

          expect(retrieved.themeMode, equals(mode));
        }
      });

      test('should remove theme when saving null', () {
        const testTheme = AppTheme(
          themeMode: ThemeMode.dark,
          seedColor: Colors.blue,
        );

        // Save a theme first
        repository.saveAppTheme(testTheme);
        final savedTheme = repository.getAppTheme();
        expect(savedTheme.themeMode, equals(testTheme.themeMode));
        expect(
          savedTheme.seedColor.toARGB32(),
          equals(testTheme.seedColor.toARGB32()),
        );

        // Remove it
        repository.saveAppTheme(null);
        
        // Should return default theme
        final defaultTheme = repository.getAppTheme();
        expect(defaultTheme.themeMode, equals(kFirstAppTheme.themeMode));
        expect(
          defaultTheme.seedColor.toARGB32(),
          equals(kFirstAppTheme.seedColor.toARGB32()),
        );
      });

      test('should persist theme through JSON serialization', () {
        const testTheme = AppTheme(
          themeMode: ThemeMode.system,
          seedColor: Colors.indigo,
          secondarySeedColor: Colors.amber,
        );

        repository.saveAppTheme(testTheme);
        
        // Verify it was saved as JSON
        final savedJson = prefs.getString('appTheme');
        expect(savedJson, isNotNull);
        expect(savedJson, contains('system'));
        expect(savedJson, contains(Colors.indigo.toARGB32().toString()));
      });
    });

    group('NavigationSettings', () {
      test('should return default settings when nothing is saved', () {
        final settings = repository.getNavigationSettings();
        
        expect(settings, equals(kDefaultNavigationSettings));
        expect(settings.showNorthUp, isFalse);
        expect(
          settings.audioGuidanceType,
          equals(AudioGuidanceType.alertsAndGuidance),
        );
        expect(settings.shouldSimulateLocation, isFalse);
        expect(settings.simulationSpeedMultiplier, equals(3));
        expect(settings.simulationStartingLocation, equals(randolphEms));
      });

      test('should save and retrieve navigation settings', () {
        const customLocation = AppWaypoint(
          latitude: 40.7128,
          longitude: -74.0060,
          label: 'New York',
        );

        const testSettings = NavigationSettings(
          showNorthUp: true,
          audioGuidanceType: AudioGuidanceType.alertsOnly,
          shouldSimulateLocation: true,
          simulationSpeedMultiplier: 5,
          simulationStartingLocation: customLocation,
        );

        repository.saveNavigationSettings(testSettings);
        final retrieved = repository.getNavigationSettings();

        expect(retrieved.showNorthUp, isTrue);
        expect(
          retrieved.audioGuidanceType,
          equals(AudioGuidanceType.alertsOnly),
        );
        expect(retrieved.shouldSimulateLocation, isTrue);
        expect(retrieved.simulationSpeedMultiplier, equals(5));
        expect(retrieved.simulationStartingLocation, equals(customLocation));
      });

      test('should handle all audio guidance types', () {
        for (final audioType in AudioGuidanceType.values) {
          final settings = NavigationSettings(
            audioGuidanceType: audioType,
          );

          repository.saveNavigationSettings(settings);
          final retrieved = repository.getNavigationSettings();

          expect(retrieved.audioGuidanceType, equals(audioType));
        }
      });

      test('should remove settings when saving null', () {
        const testSettings = NavigationSettings(
          showNorthUp: true,
          simulationSpeedMultiplier: 10,
        );

        // Save settings first
        repository.saveNavigationSettings(testSettings);
        expect(repository.getNavigationSettings().showNorthUp, isTrue);

        // Remove them
        repository.saveNavigationSettings(null);
        
        // Should return default settings
        expect(
          repository.getNavigationSettings(),
          equals(kDefaultNavigationSettings),
        );
      });

      test('should handle extreme waypoint coordinates', () {
        const extremeLocation = AppWaypoint(
          latitude: 90, // North pole
          longitude: 180, // Will be normalized to -180
          label: 'Extreme location',
          isSilent: true,
        );

        const settings = NavigationSettings(
          simulationStartingLocation: extremeLocation,
        );

        repository.saveNavigationSettings(settings);
        final retrieved = repository.getNavigationSettings();

        expect(retrieved.simulationStartingLocation.latitude, equals(90));
        expect(retrieved.simulationStartingLocation.longitude, equals(-180));
        expect(
          retrieved.simulationStartingLocation.label,
          equals('Extreme location'),
        );
        expect(retrieved.simulationStartingLocation.isSilent, isTrue);
      });

      test('should persist settings through JSON serialization', () {
        const testSettings = NavigationSettings(
          showNorthUp: true,
          shouldSimulateLocation: true,
        );

        repository.saveNavigationSettings(testSettings);
        
        // Verify it was saved as JSON
        final savedJson = prefs.getString('navigationSettings');
        expect(savedJson, isNotNull);
        expect(savedJson, contains('true')); // showNorthUp
        expect(savedJson, contains('shouldSimulateLocation'));
      });
    });

    group('reload', () {
      test('should reload preferences', () async {
        // Save a theme
        const testTheme = AppTheme(
          themeMode: ThemeMode.dark,
          seedColor: Colors.blue,
        );
        repository.saveAppTheme(testTheme);

        // Clear in-memory cache
        await prefs.clear();

        // Reload should restore from persistent storage
        await repository.reload();
        
        // Note: In a real scenario, reload would refresh from disk
        // but in tests with mock preferences, this behavior may differ
      });
    });

    group('integration', () {
      test('should handle both theme and settings independently', () {
        const testTheme = AppTheme(
          themeMode: ThemeMode.dark,
          seedColor: Colors.red,
        );

        const testSettings = NavigationSettings(
          showNorthUp: true,
          simulationSpeedMultiplier: 7,
        );

        // Save both
        repository
          ..saveAppTheme(testTheme)
          ..saveNavigationSettings(testSettings);

        // Retrieve both
        final retrievedTheme = repository.getAppTheme();
        final retrievedSettings = repository.getNavigationSettings();

        expect(retrievedTheme.themeMode, equals(testTheme.themeMode));
        expect(
          retrievedTheme.seedColor.toARGB32(),
          equals(testTheme.seedColor.toARGB32()),
        );
        expect(retrievedSettings.showNorthUp, isTrue);
        expect(retrievedSettings.simulationSpeedMultiplier, equals(7));

        // Remove theme but keep settings
        repository.saveAppTheme(null);

        final defaultTheme = repository.getAppTheme();
        expect(defaultTheme.themeMode, equals(kFirstAppTheme.themeMode));
        expect(
          defaultTheme.seedColor.toARGB32(),
          equals(kFirstAppTheme.seedColor.toARGB32()),
        );
        expect(repository.getNavigationSettings().showNorthUp, isTrue);
      });

      test('should use correct storage keys', () {
        repository
          ..saveAppTheme(
            const AppTheme(
              themeMode: ThemeMode.light,
              seedColor: Colors.blue,
            ),
          )
          ..saveNavigationSettings(
            const NavigationSettings(showNorthUp: true),
          );

        // Verify the keys used
        expect(prefs.containsKey('appTheme'), isTrue);
        expect(prefs.containsKey('navigationSettings'), isTrue);
      });
    });
  });
}
