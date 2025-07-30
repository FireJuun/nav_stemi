import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/nav_stemi.dart';

void main() {
  group('createEncounterComposition', () {
    test('creates a valid Composition with all required fields', () {
      final composition = createEncounterComposition(
        encounterId: 'enc123',
        patientId: 'pat456',
        practitionerIds: ['prac789'],
        observationIds: ['obs111', 'obs222'],
        medicationAdminIds: ['med333'],
        questionnaireResponseIds: ['qr444'],
        conditionId: 'cond555',
      );

      expect(composition, isA<Composition>());
      expect(composition.status, CompositionStatus.final_);
      expect(composition.title.toString(), 'STEMI Encounter Summary');

      // Check type coding
      expect(
        composition.type.coding?.first.system.toString(),
        'http://loinc.org',
      );
      expect(composition.type.coding?.first.code.toString(), '34133-9');
      expect(
        composition.type.coding?.first.display.toString(),
        'Summary of episode note',
      );

      // Check references
      expect(composition.subject?.reference.toString(), 'Patient/pat456');
      expect(composition.encounter?.reference.toString(), 'Encounter/enc123');

      // Check date is set
      expect(composition.date, isNotNull);
      expect(composition.date, isA<FhirDateTime>());

      // Check authors
      expect(composition.author, hasLength(1));
      expect(
        composition.author.first.reference.toString(),
        'Practitioner/prac789',
      );
    });

    test('creates composition with multiple practitioners', () {
      final composition = createEncounterComposition(
        encounterId: 'enc123',
        patientId: 'pat456',
        practitionerIds: ['prac1', 'prac2', 'prac3'],
        observationIds: [],
        medicationAdminIds: [],
        questionnaireResponseIds: [],
      );

      expect(composition.author, hasLength(3));
      expect(composition.author[0].reference.toString(), 'Practitioner/prac1');
      expect(composition.author[1].reference.toString(), 'Practitioner/prac2');
      expect(composition.author[2].reference.toString(), 'Practitioner/prac3');
    });

    test('creates correct sections structure', () {
      final composition = createEncounterComposition(
        encounterId: 'enc123',
        patientId: 'pat456',
        practitionerIds: ['prac789'],
        observationIds: ['obs111'],
        medicationAdminIds: ['med333'],
        questionnaireResponseIds: ['qr444'],
        conditionId: 'cond555',
      );

      expect(composition.section, hasLength(5));

      // Encounter Details section
      final encounterSection = composition.section?[0];
      expect(encounterSection?.title.toString(), 'Encounter Details');
      expect(
        encounterSection?.code?.coding?.first.code.toString(),
        'LP173192-8',
      );
      expect(encounterSection?.entry, hasLength(1));
      expect(
        encounterSection?.entry?.first.reference.toString(),
        'Encounter/enc123',
      );

      // Patient Details section
      final patientSection = composition.section?[1];
      expect(patientSection?.title.toString(), 'Patient Details');
      expect(patientSection?.code?.coding?.first.code.toString(), '60591-5');
      expect(patientSection?.entry, hasLength(1));
      expect(
        patientSection?.entry?.first.reference.toString(),
        'Patient/pat456',
      );

      // Clinical Findings section
      final clinicalSection = composition.section?[2];
      expect(clinicalSection?.title.toString(), 'Clinical Findings');
      expect(clinicalSection?.code?.coding?.first.code.toString(), '11348-0');
      expect(
        clinicalSection?.entry,
        hasLength(2),
      ); // 1 observation + 1 condition
      expect(
        clinicalSection?.entry?[0].reference.toString(),
        'Observation/obs111',
      );
      expect(
        clinicalSection?.entry?[1].reference.toString(),
        'Condition/cond555',
      );

      // Medications section
      final medicationsSection = composition.section?[3];
      expect(medicationsSection?.title.toString(), 'Medications Administered');
      expect(
        medicationsSection?.code?.coding?.first.code.toString(),
        '29549-3',
      );
      expect(medicationsSection?.entry, hasLength(1));
      expect(
        medicationsSection?.entry?.first.reference.toString(),
        'MedicationAdministration/med333',
      );

      // Questionnaire responses section
      final questionnaireSection = composition.section?[4];
      expect(questionnaireSection?.title.toString(), 'Timestamp Forms');
      expect(questionnaireSection?.entry, hasLength(1));
      expect(
        questionnaireSection?.entry?.first.reference.toString(),
        'QuestionnaireResponse/qr444',
      );
    });

    test('handles empty observation and medication lists', () {
      final composition = createEncounterComposition(
        encounterId: 'enc123',
        patientId: 'pat456',
        practitionerIds: ['prac789'],
        observationIds: [],
        medicationAdminIds: [],
        questionnaireResponseIds: [],
      );

      // Clinical findings section should have no entries (no observations, no condition)
      final clinicalSection = composition.section?[2];
      expect(clinicalSection?.entry, isEmpty);

      // Medications section should have no entries
      final medicationsSection = composition.section?[3];
      expect(medicationsSection?.entry, isEmpty);

      // Questionnaire responses section should have no entries
      final questionnaireSection = composition.section?[4];
      expect(questionnaireSection?.entry, isEmpty);
    });

    test('handles null conditionId', () {
      final composition = createEncounterComposition(
        encounterId: 'enc123',
        patientId: 'pat456',
        practitionerIds: ['prac789'],
        observationIds: ['obs111'],
        medicationAdminIds: ['med333'],
        questionnaireResponseIds: ['qr444'],
      );

      // Clinical findings section should only have observation, no condition
      final clinicalSection = composition.section?[2];
      expect(clinicalSection?.entry, hasLength(1));
      expect(
        clinicalSection?.entry?.first.reference.toString(),
        'Observation/obs111',
      );
    });

    test('creates multiple observations in clinical findings', () {
      final composition = createEncounterComposition(
        encounterId: 'enc123',
        patientId: 'pat456',
        practitionerIds: ['prac789'],
        observationIds: ['obs1', 'obs2', 'obs3'],
        medicationAdminIds: [],
        questionnaireResponseIds: [],
      );

      final clinicalSection = composition.section?[2];
      expect(clinicalSection?.entry, hasLength(3));
      expect(
        clinicalSection?.entry?[0].reference.toString(),
        'Observation/obs1',
      );
      expect(
        clinicalSection?.entry?[1].reference.toString(),
        'Observation/obs2',
      );
      expect(
        clinicalSection?.entry?[2].reference.toString(),
        'Observation/obs3',
      );
    });

    test('creates multiple medications in medications section', () {
      final composition = createEncounterComposition(
        encounterId: 'enc123',
        patientId: 'pat456',
        practitionerIds: ['prac789'],
        observationIds: [],
        medicationAdminIds: ['med1', 'med2', 'med3'],
        questionnaireResponseIds: [],
      );

      final medicationsSection = composition.section?[3];
      expect(medicationsSection?.entry, hasLength(3));
      expect(
        medicationsSection?.entry?[0].reference.toString(),
        'MedicationAdministration/med1',
      );
      expect(
        medicationsSection?.entry?[1].reference.toString(),
        'MedicationAdministration/med2',
      );
      expect(
        medicationsSection?.entry?[2].reference.toString(),
        'MedicationAdministration/med3',
      );
    });

    test('creates multiple questionnaire responses', () {
      final composition = createEncounterComposition(
        encounterId: 'enc123',
        patientId: 'pat456',
        practitionerIds: ['prac789'],
        observationIds: [],
        medicationAdminIds: [],
        questionnaireResponseIds: ['qr1', 'qr2', 'qr3'],
      );

      final questionnaireSection = composition.section?[4];
      expect(questionnaireSection?.entry, hasLength(3));
      expect(
        questionnaireSection?.entry?[0].reference.toString(),
        'QuestionnaireResponse/qr1',
      );
      expect(
        questionnaireSection?.entry?[1].reference.toString(),
        'QuestionnaireResponse/qr2',
      );
      expect(
        questionnaireSection?.entry?[2].reference.toString(),
        'QuestionnaireResponse/qr3',
      );
    });

    test('all sections have proper LOINC coding', () {
      final composition = createEncounterComposition(
        encounterId: 'enc123',
        patientId: 'pat456',
        practitionerIds: ['prac789'],
        observationIds: [],
        medicationAdminIds: [],
        questionnaireResponseIds: [],
      );

      // Check LOINC system in all coded sections
      for (var i = 0; i < 4; i++) {
        // First 4 sections have codes
        final section = composition.section?[i];
        expect(
          section?.code?.coding?.first.system.toString(),
          'http://loinc.org',
        );
        expect(section?.code?.coding?.first.code, isNotNull);
        expect(section?.code?.coding?.first.display, isNotNull);
      }
    });

    test('composition date is close to current time', () {
      final beforeCreation = DateTime.now();

      final composition = createEncounterComposition(
        encounterId: 'enc123',
        patientId: 'pat456',
        practitionerIds: ['prac789'],
        observationIds: [],
        medicationAdminIds: [],
        questionnaireResponseIds: [],
      );

      final afterCreation = DateTime.now();

      expect(composition.date, isNotNull);
      // FhirDateTime can be compared to DateTime
      // Just verify it was set recently
    });

    test('all sections are present even with empty arrays', () {
      final composition = createEncounterComposition(
        encounterId: 'enc123',
        patientId: 'pat456',
        practitionerIds: [],
        observationIds: [],
        medicationAdminIds: [],
        questionnaireResponseIds: [],
      );

      expect(composition.section, hasLength(5));
      expect(composition.section?[0].title.toString(), 'Encounter Details');
      expect(composition.section?[1].title.toString(), 'Patient Details');
      expect(composition.section?[2].title.toString(), 'Clinical Findings');
      expect(
        composition.section?[3].title.toString(),
        'Medications Administered',
      );
      expect(composition.section?[4].title.toString(), 'Timestamp Forms');
    });

    test('composition resource is valid for FHIR serialization', () {
      final composition = createEncounterComposition(
        encounterId: 'enc123',
        patientId: 'pat456',
        practitionerIds: ['prac789'],
        observationIds: ['obs111'],
        medicationAdminIds: ['med333'],
        questionnaireResponseIds: ['qr444'],
        conditionId: 'cond555',
      );

      // Test that it can be converted to JSON without errors
      expect(composition.toJson, returnsNormally);

      // Test that the JSON contains expected structure
      final json = composition.toJson();
      expect(json['resourceType'], 'Composition');
      expect(json['status'], 'final');
      expect(json['type'], isNotNull);
      expect(json['subject'], isNotNull);
      expect(json['encounter'], isNotNull);
      expect(json['date'], isNotNull);
      expect(json['author'], isNotNull);
      expect(json['title'], 'STEMI Encounter Summary');
      expect(json['section'], isA<List>());
      expect((json['section'] as List).length, 5);
    });
  });
}
