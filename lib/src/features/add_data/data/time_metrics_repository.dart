import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'time_metrics_repository.g.dart';

class TimeMetricsRepository {
  TimeMetricsRepository(this.prefs) {
    final json = prefs.getString(_storageKey);
    if (json != null) {
      _store.value = TimeMetricsModel.fromJson(json);
    }
  }

  final SharedPreferences prefs;
  static const _storageKey = 'timeMetrics';
  final _store = InMemoryStore<TimeMetricsModel?>(null);

  Stream<TimeMetricsModel?> watchTimeMetrics() {
    return _store.stream;
  }

  TimeMetricsModel? getTimeMetrics() => _store.value;

  void setTimeMetrics(TimeMetricsModel timeMetrics, {bool markAsDirty = true}) {
    _store.value =
        markAsDirty ? timeMetrics.copyWith(isDirty: () => true) : timeMetrics;
    prefs.setString(_storageKey, _store.value!.toJson());
  }

  void clearTimeMetrics() {
    _store.value = null;
    prefs.remove(_storageKey);
  }
}

@riverpod
TimeMetricsRepository timeMetricsRepository(Ref ref) {
  final prefs = ref.watch(sharedPreferencesRepositoryProvider).prefs;
  return TimeMetricsRepository(prefs);
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
