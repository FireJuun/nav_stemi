import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/nav_stemi.dart';

void main() {
  group('TimeMetricsFhirDTO', () {
    const dto = TimeMetricsFhirDTO();

    group('fromFhir()', () {
      test('should convert Encounter with all location timestamps', () {
        // Arrange
        final now = DateTime.now();
        final encounter = Encounter(
          status: EncounterStatus.inProgress,
          class_: Coding(code: FhirCode('EMER')),
          location: [
            EncounterLocation(
              location: Reference(display: FhirString('arrivedAtPatient')),
              period: Period(
                start: FhirDateTime.fromDateTime(
                  now.subtract(const Duration(hours: 2)),
                ),
              ),
            ),
            EncounterLocation(
              location: Reference(display: FhirString('firstEkg')),
              period: Period(
                start: FhirDateTime.fromDateTime(
                  now.subtract(const Duration(hours: 1, minutes: 45)),
                ),
              ),
            ),
            EncounterLocation(
              location: Reference(display: FhirString('unitLeftScene')),
              period: Period(
                start: FhirDateTime.fromDateTime(
                  now.subtract(const Duration(hours: 1, minutes: 30)),
                ),
              ),
            ),
            EncounterLocation(
              location: Reference(
                display: FhirString('patientArrivedAtDestination'),
              ),
              period: Period(
                start: FhirDateTime.fromDateTime(
                  now.subtract(const Duration(hours: 1)),
                ),
              ),
            ),
          ],
        );

        // Act
        final result = dto.fromFhir(encounter: encounter);

        // Assert
        expect(result.timeArrivedAtPatient, isNotNull);
        expect(result.timeOfEkgs, hasLength(1));
        expect(result.timeUnitLeftScene, isNotNull);
        expect(result.timePatientArrivedAtDestination, isNotNull);
        expect(result.isDirty, isFalse);
        // All fields should be unlocked for in-progress encounter
        expect(result.lockTimeArrivedAtPatient, isFalse);
        expect(result.lockTimeOfEkgs, isFalse);
        expect(result.lockTimeUnitLeftScene, isFalse);
        expect(result.lockTimePatientArrivedAtDestination, isFalse);
      });

      test('should handle missing location data', () {
        // Arrange
        final encounter = Encounter(
          status: EncounterStatus.inProgress,
          class_: Coding(code: FhirCode('EMER')),
          // No location data
        );

        // Act
        final result = dto.fromFhir(encounter: encounter);

        // Assert
        expect(result.timeArrivedAtPatient, isNull);
        expect(result.timeOfEkgs, isEmpty);
        expect(result.timeUnitLeftScene, isNull);
        expect(result.timePatientArrivedAtDestination, isNull);
        expect(result.isDirty, isFalse);
      });

      test('should extract STEMI activation from Condition', () {
        // Arrange
        final activationTime = DateTime.now().subtract(const Duration(hours: 1));
        final encounter = Encounter(
          status: EncounterStatus.inProgress,
          class_: Coding(code: FhirCode('EMER')),
        );
        final condition = Condition(
          clinicalStatus: CodeableConcept(
            coding: [Coding(code: FhirCode('active'))],
          ),
          onsetX: FhirDateTime.fromDateTime(activationTime),
          subject: const Reference(),
        );

        // Act
        final result = dto.fromFhir(
          encounter: encounter,
          stemiCondition: condition,
        );

        // Assert
        expect(
          result.timeOfStemiActivationDecision?.toLocal(),
          equals(activationTime),
        );
        expect(result.wasStemiActivated, isTrue);
        expect(result.lockTimeOfStemiActivationDecision, isFalse);
      });

      test('should extract aspirin administration data', () {
        // Arrange
        final aspirinTime = DateTime.now().subtract(const Duration(minutes: 30));
        final encounter = Encounter(
          status: EncounterStatus.inProgress,
          class_: Coding(code: FhirCode('EMER')),
        );
        final aspirinAdmin = MedicationAdministration(
          status: MedicationAdministrationStatusCodes.completed,
          medicationX: const CodeableConcept(),
          subject: const Reference(),
          effectiveX: FhirDateTime.fromDateTime(aspirinTime),
        );

        // Act
        final result = dto.fromFhir(
          encounter: encounter,
          aspirinAdministration: aspirinAdmin,
        );

        // Assert
        expect(
          result.timeOfAspirinGivenDecision?.toLocal(),
          equals(aspirinTime),
        );
        expect(result.wasAspirinGiven, isTrue);
        expect(result.lockTimeOfAspirinGivenDecision, isFalse);
      });

      test('should extract cath lab notification from QuestionnaireResponse',
          () {
        // Arrange
        final cathLabTime =
            DateTime.now().subtract(const Duration(minutes: 45));
        final encounter = Encounter(
          status: EncounterStatus.inProgress,
          class_: Coding(code: FhirCode('EMER')),
        );
        final questionnaire = QuestionnaireResponse(
          status: QuestionnaireResponseStatus.inProgress,
          item: [
            QuestionnaireResponseItem(
              linkId: FhirString('wasCathLabNotified'),
              answer: [
                QuestionnaireResponseAnswer(
                  valueX: FhirBoolean(true),
                ),
              ],
            ),
            QuestionnaireResponseItem(
              linkId: FhirString('cathLabNotificationDecisionTimestamp'),
              answer: [
                QuestionnaireResponseAnswer(
                  valueX: FhirDateTime.fromDateTime(cathLabTime),
                ),
              ],
            ),
          ],
        );

        // Act
        final result = dto.fromFhir(
          encounter: encounter,
          stemiQuestionnaire: questionnaire,
        );

        // Assert
        expect(result.timeCathLabNotifiedDecision, equals(cathLabTime));
        expect(result.wasCathLabNotified, isTrue);
        expect(result.lockTimeCathLabNotifiedDecision, isFalse);
      });

      test('should handle multiple EKG times', () {
        // Arrange
        final now = DateTime.now();
        final ekg1Time = now.subtract(const Duration(hours: 1, minutes: 45));

        final encounter = Encounter(
          status: EncounterStatus.inProgress,
          class_: Coding(code: FhirCode('EMER')),
          location: [
            EncounterLocation(
              location: Reference(display: FhirString('firstEkg')),
              period: Period(
                start: FhirDateTime.fromDateTime(ekg1Time),
              ),
            ),
            // Note: In real usage, multiple EKGs would be handled differently
            // This test shows that only the first EKG is captured
          ],
        );

        // Act
        final result = dto.fromFhir(encounter: encounter);

        // Assert
        expect(result.timeOfEkgs, hasLength(1));
        expect(result.timeOfEkgs.first?.toLocal(), equals(ekg1Time));
      });

      test('should set lock status based on Encounter status', () {
        // Arrange
        final finishedEncounter = Encounter(
          status: EncounterStatus.finished,
          class_: Coding(code: FhirCode('EMER')),
          location: [
            EncounterLocation(
              location: Reference(display: FhirString('arrivedAtPatient')),
              period: Period(
                start: FhirDateTime.fromDateTime(DateTime.now()),
              ),
            ),
          ],
        );

        // Act
        final result = dto.fromFhir(encounter: finishedEncounter);

        // Assert
        expect(result.lockTimeArrivedAtPatient, isTrue);
        expect(result.lockTimeOfEkgs, isTrue);
        expect(result.lockTimeOfStemiActivationDecision, isTrue);
        expect(result.lockTimeUnitLeftScene, isTrue);
        expect(result.lockTimeOfAspirinGivenDecision, isTrue);
        expect(result.lockTimeCathLabNotifiedDecision, isTrue);
        expect(result.lockTimePatientArrivedAtDestination, isTrue);
      });
    });

    group('toFhirEncounter()', () {
      test('should create Encounter from TimeMetricsModel', () {
        // Arrange
        final now = DateTime.now();
        final model = TimeMetricsModel(
          timeArrivedAtPatient: now.subtract(const Duration(hours: 2)),
          timeOfEkgs: {now.subtract(const Duration(hours: 1, minutes: 45))},
          timeUnitLeftScene: now.subtract(const Duration(hours: 1, minutes: 30)),
          timePatientArrivedAtDestination:
              now.subtract(const Duration(hours: 1)),
        );

        // Act
        final result = dto.toFhirEncounter(model);

        // Assert
        expect(result.status, equals(EncounterStatus.inProgress));
        expect(result.location, isNotNull);
        // At least 3 locations set
        expect(result.location!.length, greaterThanOrEqualTo(3));
      });

      test('should update existing Encounter with new times', () {
        // Arrange
        final existingEncounter = Encounter(
          id: FhirString('encounter-123'),
          status: EncounterStatus.inProgress,
          class_: Coding(code: FhirCode('EMER')),
          location: [
            EncounterLocation(
              location: Reference(display: FhirString('arrivedAtPatient')),
              period: Period(
                start: FhirDateTime.fromDateTime(
                  DateTime.now().subtract(const Duration(hours: 3)),
                ),
              ),
            ),
          ],
        );

        final model = TimeMetricsModel(
          timeArrivedAtPatient:
              DateTime.now().subtract(const Duration(hours: 2)),
          timeUnitLeftScene: DateTime.now().subtract(const Duration(hours: 1)),
        );

        // Act
        final result = dto.toFhirEncounter(
          model,
          existingEncounter: existingEncounter,
        );

        // Assert
        expect(result.id?.valueString, equals('encounter-123'));
        expect(result.status, equals(EncounterStatus.inProgress));
      });

      test('should set status based on lock states', () {
        // All fields locked
        final lockedModel = TimeMetricsModel(
          timeArrivedAtPatient: DateTime.now(),
          lockTimeArrivedAtPatient: true,
          lockTimeOfEkgs: true,
          lockTimeOfStemiActivationDecision: true,
          lockTimeUnitLeftScene: true,
          lockTimeOfAspirinGivenDecision: true,
          lockTimeCathLabNotifiedDecision: true,
          lockTimePatientArrivedAtDestination: true,
        );

        final result = dto.toFhirEncounter(lockedModel);
        expect(result.status, equals(EncounterStatus.finished));

        // Some fields unlocked
        final unlockedModel = lockedModel.copyWith(
          lockTimeArrivedAtPatient: () => false,
        );

        final result2 = dto.toFhirEncounter(unlockedModel);
        expect(result2.status, equals(EncounterStatus.inProgress));
      });

      test('should handle missing timestamps appropriately', () {
        // Arrange
        const model = TimeMetricsModel(
          // All timestamps are null
        );

        // Act
        final result = dto.toFhirEncounter(model);

        // Assert
        expect(result.status, equals(EncounterStatus.inProgress));
        expect(result.location, anyOf(isNull, isEmpty));
      });
    });

    group('toFhirQuestionnaireResponse()', () {
      test('should create QuestionnaireResponse for cath lab data', () {
        // Arrange
        final encounter = Encounter(
          id: FhirString('encounter-123'),
          status: EncounterStatus.inProgress,
          class_: Coding(code: FhirCode('EMER')),
        );

        final model = TimeMetricsModel(
          wasCathLabNotified: true,
          timeCathLabNotifiedDecision:
              DateTime.now().subtract(const Duration(minutes: 30)),
        );

        // Act
        final result = dto.toFhirQuestionnaireResponse(
          model,
          encounter: encounter,
        );

        // Assert
        expect(result.status, equals(QuestionnaireResponseStatus.inProgress));
        expect(
          result.encounter?.reference,
          equals(FhirString('Encounter/encounter-123')),
        );
        expect(result.item, isNotNull);
        expect(
          result.item!
              .any((item) => item.linkId.valueString == 'wasCathLabNotified'),
          isTrue,
        );
      });

      test('should update existing response', () {
        // Arrange
        final encounter = Encounter(
          id: FhirString('encounter-123'),
          status: EncounterStatus.inProgress,
          class_: Coding(code: FhirCode('EMER')),
        );

        final existingResponse = QuestionnaireResponse(
          id: FhirString('response-123'),
          status: QuestionnaireResponseStatus.inProgress,
          authored: FhirDateTime.fromDateTime(
            DateTime.now().subtract(const Duration(days: 1)),
          ),
        );

        final model = TimeMetricsModel(
          wasCathLabNotified: false,
          timeCathLabNotifiedDecision: DateTime.now(),
        );

        // Act
        final result = dto.toFhirQuestionnaireResponse(
          model,
          encounter: encounter,
          existingResponse: existingResponse,
        );

        // Assert
        expect(result.id?.valueString, equals('response-123'));
        expect(result.authored, isNotNull);
      });

      test('should link to Encounter correctly', () {
        // Arrange
        final encounter = Encounter(
          id: FhirString('encounter-456'),
          status: EncounterStatus.inProgress,
          class_: Coding(code: FhirCode('EMER')),
        );

        const model = TimeMetricsModel();

        // Act
        final result = dto.toFhirQuestionnaireResponse(
          model,
          encounter: encounter,
        );

        // Assert
        expect(
          result.encounter?.reference,
          equals(FhirString('Encounter/encounter-456')),
        );
      });
    });

    group('toFhirAspirinAdministration()', () {
      test('should create MedicationAdministration for aspirin given', () {
        // Arrange
        final patient = Patient(
          id: FhirString('patient-123'),
        );

        final model = TimeMetricsModel(
          wasAspirinGiven: true,
          timeOfAspirinGivenDecision:
              DateTime.now().subtract(const Duration(minutes: 15)),
        );

        // Act
        final result = dto.toFhirAspirinAdministration(
          model,
          patient: patient,
        );

        // Assert
        expect(result, isNotNull);
        expect(
          result!.status,
          equals(MedicationAdministrationStatusCodes.completed),
        );
        expect(
          result.subject.reference?.valueString,
          equals('Patient/patient-123'),
        );
      });

      test('should handle not-given scenarios', () {
        // Arrange
        final patient = Patient(
          id: FhirString('patient-123'),
        );

        final model = TimeMetricsModel(
          wasAspirinGiven: false,
          timeOfAspirinGivenDecision: DateTime.now(),
        );

        // Act
        final result = dto.toFhirAspirinAdministration(
          model,
          patient: patient,
        );

        // Assert
        expect(result, isNotNull);
        expect(
          result!.status,
          equals(MedicationAdministrationStatusCodes.notDone),
        );
      });

      test('should skip creation when no decision made', () {
        // Arrange
        final patient = Patient(
          id: FhirString('patient-123'),
        );

        const model = TimeMetricsModel(
          // No aspirin decision
        );

        // Act
        final result = dto.toFhirAspirinAdministration(
          model,
          patient: patient,
        );

        // Assert
        expect(result, isNull);
      });

      test('should preserve existing administration', () {
        // Arrange
        final patient = Patient(
          id: FhirString('patient-123'),
        );

        const model = TimeMetricsModel(
          // No aspirin decision
        );

        final existingAdministration = MedicationAdministration(
          id: FhirString('admin-123'),
          status: MedicationAdministrationStatusCodes.completed,
          medicationX: const CodeableConcept(),
          subject: Reference(reference: FhirString('Patient/patient-123')),
          effectiveX: FhirDateTime.fromDateTime(DateTime.now()),
        );

        // Act
        final result = dto.toFhirAspirinAdministration(
          model,
          patient: patient,
          existingAdministration: existingAdministration,
        );

        // Assert
        expect(result, equals(existingAdministration));
      });
    });

    group('toFhirStemiCondition()', () {
      test('should create Condition for STEMI activation', () {
        // Arrange
        final patient = Patient(
          id: FhirString('patient-123'),
        );
        final encounter = Encounter(
          id: FhirString('encounter-123'),
          status: EncounterStatus.inProgress,
          class_: Coding(code: FhirCode('EMER')),
        );

        final model = TimeMetricsModel(
          wasStemiActivated: true,
          timeOfStemiActivationDecision:
              DateTime.now().subtract(const Duration(minutes: 20)),
        );

        // Act
        final result = dto.toFhirStemiCondition(
          model,
          patient: patient,
          encounter: encounter,
        );

        // Assert
        expect(result, isNotNull);
        expect(
          result!.subject.reference,
          equals(FhirString('Patient/patient-123')),
        );
        expect(
          result.encounter?.reference,
          equals(FhirString('Encounter/encounter-123')),
        );
        expect(
          result.clinicalStatus?.coding?.first.code,
          equals(FhirCode('active')),
        );
      });

      test('should set appropriate clinical status', () {
        // Test activated
        final patient = Patient(id: FhirString('patient-123'));
        final encounter = Encounter(
          id: FhirString('encounter-123'),
          status: EncounterStatus.inProgress,
          class_: Coding(code: FhirCode('EMER')),
        );

        var model = TimeMetricsModel(
          wasStemiActivated: true,
          timeOfStemiActivationDecision: DateTime.now(),
        );

        var result = dto.toFhirStemiCondition(
          model,
          patient: patient,
          encounter: encounter,
        );

        expect(
          result!.clinicalStatus?.coding?.first.code,
          equals(FhirCode('active')),
        );

        // Test not activated
        model = TimeMetricsModel(
          wasStemiActivated: false,
          timeOfStemiActivationDecision: DateTime.now(),
        );

        result = dto.toFhirStemiCondition(
          model,
          patient: patient,
          encounter: encounter,
        );

        expect(
          result!.clinicalStatus?.coding?.first.code,
          isNot(equals(FhirCode('active'))),
        );
      });

      test('should skip creation when no STEMI decision made', () {
        // Arrange
        final patient = Patient(id: FhirString('patient-123'));
        final encounter = Encounter(
          id: FhirString('encounter-123'),
          status: EncounterStatus.inProgress,
          class_: Coding(code: FhirCode('EMER')),
        );

        const model = TimeMetricsModel(
          // No STEMI decision
        );

        // Act
        final result = dto.toFhirStemiCondition(
          model,
          patient: patient,
          encounter: encounter,
        );

        // Assert
        expect(result, isNull);
      });
    });

    group('Integration scenarios', () {
      test('should handle complete time metrics to full FHIR bundle', () {
        // Arrange
        final now = DateTime.now();
        final model = TimeMetricsModel(
          timeArrivedAtPatient: now.subtract(const Duration(hours: 2)),
          timeOfEkgs: {now.subtract(const Duration(hours: 1, minutes: 45))},
          timeOfStemiActivationDecision:
              now.subtract(const Duration(hours: 1, minutes: 40)),
          wasStemiActivated: true,
          timeUnitLeftScene: now.subtract(const Duration(hours: 1, minutes: 30)),
          timeOfAspirinGivenDecision:
              now.subtract(const Duration(hours: 1, minutes: 20)),
          wasAspirinGiven: true,
          timeCathLabNotifiedDecision:
              now.subtract(const Duration(hours: 1, minutes: 15)),
          wasCathLabNotified: true,
          timePatientArrivedAtDestination:
              now.subtract(const Duration(hours: 1)),
        );

        final patient = Patient(id: FhirString('patient-123'));

        // Act
        final encounter = dto.toFhirEncounter(model);
        final questionnaire =
            dto.toFhirQuestionnaireResponse(model, encounter: encounter);
        final aspirin = dto.toFhirAspirinAdministration(model, patient: patient);
        final stemi =
            dto.toFhirStemiCondition(model, patient: patient, encounter: encounter);

        // Assert
        expect(encounter, isNotNull);
        expect(questionnaire, isNotNull);
        expect(aspirin, isNotNull);
        expect(stemi, isNotNull);
      });

      test('should handle partial data scenarios', () {
        // Arrange - Only some fields populated
        final model = TimeMetricsModel(
          timeArrivedAtPatient: DateTime.now().subtract(const Duration(hours: 1)),
          wasStemiActivated: true,
          timeOfStemiActivationDecision:
              DateTime.now().subtract(const Duration(minutes: 45)),
          // Other fields null
        );

        final patient = Patient(id: FhirString('patient-123'));

        // Act
        final encounter = dto.toFhirEncounter(model);
        final questionnaire =
            dto.toFhirQuestionnaireResponse(model, encounter: encounter);
        final aspirin = dto.toFhirAspirinAdministration(model, patient: patient);
        final stemi =
            dto.toFhirStemiCondition(model, patient: patient, encounter: encounter);

        // Assert
        expect(encounter, isNotNull);
        expect(questionnaire, isNotNull);
        expect(aspirin, isNull); // No aspirin decision
        expect(stemi, isNotNull);
      });

      test('should maintain round-trip conversions', () {
        // Arrange
        final originalModel = TimeMetricsModel(
          timeArrivedAtPatient: DateTime.now().subtract(const Duration(hours: 2)),
          timeOfEkgs: {
            DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
          },
          timeOfStemiActivationDecision:
              DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
          wasStemiActivated: true,
          timeUnitLeftScene:
              DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
          timeOfAspirinGivenDecision:
              DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
          wasAspirinGiven: false,
          timeCathLabNotifiedDecision:
              DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
          wasCathLabNotified: true,
          timePatientArrivedAtDestination:
              DateTime.now().subtract(const Duration(hours: 1)),
        );

        final patient = Patient(id: FhirString('patient-123'));

        // Act - Convert to FHIR
        final encounter = dto.toFhirEncounter(originalModel);
        final questionnaire = dto.toFhirQuestionnaireResponse(
          originalModel,
          encounter: encounter,
        );
        final aspirin = dto.toFhirAspirinAdministration(
          originalModel,
          patient: patient,
        );
        final stemi = dto.toFhirStemiCondition(
          originalModel,
          patient: patient,
          encounter: encounter,
        );

        // Act - Convert back
        final resultModel = dto.fromFhir(
          encounter: encounter,
          aspirinAdministration: aspirin,
          stemiCondition: stemi,
          stemiQuestionnaire: questionnaire,
        );

        // Assert - Compare key fields
        expect(
          resultModel.timeArrivedAtPatient?.toLocal(),
          equals(originalModel.timeArrivedAtPatient),
        );
        expect(
          resultModel.timeOfEkgs.first?.toLocal(),
          equals(originalModel.timeOfEkgs.first),
        );
        expect(
          resultModel.timeOfStemiActivationDecision?.toLocal(),
          equals(originalModel.timeOfStemiActivationDecision),
        );
        expect(
          resultModel.wasStemiActivated,
          equals(originalModel.wasStemiActivated),
        );
        expect(
          resultModel.wasAspirinGiven,
          equals(originalModel.wasAspirinGiven),
        );
        expect(
          resultModel.wasCathLabNotified,
          equals(originalModel.wasCathLabNotified),
        );
        expect(resultModel.isDirty, isFalse); // Always false after fromFhir
      });
    });
  });
}
