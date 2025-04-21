import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fhir_sync_service.g.dart';

class FhirSyncService {
  // This class is responsible for syncing FHIR resources with the server.
  // It will handle the logic for fetching, updating, and deleting resources.

  FhirSyncService(this.ref) {
    _init();
  }

  final Ref ref;

  /// Updates the patient info sync status
  void _updatePatientInfoSyncStatus(
    FhirSyncStatus status, [
    String? errorMessage,
  ]) {
    ref
        .read(patientInfoSyncStatusRepositoryProvider)
        .setStatus(status, errorMessage);
  }

  /// Updates the time metrics sync status
  void _updateTimeMetricsSyncStatus(
    FhirSyncStatus status, [
    String? errorMessage,
  ]) {
    ref
        .read(timeMetricsSyncStatusRepositoryProvider)
        .setStatus(status, errorMessage);
  }

  void _init() {
    // Initialize the service and set up listeners for changes in the app state.
    // Listen for changes in patient info and time metrics
    ref
      ..listen<bool>(
        patientInfoShouldSyncProvider,
        (previous, current) {
          if (current) {
            final model = ref.read(patientInfoModelProvider).value;
            if (model != null) {
              _updatePatientInfoSyncStatus(FhirSyncStatus.dirty);

              // Sync the patient info with FHIR with debouncing
              localDebouncer(
                'syncPatientInfo',
                () => _syncPatientInfo(model),
              );
            }
          }
        },
      )
      ..listen<bool>(
        timeMetricsShouldSyncProvider,
        (previous, current) {
          if (current) {
            final model = ref.read(timeMetricsModelProvider).value;
            if (model != null) {
              _updateTimeMetricsSyncStatus(FhirSyncStatus.dirty);

              // Sync the time metrics with FHIR with debouncing
              localDebouncer(
                'syncTimeMetrics',
                () => _syncTimeMetrics(model),
              );
            }
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

  /// Checks if the user is connected to the FHIR server
  Future<bool> _isConnectedToFhirServer() async {
    // TODO: Implement actual connectivity check
    // This should check if the user is logged in and if the server is reachable
    return true; // Placeholder
  }

  /// Sync patient info with FHIR server
  Future<void> _syncPatientInfo(PatientInfoModel patientInfo) async {
    if (!patientInfo.isDirty) {
      _updatePatientInfoSyncStatus(FhirSyncStatus.synced);
      return;
    }

    try {
      // Check if connected to FHIR server
      final isConnected = await _isConnectedToFhirServer();
      if (!isConnected) {
        _updatePatientInfoSyncStatus(FhirSyncStatus.offline);
        return;
      }

      // Update sync status to syncing
      _updatePatientInfoSyncStatus(FhirSyncStatus.syncing);

      // Get the current FHIR resource references
      final refs = ref.read(fhirResourceReferencesNotifierProvider);

      // Use the PatientInfoFhirDTO to convert and sync data
      const dto = PatientInfoFhirDTO();

      // Convert data to FHIR resources, using existing IDs if available
      Patient patient;
      Practitioner? practitioner;

      // If we have existing Patient ID, get it from the server first
      if (refs.hasPatientReference) {
        final existingPatient = await _getPatientResource(refs.patientId!);
        patient =
            dto.toFhirPatient(patientInfo, existingPatient: existingPatient);
      } else {
        // Create a new Patient resource
        patient = dto.toFhirPatient(patientInfo);
      }

      // If there's a cardiologist, handle that reference too
      if (patientInfo.cardiologist != null) {
        if (refs.hasPractitionerReference) {
          final existingPractitioner =
              await _getPractitionerResource(refs.practitionerId!);
          practitioner = dto.toFhirCardiologist(
            patientInfo,
            existingPractitioner: existingPractitioner,
          );
        } else {
          practitioner = dto.toFhirCardiologist(patientInfo);
        }
      }

      // Create a transaction bundle to send to the server
      final bundle = Bundle(
        type: BundleType.transaction,
        entry: [
          BundleEntry(
            resource: patient,
            request: BundleRequest(
              method: refs.hasPatientReference ? HTTPVerb.PUT : HTTPVerb.POST,
              url: FhirUri(
                refs.hasPatientReference
                    ? 'Patient/${refs.patientId}'
                    : 'Patient',
              ),
            ),
          ),
          if (practitioner != null)
            BundleEntry(
              resource: practitioner,
              request: BundleRequest(
                method: refs.hasPractitionerReference
                    ? HTTPVerb.PUT
                    : HTTPVerb.POST,
                url: FhirUri(
                  refs.hasPractitionerReference
                      ? 'Practitioner/${refs.practitionerId}'
                      : 'Practitioner',
                ),
              ),
            ),
        ],
      );

      // Send the bundle to the FHIR server
      final responseBundle = await sendFhirBundle(bundle);

      // Update our resource references with the server-assigned IDs
      ref
          .read(fhirResourceReferencesNotifierProvider.notifier)
          .updateFromBundle(responseBundle);

      // Mark the model as synced in local storage
      ref.read(patientInfoRepositoryProvider).patientInfoModel?.markSynced();

      // Update sync status to synced
      _updatePatientInfoSyncStatus(FhirSyncStatus.synced);
    } catch (e) {
      // Update sync status to error
      _updatePatientInfoSyncStatus(FhirSyncStatus.error, e.toString());
      rethrow;
    }
  }

  /// Sync time metrics with FHIR server
  Future<void> _syncTimeMetrics(TimeMetricsModel timeMetrics) async {
    if (!timeMetrics.isDirty) {
      _updateTimeMetricsSyncStatus(FhirSyncStatus.synced);
      return;
    }

    try {
      // Check if connected to FHIR server
      final isConnected = await _isConnectedToFhirServer();
      if (!isConnected) {
        _updateTimeMetricsSyncStatus(FhirSyncStatus.offline);
        return;
      }

      // Update sync status to syncing
      _updateTimeMetricsSyncStatus(FhirSyncStatus.syncing);

      // Get the current FHIR resource references
      final refs = ref.read(fhirResourceReferencesNotifierProvider);

      // Get the PatientInfoModel (needed for references)
      final patientInfo = ref.read(patientInfoModelProvider).value;
      if (patientInfo == null) {
        throw Exception('Patient info is required for time metrics sync');
      }

      // Ensure we have a Patient resource first
      if (!refs.hasPatientReference) {
        await _syncPatientInfo(patientInfo);
        // Refresh references after patient sync
        // TODO(FireJuun): should this be refresh or invalidate?
        ref.invalidate(fhirResourceReferencesNotifierProvider);
      }

      // Use the TimeMetricsFhirDTO to convert and sync data
      const dto = TimeMetricsFhirDTO();

      // Get existing Patient resource using our stored reference
      final patient = await _getPatientResource(
        ref.read(fhirResourceReferencesNotifierProvider).patientId!,
      );

      // Create a list of bundle entries for our transaction
      final bundleEntries = <BundleEntry>[];

      // Handle Encounter resource
      Encounter encounter;
      if (refs.hasEncounterReference) {
        // Update existing encounter
        final existingEncounter =
            await _getEncounterResource(refs.encounterId!);
        encounter = dto.toFhirEncounter(
          timeMetrics,
          existingEncounter: existingEncounter,
        );
        bundleEntries.add(
          BundleEntry(
            resource: encounter,
            request: BundleRequest(
              method: HTTPVerb.PUT,
              url: FhirUri('Encounter/${refs.encounterId}'),
            ),
          ),
        );
      } else {
        // Create new encounter
        encounter = dto.toFhirEncounter(timeMetrics)
          ..copyWith(subject: refs.patientReference);
        bundleEntries.add(
          BundleEntry(
            resource: encounter,
            request: BundleRequest(
              method: HTTPVerb.POST,
              url: FhirUri('Encounter'),
            ),
          ),
        );
      }

      // Handle Aspirin MedicationAdministration if present
      if (timeMetrics.timeOfAspirinGivenDecision != null) {
        MedicationAdministration? aspirinAdmin;
        if (refs.hasAspirinAdministrationReference) {
          // Update existing resource
          final existingAdmin = await _getMedicationAdministrationResource(
            refs.aspirinAdministrationId!,
          );
          aspirinAdmin = dto.toFhirAspirinAdministration(
            timeMetrics,
            patient: patient,
            existingAdministration: existingAdmin,
          );

          if (aspirinAdmin == null) {
            // No aspirin given, skip this entry
            return;
          }

          bundleEntries.add(
            BundleEntry(
              resource: aspirinAdmin,
              request: BundleRequest(
                method: HTTPVerb.PUT,
                url: FhirUri(
                  'MedicationAdministration/${refs.aspirinAdministrationId}',
                ),
              ),
            ),
          );
        } else if (timeMetrics.wasAspirinGiven != null) {
          // Create new resource
          aspirinAdmin = dto.toFhirAspirinAdministration(
            timeMetrics,
            patient: patient,
          );
          bundleEntries.add(
            BundleEntry(
              resource: aspirinAdmin,
              request: BundleRequest(
                method: HTTPVerb.POST,
                url: FhirUri('MedicationAdministration'),
              ),
            ),
          );
        }
      }

      // Handle STEMI Condition if present
      if (timeMetrics.timeOfStemiActivationDecision != null) {
        Condition? stemiCondition;
        if (refs.hasStemiConditionReference) {
          // Update existing resource
          final existingCondition = await _getConditionResource(
            refs.stemiConditionId!,
          );
          stemiCondition = dto.toFhirStemiCondition(
            timeMetrics,
            patient: patient,
            encounter: encounter,
            existingCondition: existingCondition,
          );

          if (stemiCondition == null) {
            // No STEMI condition, skip this entry
            return;
          }

          bundleEntries.add(
            BundleEntry(
              resource: stemiCondition,
              request: BundleRequest(
                method: HTTPVerb.PUT,
                url: FhirUri('Condition/${refs.stemiConditionId}'),
              ),
            ),
          );
        } else if (timeMetrics.wasStemiActivated != null) {
          // Create new resource
          stemiCondition = dto.toFhirStemiCondition(
            timeMetrics,
            patient: patient,
            encounter: encounter,
          );
          bundleEntries.add(
            BundleEntry(
              resource: stemiCondition,
              request: BundleRequest(
                method: HTTPVerb.POST,
                url: FhirUri('Condition'),
              ),
            ),
          );
        }
      }

      // Handle QuestionnaireResponse if needed
      final hasStemiDecision =
          timeMetrics.timeOfStemiActivationDecision != null;
      final hasCathLabDecision =
          timeMetrics.timeCathLabNotifiedDecision != null;

      if (hasStemiDecision || hasCathLabDecision) {
        QuestionnaireResponse? questionnaire;
        if (refs.hasQuestionnaireResponseReference) {
          // Update existing resource
          final existingResponse = await _getQuestionnaireResponseResource(
            refs.questionnaireResponseId!,
          );
          questionnaire = dto.toFhirQuestionnaireResponse(
            timeMetrics,
            encounter: encounter,
            existingResponse: existingResponse,
          );

          bundleEntries.add(
            BundleEntry(
              resource: questionnaire,
              request: BundleRequest(
                method: HTTPVerb.PUT,
                url: FhirUri(
                  'QuestionnaireResponse/${refs.questionnaireResponseId}',
                ),
              ),
            ),
          );
        } else {
          // Create new resource
          questionnaire = dto.toFhirQuestionnaireResponse(
            timeMetrics,
            encounter: encounter,
          );
          bundleEntries.add(
            BundleEntry(
              resource: questionnaire,
              request: BundleRequest(
                method: HTTPVerb.POST,
                url: FhirUri('QuestionnaireResponse'),
              ),
            ),
          );
        }
      }

      // Create the transaction bundle
      final bundle = Bundle(
        type: BundleType.transaction,
        entry: bundleEntries,
      );

      // Send the bundle to the FHIR server
      final responseBundle = await sendFhirBundle(bundle);

      // Update our resource references with the server-assigned IDs
      ref
          .read(fhirResourceReferencesNotifierProvider.notifier)
          .updateFromBundle(responseBundle);

      // Mark the model as synced in local storage
      ref
          .read(timeMetricsRepositoryProvider)
          .setTimeMetrics(timeMetrics.markSynced());

      // Update sync status to synced
      _updateTimeMetricsSyncStatus(FhirSyncStatus.synced);
    } catch (e) {
      // Update sync status to error
      _updateTimeMetricsSyncStatus(FhirSyncStatus.error, e.toString());

      rethrow;
    }
  }

  // Helper methods for FHIR resource manipulation

  /// Sends a FHIR transaction bundle to the server and returns the response
  Future<Bundle> sendFhirBundle(Bundle bundle) async {
    // TODO: Implement actual API call to FHIR server
    // For now, we'll simulate a response with generated IDs

    // Create a simulated response bundle
    final responseEntries = <BundleEntry>[];
    final bundleEntries = bundle.entry ?? <BundleEntry>[];

    for (final entry in bundleEntries) {
      final resource = entry.resource;
      if (resource == null) continue;

      // Simulate the server assigning an ID if it's a POST
      final isPost = entry.request?.method == HTTPVerb.POST;
      final existingId = resource.id?.value;
      final id = isPost
          ? 'generated-${DateTime.now().millisecondsSinceEpoch}-${resource.resourceType}'
          : existingId;

      // Add ID to the resource
      final resourceWithId = resource.copyWith(id: FhirString(id));

      // Add to response bundle
      responseEntries.add(
        BundleEntry(
          resource: resourceWithId,
          response: BundleResponse(
            status: FhirString('201 Created'),
            location: FhirUri(
              '${resource.resourceType}/$id)',
            ),
          ),
        ),
      );
    }

    // Create response bundle
    final responseBundle = Bundle(
      type: BundleType.transaction_response,
      entry: responseEntries,
    );

    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 800));

    return responseBundle;
  }

  /// Get existing patient resource by ID
  Future<Patient> _getPatientResource(String id) async {
    // TODO: Implement actual FHIR API call to get existing patient
    // For now, just return a Patient with the given ID
    await Future<void>.delayed(
      const Duration(milliseconds: 200),
    ); // Simulate network delay
    return Patient(id: FhirString(id));
  }

  /// Get existing practitioner resource by ID
  Future<Practitioner> _getPractitionerResource(String id) async {
    // TODO: Implement actual FHIR API call to get existing practitioner
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return Practitioner(id: FhirString(id));
  }

  /// Get existing encounter resource by ID
  Future<Encounter> _getEncounterResource(String id) async {
    // TODO: Implement actual FHIR API call to get existing encounter
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final empty = Encounter.empty();
    return empty.copyWith(id: FhirString(id));
  }

  /// Get existing medication administration resource by ID
  Future<MedicationAdministration> _getMedicationAdministrationResource(
    String id,
  ) async {
    // TODO: Implement actual FHIR API call to get existing resource
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final empty = MedicationAdministration.empty();
    return empty.copyWith(id: FhirString(id));
  }

  /// Get existing condition resource by ID
  Future<Condition> _getConditionResource(String id) async {
    // TODO: Implement actual FHIR API call to get existing resource
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final empty = Condition.empty();
    return empty.copyWith(id: FhirString(id));
  }

  /// Get existing questionnaire response by ID
  Future<QuestionnaireResponse> _getQuestionnaireResponseResource(
    String id,
  ) async {
    // TODO: Implement actual FHIR API call to get existing resource
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final empty = QuestionnaireResponse.empty();
    return empty.copyWith(id: FhirString(id));
  }
}

/// Provides the FHIR sync service
@Riverpod(keepAlive: true)
FhirSyncService fhirSyncService(Ref ref) {
  return FhirSyncService(ref);
}
