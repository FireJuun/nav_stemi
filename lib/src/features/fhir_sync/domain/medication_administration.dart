import 'package:fhir_r4/fhir_r4.dart';

/// RxNorm API available here: https://www.nlm.nih.gov/research/umls/rxnorm/index.html
/// Content was found in this valueset: https://build.fhir.org/ig/HL7/PDDI-CDS/ValueSet-valueset-aspirin.html
///
/// "This product uses publicly available data courtesy of the U.S. National
/// Library of Medicine (NLM), National Institutes of Health, Department of
/// Health and Human Services; NLM is not responsible for the product and
/// does not endorse or recommend this or any other product."

extension MedicationAdministrationX on MedicationAdministration {
  MedicationAdministration aspirinGiven({
    required Patient patient,
    required DateTime dateTime,
    bool wasGiven = true,
  }) {
    return copyWith(
      /// defined by: https://hl7.org/fhir/R4/event.html#statemachine
      status: MedicationAdministrationStatusCodes(
        wasGiven ? 'completed' : 'not-done',
      ),
      category: CodeableConcept(
        coding: [
          /// R4 spec: https://build.fhir.org/ig/HL7/PDDI-CDS/ValueSet-valueset-aspirin.html
          Coding(
            system: FhirUri('http://www.nlm.nih.gov/research/umls/rxnorm'),
            code: FhirCode('317300'), // RxNorm code for Aspirin 325
            display: FhirString('Aspirin 325 mg'),
          ),
        ],
      ),
      subject: Reference(reference: patient.id),
      effectiveX: FhirDateTime.fromDateTime(dateTime),
    );
  }
}
