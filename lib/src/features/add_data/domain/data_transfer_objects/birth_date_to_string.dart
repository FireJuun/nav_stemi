import 'package:intl/intl.dart';

final _dateFormat = DateFormat('MM-dd-yyyy');

/// Note: while 'MMddyyyy' is the normal format of your drivers license,
/// it cannot be parsed by the intl package without further string manipulation
/// https://stackoverflow.com/a/68205488
///
// final _driversLicenseFormat = DateFormat('MMddyyyy');

class BirthDateToStringDTO {
  const BirthDateToStringDTO();

  String convertDatePicker(DateTime birthDate) {
    return _dateFormat.format(birthDate);
  }

  DateTime? convertDatePickerBack(String birthDate) {
    return (birthDate.isNotEmpty) ? _dateFormat.parse(birthDate) : null;
  }

  String convertDriversLicense(DateTime birthDate) {
    return _removeSeparatorHyphens(_dateFormat.format(birthDate));
  }

  DateTime? convertDriversLicenseBack(String birthDate) {
    return (birthDate.isNotEmpty)
        ? _dateFormat.parse(_formatDateWithSeparators(birthDate))
        : null;
  }

  String _formatDateWithSeparators(String date) {
    assert(date.length == 8, 'Date must be 8 characters long');
    return '${date.substring(0, 2)}-${date.substring(2, 4)}-${date.substring(4)}';
  }

  String _removeSeparatorHyphens(String date) => date.replaceAll('-', '');
}

extension BirthDateX on DateTime {
  // TODO(FireJuun): implement birthdate data conversions
  String toBirthDateString() =>
      const BirthDateToStringDTO().convertDatePicker(this);

  String ageFromBirthDate() {
    final age = DateTime.now().difference(this).inDays ~/ 365;
    return '$age y';
  }
}
