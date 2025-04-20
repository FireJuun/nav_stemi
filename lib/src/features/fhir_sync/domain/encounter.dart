import 'package:fhir_r4/fhir_r4.dart';
import 'package:nav_stemi/nav_stemi.dart';

extension EncounterX on Encounter {
  Encounter updateLocations(TimeMetricsModel timeMetrics) {
    final arrivedAtPatient = timeMetrics.timeArrivedAtPatient;
    final firstEkg = timeMetrics.timeOfFirstEkg();
    final unitLeftScene = timeMetrics.timeUnitLeftScene;
    final patientArrivedAtDestination =
        timeMetrics.timePatientArrivedAtDestination;

    final locations = [
      if (arrivedAtPatient != null)
        EncounterLocation(
          location: Reference(
            reference: FhirString('arrivedAtPatient'),
          ),
          period: Period(
            start: FhirDateTime.fromDateTime(arrivedAtPatient),
            end: FhirDateTime.fromDateTime(arrivedAtPatient),
          ),
        ),
      if (firstEkg != null)
        EncounterLocation(
          location: Reference(
            reference: FhirString('firstEkg'),
          ),
          period: Period(
            start: FhirDateTime.fromDateTime(firstEkg),
            end: FhirDateTime.fromDateTime(firstEkg),
          ),
        ),
      if (unitLeftScene != null)
        EncounterLocation(
          location: Reference(
            reference: FhirString('unitLeftScene'),
          ),
          period: Period(
            start: FhirDateTime.fromDateTime(unitLeftScene),
            end: FhirDateTime.fromDateTime(unitLeftScene),
          ),
        ),
      if (patientArrivedAtDestination != null)
        EncounterLocation(
          location: Reference(
            reference: FhirString('patientArrivedAtDestination'),
          ),
          period: Period(
            start: FhirDateTime.fromDateTime(patientArrivedAtDestination),
            end: FhirDateTime.fromDateTime(patientArrivedAtDestination),
          ),
        ),
    ];
    return copyWith(location: locations);
  }

  /// This tracks a single instance of STEMI care from an EMS perspective.
  /// Timestamps and their NEMSIS data connections are provided

  Encounter asEmsEncounter() {
    /// These fields define an EMS Encounter, in case other types
    /// are added in the future.
    /// R4 Spec: https://hl7.org/fhir/R4/encounter.html
    return copyWith(
      status: EncounterStatus.in_progress,

      /// R4 Spec: https://hl7.org/fhir/R4/v3/ActEncounterCode/vs.html
      class_: Coding(
        system: FhirUri('http://terminology.hl7.org/CodeSystem/v3-ActCode'),
        code: FhirCode('FLD'),
        display: FhirString('field'),
      ),

      /// R4 Spec: https://hl7.org/fhir/R4/v3/ActPriority/vs.html
      priority: CodeableConcept(
        coding: [
          Coding(
            system:
                FhirUri('http://terminology.hl7.org/CodeSystem/v3-ActPriority'),
            code: FhirCode('EM'),
            display: FhirString('emergency'),
          ),
        ],
      ),

      /// R4 Spec: https://hl7.org/fhir/R4/valueset-service-type.html
      serviceType: CodeableConcept(
        coding: [
          Coding(
            system:
                FhirUri('http://terminology.hl7.org/CodeSystem/service-type'),
            code: FhirCode('226'),
            display: FhirString('Ambulance'),
          ),
        ],
      ),
    );
  }

  Encounter updatePatientReference(Patient patient) {
    return copyWith(subject: patient.thisReference);
  }

  Encounter updateCardiologistReference(Practitioner cardiologist) {
    final participants = participant ?? [];

    /// The cardiologist is always an indirect target.
    final indirectTarget = [
      CodeableConcept(
        coding: [
          /// R4 Spec: https://hl7.org/fhir/R4/v3/ParticipationType/cs.html#v3-ParticipationType-_ParticipationAncillary
          Coding(
            system: FhirUri(
              'http://terminology.hl7.org/CodeSystem/v3-ParticipationType',
            ),
            code: FhirCode('IND'),
            display: FhirString('indirect target'),
          ),
        ],
      ),
    ];

    final cardiologistParticipant = EncounterParticipant(
      individual: cardiologist.thisReference,
      type: indirectTarget,
    );

    /// Find the index of the existing indirect target participant, if any
    final indirectTargetIndex =
        participants.indexWhere((p) => p.type == indirectTarget);

    /// Update the old cardiologist reference, or
    /// add a new one if it doesn't exist
    (indirectTargetIndex != -1)
        ? participants.replaceRange(
            indirectTargetIndex,
            indirectTargetIndex + 1,
            [cardiologistParticipant],
          )
        : participants.add(cardiologistParticipant);

    return copyWith(participant: participants);
  }
}
