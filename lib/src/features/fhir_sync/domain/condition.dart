import 'package:fhir_r4/fhir_r4.dart';

extension ConditionX on Condition {
  /// Creates a STEMI (ST-elevation myocardial infarction) observation
  ///
  /// Uses SNOMED CT coding system for STEMI (401303003)
  Condition stemiObservation({
    required Reference patientRef,
    required Reference encounterRef,
    required DateTime dateTime,
    bool isStemiActivated = true,
  }) {
    return copyWith(
      clinicalStatus: CodeableConcept(
        coding: [
          Coding(
            system: FhirUri(
              'http://terminology.hl7.org/CodeSystem/condition-clinical',
            ),
            code: FhirCode(isStemiActivated ? 'active' : 'inactive'),
          ),
        ],
      ),
      verificationStatus: CodeableConcept(
        coding: [
          Coding(
            system: FhirUri(
              'http://terminology.hl7.org/CodeSystem/condition-ver-status',
            ),
            code: FhirCode(isStemiActivated ? 'provisional' : 'refuted'),
          ),
        ],
      ),
      category: [
        CodeableConcept(
          coding: [
            Coding(
              system: FhirUri(
                'http://terminology.hl7.org/CodeSystem/condition-category',
              ),
              code: FhirCode('encounter-diagnosis'),
              display: FhirString('Encounter Diagnosis'),
            ),
          ],
        ),
      ],
      code: CodeableConcept(
        coding: [
          Coding(
            system: FhirUri('http://snomed.info/sct'),
            code: FhirCode('401303003'),
            display: FhirString('ST segment elevation myocardial infarction'),
          ),
        ],
      ),
      subject: patientRef,
      encounter: encounterRef,
      onsetX: FhirDateTime.fromDateTime(dateTime),
    );
  }
}
