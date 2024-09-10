import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'time_metrics_repository.g.dart';

class TimeMetricsRepository {
  final _store = InMemoryStore<TimeMetricsModel?>(null);

  Stream<TimeMetricsModel?> watchTimeMetrics() {
    return _store.stream;
  }

  TimeMetricsModel? getTimeMetrics() => _store.value;

  void setTimeMetrics(TimeMetricsModel timeMetrics) {
    _store.value = timeMetrics;
  }

  void clearTimeMetrics() {
    _store.value = null;
  }
}

@Riverpod(keepAlive: true)
TimeMetricsRepository timeMetricsRepository(TimeMetricsRepositoryRef ref) {
  return TimeMetricsRepository();
}

@Riverpod(keepAlive: true)
Stream<TimeMetricsModel?> timeMetricsModel(TimeMetricsModelRef ref) {
  final timeMetricsRepository = ref.watch(timeMetricsRepositoryProvider);
  return timeMetricsRepository.watchTimeMetrics();
}
