import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/src/features/add_data/application/patient_info_service.dart';
import 'package:nav_stemi/src/features/add_data/domain/patient_info_model.dart';
import 'package:nav_stemi/src/features/add_data/domain/sex_and_gender_identity.dart';
import 'package:nav_stemi/src/features/add_data/presentation/data_entry/patient_info/patient_info_controller.dart';

import '../../../../helpers/test_helpers.dart';

class MockPatientInfoService extends Mock implements PatientInfoService {}

class MockDriverLicense extends Mock implements DriverLicense {}

class FakeDriverLicense extends Fake implements DriverLicense {}

class FakePatientInfoModel extends Fake implements PatientInfoModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeDriverLicense());
    registerFallbackValue(FakePatientInfoModel());
  });

  group('PatientInfoController', () {
    late ProviderContainer container;
    late MockPatientInfoService mockService;

    setUp(() {
      mockService = MockPatientInfoService();

      // Set up default behavior
      when(() => mockService.setPatientInfoFromScannedLicense(any()))
          .thenAnswer((_) async => Future.value());
      when(() => mockService.setPatientInfoModel(any())).thenReturn(null);
      when(() => mockService.setFirstName(any())).thenReturn(null);
      when(() => mockService.setMiddleName(any())).thenReturn(null);
      when(() => mockService.setLastName(any())).thenReturn(null);
      when(() => mockService.setSexAtBirth(any())).thenReturn(null);
      when(() => mockService.setBirthDate(any())).thenReturn(null);
      when(() => mockService.setCardiologist(any())).thenReturn(null);

      container = createContainer(
        overrides: [
          patientInfoServiceProvider.overrideWithValue(mockService),
        ],
      );
    });

    test('should have initial state as AsyncValue.data(null)', () {
      final controller = container.read(patientInfoControllerProvider);
      expect(controller, equals(const AsyncValue<void>.data(null)));
    });

    group('saveLicenseAsPatientInfo', () {
      test('should save license data successfully', () async {
        final mockLicense = MockDriverLicense();
        final notifier = container.read(patientInfoControllerProvider.notifier);

        final result = await notifier.saveLicenseAsPatientInfo(mockLicense);

        expect(result, isTrue);
        verify(
          () => mockService.setPatientInfoFromScannedLicense(mockLicense),
        ).called(1);
      });

      test('should handle errors when saving license data', () async {
        final mockLicense = MockDriverLicense();
        when(() => mockService.setPatientInfoFromScannedLicense(any()))
            .thenThrow(Exception('Test error'));

        final notifier = container.read(patientInfoControllerProvider.notifier);

        final result = await notifier.saveLicenseAsPatientInfo(mockLicense);

        expect(result, isFalse);
        final state = container.read(patientInfoControllerProvider);
        expect(state.hasError, isTrue);
      });
    });

    group('field setters', () {
      test('should set patient info model', () {
        const newModel = PatientInfoModel(
          firstName: 'Jane',
          lastName: 'Smith',
        );

        container
            .read(patientInfoControllerProvider.notifier)
            .setPatientInfoModel(newModel);

        verify(() => mockService.setPatientInfoModel(newModel)).called(1);
      });

      test('should set first name', () {
        const firstName = 'Jane';

        container
            .read(patientInfoControllerProvider.notifier)
            .setFirstName(firstName);

        verify(() => mockService.setFirstName(firstName)).called(1);
      });

      test('should set middle name', () {
        const middleName = 'Marie';

        container
            .read(patientInfoControllerProvider.notifier)
            .setMiddleName(middleName);

        verify(() => mockService.setMiddleName(middleName)).called(1);
      });

      test('should set last name', () {
        const lastName = 'Smith';

        container
            .read(patientInfoControllerProvider.notifier)
            .setLastName(lastName);

        verify(() => mockService.setLastName(lastName)).called(1);
      });

      test('should set sex at birth', () {
        const sex = SexAtBirth.female;

        container
            .read(patientInfoControllerProvider.notifier)
            .setSexAtBirth(sex);

        verify(() => mockService.setSexAtBirth(sex)).called(1);
      });

      test('should set birth date', () {
        final birthDate = DateTime(1990, 5, 15);

        container
            .read(patientInfoControllerProvider.notifier)
            .setBirthDate(birthDate);

        verify(() => mockService.setBirthDate(birthDate)).called(1);
      });

      test('should set cardiologist', () {
        const cardiologist = 'Dr. Johnson';

        container
            .read(patientInfoControllerProvider.notifier)
            .setCardiologist(cardiologist);

        verify(() => mockService.setCardiologist(cardiologist)).called(1);
      });

      test('should handle null values', () {
        container.read(patientInfoControllerProvider.notifier)
          ..setFirstName(null)
          ..setMiddleName(null)
          ..setLastName(null)
          ..setSexAtBirth(null)
          ..setBirthDate(null)
          ..setCardiologist(null);

        verify(() => mockService.setFirstName(null)).called(1);
        verify(() => mockService.setMiddleName(null)).called(1);
        verify(() => mockService.setLastName(null)).called(1);
        verify(() => mockService.setSexAtBirth(null)).called(1);
        verify(() => mockService.setBirthDate(null)).called(1);
        verify(() => mockService.setCardiologist(null)).called(1);
      });
    });
  });
}
