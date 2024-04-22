import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:recase/recase.dart';

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
      lastName: driverLicense.lastName?.titleCase,
      firstName: driverLicense.firstName?.titleCase,
      middleName: driverLicense.middleName?.titleCase,
      birthDate: birthDate,
      // TODO(FireJuun): implement data conversion for gender info
      sexAtBirth: SexAtBirthToEnumConverter.fromDriversLicenseString(
        driverLicense.gender ?? 'unknown',
      ),
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
      gender: SexAtBirthToEnumConverter.toDriversLicenseString(
        patientInfo.sexAtBirth ?? SexAtBirth.unknown,
      ),
    );
  }
}

extension DriverLicenseX on DriverLicense {
  PatientInfoModel toPatientInfo() =>
      const DriversLicenseToPatientInfoDTO().convert(this);
}
