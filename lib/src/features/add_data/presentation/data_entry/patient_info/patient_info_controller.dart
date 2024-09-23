import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:nav_stemi/src/features/add_data/application/patient_info_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'patient_info_controller.g.dart';

@riverpod
class PatientInfoController extends _$PatientInfoController
    with NotifierMounted {
  @override
  FutureOr<void> build() {
    ref.onDispose(setUnmounted);
    // nothing to do
  }

  Future<bool> saveLicenseAsPatientInfo(DriverLicense driverLicense) async {
    state = const AsyncLoading();

    final value = await AsyncValue.guard(
      () => ref
          .read(patientInfoServiceProvider)
          .setPatientInfoFromScannedLicense(driverLicense),
    );

    final success = value.hasError == false;

    if (mounted) {
      state = value;
      // if (success) {
      //   onSuccess();
      // }
    }

    return success;
  }

  void setPatientInfo(PatientInfoModel patientInfo) =>
      ref.read(patientInfoServiceProvider).setPatientInfo(patientInfo);

  void setSexAtBirth(SexAtBirth? sexAtBirth) =>
      ref.read(patientInfoServiceProvider).setSexAtBirth(sexAtBirth);

  void setBirthDate(DateTime? birthDate) =>
      ref.read(patientInfoServiceProvider).setBirthDate(birthDate);
}
