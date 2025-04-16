import 'package:fhir_r4/fhir_r4.dart';

extension QuestionnaireResponseX on QuestionnaireResponse {
  QuestionnaireResponse complete() {
    return copyWith(
      authored: FhirDateTime.fromDateTime(DateTime.now()),
      status: QuestionnaireResponseStatus.completed,
    );
  }
}

/// spec: https://hl7.org/fhir/R4B/questionnaireresponse.html
class EncounterQuestionnaireResponse {
  /// Returns a complete QuestionnaireResponse FHIR resource
  static QuestionnaireResponse create({
    required Reference patient,
    bool? wasStemiActivated,
    FhirDateTime? stemiActivationTime,
    bool? wasCathLabNotified,
    FhirDateTime? cathLabNotificationTime,
  }) {
    final items = <QuestionnaireResponseItem>[];

    // Add wasStemiActivated item
    if (wasStemiActivated != null) {
      items.add(
        QuestionnaireResponseItem(
          linkId: FhirString('wasStemiActivated'),
          text: FhirString('Was STEMI activated?'),
          answer: [
            QuestionnaireResponseAnswer(
              valueX: FhirBoolean(wasStemiActivated),
            ),
          ],
        ),
      );
    }

    // Add stemiActivationTime item
    if (stemiActivationTime != null) {
      items.add(
        QuestionnaireResponseItem(
          linkId: FhirString('stemiActiviationDecisionTimestamp'),
          text: FhirString('Timestamp of STEMI activation decision'),
          answer: [
            QuestionnaireResponseAnswer(
              valueX: stemiActivationTime,
            ),
          ],
        ),
      );
    }

    // Add wasCathLabNotified item
    if (wasCathLabNotified != null) {
      items.add(
        QuestionnaireResponseItem(
          linkId: FhirString('wasCathLabNotified'),
          text: FhirString('Was the cath lab notified?'),
          answer: [
            QuestionnaireResponseAnswer(
              valueX: FhirBoolean(wasCathLabNotified),
            ),
          ],
        ),
      );
    }

    // Add cathLabNotificationTime item
    if (cathLabNotificationTime != null) {
      items.add(
        QuestionnaireResponseItem(
          linkId: FhirString('cathLabNotificationDecisionTimestamp'),
          text: FhirString('Timestamp of cath lab notification decision'),
          answer: [
            QuestionnaireResponseAnswer(
              valueX: cathLabNotificationTime,
            ),
          ],
        ),
      );
    }

    // Create and return the QuestionnaireResponse
    return QuestionnaireResponse(
      status: QuestionnaireResponseStatus.in_progress,
      subject: patient,
      authored: FhirDateTime.fromDateTime(DateTime.now()),
      item: items,
    );
  }
}
