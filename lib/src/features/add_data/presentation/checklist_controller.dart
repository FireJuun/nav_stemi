import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'checklist_controller.g.dart';

const _dto = BoolDataToChecklistDTO();

@riverpod
class ChecklistController extends _$ChecklistController with NotifierMounted {
  @override
  FutureOr<void> build() {
    // nothing to do
    ref.onDispose(setUnmounted);
  }

  TimeMetricsService _service() => ref.read(timeMetricsServiceProvider);

  /// The null / valse values that are stored in a checklist are swapped
  /// when compared to those in this data model. Use a utility class
  /// to swap them prior to saving this new state.
  ///
  void setDidGetAspirinFromChecklist({required bool? checklist}) =>
      _service().setWasAspirinGiven(
        _dto.convertChecklistToBoolData(checklist: checklist),
      );

  /// The null / valse values that are stored in a checklist are swapped
  /// when compared to those in this data model. Use a utility class
  /// to swap them prior to saving this new state.
  ///
  void setIsCathLabNotifiedFromChecklist({required bool? checklist}) =>
      _service().setWasCathLabNotified(
        _dto.convertChecklistToBoolData(checklist: checklist),
      );
}
