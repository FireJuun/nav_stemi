import 'package:nav_stemi/nav_stemi.dart';
import 'package:nav_stemi/src/features/add_data/application/patient_info_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'checklist_controller.g.dart';

const _dto = BoolDataToChecklistDTO();

@riverpod
class ChecklistController extends _$ChecklistController with NotifierMounted {
  @override
  FutureOr<void> build() {
    ref.onDispose(setUnmounted);
    // nothing to do
  }

  PatientInfoService _service() => ref.read(patientInfoServiceProvider);

  /// The null / valse values that are stored in a checklist are swapped
  /// when compared to those in this data model. Use a utility class
  /// to swap them prior to saving this new state.
  ///
  void setDidGetAspirinFromChecklist({required bool? checklist}) =>
      _service().setDidGetAspirin(
        didGetAspirin: _dto.convertChecklistToBoolData(checklist: checklist),
      );

  /// The null / valse values that are stored in a checklist are swapped
  /// when compared to those in this data model. Use a utility class
  /// to swap them prior to saving this new state.
  ///
  void setIsCathLabNotifiedFromChecklist({required bool? checklist}) =>
      _service().setIsCathLabNotified(
        isCathLabNotified:
            _dto.convertChecklistToBoolData(checklist: checklist),
      );
}
