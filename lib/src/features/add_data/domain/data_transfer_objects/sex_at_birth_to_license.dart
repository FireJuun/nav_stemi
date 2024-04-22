import 'package:nav_stemi/src/features/add_data/domain/sex_and_gender_identity.dart';

class SexAtBirthToEnumConverter {
  static SexAtBirth fromString(String sexAtBirth) {
    switch (sexAtBirth) {
      case 'male':
        return SexAtBirth.male;
      case 'female':
        return SexAtBirth.female;
      case 'other':
        return SexAtBirth.other;
      case 'unknown':
      default:
        return SexAtBirth.unknown;
    }
  }

  /// Converts a [SexAtBirth] enum to a string.
  /// Drivers license info follows a national standard,
  /// where only 1 and 2 values are allowed.
  static SexAtBirth fromDriversLicenseString(String driversLicenseSex) {
    switch (driversLicenseSex) {
      case '1':
        return SexAtBirth.male;
      case '2':
        return SexAtBirth.female;
      case 'other':
        return SexAtBirth.other;
      case 'unknown':
      default:
        return SexAtBirth.unknown;
    }
  }

  static String toDriversLicenseString(SexAtBirth sexAtBirth) {
    switch (sexAtBirth) {
      case SexAtBirth.male:
        return '1';
      case SexAtBirth.female:
        return '2';
      case SexAtBirth.other:
        return 'other';
      case SexAtBirth.unknown:
        return 'unknown';
    }
  }
}
