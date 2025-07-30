import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/src/features/add_data/application/patient_info_service.dart';
import 'package:nav_stemi/src/features/add_data/data/patient_info_repository.dart';
import 'package:nav_stemi/src/features/add_data/domain/patient_info_model.dart';
import 'package:nav_stemi/src/features/add_data/domain/sex_and_gender_identity.dart';

import '../../../../fixtures/patient_fixtures.dart';
import '../../../../helpers/mock_providers.dart';
import '../../../../helpers/test_helpers.dart';

class MockDriverLicense extends Mock implements DriverLicense {}

void main() {
  group('PatientInfoService', () {
    late ProviderContainer container;
    late PatientInfoService service;
    late MockPatientInfoRepository mockRepository;

    setUp(() {
      mockRepository = MockPatientInfoRepository();

      // Set up default behavior
      when(() => mockRepository.patientInfoModel).thenReturn(testPatientInfo);
      when(() => mockRepository.updatePatientInfoModel(any())).thenReturn(null);
      when(() => mockRepository.clearPatientInfoModel()).thenReturn(null);

      container = createContainer(
        overrides: [
          patientInfoRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      service = container.read(patientInfoServiceProvider);
    });

    test('should get patient info model from repository', () {
      final result = service.patientInfoModel;

      expect(result, equals(testPatientInfo));
      verify(() => mockRepository.patientInfoModel).called(1);
    });

    test('should return empty model when repository returns null', () {
      when(() => mockRepository.patientInfoModel).thenReturn(null);

      final result = service.patientInfoModel;

      expect(result, equals(const PatientInfoModel()));
    });

    test('should set patient info model', () {
      const newModel = PatientInfoModel(
        firstName: 'Jane',
        lastName: 'Smith',
      );

      service.setPatientInfoModel(newModel);

      verify(() => mockRepository.updatePatientInfoModel(newModel)).called(1);
    });

    group('field setters', () {
      test('should set first name', () {
        const newFirstName = 'Jane';

        service.setFirstName(newFirstName);

        final captured = verify(
          () => mockRepository.updatePatientInfoModel(captureAny()),
        ).captured.single as PatientInfoModel;

        expect(captured.firstName, equals(newFirstName));
        expect(captured.lastName, equals(testPatientInfo.lastName));
      });

      test('should set middle name', () {
        const newMiddleName = 'Marie';

        service.setMiddleName(newMiddleName);

        final captured = verify(
          () => mockRepository.updatePatientInfoModel(captureAny()),
        ).captured.single as PatientInfoModel;

        expect(captured.middleName, equals(newMiddleName));
      });

      test('should set last name', () {
        const newLastName = 'Johnson';

        service.setLastName(newLastName);

        final captured = verify(
          () => mockRepository.updatePatientInfoModel(captureAny()),
        ).captured.single as PatientInfoModel;

        expect(captured.lastName, equals(newLastName));
      });

      test('should set sex at birth', () {
        const newSex = SexAtBirth.female;

        service.setSexAtBirth(newSex);

        final captured = verify(
          () => mockRepository.updatePatientInfoModel(captureAny()),
        ).captured.single as PatientInfoModel;

        expect(captured.sexAtBirth, equals(newSex));
      });

      test('should set birth date', () {
        final newBirthDate = DateTime(1985, 5, 15);

        service.setBirthDate(newBirthDate);

        final captured = verify(
          () => mockRepository.updatePatientInfoModel(captureAny()),
        ).captured.single as PatientInfoModel;

        expect(captured.birthDate, equals(newBirthDate));
      });

      test('should set cardiologist', () {
        const newCardiologist = 'Dr. Johnson';

        service.setCardiologist(newCardiologist);

        final captured = verify(
          () => mockRepository.updatePatientInfoModel(captureAny()),
        ).captured.single as PatientInfoModel;

        expect(captured.cardiologist, equals(newCardiologist));
      });
    });

    group('driver license scanning', () {
      test('should handle null values in driver license', () async {
        final mockLicense = MockDriverLicense();

        // Set up mock license with null values
        when(() => mockLicense.firstName).thenReturn(null);
        when(() => mockLicense.lastName).thenReturn(null);
        when(() => mockLicense.middleName).thenReturn(null);
        when(() => mockLicense.gender).thenReturn(null);
        when(() => mockLicense.birthDate).thenReturn(null);

        await service.setPatientInfoFromScannedLicense(mockLicense);

        final captured = verify(
          () => mockRepository.updatePatientInfoModel(captureAny()),
        ).captured.single as PatientInfoModel;

        expect(captured.firstName, isNull);
        expect(captured.lastName, isNull);
        expect(captured.middleName, isNull);
        expect(captured.sexAtBirth, SexAtBirth.unknown);
        expect(captured.birthDate, isNull);
      });
    });

    test('should clear patient info', () {
      service.clearPatientInfo();

      verify(() => mockRepository.clearPatientInfoModel()).called(1);
    });
  });
}
