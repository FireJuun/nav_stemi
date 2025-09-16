import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/nav_stemi.dart';

void main() {
  group('AppTheme', () {
    group('Constructor', () {
      test('should create AppTheme with all properties', () {
        const theme = AppTheme(
          themeMode: ThemeMode.dark,
          seedColor: Colors.blue,
          secondarySeedColor: Colors.green,
          tertiarySeedColor: Colors.red,
        );

        expect(theme.themeMode, equals(ThemeMode.dark));
        expect(theme.seedColor, equals(Colors.blue));
        expect(theme.secondarySeedColor, equals(Colors.green));
        expect(theme.tertiarySeedColor, equals(Colors.red));
      });

      test('should create AppTheme with required properties only', () {
        const theme = AppTheme(
          themeMode: ThemeMode.light,
          seedColor: Colors.purple,
        );

        expect(theme.themeMode, equals(ThemeMode.light));
        expect(theme.seedColor, equals(Colors.purple));
        expect(theme.secondarySeedColor, isNull);
        expect(theme.tertiarySeedColor, isNull);
      });
    });

    group('copyWith', () {
      const original = AppTheme(
        themeMode: ThemeMode.system,
        seedColor: Colors.indigo,
        secondarySeedColor: Colors.amber,
        tertiarySeedColor: Colors.teal,
      );

      test('should copy with new themeMode', () {
        final copied = original.copyWith(themeMode: ThemeMode.dark);

        expect(copied.themeMode, equals(ThemeMode.dark));
        expect(copied.seedColor, equals(original.seedColor));
        expect(copied.secondarySeedColor, equals(original.secondarySeedColor));
        expect(copied.tertiarySeedColor, equals(original.tertiarySeedColor));
      });

      test('should copy with new seedColor', () {
        final copied = original.copyWith(seedColor: Colors.red);

        expect(copied.themeMode, equals(original.themeMode));
        expect(copied.seedColor, equals(Colors.red));
        expect(copied.secondarySeedColor, equals(original.secondarySeedColor));
        expect(copied.tertiarySeedColor, equals(original.tertiarySeedColor));
      });

      test('should copy with new secondarySeedColor', () {
        final copied = original.copyWith(secondarySeedColor: Colors.pink);

        expect(copied.themeMode, equals(original.themeMode));
        expect(copied.seedColor, equals(original.seedColor));
        expect(copied.secondarySeedColor, equals(Colors.pink));
        expect(copied.tertiarySeedColor, equals(original.tertiarySeedColor));
      });

      test('should copy with new tertiarySeedColor', () {
        final copied = original.copyWith(tertiarySeedColor: Colors.orange);

        expect(copied.themeMode, equals(original.themeMode));
        expect(copied.seedColor, equals(original.seedColor));
        expect(copied.secondarySeedColor, equals(original.secondarySeedColor));
        expect(copied.tertiarySeedColor, equals(Colors.orange));
      });

      test('should copy with all properties changed', () {
        final copied = original.copyWith(
          themeMode: ThemeMode.light,
          seedColor: Colors.cyan,
          secondarySeedColor: Colors.lime,
          tertiarySeedColor: Colors.brown,
        );

        expect(copied.themeMode, equals(ThemeMode.light));
        expect(copied.seedColor, equals(Colors.cyan));
        expect(copied.secondarySeedColor, equals(Colors.lime));
        expect(copied.tertiarySeedColor, equals(Colors.brown));
      });

      test('should return same object when no changes', () {
        final copied = original.copyWith();

        expect(copied.themeMode, equals(original.themeMode));
        expect(copied.seedColor, equals(original.seedColor));
        expect(copied.secondarySeedColor, equals(original.secondarySeedColor));
        expect(copied.tertiarySeedColor, equals(original.tertiarySeedColor));
      });
    });

    group('toMap', () {
      test('should convert to map with all properties', () {
        const theme = AppTheme(
          themeMode: ThemeMode.dark,
          seedColor: Colors.blue,
          secondarySeedColor: Colors.green,
          tertiarySeedColor: Colors.red,
        );

        final map = theme.toMap();

        expect(map['themeMode'], equals('dark'));
        expect(map['seedColor'], equals(Colors.blue.toARGB32()));
        expect(map['secondarySeedColor'], equals(Colors.green.toARGB32()));
        expect(map['tertiarySeedColor'], equals(Colors.red.toARGB32()));
      });

      test('should convert to map with null secondary colors', () {
        const theme = AppTheme(
          themeMode: ThemeMode.system,
          seedColor: Colors.purple,
        );

        final map = theme.toMap();

        expect(map['themeMode'], equals('system'));
        expect(map['seedColor'], equals(Colors.purple.toARGB32()));
        expect(map['secondarySeedColor'], isNull);
        expect(map['tertiarySeedColor'], isNull);
      });

      test('should handle all theme modes', () {
        for (final mode in ThemeMode.values) {
          final theme = AppTheme(
            themeMode: mode,
            seedColor: Colors.blue,
          );

          final map = theme.toMap();
          expect(map['themeMode'], equals(mode.name));
        }
      });
    });

    group('fromMap', () {
      test('should create from map with all properties', () {
        final map = {
          'themeMode': 'dark',
          'seedColor': Colors.blue.toARGB32(),
          'secondarySeedColor': Colors.green.toARGB32(),
          'tertiarySeedColor': Colors.red.toARGB32(),
        };

        final theme = AppTheme.fromMap(map);

        expect(theme.themeMode, equals(ThemeMode.dark));
        expect(theme.seedColor.toARGB32(), equals(Colors.blue.toARGB32()));
        expect(
          theme.secondarySeedColor?.toARGB32(),
          equals(Colors.green.toARGB32()),
        );
        expect(
          theme.tertiarySeedColor?.toARGB32(),
          equals(Colors.red.toARGB32()),
        );
      });

      test('should create from map with null secondary colors', () {
        final map = {
          'themeMode': 'light',
          'seedColor': Colors.purple.toARGB32(),
          'secondarySeedColor': null,
          'tertiarySeedColor': null,
        };

        final theme = AppTheme.fromMap(map);

        expect(theme.themeMode, equals(ThemeMode.light));
        expect(theme.seedColor.toARGB32(), equals(Colors.purple.toARGB32()));
        expect(theme.secondarySeedColor, isNull);
        expect(theme.tertiarySeedColor, isNull);
      });

      test('should handle invalid theme mode as light', () {
        final map = {
          'themeMode': 'invalid',
          'seedColor': Colors.blue.toARGB32(),
        };

        final theme = AppTheme.fromMap(map);

        expect(theme.themeMode, equals(ThemeMode.light));
      });

      test('should handle all valid theme modes', () {
        final modes = {
          'light': ThemeMode.light,
          'dark': ThemeMode.dark,
          'system': ThemeMode.system,
        };

        for (final entry in modes.entries) {
          final map = {
            'themeMode': entry.key,
            'seedColor': Colors.blue.toARGB32(),
          };

          final theme = AppTheme.fromMap(map);
          expect(theme.themeMode, equals(entry.value));
        }
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON', () {
        const theme = AppTheme(
          themeMode: ThemeMode.dark,
          seedColor: Colors.indigo,
          secondarySeedColor: Colors.amber,
        );

        final json = theme.toJson();

        expect(json, isA<String>());
        expect(json, contains('dark'));
        expect(json, contains(Colors.indigo.toARGB32().toString()));
        expect(json, contains(Colors.amber.toARGB32().toString()));
      });

      test('should deserialize from JSON', () {
        const original = AppTheme(
          themeMode: ThemeMode.system,
          seedColor: Colors.teal,
          tertiarySeedColor: Colors.pink,
        );

        final json = original.toJson();
        final deserialized = AppTheme.fromJson(json);

        expect(deserialized.themeMode, equals(original.themeMode));
        expect(
          deserialized.seedColor.toARGB32(),
          equals(original.seedColor.toARGB32()),
        );
        expect(deserialized.secondarySeedColor, isNull);
        expect(
          deserialized.tertiarySeedColor?.toARGB32(),
          equals(original.tertiarySeedColor?.toARGB32()),
        );
      });

      test('should handle round-trip serialization', () {
        const themes = [
          AppTheme(
            themeMode: ThemeMode.light,
            seedColor: Colors.blue,
          ),
          AppTheme(
            themeMode: ThemeMode.dark,
            seedColor: Colors.red,
            secondarySeedColor: Colors.green,
          ),
          AppTheme(
            themeMode: ThemeMode.system,
            seedColor: Colors.purple,
            secondarySeedColor: Colors.orange,
            tertiarySeedColor: Colors.cyan,
          ),
        ];

        for (final original in themes) {
          final json = original.toJson();
          final deserialized = AppTheme.fromJson(json);

          expect(deserialized.themeMode, equals(original.themeMode));
          expect(
            deserialized.seedColor.toARGB32(),
            equals(original.seedColor.toARGB32()),
          );
          expect(
            deserialized.secondarySeedColor?.toARGB32(),
            equals(original.secondarySeedColor?.toARGB32()),
          );
          expect(
            deserialized.tertiarySeedColor?.toARGB32(),
            equals(original.tertiarySeedColor?.toARGB32()),
          );
        }
      });
    });

    group('Equatable', () {
      test('should be equal when all properties are same', () {
        const theme1 = AppTheme(
          themeMode: ThemeMode.dark,
          seedColor: Colors.blue,
          secondarySeedColor: Colors.green,
          tertiarySeedColor: Colors.red,
        );

        const theme2 = AppTheme(
          themeMode: ThemeMode.dark,
          seedColor: Colors.blue,
          secondarySeedColor: Colors.green,
          tertiarySeedColor: Colors.red,
        );

        expect(theme1, equals(theme2));
        expect(theme1.hashCode, equals(theme2.hashCode));
      });

      test('should not be equal when theme mode differs', () {
        const theme1 = AppTheme(
          themeMode: ThemeMode.light,
          seedColor: Colors.blue,
        );

        const theme2 = AppTheme(
          themeMode: ThemeMode.dark,
          seedColor: Colors.blue,
        );

        expect(theme1, isNot(equals(theme2)));
      });

      test('should not be equal when seed color differs', () {
        const theme1 = AppTheme(
          themeMode: ThemeMode.system,
          seedColor: Colors.blue,
        );

        const theme2 = AppTheme(
          themeMode: ThemeMode.system,
          seedColor: Colors.red,
        );

        expect(theme1, isNot(equals(theme2)));
      });

      test('should not be equal when secondary colors differ', () {
        const theme1 = AppTheme(
          themeMode: ThemeMode.system,
          seedColor: Colors.blue,
          secondarySeedColor: Colors.green,
        );

        const theme2 = AppTheme(
          themeMode: ThemeMode.system,
          seedColor: Colors.blue,
          secondarySeedColor: Colors.red,
        );

        expect(theme1, isNot(equals(theme2)));
      });

      test('should handle null secondary colors in equality', () {
        const theme1 = AppTheme(
          themeMode: ThemeMode.system,
          seedColor: Colors.blue,
        );

        const theme2 = AppTheme(
          themeMode: ThemeMode.system,
          seedColor: Colors.blue,
        );

        expect(theme1, equals(theme2));
      });

      test('should have stringify enabled', () {
        const theme = AppTheme(
          themeMode: ThemeMode.dark,
          seedColor: Colors.blue,
        );

        expect(theme.stringify, isTrue);
      });
    });

    group('Default theme constant', () {
      test('kFirstAppTheme should have expected values', () {
        expect(kFirstAppTheme.themeMode, equals(ThemeMode.light));
        expect(kFirstAppTheme.seedColor, equals(const Color(0xFF6076B4)));
        expect(
          kFirstAppTheme.secondarySeedColor,
          equals(const Color(0xFF999999)),
        );
        expect(
          kFirstAppTheme.tertiarySeedColor,
          equals(const Color(0xFF36B042)),
        );
      });
    });
  });
}
