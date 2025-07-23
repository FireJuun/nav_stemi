import 'package:nav_stemi/src/features/add_data/domain/patient_info_model.dart';
import 'package:nav_stemi/src/features/add_data/domain/sex_and_gender_identity.dart';

// Test patient data fixtures
const testPatientFirstName = 'John';
const testPatientLastName = 'Doe';
const testPatientMiddleName = 'William';
const testPatientBirthDate = '1990-01-01';

const testPatientInfo = PatientInfoModel(
  firstName: testPatientFirstName,
  lastName: testPatientLastName,
  middleName: testPatientMiddleName,
  sexAtBirth: SexAtBirth.male,
  cardiologist: 'Dr. Smith',
);

const testPatientInfoIncomplete = PatientInfoModel(
  firstName: testPatientFirstName,
);

// JSON test data
const testPatientInfoJson = {
  'firstName': testPatientFirstName,
  'lastName': testPatientLastName,
  'middleName': testPatientMiddleName,
  'birthDate': 946684800000, // 2000-01-01 in milliseconds
  'sexAtBirth': 'male',
  'cardiologist': 'Dr. Smith',
  'isDirty': false,
};
