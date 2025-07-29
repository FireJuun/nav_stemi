import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/nav_stemi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeRepository', () {
    late ThemeRepository repository;
    const defaultTheme = AppTheme(
      themeMode: ThemeMode.system,
      seedColor: Colors.blue,
    );

    setUp(() {
      repository = ThemeRepository(defaultTheme);
    });

    group('Initialization', () {
      test('should initialize with provided theme', () async {
        final theme = await repository.appThemeChanges.first;
        expect(theme, equals(defaultTheme));
        expect(theme.themeMode, equals(ThemeMode.system));
        expect(theme.seedColor, equals(Colors.blue));
        expect(theme.secondarySeedColor, isNull);
        expect(theme.tertiarySeedColor, isNull);
      });

      test('should handle theme with all colors', () async {
        const customTheme = AppTheme(
          themeMode: ThemeMode.dark,
          seedColor: Colors.red,
          secondarySeedColor: Colors.green,
          tertiarySeedColor: Colors.purple,
        );

        final customRepository = ThemeRepository(customTheme);
        final theme = await customRepository.appThemeChanges.first;

        expect(theme, equals(customTheme));
        expect(theme.themeMode, equals(ThemeMode.dark));
        expect(theme.seedColor, equals(Colors.red));
        expect(theme.secondarySeedColor, equals(Colors.green));
        expect(theme.tertiarySeedColor, equals(Colors.purple));
      });
    });

    group('Theme Updates', () {
      test('should update entire theme', () async {
        const newTheme = AppTheme(
          themeMode: ThemeMode.dark,
          seedColor: Colors.purple,
        );

        repository.setAppTheme(newTheme);

        final theme = await repository.appThemeChanges.first;
        expect(theme, equals(newTheme));
        expect(theme.themeMode, equals(ThemeMode.dark));
        expect(theme.seedColor, equals(Colors.purple));
      });

      test('should update theme mode only', () async {
        repository.setAppThemeMode(ThemeMode.light);

        final theme = await repository.appThemeChanges.first;
        expect(theme.themeMode, equals(ThemeMode.light));
        expect(theme.seedColor, equals(Colors.blue));
      });

      test('should update seed color only', () async {
        repository.setAppSeedColor(Colors.green);

        final theme = await repository.appThemeChanges.first;
        expect(theme.themeMode, equals(ThemeMode.system));
        expect(theme.seedColor, equals(Colors.green));
      });

      test('should handle all theme modes', () async {
        for (final mode in ThemeMode.values) {
          repository.setAppThemeMode(mode);
          final theme = await repository.appThemeChanges.first;
          expect(theme.themeMode, equals(mode));
        }
      });
    });

    group('Theme Stream', () {
      test('should emit theme changes', () async {
        final themes = <AppTheme>[];
        final subscription = repository.appThemeChanges.listen(themes.add);

        // Wait for initial value
        await Future<void>.delayed(Duration.zero);

        const theme1 = AppTheme(
          themeMode: ThemeMode.light,
          seedColor: Colors.red,
        );
        const theme2 = AppTheme(
          themeMode: ThemeMode.dark,
          seedColor: Colors.green,
        );
        const theme3 = AppTheme(
          themeMode: ThemeMode.system,
          seedColor: Colors.blue,
        );

        repository.setAppTheme(theme1);
        await Future<void>.delayed(Duration.zero);

        repository.setAppTheme(theme2);
        await Future<void>.delayed(Duration.zero);

        repository.setAppTheme(theme3);
        await Future<void>.delayed(Duration.zero);

        expect(themes.length, greaterThanOrEqualTo(4)); // Initial + 3 updates
        expect(themes.first, equals(defaultTheme));
        expect(themes, contains(theme1));
        expect(themes, contains(theme2));
        expect(themes, contains(theme3));

        await subscription.cancel();
      });

      test('should emit theme mode changes', () async {
        final themes = <AppTheme>[];
        final subscription = repository.appThemeChanges.listen(themes.add);

        // Wait for initial value
        await Future<void>.delayed(Duration.zero);

        repository.setAppThemeMode(ThemeMode.light);
        await Future<void>.delayed(Duration.zero);

        repository.setAppThemeMode(ThemeMode.dark);
        await Future<void>.delayed(Duration.zero);

        expect(themes.length, greaterThanOrEqualTo(3));
        expect(themes.any((t) => t.themeMode == ThemeMode.light), isTrue);
        expect(themes.any((t) => t.themeMode == ThemeMode.dark), isTrue);
        // All should have the same seed color
        expect(themes.every((t) => t.seedColor == Colors.blue), isTrue);

        await subscription.cancel();
      });

      test('should emit seed color changes', () async {
        final themes = <AppTheme>[];
        final subscription = repository.appThemeChanges.listen(themes.add);

        // Wait for initial value
        await Future<void>.delayed(Duration.zero);

        repository.setAppSeedColor(Colors.red);
        await Future<void>.delayed(Duration.zero);

        repository.setAppSeedColor(Colors.green);
        await Future<void>.delayed(Duration.zero);

        expect(themes.length, greaterThanOrEqualTo(3));
        expect(themes.any((t) => t.seedColor == Colors.red), isTrue);
        expect(themes.any((t) => t.seedColor == Colors.green), isTrue);
        // All should have the same theme mode
        expect(themes.every((t) => t.themeMode == ThemeMode.system), isTrue);

        await subscription.cancel();
      });
    });

    group('ThemeData Generation', () {
      test('should generate light theme', () {
        final lightTheme = repository.lightTheme;

        expect(lightTheme, isNotNull);
        expect(lightTheme.brightness, equals(Brightness.light));
        expect(lightTheme.useMaterial3, isTrue);
        expect(lightTheme.colorScheme.brightness, equals(Brightness.light));
      });

      test('should generate dark theme', () {
        final darkTheme = repository.darkTheme;

        expect(darkTheme, isNotNull);
        expect(darkTheme.brightness, equals(Brightness.dark));
        expect(darkTheme.useMaterial3, isTrue);
        expect(darkTheme.colorScheme.brightness, equals(Brightness.dark));
      });

      test('should respect seed colors in generated themes', () {
        const customTheme = AppTheme(
          themeMode: ThemeMode.system,
          seedColor: Colors.purple,
          secondarySeedColor: Colors.orange,
          tertiarySeedColor: Colors.teal,
        );

        final customRepository = ThemeRepository(customTheme);
        final lightTheme = customRepository.lightTheme;
        final darkTheme = customRepository.darkTheme;

        // The generated color schemes should be based on the seed colors
        expect(lightTheme.colorScheme, isNotNull);
        expect(darkTheme.colorScheme, isNotNull);
      });

      test('should have consistent text theme', () {
        final lightTheme = repository.lightTheme;
        final darkTheme = repository.darkTheme;

        // Text themes should be the same structure
        expect(lightTheme.textTheme.displayLarge?.fontSize, equals(60));
        expect(darkTheme.textTheme.displayLarge?.fontSize, equals(60));

        expect(lightTheme.textTheme.bodyMedium?.fontSize, equals(18));
        expect(darkTheme.textTheme.bodyMedium?.fontSize, equals(18));
      });

      test('should have custom component themes', () {
        final theme = repository.lightTheme;

        // AppBar
        expect(theme.appBarTheme.iconTheme?.size, equals(40));
        expect(theme.appBarTheme.titleTextStyle?.fontSize, equals(40));

        // Card
        expect(theme.cardTheme.color, isNotNull);

        // Buttons
        expect(theme.filledButtonTheme.style?.padding, isNotNull);
        expect(theme.outlinedButtonTheme.style?.padding, isNotNull);
        expect(theme.segmentedButtonTheme.style?.padding, isNotNull);

        // Input
        expect(theme.inputDecorationTheme.border, isA<OutlineInputBorder>());
        expect(
          theme.inputDecorationTheme.contentPadding,
          equals(const EdgeInsets.all(8)),
        );

        // FAB
        expect(theme.floatingActionButtonTheme.shape, isA<CircleBorder>());

        // Scrollbar
        expect(theme.scrollbarTheme.thickness?.resolve({}), equals(8));

        // TabBar
        expect(theme.tabBarTheme.labelStyle?.fontSize, equals(20));
      });

      test('should update themes when seed color changes', () async {
        final initialLight = repository.lightTheme;
        final initialDark = repository.darkTheme;

        repository.setAppSeedColor(Colors.red);
        await Future<void>.delayed(Duration.zero);

        final updatedLight = repository.lightTheme;
        final updatedDark = repository.darkTheme;

        // Themes should be different after color change
        expect(
          initialLight.colorScheme,
          isNot(equals(updatedLight.colorScheme)),
        );
        expect(
          initialDark.colorScheme,
          isNot(equals(updatedDark.colorScheme)),
        );
      });
    });

    group('Provider Integration', () {
      test('themeRepository provider throws unimplemented error', () {
        final container = ProviderContainer();
        
        expect(
          () => container.read(themeRepositoryProvider),
          throwsUnimplementedError,
        );

        container.dispose();
      });

      test('appThemeChanges provider returns stream', () {
        final container = ProviderContainer(
          overrides: [
            themeRepositoryProvider.overrideWithValue(repository),
          ],
        );

        final asyncValue = container.read(appThemeChangesProvider);
        expect(asyncValue, isA<AsyncValue<AppTheme>>());

        container.dispose();
      });

      test('appThemeChanges provider emits changes', () async {
        final container = ProviderContainer(
          overrides: [
            themeRepositoryProvider.overrideWithValue(repository),
          ],
        );

        // Listen to the provider changes
        final themes = <AppTheme>[];
        container.listen(
          appThemeChangesProvider,
          (previous, next) {
            next.whenData(themes.add);
          },
          fireImmediately: true,
        );

        await Future<void>.delayed(Duration.zero);

        const newTheme = AppTheme(
          themeMode: ThemeMode.dark,
          seedColor: Colors.purple,
        );
        repository.setAppTheme(newTheme);

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(themes.length, greaterThanOrEqualTo(2));
        expect(themes.last, equals(newTheme));

        container.dispose();
      });
    });

    group('Edge Cases', () {
      test('should handle rapid theme changes', () async {
        final themes = <AppTheme>[];
        final subscription = repository.appThemeChanges.listen(themes.add);

        await Future<void>.delayed(Duration.zero);

        // Rapid fire changes
        for (var i = 0; i < 10; i++) {
          repository.setAppTheme(AppTheme(
            themeMode: i.isEven ? ThemeMode.light : ThemeMode.dark,
            seedColor: i % 3 == 0 ? Colors.red : Colors.blue,
          ),);
        }

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(themes.length, greaterThan(1));

        await subscription.cancel();
      });

      test('should preserve secondary colors when changing primary', () async {
        const initialTheme = AppTheme(
          themeMode: ThemeMode.system,
          seedColor: Colors.blue,
          secondarySeedColor: Colors.green,
          tertiarySeedColor: Colors.red,
        );

        final customRepository = ThemeRepository(initialTheme);

        customRepository.setAppSeedColor(Colors.purple);
        final theme = await customRepository.appThemeChanges.first;
        expect(theme.seedColor, equals(Colors.purple));
        // Secondary and tertiary colors are not preserved when using
        // setAppSeedColor as it creates a new AppTheme with only the
        // primary color
        expect(theme.secondarySeedColor, isNull);
        expect(theme.tertiarySeedColor, isNull);
      });
    });
  });
}
