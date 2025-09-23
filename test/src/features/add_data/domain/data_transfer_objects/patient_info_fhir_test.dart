import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/src/features/add_data/domain/data_transfer_objects/patient_info_fhir.dart';
import 'package:nav_stemi/src/features/add_data/domain/patient_info_model.dart';
import 'package:nav_stemi/src/features/add_data/domain/sex_and_gender_identity.dart';

void main() {
  group('PatientInfoFhirDTO', () {
    const dto = PatientInfoFhirDTO();

    group('fromFhir()', () {
      test(
        'should convert valid Patient with all fields to PatientInfoModel',
        () {
          // Arrange
          final patient = Patient(
            active: FhirBoolean(true),
            name: [
              HumanName(
                given: [FhirString('John'), FhirString('Michael')],
                family: FhirString('Doe'),
                use: NameUse.official,
              ),
            ],
            birthDate: FhirDate.fromString('1990-05-15'),
            gender: AdministrativeGender.male,
          );

          final practitioner = Practitioner(
            name: [
              HumanName(
                text: FhirString('Dr. Sarah Johnson'),
                family: FhirString('Johnson'),
                given: [FhirString('Sarah')],
                prefix: [FhirString('Dr.')],
              ),
            ],
          );

          // Act
          final result = dto.fromFhir(
            patient: patient,
            cardiologist: practitioner,
          );

          // Assert
          expect(result.firstName, equals('John'));
          expect(result.middleName, equals('Michael'));
          expect(result.lastName, equals('Doe'));
          expect(result.birthDate, equals(DateTime(1990, 5, 15)));
          expect(result.sexAtBirth, equals(SexAtBirth.male));
          expect(result.cardiologist, equals('Dr. Sarah Johnson'));
          expect(result.isDirty, isFalse);
        },
      );

      test(
        'should handle temporary patient data and exclude temp fields',
        () {
          // Arrange
          final patient = Patient(
            active: FhirBoolean(false),
            name: [
              HumanName(
                given: [FhirString('Patient')],
                family: FhirString('Temporary'),
                use: NameUse.temp,
              ),
            ],
            gender: AdministrativeGender.unknown,
          );

          // Act
          final result = dto.fromFhir(patient: patient);

          // Assert
          expect(result.firstName, isNull);
          expect(result.middleName, isNull);
          expect(result.lastName, isNull);
          expect(result.birthDate, isNull);
          expect(result.sexAtBirth, isNull);
          expect(result.cardiologist, isNull);
          expect(result.isDirty, isFalse);
        },
      );

      test('should handle missing/null fields gracefully', () {
        // Arrange
        final patient = Patient(
          active: FhirBoolean(true),
        );

        // Act
        final result = dto.fromFhir(patient: patient);

        // Assert
        expect(result.firstName, isNull);
        expect(result.middleName, isNull);
        expect(result.lastName, isNull);
        expect(result.birthDate, isNull);
        expect(result.sexAtBirth, isNull);
        expect(result.cardiologist, isNull);
        expect(result.isDirty, isFalse);
      });

      test(
        'should handle various AdministrativeGender mappings to SexAtBirth',
        () {
          // Test male
          var patient = Patient(
            active: FhirBoolean(true),
            gender: AdministrativeGender.male,
          );
          var result = dto.fromFhir(patient: patient);
          expect(result.sexAtBirth, equals(SexAtBirth.male));

          // Test female
          patient = Patient(
            active: FhirBoolean(true),
            gender: AdministrativeGender.female,
          );
          result = dto.fromFhir(patient: patient);
          expect(result.sexAtBirth, equals(SexAtBirth.female));

          // Test other
          patient = Patient(
            active: FhirBoolean(true),
            gender: AdministrativeGender.other,
          );
          result = dto.fromFhir(patient: patient);
          expect(result.sexAtBirth, equals(SexAtBirth.other));

          // Test unknown
          patient = Patient(
            active: FhirBoolean(true),
            gender: AdministrativeGender.unknown,
          );
          result = dto.fromFhir(patient: patient);
          expect(result.sexAtBirth, isNull); // Unknown treated as temporary
        },
      );

      test(
        'should extract cardiologist name from different name formats',
        () {
          // Test with text property
          var practitioner = Practitioner(
            name: [
              HumanName(
                text: FhirString('Dr. John Smith'),
              ),
            ],
          );
          var result = dto.fromFhir(
            patient: Patient(active: FhirBoolean(true)),
            cardiologist: practitioner,
          );
          expect(result.cardiologist, equals('Dr. John Smith'));

          // Test with family and given names
          practitioner = Practitioner(
            name: [
              HumanName(
                family: FhirString('Smith'),
                given: [FhirString('John'), FhirString('Michael')],
              ),
            ],
          );
          result = dto.fromFhir(
            patient: Patient(active: FhirBoolean(true)),
            cardiologist: practitioner,
          );
          expect(result.cardiologist, equals('John Michael Smith'));

          // Test with only family name
          practitioner = Practitioner(
            name: [
              HumanName(
                family: FhirString('Smith'),
              ),
            ],
          );
          result = dto.fromFhir(
            patient: Patient(active: FhirBoolean(true)),
            cardiologist: practitioner,
          );
          expect(result.cardiologist, equals('Smith'));
        },
      );
    });

    group('toFhirPatient()', () {
      test(
        'should convert complete PatientInfoModel to Patient resource',
        () {
          // Arrange
          final model = PatientInfoModel(
            firstName: 'John',
            middleName: 'Michael',
            lastName: 'Doe',
            birthDate: DateTime(1990, 5, 15),
            sexAtBirth: SexAtBirth.male,
            cardiologist: 'Dr. Sarah Johnson',
          );

          // Act
          final result = dto.toFhirPatient(model);

          // Assert
          expect(result.active?.valueBoolean, isTrue);
          expect(result.name?.first.given?.first.valueString, equals('John'));
          expect(
            result.name?.first.given?.elementAt(1).valueString,
            equals('Michael'),
          );
          expect(result.name?.first.family?.valueString, equals('Doe'));
          expect(result.birthDate?.valueString, equals('1990-05-15'));
          expect(result.gender, equals(AdministrativeGender.male));

          // Should have NAV-STEMI identifier
          expect(result.identifier, isNotNull);
          expect(
            result.identifier!.any(
              (id) =>
                  id.system?.valueUri.toString() ==
                  'https://navstemi.org/patient',
            ),
            isTrue,
          );
        },
      );

      test(
        'should handle empty/minimal PatientInfoModel and add temp defaults',
        () {
          // Arrange
          const model = PatientInfoModel();

          // Act
          final result = dto.toFhirPatient(model);

          // Assert
          expect(result.active?.valueBoolean, isFalse); // No real data
          expect(result.name?.first.use, equals(NameUse.temp));
          expect(result.name?.first.family?.valueString, equals('Temporary'));
          expect(result.name?.first.given?.first.valueString, equals('Patient'));
          expect(result.gender, equals(AdministrativeGender.unknown));
          expect(result.identifier, isNotNull);
        },
      );

      test('should preserve existing Patient data when updating', () {
        // Arrange
        const model = PatientInfoModel(
          firstName: 'Jane',
          lastName: 'Smith',
        );

        final existingPatient = Patient(
          id: FhirString('existing-123'),
          identifier: [
            Identifier(
              system: FhirUri('https://navstemi.org/patient'),
              value: FhirString('nav-123'),
            ),
            Identifier(
              system: FhirUri('https://example.com/mrn'),
              value: FhirString('MRN-456'),
            ),
          ],
          meta: FhirMeta(
            lastUpdated: FhirInstant.fromDateTime(DateTime(2023)),
          ),
        );

        // Act
        final result =
            dto.toFhirPatient(model, existingPatient: existingPatient);

        // Assert
        expect(result.id?.valueString, equals('existing-123'));
        expect(result.meta?.lastUpdated, isNotNull);
        // Preserved both identifiers
        expect(result.identifier?.length, equals(2));
        expect(result.name?.first.given?.first.valueString, equals('Jane'));
        expect(result.name?.first.family?.valueString, equals('Smith'));
      });

      test(
        'should ensure required FHIR fields are populated',
        () {
          // Arrange
          const model = PatientInfoModel(
            firstName: 'John',
            // No other fields
          );

          // Act
          final result = dto.toFhirPatient(model);

          // Assert
          expect(result.active, isNotNull);
          expect(result.name, isNotNull);
          expect(result.gender, isNotNull);
          expect(result.identifier, isNotNull);
        },
      );

      test('should handle sex at birth to gender conversion', () {
        // Test male
        var model = const PatientInfoModel(sexAtBirth: SexAtBirth.male);
        var result = dto.toFhirPatient(model);
        expect(result.gender, equals(AdministrativeGender.male));

        // Test female
        model = const PatientInfoModel(sexAtBirth: SexAtBirth.female);
        result = dto.toFhirPatient(model);
        expect(result.gender, equals(AdministrativeGender.female));

        // Test other
        model = const PatientInfoModel(sexAtBirth: SexAtBirth.other);
        result = dto.toFhirPatient(model);
        expect(result.gender, equals(AdministrativeGender.other));

        // Test unknown
        model = const PatientInfoModel(sexAtBirth: SexAtBirth.unknown);
        result = dto.toFhirPatient(model);
        expect(result.gender, equals(AdministrativeGender.unknown));
      });
    });

    group('toFhirCardiologist()', () {
      test('should create Practitioner from cardiologist name', () {
        // Arrange
        const model = PatientInfoModel(
          cardiologist: 'Dr. Sarah Johnson',
        );

        // Act
        final result = dto.toFhirCardiologist(model);

        // Assert
        expect(result, isNotNull);
        expect(
          result!.name?.first.text?.valueString,
          equals('Dr. Sarah Johnson'),
        );
      });

      test('should handle null/empty cardiologist name', () {
        // Test null
        var model = const PatientInfoModel();
        var result = dto.toFhirCardiologist(model);
        expect(result, isNull);

        // Test empty string
        model = const PatientInfoModel(cardiologist: '');
        result = dto.toFhirCardiologist(model);
        expect(result, isNull);
      });

      test(
        'should preserve existing Practitioner data when updating',
        () {
          // Arrange
          const model = PatientInfoModel(
            cardiologist: 'Dr. John Smith',
          );

          final existingPractitioner = Practitioner(
            id: FhirString('practitioner-123'),
            identifier: [
              Identifier(
                system: FhirUri('https://example.com/npi'),
                value: FhirString('1234567890'),
              ),
            ],
            qualification: [
              PractitionerQualification(
                code: CodeableConcept(
                  text: FhirString('MD'),
                ),
              ),
            ],
          );

          // Act
          final result = dto.toFhirCardiologist(
            model,
            existingPractitioner: existingPractitioner,
          );

          // Assert
          expect(result!.id?.valueString, equals('practitioner-123'));
          expect(result.identifier, isNotEmpty);
          expect(result.qualification, isNotEmpty);
          expect(result.name?.first.text?.valueString, equals('Dr. John Smith'));
        },
      );
    });

    group('round-trip conversions', () {
      test(
        'should maintain data integrity through Model → FHIR → Model conversion',
        () {
          // Arrange
          final originalModel = PatientInfoModel(
            firstName: 'John',
            middleName: 'Michael',
            lastName: 'Doe',
            birthDate: DateTime(1990, 5, 15),
            sexAtBirth: SexAtBirth.male,
            cardiologist: 'Dr. Sarah Johnson',
            isDirty: true,
          );

          // Act - Convert to FHIR
          final patient = dto.toFhirPatient(originalModel);
          final practitioner = dto.toFhirCardiologist(originalModel);

          // Act - Convert back to Model
          final resultModel = dto.fromFhir(
            patient: patient,
            cardiologist: practitioner,
          );

          // Assert
          expect(resultModel.firstName, equals(originalModel.firstName));
          expect(resultModel.middleName, equals(originalModel.middleName));
          expect(resultModel.lastName, equals(originalModel.lastName));
          expect(resultModel.birthDate, equals(originalModel.birthDate));
          expect(resultModel.sexAtBirth, equals(originalModel.sexAtBirth));
          expect(resultModel.cardiologist, equals(originalModel.cardiologist));
          expect(resultModel.isDirty, isFalse); // Always false after fromFhir
        },
      );

      test('should handle edge cases in round-trip conversion', () {
        // Test with minimal data
        const minimalModel = PatientInfoModel(
          firstName: 'Jane',
          isDirty: true,
        );

        final patient = dto.toFhirPatient(minimalModel);
        final resultModel = dto.fromFhir(patient: patient);

        expect(resultModel.firstName, equals('Jane'));
        expect(resultModel.lastName, isNull);
        expect(resultModel.isDirty, isFalse);
      });
    });

    group('edge cases', () {
      test('should handle special characters in names', () {
        // Arrange
        const model = PatientInfoModel(
          firstName: "D'Angelo",
          lastName: "O'Brien-Smith",
          middleName: 'José María',
        );

        // Act
        final patient = dto.toFhirPatient(model);

        // Assert
        expect(patient.name?.first.given?.first.valueString, equals("D'Angelo"));
        expect(
          patient.name?.first.family?.valueString,
          equals("O'Brien-Smith"),
        );
        expect(
          patient.name?.first.given?.elementAt(1).valueString,
          equals('José María'),
        );

        // Verify round-trip
        final resultModel = dto.fromFhir(patient: patient);
        expect(resultModel.firstName, equals("D'Angelo"));
        expect(resultModel.lastName, equals("O'Brien-Smith"));
        expect(resultModel.middleName, equals('José María'));
      });

      test('should handle multiple middle names correctly', () {
        // Arrange
        final patient = Patient(
          active: FhirBoolean(true),
          name: [
            HumanName(
              given: [
                FhirString('John'),
                FhirString('Michael'),
                FhirString('Robert'),
                FhirString('James'),
              ],
              family: FhirString('Doe'),
            ),
          ],
        );

        // Act
        final result = dto.fromFhir(patient: patient);

        // Assert
        expect(result.firstName, equals('John'));
        expect(result.middleName, equals('Michael Robert James'));
        expect(result.lastName, equals('Doe'));
      });

      test('should handle birthDate edge cases', () {
        // Test leap year
        final leapYearModel = PatientInfoModel(
          // Need at least one name field to not be temporary
          firstName: 'Test',
          birthDate: DateTime(2000, 2, 29),
        );

        final patient = dto.toFhirPatient(leapYearModel);
        expect(patient.birthDate?.valueString, equals('2000-02-29'));

        final resultModel = dto.fromFhir(patient: patient);
        expect(resultModel.birthDate, equals(DateTime(2000, 2, 29)));
      });
    });
  });
}
