import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'patient_info_service.g.dart';

const _birthDateToStringDTO = BirthDateToStringDTO();

class PatientInfoService {
  const PatientInfoService(this.ref);

  final Ref ref;

  PatientInfoRepository get patientInfoRepository =>
      ref.read(patientInfoRepositoryProvider);

  void setPatientInfo(PatientInfoModel patientInfo) {
    patientInfoRepository.setPatientInfo(patientInfo);
  }

  void setSexAtBirth(SexAtBirth? sexAtBirth) {
    final patientInfo =
        patientInfoRepository.getPatientInfo() ?? const PatientInfoModel();

    final updated = patientInfo.copyWith(sexAtBirth: () => sexAtBirth);
    setPatientInfo(updated);
  }

  void setBirthDate(DateTime? birthDate) {
    final patientInfo =
        patientInfoRepository.getPatientInfo() ?? const PatientInfoModel();

    final updated = patientInfo.copyWith(birthDate: () => birthDate);

    setPatientInfo(updated);
  }

  Future<void> setPatientInfoFromScannedLicense(
    DriverLicense driverLicense,
  ) async {
    final oldInfo =
        patientInfoRepository.getPatientInfo() ?? const PatientInfoModel();

    final newInfo = driverLicense.toPatientInfo();

    final merged = oldInfo.copyWith(
      lastName: newInfo.lastName ?? oldInfo.lastName,
      firstName: newInfo.firstName ?? oldInfo.firstName,
      middleName: newInfo.middleName ?? oldInfo.middleName,
      birthDate: () => newInfo.birthDate ?? oldInfo.birthDate,
      sexAtBirth: () => newInfo.sexAtBirth ?? oldInfo.sexAtBirth,
    );

    patientInfoRepository.setPatientInfo(merged);
  }

  void clearPatientInfo() {
    patientInfoRepository.clearPatientInfo();
  }
}

@riverpod
PatientInfoService patientInfoService(PatientInfoServiceRef ref) {
  return PatientInfoService(ref);
}
