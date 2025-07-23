import 'package:fhir_r4/fhir_r4.dart';
import 'package:nav_stemi/nav_stemi.dart';

/// Data Transfer Object to convert between TimeMetricsModel and FHIR resources
///
/// This handles conversion to/from the following FHIR resources:
/// - Encounter (for arrivedAtPatient, firstEkg, unitLeftScene,
///     patientArrivedAtDestination timestamps)
/// - QuestionnaireResponse (for additional STEMI and cath lab
///     notification data)
/// - MedicationAdministration (for aspirinGiven data)
/// - Condition (for stemiObservation data)
///
/// Leverages existing FHIR domain extensions in fhir_sync/domain
class TimeMetricsFhirDTO {
  const TimeMetricsFhirDTO();

  /// Converts from FHIR resources to TimeMetricsModel
  /// Returns a TimeMetricsModel with the dirty flag set to false
  TimeMetricsModel fromFhir({
    required Encounter encounter,
    MedicationAdministration? aspirinAdministration,
    Condition? stemiCondition,
    QuestionnaireResponse? stemiQuestionnaire,
  }) {
    // Extract location information from encounter
    final locations = encounter.location ?? [];

    // Extract timestamps
    DateTime? timeArrivedAtPatient;
    DateTime? firstEkgTime;
    DateTime? timeUnitLeftScene;
    DateTime? timePatientArrivedAtDestination;

    // Extract all time information from location resources
    for (final location in locations) {
      final displayName = location.location.display?.valueString;
      final startTime = location.period?.start != null
          ? DateTime.parse(location.period!.start.toString())
          : null;

      if (startTime != null && displayName != null) {
        switch (displayName) {
          case 'arrivedAtPatient':
            timeArrivedAtPatient = startTime;
          case 'firstEkg':
            firstEkgTime = startTime;
          case 'unitLeftScene':
            timeUnitLeftScene = startTime;
          case 'patientArrivedAtDestination':
            timePatientArrivedAtDestination = startTime;
        }
      }
    }

    // Create set of EKG times
    final timeOfEkgs = <DateTime?>{};
    if (firstEkgTime != null) {
      timeOfEkgs.add(firstEkgTime);
    }

    // Extract STEMI activation data from Condition
    DateTime? timeOfStemiActivationDecision;
    bool? wasStemiActivated;
    if (stemiCondition != null) {
      // Extract time from onset
      if (stemiCondition.onsetX is FhirDateTime) {
        timeOfStemiActivationDecision =
            DateTime.parse(stemiCondition.onsetX!.primitiveValue ?? '');
      }

      // Extract activation status from clinicalStatus
      final clinicalStatusCode =
          stemiCondition.clinicalStatus?.coding?.firstOrNull?.code;

      if (clinicalStatusCode != null) {
        wasStemiActivated = clinicalStatusCode == FhirCode('active');
      }
    }

    // Extract aspirin data from MedicationAdministration
    DateTime? timeOfAspirinGivenDecision;
    bool? wasAspirinGiven;
    if (aspirinAdministration != null) {
      // Extract time
      if (aspirinAdministration.effectiveX is FhirDateTime) {
        timeOfAspirinGivenDecision = DateTime.parse(
          aspirinAdministration.effectiveX.primitiveValue ?? '',
        );
      }

      // Extract given status
      wasAspirinGiven = aspirinAdministration.status ==
          MedicationAdministrationStatusCodes.completed;
    }

    // Extract cath lab notification data from QuestionnaireResponse
    DateTime? timeCathLabNotifiedDecision;
    bool? wasCathLabNotified;
    if (stemiQuestionnaire != null) {
      final items = stemiQuestionnaire.item ?? [];
      for (final item in items) {
        if (item.linkId == FhirString('wasCathLabNotified')) {
          wasCathLabNotified =
              item.answer?.firstOrNull?.valueBoolean?.valueBoolean;
        }
        if (item.linkId == FhirString('cathLabNotificationDecisionTimestamp')) {
          timeCathLabNotifiedDecision =
              item.answer?.firstOrNull?.valueDateTime?.valueDateTime;
        }
      }
    }

    // Determine lock statuses based on encounter status
    final isLocked = encounter.status == EncounterStatus.finished;

    // Create TimeMetricsModel with dirty flag set to false (synced with FHIR)
    return TimeMetricsModel(
      timeArrivedAtPatient: timeArrivedAtPatient,
      lockTimeArrivedAtPatient: isLocked,
      timeOfEkgs: timeOfEkgs,
      lockTimeOfEkgs: isLocked,
      timeOfStemiActivationDecision: timeOfStemiActivationDecision,
      wasStemiActivated: wasStemiActivated,
      lockTimeOfStemiActivationDecision: isLocked,
      timeUnitLeftScene: timeUnitLeftScene,
      lockTimeUnitLeftScene: isLocked,
      timeOfAspirinGivenDecision: timeOfAspirinGivenDecision,
      wasAspirinGiven: wasAspirinGiven,
      lockTimeOfAspirinGivenDecision: isLocked,
      timeCathLabNotifiedDecision: timeCathLabNotifiedDecision,
      wasCathLabNotified: wasCathLabNotified,
      lockTimeCathLabNotifiedDecision: isLocked,
      timePatientArrivedAtDestination: timePatientArrivedAtDestination,
      lockTimePatientArrivedAtDestination: isLocked,
      isDirty: false, // Data is synced with FHIR
    );
  }

