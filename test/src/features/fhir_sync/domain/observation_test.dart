import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/nav_stemi.dart';

void main() {
  group('ObservationX', () {
    late Patient patient;
    late Observation baseObservation;
    late DateTime testDateTime;

    setUp(() {
      patient = Patient(
        id: FhirString('patient123'),
        name: [
          HumanName(
            given: [FhirString('John')],
            family: FhirString('Doe'),
          ),
        ],
      );

      baseObservation = Observation(
        status: ObservationStatus.final_,
        code: CodeableConcept(
          text: FhirString('Base observation'),
        ),
      );
      testDateTime = DateTime(2024, 1, 15, 10, 30);
    });

    group('chestPainObservation', () {
      test('creates observation with correct status', () {
        final observation = baseObservation.chestPainObservation(
          patient: patient,
          dateTime: testDateTime,
        );

        expect(observation.status, ObservationStatus.final_);
      });

      test('creates observation with correct category', () {
        final observation = baseObservation.chestPainObservation(
          patient: patient,
          dateTime: testDateTime,
        );

        expect(observation.category, hasLength(1));
        final category = observation.category!.first;
        expect(category.coding, hasLength(1));
        final coding = category.coding!.first;
        expect(
          coding.system.toString(),
          'http://terminology.hl7.org/CodeSystem/observation-category',
        );
        expect(coding.code.toString(), 'exam');
        expect(coding.display.toString(), 'Examination');
      });

      test('creates observation with correct code for chest pain', () {
        final observation = baseObservation.chestPainObservation(
          patient: patient,
          dateTime: testDateTime,
        );

        expect(observation.code, isNotNull);
        expect(observation.code.coding, hasLength(1));
        final coding = observation.code.coding!.first;
        expect(coding.system.toString(), 'http://snomed.info/sct');
        expect(coding.code.toString(), '29857009');
        expect(coding.display.toString(), 'Chest pain');
        expect(observation.code.text.toString(), 'Chest pain assessment');
      });

      test('creates observation with correct patient reference', () {
        final observation = baseObservation.chestPainObservation(
          patient: patient,
          dateTime: testDateTime,
        );

        expect(observation.subject, isNotNull);
        expect(observation.subject!.reference.toString(), 'patient123');
      });

      test('creates observation with correct effective date time', () {
        final observation = baseObservation.chestPainObservation(
          patient: patient,
          dateTime: testDateTime,
        );

        expect(observation.effectiveX, isA<FhirDateTime>());
        final effectiveDateTime = observation.effectiveX! as FhirDateTime;
        expect(effectiveDateTime.toString(), contains('2024-01-15T10:30'));
      });
    });

    group('ekgObservation', () {
      test('creates observation with correct status', () {
        final observation = baseObservation.ekgObservation(
          patient: patient,
          dateTime: testDateTime,
        );

        expect(observation.status, ObservationStatus.final_);
      });

      test('creates observation with correct category', () {
        final observation = baseObservation.ekgObservation(
          patient: patient,
          dateTime: testDateTime,
        );

        expect(observation.category, hasLength(1));
        final category = observation.category!.first;
        expect(category.coding, hasLength(1));
        final coding = category.coding!.first;
        expect(
          coding.system.toString(),
          'http://terminology.hl7.org/CodeSystem/observation-category',
        );
        expect(coding.code.toString(), 'procedure');
        expect(coding.display.toString(), 'Procedure');
      });

      test('creates observation with correct code for EKG', () {
        final observation = baseObservation.ekgObservation(
          patient: patient,
          dateTime: testDateTime,
        );

        expect(observation.code, isNotNull);
        expect(observation.code.coding, hasLength(1));
        final coding = observation.code.coding!.first;
        expect(coding.system.toString(), 'http://loinc.org');
        expect(coding.code.toString(), '11524-6');
        expect(coding.display.toString(), 'EKG study');
        expect(observation.code.text.toString(), '12-lead EKG');
      });

      test('creates observation with correct patient reference', () {
        final observation = baseObservation.ekgObservation(
          patient: patient,
          dateTime: testDateTime,
        );

        expect(observation.subject, isNotNull);
        expect(observation.subject!.reference.toString(), 'patient123');
      });

      test('creates observation with correct effective date time', () {
        final observation = baseObservation.ekgObservation(
          patient: patient,
          dateTime: testDateTime,
        );

        expect(observation.effectiveX, isA<FhirDateTime>());
        final effectiveDateTime = observation.effectiveX! as FhirDateTime;
        expect(effectiveDateTime.toString(), contains('2024-01-15T10:30'));
      });

      test('creates observation with notes when provided', () {
        const notes = 'ST elevation in leads II, III, aVF';
        final observation = baseObservation.ekgObservation(
          patient: patient,
          dateTime: testDateTime,
          notes: notes,
        );

        expect(observation.note, isNotNull);
        expect(observation.note, hasLength(1));
        expect(observation.note!.first.text.toString(), notes);
      });

      test('creates observation without notes when not provided', () {
        final observation = baseObservation.ekgObservation(
          patient: patient,
          dateTime: testDateTime,
        );

        expect(observation.note, isNull);
      });

      test('creates observation with EKG data attachment when provided', () {
        final ekgData = Attachment(
          data: FhirBase64Binary('base64encodedpdf'),
          contentType: FhirCode('application/pdf'),
          title: FhirString('12-lead EKG'),
        );

        final observation = baseObservation.ekgObservation(
          patient: patient,
          dateTime: testDateTime,
          ekgData: ekgData,
        );

        expect(observation.contained, isNotNull);
        expect(observation.contained, hasLength(1));
        expect(observation.contained!.first, isA<Binary>());

        final binary = observation.contained!.first as Binary;
        expect(binary.contentType.toString(), 'application/pdf');
        expect(binary.data, ekgData.data);
      });

      test(
          'creates observation without contained data when EKG data not provided',
          () {
        final observation = baseObservation.ekgObservation(
          patient: patient,
          dateTime: testDateTime,
        );

        expect(observation.contained, isNull);
      });

      test('creates observation with both notes and EKG data', () {
        const notes = 'Acute inferior STEMI';
        final ekgData = Attachment(
          data: FhirBase64Binary('base64encodedpdf'),
          contentType: FhirCode('application/pdf'),
          title: FhirString('12-lead EKG'),
        );

        final observation = baseObservation.ekgObservation(
          patient: patient,
          dateTime: testDateTime,
          notes: notes,
          ekgData: ekgData,
        );

        expect(observation.note, isNotNull);
        expect(observation.note, hasLength(1));
        expect(observation.note!.first.text.toString(), notes);

        expect(observation.contained, isNotNull);
        expect(observation.contained, hasLength(1));
        expect(observation.contained!.first, isA<Binary>());
      });
    });
  });
}
