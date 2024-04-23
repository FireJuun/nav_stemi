import 'package:nav_stemi/nav_stemi.dart';
import 'package:nav_stemi/src/features/add_data/application/time_metrics_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'time_metrics_controller.g.dart';

@riverpod
class TimeMetricsController extends _$TimeMetricsController
    with NotifierMounted {
  @override
  FutureOr<void> build() {
    ref.onDispose(setUnmounted);
    // nothing to do
  }

  void setTimeMetrics(TimeMetricsModel timeMetrics) =>
      ref.read(timeMetricsServiceProvider).setTimeMetrics(timeMetrics);

  void clearTimeMetrics() =>
      ref.read(timeMetricsServiceProvider).clearTimeMetrics();

  void setTimeArrivedAtPatient(DateTime? timeArrivedAtPatient) => ref
      .read(timeMetricsServiceProvider)
      .setTimeArrivedAtPatient(timeArrivedAtPatient);

  void setTimeOfFirstEkg(DateTime? timeOfFirstEkg) =>
      ref.read(timeMetricsServiceProvider).setTimeOfFirstEkg(timeOfFirstEkg);

  void setTimeOfStemiActivation(DateTime? timeOfStemiActivation) => ref
      .read(timeMetricsServiceProvider)
      .setTimeOfStemiActivation(timeOfStemiActivation);

  void setTimeUnitLeftScene(DateTime? timeUnitLeftScene) => ref
      .read(timeMetricsServiceProvider)
      .setTimeUnitLeftScene(timeUnitLeftScene);

  void setTimePatientArrivedAtDestination(
    DateTime? timePatientArrivedAtDestination,
  ) =>
      ref
          .read(timeMetricsServiceProvider)
          .setTimePatientArrivedAtDestination(timePatientArrivedAtDestination);
}
