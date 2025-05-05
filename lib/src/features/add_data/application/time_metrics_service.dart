import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'time_metrics_service.g.dart';

class TimeMetricsService {
  const TimeMetricsService(this.ref);

  final Ref ref;

  TimeMetricsRepository get timeMetricsRepository =>
      ref.read(timeMetricsRepositoryProvider);

  TimeMetricsModel _timeMetrics() =>
      timeMetricsRepository.getTimeMetrics() ?? const TimeMetricsModel();

  void setTimeMetrics(TimeMetricsModel timeMetrics) {
    timeMetricsRepository.setTimeMetrics(timeMetrics);
  }

  void clearTimeMetrics() {
    timeMetricsRepository.clearTimeMetrics();
  }

  void setTimeArrivedAtPatient(DateTime? timeArrivedAtPatient) {
    final updated = _timeMetrics()
        .copyWith(timeArrivedAtPatient: () => timeArrivedAtPatient);

    setTimeMetrics(updated);
  }

  void toggleTimeArrivedAtPatientLock() {
    final lastValue = _timeMetrics().lockTimeArrivedAtPatient;
    final updated = _timeMetrics().copyWith(
      lockTimeArrivedAtPatient: () => !lastValue,
    );

    setTimeMetrics(updated);
  }

  void setTimeOfFirstEkg(DateTime? timeOfFirstEkg) {
    final timeMetrics = _timeMetrics();

    if (timeMetrics.timeOfEkgs.isEmpty) {
      final updated = timeMetrics.copyWith(timeOfEkgs: () => {timeOfFirstEkg});
      setTimeMetrics(updated);
      return;
    } else {
      final ekgs = timeMetrics.sortedEkgsByDateTime().toList();
      ekgs[0] = timeOfFirstEkg;

      if (ekgs.length > 1) {
        final firstEkg = ekgs[0];
        final secondEkg = ekgs[1];
        assert(
          firstEkg != null && secondEkg != null && firstEkg.isBefore(secondEkg),
          'First EKG must be before second EKG',
        );
        // TODO(FireJuun): should this be a warning or an error?
      }
      final sortedEkgs = timeMetrics.sortedEkgsByDateTime(ekgs.toSet());

      final updated = timeMetrics.copyWith(
        timeOfEkgs: () => sortedEkgs,
      );
      setTimeMetrics(updated);
      return;
    }
  }

  void toggleTimeOfFirstEkgLock() {
    final lastValue = _timeMetrics().lockTimeOfEkgs;
    final updated = _timeMetrics().copyWith(
      lockTimeOfEkgs: () => !lastValue,
    );

    setTimeMetrics(updated);
  }

  void addTimeOfEkg(DateTime timeOfEkg) {
    final updated = _timeMetrics()
        .copyWith(timeOfEkgs: () => _timeMetrics().timeOfEkgs..add(timeOfEkg));

    setTimeMetrics(updated);
  }

  void removeTimeOfEkg(DateTime timeOfEkg) {
    final updated = _timeMetrics().copyWith(
      timeOfEkgs: () => _timeMetrics().timeOfEkgs..remove(timeOfEkg),
    );

    setTimeMetrics(updated);
  }

  void setTimeOfStemiActivationDecision(
    DateTime? timeOfStemiActivationDecision,
  ) {
    final updated = _timeMetrics().copyWith(
      timeOfStemiActivationDecision: () => timeOfStemiActivationDecision,
    );

    setTimeMetrics(updated);
  }

  void setWasStemiActivated(bool? wasStemiActivated) {
    final updated = _timeMetrics().copyWith(
      wasStemiActivated: () => wasStemiActivated,
    );

    setTimeMetrics(updated);
  }

  void toggleTimeOfStemiActivationDecisionLock() {
    final lastValue = _timeMetrics().lockTimeOfStemiActivationDecision;
    final updated = _timeMetrics().copyWith(
      lockTimeOfStemiActivationDecision: () => !lastValue,
    );

    setTimeMetrics(updated);
  }

  void setTimeUnitLeftScene(DateTime? timeUnitLeftScene) {
    final updated =
        _timeMetrics().copyWith(timeUnitLeftScene: () => timeUnitLeftScene);

    setTimeMetrics(updated);
  }

  void toggleTimeUnitLeftSceneLock() {
    final lastValue = _timeMetrics().lockTimeUnitLeftScene;
    final updated = _timeMetrics().copyWith(
      lockTimeUnitLeftScene: () => !lastValue,
    );

    setTimeMetrics(updated);
  }

  void setTimeOfAspirinGivenDecision(DateTime? timeOfAspirinGivenDecision) {
    final updated = _timeMetrics().copyWith(
      timeOfAspirinGivenDecision: () => timeOfAspirinGivenDecision,
    );

    setTimeMetrics(updated);
  }

  void setWasAspirinGiven(bool? wasAspirinGiven) {
    final updated = _timeMetrics().copyWith(
      wasAspirinGiven: () => wasAspirinGiven,
    );

    setTimeMetrics(updated);
  }

  void toggleTimeOfAspirinGivenDecisionLock() {
    final lastValue = _timeMetrics().lockTimeOfAspirinGivenDecision;
    final updated = _timeMetrics().copyWith(
      lockTimeOfAspirinGivenDecision: () => !lastValue,
    );
    setTimeMetrics(updated);
  }

  void setTimeCathLabNotifiedDecision(DateTime? timeCathLabNotifiedDecision) {
    final updated = _timeMetrics().copyWith(
      timeCathLabNotifiedDecision: () => timeCathLabNotifiedDecision,
    );

    setTimeMetrics(updated);
  }

  void setWasCathLabNotified(bool? wasCathLabNotified) {
    final updated = _timeMetrics().copyWith(
      wasCathLabNotified: () => wasCathLabNotified,
    );

    setTimeMetrics(updated);
  }

  void toggleTimeCathLabNotifiedDecisionLock() {
    final lastValue = _timeMetrics().lockTimeCathLabNotifiedDecision;
    final updated = _timeMetrics().copyWith(
      lockTimeCathLabNotifiedDecision: () => !lastValue,
    );

    setTimeMetrics(updated);
  }

  void setTimePatientArrivedAtDestination(
    DateTime? timePatientArrivedAtDestination,
  ) {
    final updated = _timeMetrics().copyWith(
      timePatientArrivedAtDestination: () => timePatientArrivedAtDestination,
    );

    setTimeMetrics(updated);
  }

  void toggleTimePatientArrivedAtDestinationLock() {
    final lastValue = _timeMetrics().lockTimePatientArrivedAtDestination;
    final updated = _timeMetrics().copyWith(
      lockTimePatientArrivedAtDestination: () => !lastValue,
    );

    setTimeMetrics(updated);
  }
}

@riverpod
TimeMetricsService timeMetricsService(Ref ref) {
  return TimeMetricsService(ref);
}
