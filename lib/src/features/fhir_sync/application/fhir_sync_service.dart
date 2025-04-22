import 'dart:async';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fhir_sync_service.g.dart';

// Increase debounce duration to reduce sync frequency
const _debounceDuration = Duration(seconds: 5);

class FhirSyncService {
  // This class is responsible for syncing FHIR resources with the server.
  // It will handle the logic for fetching, updating, and deleting resources.

  FhirSyncService(this.ref) {
    _init();
    _retryManager = RetryManager();
  }

  final Ref ref;
  late final RetryManager _retryManager;

  // Flags to control sync behavior
  bool _isSyncPaused = false;
  final Map<String, Timer?> _pendingRetries = {};

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
                _debounceDuration,
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
              print('TimeMetricsModel marked as dirty, scheduling sync');

              // Sync the time metrics with FHIR with debouncing
              localDebouncer(
                'syncTimeMetrics',
                () {
                  print('Executing timeMetrics sync');
                  _syncTimeMetrics(model);
                },
                _debounceDuration,
              );
            }
          }
        },
      )
      // Also listen directly to the TimeMetricsModel to catch manual updates
      ..listen<AsyncValue<TimeMetricsModel?>>(
        timeMetricsModelProvider,
        (previous, current) {
          if (current.hasValue &&
              current.value != null &&
              current.value!.isDirty) {
            print('TimeMetricsModel changed and is dirty, scheduling sync');
            _updateTimeMetricsSyncStatus(FhirSyncStatus.dirty);

            // Sync with debouncing
            localDebouncer(
              'syncTimeMetrics',
              () {
                print('Executing timeMetrics sync from model listener');
                _syncTimeMetrics(current.value!);
              },
            );
          }
        },
      );
  }

  void cancelPatientInfoSync() {
    cancelLocalDebouncer('syncPatientInfo');
    _cancelRetry('patientInfo');
    _retryManager.resetRetries('patientInfo');
  }

  void cancelTimeMetricsSync() {
    cancelLocalDebouncer('syncTimeMetrics');
    _cancelRetry('timeMetrics');
    _retryManager.resetRetries('timeMetrics');
  }

  void pauseSyncing() {
    _isSyncPaused = true;
    cancelPatientInfoSync();
    cancelTimeMetricsSync();
  }

  void resumeSyncing() {
    _isSyncPaused = false;
    manuallySyncAllData();
  }

  bool get isSyncPaused => _isSyncPaused;

  Future<void> manuallySyncAllData() async {
    if (_isSyncPaused) {
      print('Sync is paused, not performing manual sync');
      return;
    }

    cancelPatientInfoSync();
    cancelTimeMetricsSync();

    // Reset retry counts when manually syncing
    _retryManager.resetRetries('patientInfo');
    _retryManager.resetRetries('timeMetrics');

    final patientInfo = ref.read(patientInfoModelProvider).value;
    final timeMetrics = ref.read(timeMetricsModelProvider).value;

    if (patientInfo != null) {
      await _syncPatientInfo(patientInfo);
    }
    if (timeMetrics != null) {
      await _syncTimeMetrics(timeMetrics);
    }
  }

  /// Cancels a pending retry
  void _cancelRetry(String operationId) {
    final timer = _pendingRetries[operationId];
    if (timer != null && timer.isActive) {
      timer.cancel();
      _pendingRetries[operationId] = null;
    }
  }

  /// Schedules a retry with exponential backoff
  void _scheduleRetry(String operationId, Function() retryFunction) {
    if (_isSyncPaused) {
      print('Sync is paused, not scheduling retry for $operationId');
      return;
    }

    _retryManager.incrementRetryCount(operationId);

    if (_retryManager.shouldRetry(operationId)) {
      final delayMs = _retryManager.getNextRetryDelayMs(operationId);
      print('Scheduling retry #${_retryManager.getRetryCount(operationId)} '
          'for $operationId in $delayMs ms');

      // Cancel any existing retry timer
      _cancelRetry(operationId);

      // Schedule new retry
      _pendingRetries[operationId] = Timer(
        Duration(milliseconds: delayMs),
        retryFunction,
      );
    } else {
      print('Max retries reached for $operationId, giving up');
      // Update appropriate status depending on the operation
      if (operationId == 'patientInfo') {
        _updatePatientInfoSyncStatus(
          FhirSyncStatus.error,
          'Max retries reached (${_retryManager.maxRetries})',
        );
      } else if (operationId == 'timeMetrics') {
        _updateTimeMetricsSyncStatus(
          FhirSyncStatus.error,
          'Max retries reached (${_retryManager.maxRetries})',
        );
      }
    }
  }

  /// Checks if the user is connected to the FHIR server
  Future<bool> _isConnectedToFhirServer() async {
    try {
      return await ref.read(fhirServiceProvider).isConnected();
    } catch (e) {
      debugPrint('Error checking FHIR server connection: $e');
      return false;
    }
  }

  // Track in-progress sync operations to prevent race conditions
  bool _patientSyncInProgress = false;
  bool _timeMetricsSyncInProgress = false;

  /// Sync patient info with FHIR server
  Future<void> _syncPatientInfo(PatientInfoModel patientInfo) async {
    // Don't sync if paused
    if (_isSyncPaused) {
      print('Sync is paused, not syncing patient info');
      return;
    }

    // Prevent concurrent syncs
    if (_patientSyncInProgress) {
      debugPrint('Patient sync already in progress, skipping');
      return;
    }

    if (!patientInfo.isDirty) {
      _updatePatientInfoSyncStatus(FhirSyncStatus.synced);
      return;
    }

    try {
      _patientSyncInProgress = true;

      // Check if connected to FHIR server
      final isConnected = await _isConnectedToFhirServer();
      if (!isConnected) {
        debugPrint('Not connected to FHIR server, marking as offline');
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
              method: refs.hasPatientReference ? HTTPVerb.pUT : HTTPVerb.pOST,
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
                    ? HTTPVerb.pUT
                    : HTTPVerb.pOST,
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

      // Reset retry count on successful sync
      _retryManager.resetRetries('patientInfo');

      // Update sync status to synced
      _updatePatientInfoSyncStatus(FhirSyncStatus.synced);
    } catch (e) {
      // Update sync status to error
      _updatePatientInfoSyncStatus(FhirSyncStatus.error, e.toString());

      // Schedule a retry with exponential backoff
      _scheduleRetry('patientInfo', () => _syncPatientInfo(patientInfo));

      debugPrint('Error syncing patient info: $e');
    } finally {
      _patientSyncInProgress = false;
    }
  }

  /// Sync time metrics with FHIR server
  Future<void> _syncTimeMetrics(TimeMetricsModel timeMetrics) async {
    // Don't sync if paused
    if (_isSyncPaused) {
      print('Sync is paused, not syncing time metrics');
      return;
    }

    // Prevent concurrent syncs
    if (_timeMetricsSyncInProgress) {
      debugPrint('Time metrics sync already in progress, skipping');
      return;
    }

    if (!timeMetrics.isDirty) {
      _updateTimeMetricsSyncStatus(FhirSyncStatus.synced);
      return;
    }

    try {
      _timeMetricsSyncInProgress = true;

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
              method: HTTPVerb.pUT,
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
              method: HTTPVerb.pOST,
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
                method: HTTPVerb.pUT,
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
                method: HTTPVerb.pOST,
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
                method: HTTPVerb.pUT,
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
                method: HTTPVerb.pOST,
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
                method: HTTPVerb.pUT,
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
                method: HTTPVerb.pOST,
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
      // Use the markAsDirty=false parameter to avoid setting isDirty=true right after sync
      final syncedModel = timeMetrics.markSynced();
      ref
          .read(timeMetricsRepositoryProvider)
          .setTimeMetrics(syncedModel, markAsDirty: false);

      // Reset retry count on successful sync
      _retryManager.resetRetries('timeMetrics');

      // Update sync status to synced
      _updateTimeMetricsSyncStatus(FhirSyncStatus.synced);
    } catch (e) {
      // Update sync status to error
      _updateTimeMetricsSyncStatus(FhirSyncStatus.error, e.toString());

      // Schedule a retry with exponential backoff
      _scheduleRetry('timeMetrics', () => _syncTimeMetrics(timeMetrics));

      debugPrint('Error syncing time metrics: $e');
    } finally {
      _timeMetricsSyncInProgress = false;
    }
  }

  // Helper methods for FHIR resource manipulation

  /// Sends a FHIR transaction bundle to the server and returns the response
  Future<Bundle> sendFhirBundle(Bundle bundle) async {
    try {
      // Use the FhirService for handling authenticated FHIR requests
      // with fallback to simulation when needed
      return await ref
          .read(fhirServiceProvider)
          .postTransactionBundleWithFallback(bundle);
    } catch (e) {
      // Log the error for debugging
      print('Error sending FHIR bundle: $e');

      // Rethrow to let the calling code handle the error
      rethrow;
    }
  }

  /// Get existing patient resource by ID
  Future<Patient> _getPatientResource(String id) async {
    try {
      // Use the FhirService for authenticated resource retrieval
      final resource = await ref.read(fhirServiceProvider).readResource(
            resourceType: 'Patient',
            id: id,
          );
      return resource as Patient;
    } catch (e) {
      print('Error retrieving Patient $id: $e');
      // Fallback to simulated response for demo mode
      return Patient(id: FhirString(id));
    }
  }

  /// Get existing practitioner resource by ID
  Future<Practitioner> _getPractitionerResource(String id) async {
    try {
      // Use the FhirService for authenticated resource retrieval
      final resource = await ref.read(fhirServiceProvider).readResource(
            resourceType: 'Practitioner',
            id: id,
          );
      return resource as Practitioner;
    } catch (e) {
      print('Error retrieving Practitioner $id: $e');
      // Fallback to simulated response for demo mode
      return Practitioner(id: FhirString(id));
    }
  }

  /// Get existing encounter resource by ID
  Future<Encounter> _getEncounterResource(String id) async {
    try {
      // Use the FhirService for authenticated resource retrieval
      final resource = await ref.read(fhirServiceProvider).readResource(
            resourceType: 'Encounter',
            id: id,
          );
      return resource as Encounter;
    } catch (e) {
      print('Error retrieving Encounter $id: $e');
      // Fallback to simulated response for demo mode
      final empty = defaultEmsEncounter;
      return empty.copyWith(id: FhirString(id));
    }
  }

  /// Get existing medication administration resource by ID
  Future<MedicationAdministration> _getMedicationAdministrationResource(
    String id,
  ) async {
    try {
      // Use the FhirService for authenticated resource retrieval
      final resource = await ref.read(fhirServiceProvider).readResource(
            resourceType: 'MedicationAdministration',
            id: id,
          );
      return resource as MedicationAdministration;
    } catch (e) {
      print('Error retrieving MedicationAdministration $id: $e');
      // Fallback to simulated response for demo mode
      // final empty = MedicationAdministration.empty();
      // return empty.copyWith(id: FhirString(id));
      rethrow;
    }
  }

  /// Get existing condition resource by ID
  Future<Condition> _getConditionResource(String id) async {
    try {
      // Use the FhirService for authenticated resource retrieval
      final resource = await ref.read(fhirServiceProvider).readResource(
            resourceType: 'Condition',
            id: id,
          );
      return resource as Condition;
    } catch (e) {
      print('Error retrieving Condition $id: $e');
      // Fallback to simulated response for demo mode
      // final empty = Condition.empty();
      // return empty.copyWith(id: FhirString(id));
      rethrow;
    }
  }

  /// Get existing questionnaire response by ID
  Future<QuestionnaireResponse> _getQuestionnaireResponseResource(
    String id,
  ) async {
    try {
      // Use the FhirService for authenticated resource retrieval
      final resource = await ref.read(fhirServiceProvider).readResource(
            resourceType: 'QuestionnaireResponse',
            id: id,
          );
      return resource as QuestionnaireResponse;
    } catch (e) {
      print('Error retrieving QuestionnaireResponse $id: $e');
      // Fallback to simulated response for demo mode
      // final empty = QuestionnaireResponse.empty();
      // return empty.copyWith(id: FhirString(id));
      rethrow;
    }
  }
}

/// Provides the FHIR sync service
@Riverpod(keepAlive: true)
FhirSyncService fhirSyncService(Ref ref) {
  return FhirSyncService(ref);
}
