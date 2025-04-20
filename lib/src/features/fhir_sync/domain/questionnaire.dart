import 'package:fhir_r4/fhir_r4.dart';

/// Questionnaire model for whether a STEMI was activated (+ timestamp)
/// and whether the cath lab was notified (+ timestamp).
/// Look at this example:
/// https://hl7.org/fhir/R4B/questionnaireresponse-example-bluebook.json.html
///

final encounterQuestionnaire = Questionnaire(
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
