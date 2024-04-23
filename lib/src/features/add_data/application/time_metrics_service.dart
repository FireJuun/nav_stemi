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

  void setTimeUnitLeftScene(DateTime? timeUnitLeftScene) {
    final updated =
        _timeMetrics().copyWith(timeUnitLeftScene: () => timeUnitLeftScene);

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
}

@riverpod
TimeMetricsService timeMetricsService(TimeMetricsServiceRef ref) {
  return TimeMetricsService(ref);
}
