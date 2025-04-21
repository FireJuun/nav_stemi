import 'package:fhir_r4/fhir_r4.dart';
import 'package:nav_stemi/nav_stemi.dart';

extension QuestionnaireResponseX on QuestionnaireResponse {
  QuestionnaireResponse create({
    required Reference patient,
    required Reference encounter,
  }) {
    return copyWith(
      status: QuestionnaireResponseStatus.inProgress,
      authored: FhirDateTime.fromDateTime(DateTime.now()),
      subject: patient,
      encounter: encounter,
    );
  }

  QuestionnaireResponse updateTimeMetricAnswers(TimeMetricsModel? timeMetrics) {
    final wasStemiActivated = timeMetrics?.wasStemiActivated;
    final timeOfStemiActivationDecision =
        timeMetrics?.timeOfStemiActivationDecision;
    final wasCathLabNotified = timeMetrics?.wasCathLabNotified;
    final timeCathLabNotifiedDecision =
        timeMetrics?.timeCathLabNotifiedDecision;
    final wasAspirinGiven = timeMetrics?.wasAspirinGiven;
    final timeofAspirinGivenDecision = timeMetrics?.timeOfAspirinGivenDecision;

    return copyWith(
      status: QuestionnaireResponseStatus.inProgress,
      authored: FhirDateTime.fromDateTime(DateTime.now()),
      item: [
        if (wasCathLabNotified != null)
          QuestionnaireResponseItem(
            linkId: FhirString('wasStemiActivated'),
            text: FhirString('Was STEMI activated?'),
            answer: [
              QuestionnaireResponseAnswer(
                valueX: FhirBoolean(wasStemiActivated),
              ),
            ],
          ),
        if (timeOfStemiActivationDecision != null)
          QuestionnaireResponseItem(
            linkId: FhirString('stemiActiviationDecisionTimestamp'),
            text: FhirString('Timestamp of STEMI activation decision'),
            answer: [
              QuestionnaireResponseAnswer(
                valueX:
                    FhirDateTime.fromDateTime(timeOfStemiActivationDecision),
              ),
            ],
          ),
        if (wasCathLabNotified != null)
          QuestionnaireResponseItem(
            linkId: FhirString('wasCathLabNotified'),
            text: FhirString('Was the cath lab notified?'),
            answer: [
              QuestionnaireResponseAnswer(
                valueX: FhirBoolean(wasCathLabNotified),
              ),
            ],
          ),
        if (timeCathLabNotifiedDecision != null)
          QuestionnaireResponseItem(
            linkId: FhirString('cathLabNotificationDecisionTimestamp'),
            text: FhirString('Timestamp of cath lab notification decision'),
            answer: [
              QuestionnaireResponseAnswer(
                valueX: FhirDateTime.fromDateTime(timeCathLabNotifiedDecision),
              ),
            ],
          ),

        /// Note, these fields are used to keep all timestamps in one place.
        /// The medication administration is used to track aspirin given.
        if (wasAspirinGiven != null)
          QuestionnaireResponseItem(
            linkId: FhirString('wasAspirinGiven'),
            text: FhirString('Was aspirin given?'),
            answer: [
              QuestionnaireResponseAnswer(
                valueX: FhirBoolean(wasAspirinGiven),
              ),
            ],
          ),
        if (timeofAspirinGivenDecision != null)
          QuestionnaireResponseItem(
            linkId: FhirString('aspirinDecisionTimestamp'),
            text: FhirString('Timestamp of aspirin decision'),
            answer: [
              QuestionnaireResponseAnswer(
                valueX: FhirDateTime.fromDateTime(timeofAspirinGivenDecision),
              ),
            ],
          ),
      ],
    );
  }

  QuestionnaireResponse complete() {
    return copyWith(
      authored: FhirDateTime.fromDateTime(DateTime.now()),
      status: QuestionnaireResponseStatus.completed,
    );
  }
}
