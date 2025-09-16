import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/src/features/add_data/domain/patient_info_model.dart';
import 'package:nav_stemi/src/features/add_data/domain/sex_and_gender_identity.dart';

void main() {
  group('PatientInfoModel', () {
    const testFirstName = 'John';
    const testLastName = 'Doe';
    const testMiddleName = 'William';
    final testBirthDate = DateTime(1990);
    const testSexAtBirth = SexAtBirth.male;
    const testCardiologist = 'Dr. Smith';

    test('should create model with valid data', () {
      final model = PatientInfoModel(
        firstName: testFirstName,
        lastName: testLastName,
        middleName: testMiddleName,
        birthDate: testBirthDate,
        sexAtBirth: testSexAtBirth,
        cardiologist: testCardiologist,
      );

      expect(model.firstName, equals(testFirstName));
      expect(model.lastName, equals(testLastName));
      expect(model.middleName, equals(testMiddleName));
      expect(model.birthDate, equals(testBirthDate));
      expect(model.sexAtBirth, equals(testSexAtBirth));
      expect(model.cardiologist, equals(testCardiologist));
      expect(model.isDirty, isFalse);
    });

    test('should create model with null values', () {
      const model = PatientInfoModel();

      expect(model.firstName, isNull);
      expect(model.lastName, isNull);
      expect(model.middleName, isNull);
      expect(model.birthDate, isNull);
      expect(model.sexAtBirth, isNull);
      expect(model.cardiologist, isNull);
      expect(model.isDirty, isFalse);
    });

    group('copyWith', () {
      test('should copy with new values', () {
        const original = PatientInfoModel(
          firstName: testFirstName,
          lastName: testLastName,
        );

        final copied = original.copyWith(
          firstName: () => 'Jane',
          cardiologist: () => 'Dr. Jones',
        );

        expect(copied.firstName, equals('Jane'));
        expect(copied.lastName, equals(testLastName));
        expect(copied.cardiologist, equals('Dr. Jones'));
        expect(copied.isDirty, isTrue); // Should be dirty after changes
      });

      test('should handle null values in copyWith', () {
        final original = PatientInfoModel(
          firstName: testFirstName,
          lastName: testLastName,
          birthDate: testBirthDate,
        );

        final copied = original.copyWith(
          firstName: () => null,
          birthDate: () => null,
        );

        expect(copied.firstName, isNull);
        expect(copied.lastName, equals(testLastName));
        expect(copied.birthDate, isNull);
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final model = PatientInfoModel(
          firstName: testFirstName,
          lastName: testLastName,
          middleName: testMiddleName,
          birthDate: testBirthDate,
          sexAtBirth: testSexAtBirth,
          cardiologist: testCardiologist,
          isDirty: true,
        );

        final map = model.toMap();

        expect(map['firstName'], equals(testFirstName));
        expect(map['lastName'], equals(testLastName));
        expect(map['middleName'], equals(testMiddleName));
        expect(map['birthDate'], equals(testBirthDate.millisecondsSinceEpoch));
        expect(map['sexAtBirth'], equals(testSexAtBirth));
        expect(map['cardiologist'], equals(testCardiologist));
        expect(map['isDirty'], isTrue);
      });

      test('should deserialize from JSON correctly', () {
        final map = {
          'firstName': testFirstName,
          'lastName': testLastName,
          'middleName': testMiddleName,
          'birthDate': testBirthDate.millisecondsSinceEpoch,
          'sexAtBirth': 'male',
          'cardiologist': testCardiologist,
          'isDirty': false,
        };

        final model = PatientInfoModel.fromMap(map);

        expect(model.firstName, equals(testFirstName));
        expect(model.lastName, equals(testLastName));
        expect(model.middleName, equals(testMiddleName));
        expect(model.birthDate, equals(testBirthDate));
        expect(model.sexAtBirth, equals(testSexAtBirth));
        expect(model.cardiologist, equals(testCardiologist));
        expect(model.isDirty, isFalse);
      });

      test('should handle null values in JSON', () {
        final map = <String, dynamic>{
          'firstName': null,
          'lastName': null,
          'middleName': null,
          'birthDate': null,
          'sexAtBirth': null,
          'cardiologist': null,
          'isDirty': null,
        };

        final model = PatientInfoModel.fromMap(map);

        expect(model.firstName, isNull);
        expect(model.lastName, isNull);
        expect(model.middleName, isNull);
        expect(model.birthDate, isNull);
        expect(model.sexAtBirth, isNull);
        expect(model.cardiologist, isNull);
        expect(model.isDirty, isTrue); // Defaults to true when null
      });
    });

    group('checklist state', () {
      test('should return true when patient info is present', () {
        const model = PatientInfoModel(
          firstName: testFirstName,
          lastName: testLastName,
        );

        expect(model.patientInfoChecklistState(), isTrue);
      });

      test('should return false when no patient info is present', () {
        const model = PatientInfoModel();

        expect(model.patientInfoChecklistState(), isFalse);
      });

      test('should return true when only birthDate is present', () {
        final model = PatientInfoModel(
          birthDate: testBirthDate,
        );

        expect(model.patientInfoChecklistState(), isTrue);
      });

      test('should return true when cardiologist info is present', () {
        const model = PatientInfoModel(
          cardiologist: testCardiologist,
        );

        expect(model.cardiologistInfoChecklistState(), isTrue);
      });

      test('should return false when cardiologist is empty string', () {
        const model = PatientInfoModel(
          cardiologist: '',
        );

        expect(model.cardiologistInfoChecklistState(), isFalse);
      });
    });

    group('sync status', () {
      test('should mark as synced', () {
        const model = PatientInfoModel(
          firstName: testFirstName,
          isDirty: true,
        );

        final synced = model.markSynced();

        expect(synced.isDirty, isFalse);
        expect(synced.firstName, equals(testFirstName));
      });

      test('should mark as dirty', () {
        const model = PatientInfoModel(
          firstName: testFirstName,
        );

        final dirty = model.markDirty();

        expect(dirty.isDirty, isTrue);
        expect(dirty.firstName, equals(testFirstName));
      });
    });

    group('equality', () {
      test('should be equal when all fields are the same', () {
        final model1 = PatientInfoModel(
          firstName: testFirstName,
          lastName: testLastName,
          birthDate: testBirthDate,
        );

        final model2 = PatientInfoModel(
          firstName: testFirstName,
          lastName: testLastName,
          birthDate: testBirthDate,
        );

        expect(model1, equals(model2));
      });

      test('should not be equal when fields differ', () {
        const model1 = PatientInfoModel(
          firstName: testFirstName,
          lastName: testLastName,
        );

        const model2 = PatientInfoModel(
          firstName: 'Jane',
          lastName: testLastName,
        );

        expect(model1, isNot(equals(model2)));
      });
    });
  });
}
