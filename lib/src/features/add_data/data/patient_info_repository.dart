import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:nav_stemi/src/export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'patient_info_repository.g.dart';

class PatientInfoRepository {
  final _store = InMemoryStore<PatientInfoModel?>(const PatientInfoModel());

  Stream<PatientInfoModel?> watchPatientInfoModel() {
    return _store.stream;
  }

  PatientInfoModel? get patientInfoModel => _store.value;

  /// Sets the patient info model and marks it as dirty by default
  /// This is used for local updates that need to be synced to FHIR
  set patientInfoModel(PatientInfoModel? patientInfo) =>
      _store.value = patientInfo?.copyWith(
        isDirty: () => true,
      );

  /// Updates the patient info model with control over the dirty flag
  /// This is useful for when we're syncing from FHIR (markAsDirty=false)
  void updatePatientInfoModel(
    PatientInfoModel? patientInfo, {
    bool markAsDirty = true,
  }) {
    final newValue = patientInfo == null
        ? null
        : markAsDirty
            ? patientInfo.copyWith(isDirty: () => true)
            : patientInfo;

    _store.value = newValue;
  }

  void clearPatientInfoModel() => _store.value = null;
}

@riverpod
PatientInfoRepository patientInfoRepository(Ref ref) {
  return PatientInfoRepository();
}

@riverpod
Stream<PatientInfoModel?> patientInfoModel(Ref ref) {
  final patientInfoRepository = ref.watch(patientInfoRepositoryProvider);
  return patientInfoRepository.watchPatientInfoModel();
}

@riverpod
DateTime? patientBirthDate(Ref ref) => ref.watch(
      patientInfoModelProvider.select((model) => model.value?.birthDate),
    );

@riverpod
bool patientInfoShouldSync(Ref ref) {
  final modelValue = ref.watch(patientInfoModelProvider);

  if (modelValue.isLoading || modelValue.hasError || modelValue.value == null) {
    return false;
  }

  return modelValue.value!.isDirty;
}
