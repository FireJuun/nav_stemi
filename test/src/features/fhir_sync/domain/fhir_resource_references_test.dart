import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/nav_stemi.dart';

void main() {
  group('FhirResourceReferences', () {
    test('should create empty instance', () {
      final refs = FhirResourceReferences();

      expect(refs.patientId, isNull);
      expect(refs.practitionerId, isNull);
      expect(refs.encounterId, isNull);
      expect(refs.stemiConditionId, isNull);
      expect(refs.aspirinAdministrationId, isNull);
      expect(refs.questionnaireResponseId, isNull);
    });

    test('should create instance with values', () {
      final refs = FhirResourceReferences(
        patientId: 'patient123',
        practitionerId: 'practitioner456',
        encounterId: 'encounter789',
        stemiConditionId: 'condition001',
        aspirinAdministrationId: 'medadmin002',
        questionnaireResponseId: 'qr003',
      );

      expect(refs.patientId, equals('patient123'));
      expect(refs.practitionerId, equals('practitioner456'));
      expect(refs.encounterId, equals('encounter789'));
      expect(refs.stemiConditionId, equals('condition001'));
      expect(refs.aspirinAdministrationId, equals('medadmin002'));
      expect(refs.questionnaireResponseId, equals('qr003'));
    });

    group('copyWith', () {
      test('should copy with all fields changed', () {
        final original = FhirResourceReferences(
          patientId: 'patient123',
          practitionerId: 'practitioner456',
        );

        final copied = original.copyWith(
          patientId: 'newPatient',
          practitionerId: 'newPractitioner',
          encounterId: 'newEncounter',
          stemiConditionId: 'newCondition',
          aspirinAdministrationId: 'newMedAdmin',
          questionnaireResponseId: 'newQR',
        );

        expect(copied.patientId, equals('newPatient'));
        expect(copied.practitionerId, equals('newPractitioner'));
        expect(copied.encounterId, equals('newEncounter'));
        expect(copied.stemiConditionId, equals('newCondition'));
        expect(copied.aspirinAdministrationId, equals('newMedAdmin'));
        expect(copied.questionnaireResponseId, equals('newQR'));
      });

      test('should copy with partial fields changed', () {
        final original = FhirResourceReferences(
          patientId: 'patient123',
          practitionerId: 'practitioner456',
          encounterId: 'encounter789',
        );

        final copied = original.copyWith(
          patientId: 'newPatient',
        );

        expect(copied.patientId, equals('newPatient'));
        expect(copied.practitionerId, equals('practitioner456'));
        expect(copied.encounterId, equals('encounter789'));
      });
    });

    group('has reference getters', () {
      test('should return true when reference exists', () {
        final refs = FhirResourceReferences(
          patientId: 'patient123',
          practitionerId: 'practitioner456',
          encounterId: 'encounter789',
          stemiConditionId: 'condition001',
          aspirinAdministrationId: 'medadmin002',
          questionnaireResponseId: 'qr003',
        );

        expect(refs.hasPatientReference, isTrue);
        expect(refs.hasPractitionerReference, isTrue);
        expect(refs.hasEncounterReference, isTrue);
        expect(refs.hasStemiConditionReference, isTrue);
        expect(refs.hasAspirinAdministrationReference, isTrue);
        expect(refs.hasQuestionnaireResponseReference, isTrue);
      });

      test('should return false when reference is null', () {
        final refs = FhirResourceReferences();

        expect(refs.hasPatientReference, isFalse);
        expect(refs.hasPractitionerReference, isFalse);
        expect(refs.hasEncounterReference, isFalse);
        expect(refs.hasStemiConditionReference, isFalse);
        expect(refs.hasAspirinAdministrationReference, isFalse);
        expect(refs.hasQuestionnaireResponseReference, isFalse);
      });

      test('should return false when reference is empty string', () {
        final refs = FhirResourceReferences(
          patientId: '',
          practitionerId: '',
          encounterId: '',
          stemiConditionId: '',
          aspirinAdministrationId: '',
          questionnaireResponseId: '',
        );

        expect(refs.hasPatientReference, isFalse);
        expect(refs.hasPractitionerReference, isFalse);
        expect(refs.hasEncounterReference, isFalse);
        expect(refs.hasStemiConditionReference, isFalse);
        expect(refs.hasAspirinAdministrationReference, isFalse);
        expect(refs.hasQuestionnaireResponseReference, isFalse);
      });
    });

    group('reference getters', () {
      test('should return Reference objects when IDs exist', () {
        final refs = FhirResourceReferences(
          patientId: 'patient123',
          practitionerId: 'practitioner456',
          encounterId: 'encounter789',
          stemiConditionId: 'condition001',
          aspirinAdministrationId: 'medadmin002',
          questionnaireResponseId: 'qr003',
        );

        expect(refs.patientReference, isNotNull);
        expect(
          refs.patientReference!.reference.toString(),
          equals('Patient/patient123'),
        );

        expect(refs.practitionerReference, isNotNull);
        expect(
          refs.practitionerReference!.reference.toString(),
          equals('Practitioner/practitioner456'),
        );

        expect(refs.encounterReference, isNotNull);
        expect(
          refs.encounterReference!.reference.toString(),
          equals('Encounter/encounter789'),
        );

        expect(refs.stemiConditionReference, isNotNull);
        expect(
          refs.stemiConditionReference!.reference.toString(),
          equals('Condition/condition001'),
        );

        expect(refs.aspirinAdministrationReference, isNotNull);
        expect(
          refs.aspirinAdministrationReference!.reference.toString(),
          equals('MedicationAdministration/medadmin002'),
        );

        expect(refs.questionnaireResponseReference, isNotNull);
        expect(
          refs.questionnaireResponseReference!.reference.toString(),
          equals('QuestionnaireResponse/qr003'),
        );
      });

      test('should return null when IDs do not exist', () {
        final refs = FhirResourceReferences();

        expect(refs.patientReference, isNull);
        expect(refs.practitionerReference, isNull);
        expect(refs.encounterReference, isNull);
        expect(refs.stemiConditionReference, isNull);
        expect(refs.aspirinAdministrationReference, isNull);
        expect(refs.questionnaireResponseReference, isNull);
      });
    });
  });

  group('FhirResourceReferencesNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with empty references', () {
      final notifier =
          container.read(fhirResourceReferencesNotifierProvider.notifier);
      final state = container.read(fhirResourceReferencesNotifierProvider);

      expect(state.patientId, isNull);
      expect(state.practitionerId, isNull);
      expect(state.encounterId, isNull);
      expect(state.stemiConditionId, isNull);
      expect(state.aspirinAdministrationId, isNull);
      expect(state.questionnaireResponseId, isNull);
    });

    test('should update patient ID', () {
      final notifier =
          container.read(fhirResourceReferencesNotifierProvider.notifier);

      notifier.updatePatientId('patient123');

      final state = container.read(fhirResourceReferencesNotifierProvider);
      expect(state.patientId, equals('patient123'));
    });

    test('should update practitioner ID', () {
      final notifier =
          container.read(fhirResourceReferencesNotifierProvider.notifier);

      notifier.updatePractitionerId('practitioner456');

      final state = container.read(fhirResourceReferencesNotifierProvider);
      expect(state.practitionerId, equals('practitioner456'));
    });

    test('should update encounter ID', () {
      final notifier =
          container.read(fhirResourceReferencesNotifierProvider.notifier);

      notifier.updateEncounterId('encounter789');

      final state = container.read(fhirResourceReferencesNotifierProvider);
      expect(state.encounterId, equals('encounter789'));
    });

    test('should update STEMI condition ID', () {
      final notifier =
          container.read(fhirResourceReferencesNotifierProvider.notifier);

      notifier.updateStemiConditionId('condition001');

      final state = container.read(fhirResourceReferencesNotifierProvider);
      expect(state.stemiConditionId, equals('condition001'));
    });

    test('should update aspirin administration ID', () {
      final notifier =
          container.read(fhirResourceReferencesNotifierProvider.notifier);

      notifier.updateAspirinAdministrationId('medadmin002');

      final state = container.read(fhirResourceReferencesNotifierProvider);
      expect(state.aspirinAdministrationId, equals('medadmin002'));
    });

    test('should update questionnaire response ID', () {
      final notifier =
          container.read(fhirResourceReferencesNotifierProvider.notifier);

      notifier.updateQuestionnaireResponseId('qr003');

      final state = container.read(fhirResourceReferencesNotifierProvider);
      expect(state.questionnaireResponseId, equals('qr003'));
    });

    test('should reset all references', () {
      final notifier =
          container.read(fhirResourceReferencesNotifierProvider.notifier);

      // Set some values first
      notifier.updatePatientId('patient123');
      notifier.updateEncounterId('encounter789');

      // Reset
      notifier.reset();

      final state = container.read(fhirResourceReferencesNotifierProvider);
      expect(state.patientId, isNull);
      expect(state.practitionerId, isNull);
      expect(state.encounterId, isNull);
      expect(state.stemiConditionId, isNull);
      expect(state.aspirinAdministrationId, isNull);
      expect(state.questionnaireResponseId, isNull);
    });

    group('updateFromBundle', () {
      test('should handle empty bundle', () {
        final notifier =
            container.read(fhirResourceReferencesNotifierProvider.notifier);

        const bundle = Bundle(type: BundleType.transactionResponse);
        notifier.updateFromBundle(bundle);

        final state = container.read(fhirResourceReferencesNotifierProvider);
        expect(state.patientId, isNull);
      });

      test('should update references from response location', () {
        final notifier =
            container.read(fhirResourceReferencesNotifierProvider.notifier);

        final bundle = Bundle(
          type: BundleType.transactionResponse,
          entry: [
            BundleEntry(
              response: BundleResponse(
                status: FhirString('201 Created'),
                location: FhirUri('Patient/patient123'),
              ),
            ),
            BundleEntry(
              response: BundleResponse(
                status: FhirString('201 Created'),
                location: FhirUri('Encounter/encounter789'),
              ),
            ),
            BundleEntry(
              response: BundleResponse(
                status: FhirString('201 Created'),
                location: FhirUri('Practitioner/practitioner456'),
              ),
            ),
            BundleEntry(
              response: BundleResponse(
                status: FhirString('201 Created'),
                location: FhirUri('Condition/condition001'),
              ),
            ),
            BundleEntry(
              response: BundleResponse(
                status: FhirString('201 Created'),
                location: FhirUri('MedicationAdministration/medadmin002'),
              ),
            ),
            BundleEntry(
              response: BundleResponse(
                status: FhirString('201 Created'),
                location: FhirUri('QuestionnaireResponse/qr003'),
              ),
            ),
          ],
        );

        notifier.updateFromBundle(bundle);

        final state = container.read(fhirResourceReferencesNotifierProvider);
        expect(state.patientId, equals('patient123'));
        expect(state.encounterId, equals('encounter789'));
        expect(state.practitionerId, equals('practitioner456'));
        expect(state.stemiConditionId, equals('condition001'));
        expect(state.aspirinAdministrationId, equals('medadmin002'));
        expect(state.questionnaireResponseId, equals('qr003'));
      });

      test('should handle response locations with base URI', () {
        final notifier =
            container.read(fhirResourceReferencesNotifierProvider.notifier);

        final baseUri = Env.fhirBaseUri;
        final bundle = Bundle(
          type: BundleType.transactionResponse,
          entry: [
            BundleEntry(
              response: BundleResponse(
                status: FhirString('201 Created'),
                location: FhirUri('$baseUri/Patient/patient123'),
              ),
            ),
          ],
        );

        notifier.updateFromBundle(bundle);

        final state = container.read(fhirResourceReferencesNotifierProvider);
        expect(state.patientId, equals('patient123'));
      });

      test('should handle response locations with trailing parenthesis', () {
        final notifier =
            container.read(fhirResourceReferencesNotifierProvider.notifier);

        final bundle = Bundle(
          type: BundleType.transactionResponse,
          entry: [
            BundleEntry(
              response: BundleResponse(
                status: FhirString('201 Created'),
                location: FhirUri('Patient/patient123)'),
              ),
            ),
          ],
        );

        notifier.updateFromBundle(bundle);

        final state = container.read(fhirResourceReferencesNotifierProvider);
        expect(state.patientId, equals('patient123'));
      });

      test('should fallback to resource ID when location is missing', () {
        final notifier =
            container.read(fhirResourceReferencesNotifierProvider.notifier);

        final bundle = Bundle(
          type: BundleType.transactionResponse,
          entry: [
            BundleEntry(
              resource: Patient(id: FhirString('patient456')),
            ),
            BundleEntry(
              resource: Encounter(
                id: FhirString('encounter999'),
                status: EncounterStatus.arrived,
                class_: const Coding(), // Encounter's class field
              ),
            ),
          ],
        );

        notifier.updateFromBundle(bundle);

        final state = container.read(fhirResourceReferencesNotifierProvider);
        expect(state.patientId, equals('patient456'));
        expect(state.encounterId, equals('encounter999'));
      });

      test('should skip entries without ID', () {
        final notifier =
            container.read(fhirResourceReferencesNotifierProvider.notifier);

        final bundle = Bundle(
          type: BundleType.transactionResponse,
          entry: [
            BundleEntry(
              response: BundleResponse(
                status: FhirString('201 Created'),
                // No location
              ),
            ),
            const BundleEntry(
              resource: Patient(), // No ID
            ),
          ],
        );

        notifier.updateFromBundle(bundle);

        final state = container.read(fhirResourceReferencesNotifierProvider);
        expect(state.patientId, isNull);
      });

      test('should handle response with history URLs', () {
        final notifier =
            container.read(fhirResourceReferencesNotifierProvider.notifier);

        final bundle = Bundle(
          type: BundleType.transactionResponse,
          entry: [
            BundleEntry(
              response: BundleResponse(
                status: FhirString('201 Created'),
                location: FhirUri('Patient/patient123/_history/1'),
              ),
            ),
          ],
        );

        notifier.updateFromBundle(bundle);

        final state = container.read(fhirResourceReferencesNotifierProvider);
        expect(state.patientId, equals('patient123'));
      });
    });
  });
}
