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

  TimeMetricsService _service() => ref.read(timeMetricsServiceProvider);

  void setTimeMetrics(TimeMetricsModel timeMetrics) =>
      _service().setTimeMetrics(timeMetrics);

  void clearTimeMetrics() => _service().clearTimeMetrics();

  void setTimeArrivedAtPatient(DateTime? timeArrivedAtPatient) =>
      _service().setTimeArrivedAtPatient(timeArrivedAtPatient);

  void toggleTimeArrivedAtPatientLock() =>
      _service().toggleTimeArrivedAtPatientLock();

  void setTimeOfFirstEkg(DateTime? timeOfFirstEkg) =>
      _service().setTimeOfFirstEkg(timeOfFirstEkg);

  void toggleTimeOfFirstEkgLock() => _service().toggleTimeOfFirstEkgLock();

  void setTimeOfStemiActivation(DateTime? timeOfStemiActivation) =>
      _service().setTimeOfStemiActivation(timeOfStemiActivation);

  void toggleTimeOfStemiActivationLock() =>
      _service().toggleTimeOfStemiActivationLock();

  void setTimeUnitLeftScene(DateTime? timeUnitLeftScene) =>
      _service().setTimeUnitLeftScene(timeUnitLeftScene);

  void toggleTimeUnitLeftSceneLock() =>
      _service().toggleTimeUnitLeftSceneLock();

  void setTimePatientArrivedAtDestination(
    DateTime? timePatientArrivedAtDestination,
  ) =>
      _service()
          .setTimePatientArrivedAtDestination(timePatientArrivedAtDestination);

  void toggleTimePatientArrivedAtDestinationLock() =>
      _service().toggleTimePatientArrivedAtDestinationLock();
}
