import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/nav_stemi.dart';

void main() {
  group('BirthDateToStringDTO', () {
    test('convertDatePickerBack returns null for empty string', () {
      const dto = BirthDateToStringDTO();
      expect(dto.convertDatePickerBack(''), isNull);
    });

    test('convertDriversLicenseBack returns null for empty string', () {
      const dto = BirthDateToStringDTO();
      expect(dto.convertDriversLicenseBack(''), isNull);
    });

    test('convertDatePicker formats date correctly', () {
      const dto = BirthDateToStringDTO();
      final date = DateTime(2023, 5, 15);
      expect(dto.convertDatePicker(date), '05/15/2023');
    });

    test('convertDriversLicense formats date without separators', () {
      const dto = BirthDateToStringDTO();
      final date = DateTime(2023, 5, 15);
      expect(dto.convertDriversLicense(date), '05/15/2023');
    });
  });

  group('BirthDateX', () {
    test('ageFromBirthDate calculates age correctly', () {
      // Test with a birth date 25 years ago
      final birthDate =
          DateTime.now().subtract(const Duration(days: 365 * 25 + 6));
      expect(birthDate.ageFromBirthDate(), '25 y');

      // Test with a birth date 1 year ago
      final youngBirthDate = DateTime.now().subtract(const Duration(days: 365));
      expect(youngBirthDate.ageFromBirthDate(), '1 y');

      // Test with a birth date 0 years ago (less than 1 year)
      final infantBirthDate =
          DateTime.now().subtract(const Duration(days: 100));
      expect(infantBirthDate.ageFromBirthDate(), '0 y');
    });

    test('toBirthDateString formats date correctly', () {
      final date = DateTime(2023, 12, 25);
      expect(date.toBirthDateString(), '12/25/2023');

      final date2 = DateTime(2000);
      expect(date2.toBirthDateString(), '01/01/2000');

      // Test single digit month and day
      final date3 = DateTime(2023, 3, 5);
      expect(date3.toBirthDateString(), '03/05/2023');
    });
  });
}
