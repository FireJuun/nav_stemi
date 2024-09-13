import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'start_stop_timer_service.g.dart';

/// This library listens for the timer start time and the timer stop time.
///
/// Start time is when EMS first arrives at a patient.
///
/// If the Patient is at the Destination, then the timer should stop
/// counting up.
///
/// If either time changes, then the app will reflect the new difference.
///

class StartStopTimerService {
  StartStopTimerService(this.ref) {
    _init();
  }

  final Ref ref;

  void _init() {
    /// Listen for changes to the [TimeMetricsRepository].
    /// If any changes have occurred to the [timeArrivedAtPatient] (start),
    /// or to the [timePatientArrivedAtDestination] (stop) values,
    /// then update the timer with the new difference.
    ///
    /// If the [timePatientArrivedAtDestination] is null, then the timer uses
    ///  DateTime.now() instead of this value and continues to run.
    ///

    ref.listen<AsyncValue<TimeMetricsModel?>>(
      timeMetricsModelProvider,
      (previous, next) {
        final timeMetrics = next.value;

        if (timeMetrics != null) {
          _updateCountUpTimerWithTimeMetrics(timeMetrics);
        }

        // TODO(FireJuun): Add a flag/check to manually start/stop/clear the timer, overriding these values/conditions.
      },
    );
  }

  Future<void> _updateCountUpTimerWithTimeMetrics(
    TimeMetricsModel timeMetrics,
  ) async {
    final start = timeMetrics.timeArrivedAtPatient;
    final stop = timeMetrics.timePatientArrivedAtDestination;

    await ref
        .read(countUpTimerRepositoryProvider)
        .setTimerFromDateTime(start, endDateTime: stop);
  }
}

@Riverpod(keepAlive: true)
StartStopTimerService startStopTimerService(StartStopTimerServiceRef ref) {
  return StartStopTimerService(ref);
}
