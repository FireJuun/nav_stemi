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
  set patientInfoModel(PatientInfoModel? patientInfo) =>
      _store.value = patientInfo?.copyWith(
        isDirty: () => true,
      );

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
  return ref.watch(
        patientInfoModelProvider.select((model) => model.value?.isDirty),
      ) ??
      false;
}
