import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nav_stemi/nav_stemi.dart';

class PatientInfoService {
  const PatientInfoService(this.ref);

  final Ref ref;

  PatientInfoRepository get patientInfoRepository =>
      ref.read(patientInfoRepositoryProvider);

  void setPatientInfo(PatientInfoModel patientInfo) {
    patientInfoRepository.setPatientInfo(patientInfo);
  }

  void setPatientInfoFromScannedLicense(DriverLicense driverLicense) {
    final oldInfo =
        patientInfoRepository.getPatientInfo() ?? const PatientInfoModel();

    final newInfo = oldInfo.copyWith(
      lastName: driverLicense.lastName ?? oldInfo.lastName,
      firstName: driverLicense.firstName ?? oldInfo.firstName,
      middleName: driverLicense.middleName ?? oldInfo.middleName,
      // TODO(FireJuun): implement birthdate data conversions
      // birthDate: driverLicense.birthDate,
    );

    patientInfoRepository.setPatientInfo(newInfo);
  }

  void clearPatientInfo() {
    patientInfoRepository.clearPatientInfo();
  }
}
