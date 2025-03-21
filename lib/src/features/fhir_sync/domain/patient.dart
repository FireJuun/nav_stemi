import 'package:fhir_r4/fhir_r4.dart';
import 'package:nav_stemi/nav_stemi.dart';

extension PatientX on Patient {
  Patient updatePatientInfo(PatientInfoModel patientInfo) {
    final birthdate = patientInfo.birthDate;
    assert(
      birthdate != null,
      'Patient birthdate cannot be null',
    );

    final birthGender = switch (patientInfo.sexAtBirth) {
      SexAtBirth.male => AdministrativeGender.male,
      SexAtBirth.female => AdministrativeGender.female,
      SexAtBirth.other => AdministrativeGender.other,
      SexAtBirth.unknown => AdministrativeGender.unknown,
      null => AdministrativeGender.empty()
    };

    return copyWith(
      name: [
        HumanName(
          family: FhirString(patientInfo.lastName),
          given: [
            FhirString(patientInfo.firstName),
            FhirString(patientInfo.middleName),
          ],
        ),
      ],
      birthDate: FhirDate.fromDateTime(birthdate!),
      gender: birthGender,
    );
  }

  // TODO(FireJuun): Add a method to convert a Patient to a PatientInfoModel
  /// need to also include cardiologist, didGetAspirin, isCathLabNotified
  /// as separate fields
}
