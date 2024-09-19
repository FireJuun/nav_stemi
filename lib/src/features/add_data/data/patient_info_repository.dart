import 'package:nav_stemi/nav_stemi.dart';
import 'package:nav_stemi/src/export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'patient_info_repository.g.dart';

class PatientInfoRepository {
  final _store = InMemoryStore<PatientInfoModel?>(const PatientInfoModel());

  Stream<PatientInfoModel?> watchPatientInfo() {
    return _store.stream;
  }

  PatientInfoModel? getPatientInfo() => _store.value;

  void setPatientInfo(PatientInfoModel patientInfo) {
    _store.value = patientInfo;
  }

  void clearPatientInfo() {
    _store.value = null;
  }
}

@Riverpod(keepAlive: true)
PatientInfoRepository patientInfoRepository(PatientInfoRepositoryRef ref) {
  return PatientInfoRepository();
}

@riverpod
Stream<PatientInfoModel?> patientInfoModel(PatientInfoModelRef ref) {
  final patientInfoRepository = ref.watch(patientInfoRepositoryProvider);
  return patientInfoRepository.watchPatientInfo();
}
