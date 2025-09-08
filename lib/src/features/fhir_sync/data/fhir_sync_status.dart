import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fhir_sync_status.g.dart';

/// Status of FHIR synchronization
enum FhirSyncStatus {
  /// Data is synced with FHIR server
  synced,

  /// Local changes need to be synced to FHIR server
  dirty,

  /// Currently syncing with FHIR server
  syncing,

  /// Not connected to FHIR server
  offline,

  /// Error occurred during sync
  error,

  /// Using fake sync mode (for staging/demo)
  fake
}

/// Repository for managing patient info sync status
class PatientInfoSyncStatusRepository {
  PatientInfoSyncStatusRepository()
      : _store = InMemoryStore<FhirSyncStatus>(FhirSyncStatus.synced);

  final InMemoryStore<FhirSyncStatus> _store;
  String? _lastErrorMessage;

  Stream<FhirSyncStatus> watchSyncStatus() => _store.stream;

  FhirSyncStatus get status => _store.value;
  String? get lastErrorMessage => _lastErrorMessage;

  void setStatus(FhirSyncStatus status, [String? errorMessage]) {
    _store.value = status;
    if (errorMessage != null) {
      _lastErrorMessage = errorMessage;
    }
  }

  void clearError() {
    _lastErrorMessage = null;
  }
}

/// Repository for managing time metrics sync status
class TimeMetricsSyncStatusRepository {
  TimeMetricsSyncStatusRepository()
      : _store = InMemoryStore<FhirSyncStatus>(FhirSyncStatus.synced);

  final InMemoryStore<FhirSyncStatus> _store;
  String? _lastErrorMessage;

  Stream<FhirSyncStatus> watchSyncStatus() => _store.stream;

  FhirSyncStatus get status => _store.value;
  String? get lastErrorMessage => _lastErrorMessage;

  void setStatus(FhirSyncStatus status, [String? errorMessage]) {
    _store.value = status;
    if (errorMessage != null) {
      _lastErrorMessage = errorMessage;
    }
  }

  void clearError() {
    _lastErrorMessage = null;
  }
}

@riverpod
PatientInfoSyncStatusRepository patientInfoSyncStatusRepository(Ref ref) {
  return PatientInfoSyncStatusRepository();
}

@riverpod
TimeMetricsSyncStatusRepository timeMetricsSyncStatusRepository(Ref ref) {
  return TimeMetricsSyncStatusRepository();
}

@riverpod
Stream<FhirSyncStatus> patientInfoSyncStatus(Ref ref) {
  final repository = ref.watch(patientInfoSyncStatusRepositoryProvider);
  return repository.watchSyncStatus();
}

@riverpod
Stream<FhirSyncStatus> timeMetricsSyncStatus(Ref ref) {
  final repository = ref.watch(timeMetricsSyncStatusRepositoryProvider);
  return repository.watchSyncStatus();
}

@riverpod
FhirSyncStatus overallSyncStatus(Ref ref) {
  final patientStatus = ref.watch(patientInfoSyncStatusProvider).valueOrNull ??
      FhirSyncStatus.synced;
  final timeMetricsStatus =
      ref.watch(timeMetricsSyncStatusProvider).valueOrNull ??
          FhirSyncStatus.synced;

  // Return the "worst" status between patient info and time metrics
  if (patientStatus == FhirSyncStatus.error ||
      timeMetricsStatus == FhirSyncStatus.error) {
    return FhirSyncStatus.error;
  }
  if (patientStatus == FhirSyncStatus.offline ||
      timeMetricsStatus == FhirSyncStatus.offline) {
    return FhirSyncStatus.offline;
  }
  if (patientStatus == FhirSyncStatus.syncing ||
      timeMetricsStatus == FhirSyncStatus.syncing) {
    return FhirSyncStatus.syncing;
  }
  if (patientStatus == FhirSyncStatus.dirty ||
      timeMetricsStatus == FhirSyncStatus.dirty) {
    return FhirSyncStatus.dirty;
  }
  return FhirSyncStatus.synced;
}

@riverpod
String? syncLastErrorMessage(Ref ref) {
  final patientRepo = ref.watch(patientInfoSyncStatusRepositoryProvider);
  final timeMetricsRepo = ref.watch(timeMetricsSyncStatusRepositoryProvider);

  // Return the most recent error message
  return patientRepo.lastErrorMessage ?? timeMetricsRepo.lastErrorMessage;
}
