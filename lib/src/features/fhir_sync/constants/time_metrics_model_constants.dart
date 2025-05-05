import 'package:fhir_r4/fhir_r4.dart';

/// RxNorm API available here: https://www.nlm.nih.gov/research/umls/rxnorm/index.html
/// Content was found in this valueset: https://build.fhir.org/ig/HL7/PDDI-CDS/ValueSet-valueset-aspirin.html
///
/// "This product uses publicly available data courtesy of the U.S. National
/// Library of Medicine (NLM), National Institutes of Health, Department of
/// Health and Human Services; NLM is not responsible for the product and
/// does not endorse or recommend this or any other product."

MedicationAdministration defaultMedicationAdministration({
  required Reference patientId,
  required DateTime dateTime,
  bool wasGiven = true,
}) =>
    MedicationAdministration(
      status: MedicationAdministrationStatusCodes.unknown,
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
      subject: patientId,
      medicationX: CodeableConcept(
        coding: [
          /// R4 spec: https://build.fhir.org/ig/HL7/PDDI-CDS/ValueSet-valueset-aspirin.html
          Coding(
            system: FhirUri('http://www.nlm.nih.gov/research/umls/rxnorm'),
            code: FhirCode('317300'), // RxNorm code for Aspirin 325
            display: FhirString('Aspirin 325 mg'),
          ),
        ],
      ),
      effectiveX: FhirDateTime.fromDateTime(dateTime),
    );

const defaultQuestionnaireResponse =
    QuestionnaireResponse(status: QuestionnaireResponseStatus.inProgress);

/// Questionnaire model for whether a STEMI was activated (+ timestamp)
/// and whether the cath lab was notified (+ timestamp).
/// Look at this example:
/// https://hl7.org/fhir/R4B/questionnaireresponse-example-bluebook.json.html
///

final defaultQuestionnaire = Questionnaire(
  status: PublicationStatus.draft,
  subjectType: [FhirCode('Patient')],
  item: <QuestionnaireItem>[
    QuestionnaireItem(
      linkId: FhirString('wasStemiActivated'),
      text: FhirString('Was STEMI activated?'),
      type: QuestionnaireItemType.boolean,
    ),
    QuestionnaireItem(
      linkId: FhirString('stemiActiviationDecisionTimestamp'),
      text: FhirString('Timestamp of STEMI activation decision'),
      type: QuestionnaireItemType.dateTime,
    ),
    QuestionnaireItem(
      linkId: FhirString('wasCathLabNotified'),
      text: FhirString('Was the cath lab notified?'),
      type: QuestionnaireItemType.boolean,
    ),
    QuestionnaireItem(
      linkId: FhirString('cathLabNotificationDecisionTimestamp'),
      text: FhirString('Timestamp of cath lab notification decision'),
      type: QuestionnaireItemType.dateTime,
    ),
    QuestionnaireItem(
      linkId: FhirString('wasAspirinGiven'),
      text: FhirString('Was aspirin given?'),
      type: QuestionnaireItemType.boolean,
    ),
    QuestionnaireItem(
      linkId: FhirString('aspirinGivenDecisionTimestamp'),
      text: FhirString('Timestamp of aspirin given decision'),
      type: QuestionnaireItemType.dateTime,
    ),
  ],
);
