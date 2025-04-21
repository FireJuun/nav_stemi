import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    _store.value = timeMetrics.copyWith(
      isDirty: () => true,
    );
  }

  void clearTimeMetrics() {
    _store.value = null;
  }
}

@riverpod
TimeMetricsRepository timeMetricsRepository(Ref ref) {
  return TimeMetricsRepository();
}

@riverpod
Stream<TimeMetricsModel?> timeMetricsModel(Ref ref) {
  final timeMetricsRepository = ref.watch(timeMetricsRepositoryProvider);
  return timeMetricsRepository.watchTimeMetrics();
}

@riverpod
bool timeMetricsShouldSync(Ref ref) {
  return ref.watch(
        timeMetricsModelProvider.select((model) => model.value?.isDirty),
      ) ??
      false;
}
