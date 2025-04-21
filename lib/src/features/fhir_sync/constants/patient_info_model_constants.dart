import 'package:fhir_r4/fhir_r4.dart';

/// This tracks a single instance of STEMI care from an EMS perspective.
/// Timestamps and their NEMSIS data connections are provided
///
/// These fields define an EMS Encounter, in case other types
/// are added in the future.
/// R4 Spec: https://hl7.org/fhir/R4/encounter.html
final defaultEmsEncounter = Encounter(
  status: EncounterStatus.inProgress,

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
        system: FhirUri('http://terminology.hl7.org/CodeSystem/v3-ActPriority'),
        code: FhirCode('EM'),
        display: FhirString('emergency'),
      ),
    ],
  ),

  /// R4 Spec: https://hl7.org/fhir/R4/valueset-service-type.html
  serviceType: CodeableConcept(
    coding: [
      Coding(
        system: FhirUri('http://terminology.hl7.org/CodeSystem/service-type'),
        code: FhirCode('226'),
        display: FhirString('Ambulance'),
      ),
    ],
  ),
);
