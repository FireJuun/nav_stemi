import 'package:fhir_r4/fhir_r4.dart';

/// Creates a FHIR Composition resource that references all resources
/// related to a complete encounter
Composition createEncounterComposition({
  required String encounterId,
  required String patientId,
  required List<String> practitionerIds,
  required List<String> observationIds,
  required List<String> medicationAdminIds,
  required List<String> questionnaireResponseIds,
  String? conditionId,
}) {
  return Composition(
    status: CompositionStatus.final_,
    type: CodeableConcept(
      coding: [
        Coding(
          system: FhirUri('http://loinc.org'),
          code: FhirCode('34133-9'),
          display: FhirString('Summary of episode note'),
        ),
      ],
    ),
    subject: Reference(reference: FhirString('Patient/$patientId')),
    encounter: Reference(reference: FhirString('Encounter/$encounterId')),
    date: FhirDateTime.fromDateTime(DateTime.now()),
    author: [
      for (final id in practitionerIds)
        Reference(reference: FhirString('Practitioner/$id')),
    ],
    title: FhirString('STEMI Encounter Summary'),
    section: [
      // Encounter details section
      CompositionSection(
        title: FhirString('Encounter Details'),
        code: CodeableConcept(
          coding: [
            Coding(
              system: FhirUri('http://loinc.org'),
              code: FhirCode('LP173192-8'),
              display:
                  FhirString('Evaluation and management of a specific problem'),
            ),
          ],
        ),
        entry: [
          Reference(reference: FhirString('Encounter/$encounterId')),
        ],
      ),
      // Patient details section
      CompositionSection(
        title: FhirString('Patient Details'),
        code: CodeableConcept(
          coding: [
            Coding(
              system: FhirUri('http://loinc.org'),
              code: FhirCode('60591-5'),
              display: FhirString('Patient summary'),
            ),
          ],
        ),
        entry: [
          Reference(reference: FhirString('Patient/$patientId')),
        ],
      ),
      // Clinical findings section
      CompositionSection(
        title: FhirString('Clinical Findings'),
        code: CodeableConcept(
          coding: [
            Coding(
              system: FhirUri('http://loinc.org'),
              code: FhirCode('11348-0'),
              display: FhirString('History of clinical findings'),
            ),
          ],
        ),
        entry: [
          for (final id in observationIds)
            Reference(reference: FhirString('Observation/$id')),
          if (conditionId != null)
            Reference(reference: FhirString('Condition/$conditionId')),
        ],
      ),
      // Medications section
      CompositionSection(
        title: FhirString('Medications Administered'),
        code: CodeableConcept(
          coding: [
            Coding(
              system: FhirUri('http://loinc.org'),
              code: FhirCode('29549-3'),
              display: FhirString('Medication administered'),
            ),
          ],
        ),
        entry: [
          for (final id in medicationAdminIds)
            Reference(reference: FhirString('MedicationAdministration/$id')),
        ],
      ),
      // Questionnaire responses section
      CompositionSection(
        title: FhirString('Timestamp Forms'),
        entry: [
          for (final id in questionnaireResponseIds)
            Reference(reference: FhirString('QuestionnaireResponse/$id')),
        ],
      ),
    ],
  );
}
