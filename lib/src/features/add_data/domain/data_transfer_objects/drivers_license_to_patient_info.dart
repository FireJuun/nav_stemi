import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nav_stemi/nav_stemi.dart';

const _birthDateToStringDTO = BirthDateToStringDTO();

class DriversLicenseToPatientInfoDTO {
  const DriversLicenseToPatientInfoDTO();

  PatientInfoModel convert(DriverLicense driverLicense) {
    /// Don't bother importing birth date if no data available
    final birthDateString = driverLicense.birthDate;
    final birthDate = (birthDateString == null)
        ? null
        : _birthDateToStringDTO.convertDriversLicenseBack(birthDateString);

    return PatientInfoModel(
      lastName: driverLicense.lastName,
      firstName: driverLicense.firstName,
      middleName: driverLicense.middleName,
      birthDate: birthDate,
    );
  }

  DriverLicense convertBack(PatientInfoModel patientInfo) {
    final patientBirthDate = patientInfo.birthDate;
    final licenseBirthDateString = (patientBirthDate == null)
        ? null
        : _birthDateToStringDTO.convertDriversLicense(patientBirthDate);

    return DriverLicense(
      lastName: patientInfo.lastName,
      firstName: patientInfo.firstName,
      middleName: patientInfo.middleName,
      birthDate: licenseBirthDateString,
    );
  }
}
