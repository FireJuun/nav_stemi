import 'package:fhir_r4/fhir_r4.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:uuid/uuid.dart';

extension PatientX on Patient {
  /// Regenerate the MRN (Medical Record Number) for a patient.
  /// This method generates a new MRN using a UUID v5 based on a namespace URL,
  /// which is also defined in the [Identifier.system] value.
  ///
  /// If an MRN already exists, it will be replaced with a new one.
  ///
  Patient regenerateMrn() {
    // TODO(FireJuun): replace namespace url if we have a better one
    const namespaceUrl = 'https://navstemi.org/patient';

    /// Generate a new MRN using a UUID v5 based on the namespace URL
    /// Using namespace URLs to ensure uniqueness and consistency
    final newMrn = const Uuid().v5(Namespace.url.value, namespaceUrl);

    /// spec: https://terminology.hl7.org/2.1.0/CodeSystem-v2-0203.html
    final mrnConcept = CodeableConcept(
      coding: [
        Coding(
          system: FhirUri('http://terminology.hl7.org/CodeSystem/v2-0203'),
          code: FhirCode('MR'),
          display: FhirString('Medical Record Number'),
        ),
      ],
    );

    final newIdentifier = Identifier(
      use: IdentifierUse.usual,
      system: FhirUri(namespaceUrl),
      value: FhirString(newMrn),
      type: mrnConcept,
    );

    final identifiers = identifier ?? [];

    /// Check if the identifier concept already exists
    final mrnIndex = identifiers.indexWhere((i) => i.type == mrnConcept);

    /// If so, replace it. Otherwise, add it.
    (mrnIndex != -1)
        ? identifiers.replaceRange(
            mrnIndex,
            mrnIndex + 1,
            [newIdentifier],
          )
        : identifiers.add(newIdentifier);

    return copyWith(identifier: identifiers);
  }

  Patient updatePatientInfo(PatientInfoModel patientInfo) {
    final birthdate = patientInfo.birthDate;
    // Remove assertion that was causing the exception

    final birthGender = switch (patientInfo.sexAtBirth) {
      SexAtBirth.male => AdministrativeGender.male,
      SexAtBirth.female => AdministrativeGender.female,
      SexAtBirth.other => AdministrativeGender.other,
      SexAtBirth.unknown => AdministrativeGender.unknown,
      null => null
    };

    return copyWith(
      name: [
        HumanName(
          family: (patientInfo.lastName != null)
              ? FhirString(patientInfo.lastName)
              : null,
          given: [
            if (patientInfo.firstName != null)
              FhirString(patientInfo.firstName),
            if (patientInfo.middleName != null)
              FhirString(patientInfo.middleName),
          ],
        ),
      ],
      // Handle null birthdate by not updating it
      birthDate:
          birthdate != null ? FhirDate.fromDateTime(birthdate) : birthDate,
      gender: birthGender,
    );
  }

  // TODO(FireJuun): Add a method to convert a Patient to a PatientInfoModel
  /// need to also include cardiologist, didGetAspirin, isCathLabNotified
  /// as separate fields
}