  /// Converts TimeMetricsModel to an Encounter FHIR resource
  /// Leverages the existing EncounterX.updateLocations extension
  Encounter toFhirEncounter(
    TimeMetricsModel model, {
    Encounter? existingEncounter,
  }) {
    // Create a new EMS Encounter or use an existing one
    final encounter = existingEncounter ??

        /// blank encounter, with status, class, priority, and
        /// serviceType to be overridden via .asEmsEncounter()
        defaultEmsEncounter;

    // Update encounter status based on locks
    final status = _areAllFieldsLocked(model)
        ? EncounterStatus.finished
        : EncounterStatus.inProgress;

    // Update locations using the existing extension
    return encounter.updateLocations(model).copyWith(status: status);
  }

  QuestionnaireResponse toFhirQuestionnaireResponse(
    TimeMetricsModel model, {
    required Encounter encounter,
    QuestionnaireResponse? existingResponse,
  }) {
    // Create a new QuestionnaireResponse or use an existing one
    final response = existingResponse ?? defaultQuestionnaireResponse;

    // Update the response with time metrics
    return response.updateTimeMetricAnswers(model).copyWith(
          status: _areAllFieldsLocked(model)
              ? QuestionnaireResponseStatus.completed
              : QuestionnaireResponseStatus.inProgress,
          encounter: encounter.thisReference,
        );
  }

  /// Converts TimeMetricsModel to a MedicationAdministration for aspirin
  /// Leverages the existing MedicationAdministrationX.aspirinGiven extension
  MedicationAdministration? toFhirAspirinAdministration(
    TimeMetricsModel model, {
    required Patient patient,
    MedicationAdministration? existingAdministration,
  }) {
    // Skip if no aspirin decision was made
    if (model.timeOfAspirinGivenDecision == null ||
        model.wasAspirinGiven == null) {
      return existingAdministration;
    }

    // Create a new Administration or use an existing one
    final administration = existingAdministration ??
        defaultMedicationAdministration(
          patientId: patient.thisReference,
          dateTime: model.timeOfAspirinGivenDecision!,
          wasGiven: model.wasAspirinGiven!,
        );

    // Update status based on whether aspirin was given
    return administration.copyWith(
      status: model.wasAspirinGiven!
          ? MedicationAdministrationStatusCodes.completed
          : MedicationAdministrationStatusCodes.notDone,
    );
  }

  /// Converts TimeMetricsModel to a Condition for STEMI activation
  /// Leverages the existing ConditionX.stemiObservation extension
  Condition? toFhirStemiCondition(
    TimeMetricsModel model, {
    required Patient patient,
    required Encounter encounter,
    Condition? existingCondition,
  }) {
    // Skip if no STEMI activation decision was made
    if (model.timeOfStemiActivationDecision == null ||
        model.wasStemiActivated == null) {
      return existingCondition;
    }

    // Create a new Condition or use an existing one
    final condition =
        existingCondition ?? Condition(subject: patient.thisReference);

    // Use the existing extension to create a STEMI observation
    return condition.stemiObservation(
      patientRef: patient.thisReference,
      encounterRef: encounter.thisReference,
      dateTime: model.timeOfStemiActivationDecision!,
      isStemiActivated: model.wasStemiActivated!,
    );
  }

  /// Helper method to check if all fields in the TimeMetricsModel are locked
  bool _areAllFieldsLocked(TimeMetricsModel model) {
    return model.lockTimeArrivedAtPatient &&
        model.lockTimeOfEkgs &&
        model.lockTimeOfStemiActivationDecision &&
        model.lockTimeUnitLeftScene &&
        model.lockTimeOfAspirinGivenDecision &&
        model.lockTimeCathLabNotifiedDecision &&
        model.lockTimePatientArrivedAtDestination;
  }
}
