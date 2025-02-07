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

  void setTimeOfStemiActivation(DateTime? timeOfStemiActivation) {
    final updated = _timeMetrics().copyWith(
      timeOfStemiActivation: () => timeOfStemiActivation,
    );

    setTimeMetrics(updated);
  }

  void toggleTimeOfStemiActivationLock() {
    final lastValue = _timeMetrics().lockTimeOfStemiActivation;
    final updated = _timeMetrics().copyWith(
      lockTimeOfStemiActivation: () => !lastValue,
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
