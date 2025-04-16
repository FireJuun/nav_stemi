import 'package:fhir_r4/fhir_r4.dart';

/// Extension for Observation resource with methods to create specific
/// observations for chest pain, and EKG findings
extension ObservationX on Observation {
  /// Creates a chest pain observation
  ///
  /// Uses SNOMED CT coding system for chest pain (29857009)
  Observation chestPainObservation({
    required Patient patient,
    required DateTime dateTime,
  }) {
    return copyWith(
      status: ObservationStatus.final_,
      category: [
        CodeableConcept(
          coding: [
            Coding(
              system: FhirUri(
                'http://terminology.hl7.org/CodeSystem/observation-category',
              ),
              code: FhirCode('exam'),
              display: FhirString('Examination'),
            ),
          ],
        ),
      ],
      code: CodeableConcept(
        coding: [
          Coding(
            system: FhirUri('http://snomed.info/sct'),
            code: FhirCode('29857009'),
            display: FhirString('Chest pain'),
          ),
        ],
        text: FhirString('Chest pain assessment'),
      ),
      subject: Reference(reference: patient.id),
      effectiveX: FhirDateTime.fromDateTime(dateTime),
    );
  }

  /// Creates an EKG observation
  ///
  /// Uses LOINC coding system for 12-lead EKG (11524-6)
  Observation ekgObservation({
    required Patient patient,
    required DateTime dateTime,
    String? interpretation,
    String? notes,
    // Could include binary data for the actual EKG trace in the future
    Attachment? ekgData,
  }) {
    return copyWith(
      status: ObservationStatus.final_,
      category: [
        CodeableConcept(
          coding: [
            Coding(
              system: FhirUri(
                'http://terminology.hl7.org/CodeSystem/observation-category',
              ),
              code: FhirCode('procedure'),
              display: FhirString('Procedure'),
            ),
          ],
        ),
      ],
      code: CodeableConcept(
        coding: [
          Coding(
            system: FhirUri('http://loinc.org'),
            code: FhirCode('11524-6'),
            display: FhirString('EKG study'),
          ),
        ],
        text: FhirString('12-lead EKG'),
      ),
      subject: Reference(reference: patient.id),
      effectiveX: FhirDateTime.fromDateTime(dateTime),
      valueX: interpretation != null ? FhirString(interpretation) : null,
      note: notes != null ? [Annotation(text: FhirMarkdown(notes))] : null,
      // If we have binary EKG data in the future
      contained: ekgData != null
          ? [
              Binary(
                contentType: FhirCode('application/pdf'),
                data: ekgData.data,
              ),
            ]
          : null,
    );
  }
}
