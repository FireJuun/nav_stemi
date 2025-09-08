import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fake_fhir_sync_status.g.dart';

/// Fake implementation of the FHIR sync status repositories
///
/// These repositories always return FhirSyncStatus.fake regardless of
/// the actual state of the sync process. This makes it clear to users
/// that they're in the staging/fake mode.
class FakePatientInfoSyncStatusRepository
    extends PatientInfoSyncStatusRepository {
  FakePatientInfoSyncStatusRepository() : super();

  @override
  Stream<FhirSyncStatus> watchSyncStatus() => Stream.value(FhirSyncStatus.fake);

  @override
  FhirSyncStatus get status => FhirSyncStatus.fake;

  @override
  void setStatus(FhirSyncStatus status, [String? errorMessage]) {
    // Always maintain fake status regardless of attempted changes
    super.setStatus(FhirSyncStatus.fake, errorMessage);
  }
}

/// Fake implementation of time metrics sync status repository
class FakeTimeMetricsSyncStatusRepository
    extends TimeMetricsSyncStatusRepository {
  FakeTimeMetricsSyncStatusRepository() : super();

  @override
  Stream<FhirSyncStatus> watchSyncStatus() => Stream.value(FhirSyncStatus.fake);

  @override
  FhirSyncStatus get status => FhirSyncStatus.fake;

  @override
  void setStatus(FhirSyncStatus status, [String? errorMessage]) {
    // Always maintain fake status regardless of attempted changes
    super.setStatus(FhirSyncStatus.fake, errorMessage);
  }
}

/// Provider for the fake patient info sync status repository
@riverpod
PatientInfoSyncStatusRepository fakePatientInfoSyncStatusRepository(Ref ref) {
  return FakePatientInfoSyncStatusRepository();
}

/// Provider for the fake time metrics sync status repository
@riverpod
TimeMetricsSyncStatusRepository fakeTimeMetricsSyncStatusRepository(Ref ref) {
  return FakeTimeMetricsSyncStatusRepository();
}

/// Fake implementation of patient info sync status
@riverpod
Stream<FhirSyncStatus> fakePatientInfoSyncStatus(Ref ref) {
  return Stream.value(FhirSyncStatus.fake);
}

/// Fake implementation of time metrics sync status
@riverpod
Stream<FhirSyncStatus> fakeTimeMetricsSyncStatus(Ref ref) {
  return Stream.value(FhirSyncStatus.fake);
}

/// Fake implementation of overall sync status
@riverpod
FhirSyncStatus fakeOverallSyncStatus(Ref ref) {
  return FhirSyncStatus.fake;
}

/// Fake implementation of sync last error message
@riverpod
String? fakeSyncLastErrorMessage(Ref ref) {
  return null; // No error message in fake mode
}
