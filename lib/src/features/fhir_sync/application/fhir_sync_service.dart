import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

class FhirSyncService {
  // This class is responsible for syncing FHIR resources with the server.
  // It will handle the logic for fetching, updating, and deleting resources.

  FhirSyncService(this.ref) {
    _init();
  }

  final Ref ref;

  void _init() {
    // Initialize the service and set up listeners for changes in the app state.
    // This could include setting up listeners for changes in patient info,
    // time metrics, or any other data that needs to be synced with FHIR.
    ref
      ..listen<AsyncValue<PatientInfoModel?>>(
        patientInfoModelProvider,
        (previous, next) {
          final isDirty = next.value?.isDirty ?? false;

          if (next is AsyncData && isDirty) {
            // Sync the patient info with FHIR
            localDebouncer(
              'syncPatientInfo',
              () => _syncPatientInfo(next.value),
            );
          }
        },
      )
      ..listen<AsyncValue<TimeMetricsModel?>>(
        timeMetricsModelProvider,
        (previous, next) {
          final isDirty = next.value?.isDirty ?? false;
          if (next is AsyncData && isDirty) {
            // Sync the time metrics with FHIR
            localDebouncer(
              'syncTimeMetrics',
              () => _syncTimeMetrics(next.value),
            );
          }
        },
      );
  }

  void cancelPatientInfoSync() => cancelLocalDebouncer('syncPatientInfo');

  void cancelTimeMetricsSync() => cancelLocalDebouncer('syncTimeMetrics');

  Future<void> manuallySyncAllData() async {
    cancelPatientInfoSync();
    cancelTimeMetricsSync();

    final patientInfo = ref.read(patientInfoModelProvider).value;
    final timeMetrics = ref.read(timeMetricsModelProvider).value;

    if (patientInfo != null) {
      await _syncPatientInfo(patientInfo);
    }
    if (timeMetrics != null) {
      await _syncTimeMetrics(timeMetrics);
    }
  }

  Future<void> _syncPatientInfo(PatientInfoModel? patientInfo) async {
    // Logic to sync patient info with FHIR
    // This could include making API calls to update the patient's information
    // on the FHIR server.
  }

  Future<void> _syncTimeMetrics(TimeMetricsModel? timeMetrics) async {
    // Logic to sync time metrics with FHIR
    // This could include making API calls to update the time metrics
    // on the FHIR server.
  }
}
