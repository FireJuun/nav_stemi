import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fhir_sync_service.g.dart';

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
  error
}

class FhirSyncService {
  // This class is responsible for syncing FHIR resources with the server.
  // It will handle the logic for fetching, updating, and deleting resources.

  FhirSyncService(this.ref) {
    _init();
  }

  final Ref ref;

  // Track the current sync status
  FhirSyncStatus _patientInfoSyncStatus = FhirSyncStatus.synced;
  FhirSyncStatus _timeMetricsSyncStatus = FhirSyncStatus.synced;
  String? _lastErrorMessage;

  FhirSyncStatus get patientInfoSyncStatus => _patientInfoSyncStatus;
  FhirSyncStatus get timeMetricsSyncStatus => _timeMetricsSyncStatus;
  String? get lastErrorMessage => _lastErrorMessage;

  /// Updates the patient info sync status and notifies listeners
  void _updatePatientInfoSyncStatus(
    FhirSyncStatus status, [
    String? errorMessage,
  ]) {
    _patientInfoSyncStatus = status;
    if (errorMessage != null) {
      _lastErrorMessage = errorMessage;
    }
    ref.notifyListeners();
  }

  /// Updates the time metrics sync status and notifies listeners
  void _updateTimeMetricsSyncStatus(
    FhirSyncStatus status, [
    String? errorMessage,
  ]) {
    _timeMetricsSyncStatus = status;
    if (errorMessage != null) {
      _lastErrorMessage = errorMessage;
    }
    ref.notifyListeners();
  }

  /// Updates the overall sync status and notifies listeners
  void _updateOverallSyncStatus() {
    // Overall status is the "worst" status between patient info
    // and time metrics
    ref.notifyListeners();
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
              _updateOverallSyncStatus();

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
              _updateOverallSyncStatus();

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
      _updateOverallSyncStatus();
      return;
    }

