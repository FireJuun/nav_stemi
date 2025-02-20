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

  void setTimeOfStemiActivationDecision(DateTime? timeOfStemiActivation) =>
      _service().setTimeOfStemiActivationDecision(timeOfStemiActivation);

  void setWasStemiActivated(bool? wasStemiActivated) =>
      _service().setWasStemiActivated(wasStemiActivated);

  void toggleTimeOfStemiActivationDecisionLock() =>
      _service().toggleTimeOfStemiActivationDecisionLock();

  void setTimeUnitLeftScene(DateTime? timeUnitLeftScene) =>
      _service().setTimeUnitLeftScene(timeUnitLeftScene);

  void toggleTimeUnitLeftSceneLock() =>
      _service().toggleTimeUnitLeftSceneLock();

  void setTimeOfAspirinGivenDecision(DateTime? timeOfAspirinGivenDecision) =>
      _service().setTimeOfAspirinGivenDecision(timeOfAspirinGivenDecision);

  void setWasAspirinGiven(bool? wasAspirinGiven) =>
      _service().setWasAspirinGiven(wasAspirinGiven);

  void toggleTimeOfAspirinGivenDecisionLock() =>
      _service().toggleTimeOfAspirinGivenDecisionLock();

  void setTimeCathLabNotifiedDecision(DateTime? timeCathLabNotifiedDecision) =>
      _service().setTimeCathLabNotifiedDecision(timeCathLabNotifiedDecision);

  void setWasCathLabNotified(bool? wasCathLabNotified) =>
      _service().setWasCathLabNotified(wasCathLabNotified);

  void toggleTimeCathLabNotifiedDecisionLock() =>
      _service().toggleTimeCathLabNotifiedDecisionLock();

  void setTimePatientArrivedAtDestination(
    DateTime? timePatientArrivedAtDestination,
  ) =>
      _service()
          .setTimePatientArrivedAtDestination(timePatientArrivedAtDestination);

  void toggleTimePatientArrivedAtDestinationLock() =>
      _service().toggleTimePatientArrivedAtDestinationLock();
}
