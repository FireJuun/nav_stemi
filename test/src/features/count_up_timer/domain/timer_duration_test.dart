import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/src/features/count_up_timer/domain/timer_duration.dart';

void main() {
  group('timerIntToString', () {
    test('should return "----" for null input', () {
      expect(timerIntToString(null), equals('----'));
    });

    test('should format zero seconds as 00:00', () {
      expect(timerIntToString(0), equals('00:00'));
    });

    test('should format seconds only (less than a minute)', () {
      expect(timerIntToString(5), equals('00:05'));
      expect(timerIntToString(30), equals('00:30'));
      expect(timerIntToString(59), equals('00:59'));
    });

    test('should format minutes and seconds (less than an hour)', () {
      expect(timerIntToString(60), equals('01:00'));
      expect(timerIntToString(90), equals('01:30'));
      expect(timerIntToString(599), equals('09:59'));
      expect(timerIntToString(3599), equals('59:59'));
    });

    test('should format hours, minutes, and seconds', () {
      expect(timerIntToString(3600), equals('01:00:00'));
      expect(timerIntToString(3661), equals('01:01:01'));
      expect(timerIntToString(7200), equals('02:00:00'));
      expect(timerIntToString(36000), equals('10:00:00'));
      expect(timerIntToString(86399), equals('23:59:59'));
      expect(timerIntToString(86400), equals('24:00:00'));
    });

    test('should handle edge cases', () {
      // Over 24 hours
      expect(timerIntToString(90000), equals('25:00:00'));
      expect(timerIntToString(100000), equals('27:46:40'));
      
      // Maximum int value
      expect(timerIntToString(2147483647), contains(':'));
    });

    test('should pad single digits with leading zeros', () {
      expect(timerIntToString(1), equals('00:01'));
      expect(timerIntToString(61), equals('01:01'));
      expect(timerIntToString(3661), equals('01:01:01'));
    });

    test('should handle warning threshold (45 minutes)', () {
      const warningThreshold = 45 * 60; // 45 minutes in seconds
      expect(timerIntToString(warningThreshold), equals('45:00'));
      expect(timerIntToString(warningThreshold - 1), equals('44:59'));
      expect(timerIntToString(warningThreshold + 1), equals('45:01'));
    });

    test('should handle error threshold (60 minutes)', () {
      const errorThreshold = 60 * 60; // 60 minutes in seconds
      expect(timerIntToString(errorThreshold), equals('01:00:00'));
      expect(timerIntToString(errorThreshold - 1), equals('59:59'));
      expect(timerIntToString(errorThreshold + 1), equals('01:00:01'));
    });

    test('should handle past error threshold (90 minutes)', () {
      const pastErrorThreshold = 90 * 60; // 90 minutes in seconds
      expect(timerIntToString(pastErrorThreshold), equals('01:30:00'));
      expect(timerIntToString(pastErrorThreshold - 1), equals('01:29:59'));
      expect(timerIntToString(pastErrorThreshold + 1), equals('01:30:01'));
    });
  });

  group('timerIntAsDuration', () {
    test('should return Duration.zero for null input', () {
      expect(timerIntAsDuration(null), equals(Duration.zero));
    });

    test('should convert zero seconds to Duration.zero', () {
      expect(timerIntAsDuration(0), equals(Duration.zero));
    });

    test('should convert seconds to Duration correctly', () {
      expect(timerIntAsDuration(1), equals(const Duration(seconds: 1)));
      expect(timerIntAsDuration(60), equals(const Duration(minutes: 1)));
      expect(timerIntAsDuration(3600), equals(const Duration(hours: 1)));
      expect(
        timerIntAsDuration(3661),
        equals(const Duration(hours: 1, minutes: 1, seconds: 1)),
      );
    });

    test('should handle large values', () {
      expect(
        timerIntAsDuration(86400),
        equals(const Duration(days: 1)),
      );
      expect(
        timerIntAsDuration(2147483647),
        equals(const Duration(seconds: 2147483647)),
      );
    });

    test('should handle warning threshold duration', () {
      const warningSeconds = 45 * 60;
      expect(
        timerIntAsDuration(warningSeconds),
        equals(const Duration(minutes: 45)),
      );
    });

    test('should handle error threshold duration', () {
      const errorSeconds = 60 * 60;
      expect(
        timerIntAsDuration(errorSeconds),
        equals(const Duration(hours: 1)),
      );
    });

    test('should handle past error threshold duration', () {
      const pastErrorSeconds = 90 * 60;
      expect(
        timerIntAsDuration(pastErrorSeconds),
        equals(const Duration(minutes: 90)),
      );
    });

    test('duration conversion should be reversible with formatting', () {
      const testValues = [0, 1, 59, 60, 3599, 3600, 86400];
      for (final seconds in testValues) {
        final duration = timerIntAsDuration(seconds);
        expect(duration.inSeconds, equals(seconds));
      }
    });
  });
}