    try {
      // Check if connected to FHIR server
      final isConnected = await _isConnectedToFhirServer();
      if (!isConnected) {
        _updatePatientInfoSyncStatus(FhirSyncStatus.offline);
        _updateOverallSyncStatus();
        return;
      }

      // Update sync status to syncing
      _updatePatientInfoSyncStatus(FhirSyncStatus.syncing);
      _updateOverallSyncStatus();

      // Use the PatientInfoFhirDTO to convert and sync data
      const dto = PatientInfoFhirDTO();

      // Get existing FHIR resources or create new ones if they don't exist
      final existingPatient = await _getOrCreatePatientResource(patientInfo);
      final existingPractitioner = patientInfo.cardiologist != null
          ? await _getOrCreateCardiologistResource(patientInfo)
          : null;

      // Update FHIR resources with changes from PatientInfoModel
      final updatedPatient =
          dto.toFhirPatient(patientInfo, existingPatient: existingPatient);
      final updatedPractitioner = patientInfo.cardiologist != null
          ? dto.toFhirCardiologist(
              patientInfo,
              existingPractitioner: existingPractitioner,
            )
          : null;

      // Send updated resources to FHIR server
      await _savePatientResource(updatedPatient);
      if (updatedPractitioner != null) {
        await _savePractitionerResource(updatedPractitioner);
      }

      // Mark the model as synced in local storage
      final repository = ref.read(patientInfoRepositoryProvider);
      repository.patientInfoModel = patientInfo.markSynced();

      // Update sync status to synced
      _updatePatientInfoSyncStatus(FhirSyncStatus.synced);
      _updateOverallSyncStatus();
    } catch (e) {
      // Update sync status to error
      _updatePatientInfoSyncStatus(FhirSyncStatus.error, e.toString());
      _updateOverallSyncStatus();
    }
  }

  /// Sync time metrics with FHIR server
  Future<void> _syncTimeMetrics(TimeMetricsModel timeMetrics) async {
    if (!timeMetrics.isDirty) {
      _updateTimeMetricsSyncStatus(FhirSyncStatus.synced);
      _updateOverallSyncStatus();
      return;
    }

    try {
      // Check if connected to FHIR server
      final isConnected = await _isConnectedToFhirServer();
      if (!isConnected) {
        _updateTimeMetricsSyncStatus(FhirSyncStatus.offline);
        _updateOverallSyncStatus();
        return;
      }

      // Update sync status to syncing
      _updateTimeMetricsSyncStatus(FhirSyncStatus.syncing);
      _updateOverallSyncStatus();

      // Use the TimeMetricsFhirDTO to convert and sync data
      const dto = TimeMetricsFhirDTO();

      // Get existing FHIR resources or create new ones if they don't exist
      final patientInfo = ref.read(patientInfoModelProvider).value;
      if (patientInfo == null) {
        throw Exception('Patient info is required for time metrics sync');
      }

      final existingPatient = await _getOrCreatePatientResource(patientInfo);
      final existingEncounter =
          await _getOrCreateEncounterResource(timeMetrics, existingPatient);
      final existingAspirin =
          await _getOrCreateAspirinResource(timeMetrics, existingPatient);
      final existingStemi = await _getOrCreateStemiResource(
        timeMetrics,
        existingPatient,
        existingEncounter,
      );
      final existingResponse = await _getOrCreateQuestionnaireResponse(
        timeMetrics,
        existingPatient,
        existingEncounter,
      );

      // Update FHIR resources with changes from TimeMetricsModel
      final updatedEncounter = dto.toFhirEncounter(
        timeMetrics,
        existingEncounter: existingEncounter,
      );

      final updatedAspirin = timeMetrics.timeOfAspirinGivenDecision != null
          ? dto.toFhirAspirinAdministration(
              timeMetrics,
              patient: existingPatient,
              existingAdministration: existingAspirin,
            )
          : null;

      final updatedStemi = timeMetrics.timeOfStemiActivationDecision != null
          ? dto.toFhirStemiCondition(
              timeMetrics,
              patient: existingPatient,
              encounter: existingEncounter,
              existingCondition: existingStemi,
            )
          : null;

      final updatedQuestionnaire =
          timeMetrics.timeCathLabNotifiedDecision != null ||
                  timeMetrics.timeOfStemiActivationDecision != null
              ? dto.toFhirQuestionnaireResponse(
                  timeMetrics,
                  encounter: existingEncounter,
                  existingResponse: existingResponse,
                )
              : null;

      // Send updated resources to FHIR server
      await _saveEncounterResource(updatedEncounter);
      if (updatedAspirin != null) {
        await _saveMedicationAdministrationResource(updatedAspirin);
      }
      if (updatedStemi != null) {
        await _saveConditionResource(updatedStemi);
      }
      if (updatedQuestionnaire != null) {
        await _saveQuestionnaireResponseResource(updatedQuestionnaire);
      }

      // Mark the model as synced in local storage
      ref
          .read(timeMetricsRepositoryProvider)
          .setTimeMetrics(timeMetrics.markSynced());

      // Update sync status to synced
      _updateTimeMetricsSyncStatus(FhirSyncStatus.synced);
      _updateOverallSyncStatus();
    } catch (e) {
      // Update sync status to error
      _updateTimeMetricsSyncStatus(FhirSyncStatus.error, e.toString());
      _updateOverallSyncStatus();
    }
  }

  // Helper methods for FHIR resource manipulation

  /// Get existing patient resource or create a new one
  Future<Patient> _getOrCreatePatientResource(
    PatientInfoModel patientInfo,
  ) async {
    // TODO: Implement actual FHIR API call to get existing patient
    // For now, just return a new Patient
    return const Patient();
  }

  /// Get existing cardiologist resource or create a new one
  Future<Practitioner> _getOrCreateCardiologistResource(
    PatientInfoModel patientInfo,
  ) async {
    // TODO: Implement actual FHIR API call to get existing practitioner
    // For now, just return a new Practitioner
    return const Practitioner();
  }

  /// Get existing encounter resource or create a new one
  Future<Encounter> _getOrCreateEncounterResource(
    TimeMetricsModel timeMetrics,
    Patient patient,
  ) async {
    // TODO: Implement actual FHIR API call to get existing encounter
    // For now, just return a new Encounter
    return Encounter.empty().asEmsEncounter();
  }

  /// Get existing aspirin administration resource or create a new one
  Future<MedicationAdministration?> _getOrCreateAspirinResource(
    TimeMetricsModel timeMetrics,
    Patient patient,
  ) async {
    // TODO: Implement actual FHIR API call to get existing resource
    // For now, just return null if no aspirin decision was made
    if (timeMetrics.timeOfAspirinGivenDecision == null) {
      return null;
    }
    return MedicationAdministration.empty();
  }

  /// Get existing STEMI condition resource or create a new one
  Future<Condition?> _getOrCreateStemiResource(
    TimeMetricsModel timeMetrics,
    Patient patient,
    Encounter encounter,
  ) async {
    // TODO: Implement actual FHIR API call to get existing resource
    // For now, just return null if no STEMI decision was made
    if (timeMetrics.timeOfStemiActivationDecision == null) {
      return null;
    }
    return Condition.empty();
  }

  /// Get existing questionnaire response or create a new one
  Future<QuestionnaireResponse?> _getOrCreateQuestionnaireResponse(
    TimeMetricsModel timeMetrics,
    Patient patient,
    Encounter encounter,
  ) async {
    // TODO: Implement actual FHIR API call to get existing resource
    // For now, just return a new one if needed
    if (timeMetrics.timeCathLabNotifiedDecision == null &&
        timeMetrics.timeOfStemiActivationDecision == null) {
      return null;
    }
    return QuestionnaireResponse.empty().create(
      patient: patient.thisReference,
      encounter: encounter.thisReference,
    );
  }

  /// Save patient resource to FHIR server
  Future<void> _savePatientResource(Patient patient) async {
    // TODO: Implement actual FHIR API call to save resource
    await Future<void>.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate network delay
  }

  /// Save practitioner resource to FHIR server
  Future<void> _savePractitionerResource(Practitioner practitioner) async {
    // TODO: Implement actual FHIR API call to save resource
    await Future<void>.delayed(
      const Duration(milliseconds: 300),
    ); // Simulate network delay
  }

  /// Save encounter resource to FHIR server
  Future<void> _saveEncounterResource(Encounter encounter) async {
    // TODO: Implement actual FHIR API call to save resource
    await Future<void>.delayed(
      const Duration(milliseconds: 400),
    ); // Simulate network delay
  }

  /// Save medication administration resource to FHIR server
  Future<void> _saveMedicationAdministrationResource(
    MedicationAdministration resource,
  ) async {
    // TODO: Implement actual FHIR API call to save resource
    await Future<void>.delayed(
      const Duration(milliseconds: 300),
    ); // Simulate network delay
  }

  /// Save condition resource to FHIR server
  Future<void> _saveConditionResource(Condition condition) async {
    // TODO: Implement actual FHIR API call to save resource
    await Future<void>.delayed(
      const Duration(milliseconds: 350),
    ); // Simulate network delay
  }

  /// Save questionnaire response resource to FHIR server
  Future<void> _saveQuestionnaireResponseResource(
    QuestionnaireResponse response,
  ) async {
    // TODO: Implement actual FHIR API call to save resource
    await Future<void>.delayed(
      const Duration(milliseconds: 300),
    ); // Simulate network delay
  }
}

/// Provides the FHIR sync service
@Riverpod(keepAlive: true)
FhirSyncService fhirSyncService(Ref ref) {
  return FhirSyncService(ref);
}

/// Provides the status of patient info sync
@Riverpod(keepAlive: true)
FhirSyncStatus fhirPatientInfoSyncStatus(Ref ref) {
  return ref.watch(fhirSyncServiceProvider).patientInfoSyncStatus;
}

/// Provides the status of time metrics sync
@Riverpod(keepAlive: true)
FhirSyncStatus fhirTimeMetricsSyncStatus(Ref ref) {
  return ref.watch(fhirSyncServiceProvider).timeMetricsSyncStatus;
}

/// Provides the overall sync status (combined from patient info and time metrics)
@Riverpod(keepAlive: true)
FhirSyncStatus fhirOverallSyncStatus(Ref ref) {
  final patientStatus = ref.watch(fhirPatientInfoSyncStatusProvider);
  final timeMetricsStatus = ref.watch(fhirTimeMetricsSyncStatusProvider);

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

/// Provides the last error message from sync operations
@Riverpod(keepAlive: true)
String? fhirSyncLastErrorMessage(Ref ref) {
  return ref.watch(fhirSyncServiceProvider).lastErrorMessage;
}
