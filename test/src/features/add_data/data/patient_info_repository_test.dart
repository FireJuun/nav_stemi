import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/src/features/add_data/data/patient_info_repository.dart';
import 'package:nav_stemi/src/features/add_data/domain/patient_info_model.dart';

import '../../../../fixtures/patient_fixtures.dart';

void main() {
  group('PatientInfoRepository', () {
    late PatientInfoRepository repository;

    setUp(() {
      repository = PatientInfoRepository();
    });

    test('should initialize with default empty PatientInfoModel', () {
      expect(repository.patientInfoModel, equals(const PatientInfoModel()));
    });

    test('should set patient info model and mark as dirty', () {
      repository.patientInfoModel = testPatientInfo;

      expect(repository.patientInfoModel?.firstName, equals('John'));
      expect(repository.patientInfoModel?.lastName, equals('Doe'));
      expect(repository.patientInfoModel?.isDirty, isTrue);
    });

    test('should update patient info model with dirty flag control', () {
      // Update without marking as dirty
      repository.updatePatientInfoModel(
        testPatientInfo,
        markAsDirty: false,
      );

      expect(repository.patientInfoModel?.firstName, equals('John'));
      expect(repository.patientInfoModel?.isDirty, isFalse);

      // Update with marking as dirty (default)
      repository.updatePatientInfoModel(testPatientInfo);

      expect(repository.patientInfoModel?.firstName, equals('John'));
      expect(repository.patientInfoModel?.isDirty, isTrue);
    });

    test('should clear patient info model', () {
      repository.patientInfoModel = testPatientInfo;
      expect(repository.patientInfoModel, isNotNull);

      repository.clearPatientInfoModel();
      expect(repository.patientInfoModel, isNull);
    });

    test('should handle null when updating', () {
      repository.updatePatientInfoModel(null);
      expect(repository.patientInfoModel, isNull);
    });

    test('should watch patient info model changes', () async {
      final stream = repository.watchPatientInfoModel();

      // Collect stream events
      final events = <PatientInfoModel?>[];
      final subscription = stream.listen(events.add);

      // Make changes
      repository.patientInfoModel = testPatientInfo;
      await Future.delayed(const Duration(milliseconds: 100));

      repository.clearPatientInfoModel();
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify events
      expect(events.length, greaterThanOrEqualTo(2));
      expect(events.first, equals(const PatientInfoModel()));
      expect(events.any((e) => e?.firstName == 'John'), isTrue);
      expect(events.last, isNull);

      await subscription.cancel();
    });

    test('should preserve existing data when setting new model', () {
      const initialModel = PatientInfoModel(
        firstName: 'Jane',
        lastName: 'Smith',
        cardiologist: 'Dr. Johnson',
      );

      repository.updatePatientInfoModel(initialModel, markAsDirty: false);
      expect(repository.patientInfoModel?.isDirty, isFalse);

      // Set new model via setter (should mark as dirty)
      final updatedModel = initialModel.copyWith(
        firstName: () => 'Janet',
      );

      repository.patientInfoModel = updatedModel;

      expect(repository.patientInfoModel?.firstName, equals('Janet'));
      expect(repository.patientInfoModel?.lastName, equals('Smith'));
      expect(repository.patientInfoModel?.cardiologist, equals('Dr. Johnson'));
      expect(repository.patientInfoModel?.isDirty, isTrue);
    });
  });
}
