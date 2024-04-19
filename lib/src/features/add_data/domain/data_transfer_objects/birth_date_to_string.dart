import 'package:intl/intl.dart';

final _datePickerFormat = DateFormat('MM-dd-yyyy');
final _driversLicenseFormat = DateFormat('MMddyyyy');

class BirthDateToStringDTO {
  const BirthDateToStringDTO();

  String convertDatePicker(DateTime birthDate) {
    return _datePickerFormat.format(birthDate);
  }

  DateTime? convertDatePickerBack(String birthDate) {
    return (birthDate.isNotEmpty) ? _datePickerFormat.parse(birthDate) : null;
  }

  String convertDriversLicense(DateTime birthDate) {
    return _driversLicenseFormat.format(birthDate);
  }

  DateTime? convertDriversLicenseBack(String birthDate) {
    return (birthDate.isNotEmpty)
        ? _driversLicenseFormat.parse(birthDate)
        : null;
  }

  // TODO(FireJuun): implement birthdate data conversions
  String ageFromBirthDate(DateTime birthDate) {
    final age = DateTime.now().difference(birthDate).inDays ~/ 365;
    return '$age y';
  }
}
