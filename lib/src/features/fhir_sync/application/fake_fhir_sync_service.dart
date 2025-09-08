import 'dart:async';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fake_fhir_sync_service.g.dart';

/// A fake implementation of the FhirSyncService for staging/demo environments
///
/// This service simulates the synchronization of FHIR resources without
/// actually communicating with a FHIR server. It maintains the same interface
/// as the real FhirSyncService but operates entirely in-memory.
class FakeFhirSyncService implements FhirSyncService {
  FakeFhirSyncService(this.ref) {
    _init();
  }

  @override
  final Ref ref;

  // Set status to fake mode immediately
  void _init() {
    debugPrint('Initializing FakeFhirSyncService for staging environment');

    // Mark both repositories as using fake mode
    ref
        .read(patientInfoSyncStatusRepositoryProvider)
        .setStatus(FhirSyncStatus.fake);
    ref
        .read(timeMetricsSyncStatusRepositoryProvider)
        .setStatus(FhirSyncStatus.fake);

    // Set up the FHIR resource references
    _initializeFakeResources();
  }

  /// Initialize some fake FHIR resources for testing
  Future<void> _initializeFakeResources() async {
    // Create a fake patient and encounter to ensure references exist
    try {
      await initializeBlankResources();
    } catch (e) {
      debugPrint('Error initializing fake resources: $e');
    }
  }

  @override
  void cancelPatientInfoSync() {
    // No-op in fake mode
    debugPrint('FAKE: Cancelling patient info sync (no-op)');
  }

  @override
  void cancelTimeMetricsSync() {
    // No-op in fake mode
    debugPrint('FAKE: Cancelling time metrics sync (no-op)');
  }

  @override
  bool get isSyncPaused => false;

  @override
  void pauseSyncing() {
    // No-op in fake mode, we don't allow pausing in staging mode
    debugPrint('FAKE: Pausing sync is not supported in staging mode');
  }

  @override
  void resumeSyncing() {
    // No-op in fake mode
    debugPrint('FAKE: Resuming sync is not supported in staging mode');
  }

  @override
  Future<void> manuallySyncAllData() async {
    debugPrint('FAKE: Manually syncing all data');

    // Simulate a brief operation
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // In fake mode, we just mark everything as synced immediately
    final patientInfo = ref.read(patientInfoModelProvider).value;
    final timeMetrics = ref.read(timeMetricsModelProvider).value;

    if (patientInfo != null && patientInfo.isDirty) {
      // Mark as synced without actually syncing
      final syncedModel = patientInfo.markSynced();
      ref
          .read(patientInfoRepositoryProvider)
          .updatePatientInfoModel(syncedModel, markAsDirty: false);
    }

    if (timeMetrics != null && timeMetrics.isDirty) {
      // Mark as synced without actually syncing
      final syncedModel = timeMetrics.markSynced();
      ref
          .read(timeMetricsRepositoryProvider)
          .setTimeMetrics(syncedModel, markAsDirty: false);
    }

    // Maintain fake status instead of synced
    ref
        .read(patientInfoSyncStatusRepositoryProvider)
        .setStatus(FhirSyncStatus.fake);
    ref
        .read(timeMetricsSyncStatusRepositoryProvider)
        .setStatus(FhirSyncStatus.fake);
  }

  Future<void> initializeBlankResources() async {
    debugPrint('FAKE: Initializing blank resources');

    // Get the current references
    final refs = ref.read(fhirResourceReferencesNotifierProvider);

    // Only create resources if they don't already exist
    if (!refs.hasPatientReference) {
      await _createBlankPatient();
    }

    if (!refs.hasEncounterReference) {
      await _createBlankEncounter();
    }
  }

  /// Create a blank Patient resource in the fake system
  Future<void> _createBlankPatient() async {
    // Create a patient directly without a real server
    final patient = Patient(
      id: FhirString('fake-patient-${DateTime.now().millisecondsSinceEpoch}'),
      active: FhirBoolean(true),
      name: [
        HumanName(
          family: FhirString('Staging'),
          given: [FhirString('Patient')],
          use: NameUse.temp,
        ),
      ],
      gender: AdministrativeGender.unknown,
    );

    // Create a fake bundle response
    final bundle = Bundle(
      type: BundleType.transactionResponse,
      entry: [
        BundleEntry(
          resource: patient,
          response: BundleResponse(
            status: FhirString('201 Created'),
            location: FhirUri('Patient/${patient.id?.valueString}'),
          ),
        ),
      ],
    );

    // Update references
    ref
        .read(fhirResourceReferencesNotifierProvider.notifier)
        .updateFromBundle(bundle);
  }

  /// Create a blank Encounter resource in the fake system
  Future<void> _createBlankEncounter() async {
    // Get the current references
    final refs = ref.read(fhirResourceReferencesNotifierProvider);

    // Ensure we have a patient reference first
    if (!refs.hasPatientReference) {
      await _createBlankPatient();
    }

    // Create an encounter with the patient reference
    final patientRef =
        ref.read(fhirResourceReferencesNotifierProvider).patientReference;
    final encounter = defaultEmsEncounter.copyWith(
      id: FhirString('fake-encounter-${DateTime.now().millisecondsSinceEpoch}'),
      subject: patientRef,
    );

    // Create a fake bundle response
    final bundle = Bundle(
      type: BundleType.transactionResponse,
      entry: [
        BundleEntry(
          resource: encounter,
          response: BundleResponse(
            status: FhirString('201 Created'),
            location: FhirUri('Encounter/${encounter.id?.valueString}'),
          ),
        ),
      ],
    );

    // Update references
    ref
        .read(fhirResourceReferencesNotifierProvider.notifier)
        .updateFromBundle(bundle);
  }

  @override
  Future<Bundle> sendFhirBundle(Bundle bundle) async {
    debugPrint(
      'FAKE: Sending FHIR bundle with ${bundle.entry?.length ?? 0} entries',
    );
    // Use the fake FHIR service to handle this
    return ref.read(fakeFhirServiceProvider).postTransactionBundle(bundle);
  }
}

/// Provider for the fake FHIR sync service
@riverpod
FhirSyncService fakeFhirSyncService(Ref ref) {
  return FakeFhirSyncService(ref);
}
