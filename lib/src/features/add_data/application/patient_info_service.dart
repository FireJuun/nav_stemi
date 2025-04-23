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

  PatientInfoModel get patientInfoModel =>
      patientInfoRepository.patientInfoModel ?? const PatientInfoModel();

  // TODO(FireJuun): find cleaner way to update the model
  /// That, or add logic to ensure things are working as intended
  void setPatientInfoModel(PatientInfoModel newModel) {
    patientInfoRepository.patientInfoModel = newModel;
  }

  Future<void> setPatientInfoFromScannedLicense(
    DriverLicense driverLicense,
  ) async {
    final oldInfo = patientInfoModel;
    final newInfo = driverLicense.toPatientInfo();

    final merged = oldInfo.copyWith(
      lastName: () => newInfo.lastName,
      firstName: () => newInfo.firstName,
      middleName: () => newInfo.middleName,
      birthDate: () => newInfo.birthDate,
      sexAtBirth: () => newInfo.sexAtBirth,
    );

    setPatientInfoModel(merged);
  }

  void setFirstName(String? firstName) {
    final merged = patientInfoModel.copyWith(firstName: () => firstName);

    setPatientInfoModel(merged);
  }

  void setMiddleName(String? middleName) {
    final merged = patientInfoModel.copyWith(middleName: () => middleName);

    setPatientInfoModel(merged);
  }

  void setLastName(String? lastName) {
    final merged = patientInfoModel.copyWith(lastName: () => lastName);

    setPatientInfoModel(merged);
  }

  void setSexAtBirth(SexAtBirth? sexAtBirth) {
    final merged = patientInfoModel.copyWith(sexAtBirth: () => sexAtBirth);

    setPatientInfoModel(merged);
  }

  void setBirthDate(DateTime? birthDate) {
    final merged = patientInfoModel.copyWith(birthDate: () => birthDate);

    setPatientInfoModel(merged);
  }

  void setCardiologist(String? cardiologist) {
    final merged = patientInfoModel.copyWith(cardiologist: () => cardiologist);

    setPatientInfoModel(merged);
  }

  void clearPatientInfo() {
    patientInfoRepository.clearPatientInfoModel();
  }
}

@riverpod
PatientInfoService patientInfoService(Ref ref) {
  return PatientInfoService(ref);
}
