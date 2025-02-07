import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'patient_info_service.g.dart';

class PatientInfoService {
  const PatientInfoService(this.ref);

  final Ref ref;

  PatientInfoRepository get patientInfoRepository =>
      ref.read(patientInfoRepositoryProvider);

  PatientInfoModel _patientInfo() =>
      patientInfoRepository.getPatientInfo() ?? const PatientInfoModel();

  void setPatientInfo(PatientInfoModel patientInfo) {
    patientInfoRepository.setPatientInfo(patientInfo);
  }

  void setSexAtBirth(SexAtBirth? sexAtBirth) {
    final updated = _patientInfo().copyWith(sexAtBirth: () => sexAtBirth);
    setPatientInfo(updated);
  }

  void setBirthDate(DateTime? birthDate) {
    final updated = _patientInfo().copyWith(birthDate: () => birthDate);

    setPatientInfo(updated);
  }

  void setCardiologist(String? cardiologist) {
    final updated = _patientInfo().copyWith(cardiologist: () => cardiologist);

    setPatientInfo(updated);
  }

  void setDidGetAspirin({required bool? didGetAspirin}) {
    final updated = _patientInfo().copyWith(didGetAspirin: () => didGetAspirin);

    setPatientInfo(updated);
  }

  void setIsCathLabNotified({required bool? isCathLabNotified}) {
    final updated =
        _patientInfo().copyWith(isCathLabNotified: () => isCathLabNotified);

    setPatientInfo(updated);
  }

  Future<void> setPatientInfoFromScannedLicense(
    DriverLicense driverLicense,
  ) async {
    final oldInfo = _patientInfo();

    final newInfo = driverLicense.toPatientInfo();

    final merged = oldInfo.copyWith(
      lastName: () => newInfo.lastName ?? oldInfo.lastName,
      firstName: () => newInfo.firstName ?? oldInfo.firstName,
      middleName: () => newInfo.middleName ?? oldInfo.middleName,
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
PatientInfoService patientInfoService(Ref ref) {
  return PatientInfoService(ref);
}
