import 'package:fhir_r4/fhir_r4.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:uuid/uuid.dart';

/// Data Transfer Object to convert between PatientInfoModel and FHIR resources
/// This handles conversion to/from Patient and Practitioner resources
/// Leverages existing FHIR domain extensions in fhir_sync/domain
class PatientInfoFhirDTO {
  const PatientInfoFhirDTO();

  /// Converts from FHIR Patient and Practitioner resources to PatientInfoModel
  /// Returns a PatientInfoModel with the dirty flag set to false
  PatientInfoModel fromFhir({
    required Patient patient,
    Practitioner? cardiologist,
  }) {
    // Check if this is a temporary patient (not active or has temp name)
    final isTemporary = patient.active?.valueBoolean == false ||
        patient.name?.firstOrNull?.use == NameUse.temp;

    // Extract name components from FHIR Patient, but not if they're temporary
    final humanName = patient.name?.firstOrNull;
    final isTemporaryName = humanName?.use == NameUse.temp ||
        (humanName?.family?.valueString == 'Temporary' &&
            humanName?.given?.firstOrNull?.valueString == 'Patient');

    // Only use name fields if they're not temporary placeholders
    final lastName = isTemporaryName ? null : humanName?.family;
    final firstName = isTemporaryName ? null : humanName?.given?.firstOrNull;
    final middleNames =
        isTemporaryName ? null : humanName?.given?.skip(1).join(' ');

    // Extract birthDate from FHIR Patient
    final birthDate = patient.birthDate != null && !isTemporary
        ? DateTime.parse(patient.birthDate!.toString())
        : null;

    // Extract sex from FHIR Patient, but not if temporary or unknown
    final sex = isTemporary || patient.gender == AdministrativeGender.unknown
        ? null
        : _extractSexAtBirthFromFhir(patient);

    // Extract cardiologist name from FHIR Practitioner
    final cardiologistName = _extractCardiologistName(cardiologist);

    // Create PatientInfoModel with dirty flag set to false
    return PatientInfoModel(
      lastName: lastName?.valueString,
      firstName: firstName?.valueString,
      middleName: middleNames,
      birthDate: birthDate,
      sexAtBirth: sex,
      cardiologist: cardiologistName,
    );
  }

  /// Converts from PatientInfoModel to FHIR Patient resource
  /// Leverages the existing PatientX.updatePatientInfo extension
  Patient toFhirPatient(PatientInfoModel model, {Patient? existingPatient}) {
    // Create a new Patient or use an existing one
    final patient = existingPatient ?? const Patient();

    // Determine if this is real patient data or just temporary data
    final hasRealData = model.lastName != null ||
        model.firstName != null ||
        model.birthDate != null ||
        (model.sexAtBirth != null && model.sexAtBirth != SexAtBirth.unknown);

    // Set active status based on whether we have real data
    final isActive = FhirBoolean(hasRealData);

    // First update with model data
    final updatedPatient = patient.updatePatientInfo(model);

    // Then ensure required fields are present - if they were removed or weren't set
    HumanName? tempName;

    // Check if name is missing or empty after update
    final needsDefaultName = updatedPatient.name == null ||
        updatedPatient.name!.isEmpty ||
        (updatedPatient.name![0].family == null &&
            (updatedPatient.name![0].given == null ||
                updatedPatient.name![0].given!.isEmpty));

    if (needsDefaultName) {
      tempName = HumanName(
        family: FhirString('Temporary'),
        given: [FhirString('Patient')],
        use: NameUse.temp,
      );
    }

    // Ensure gender is present
    final gender = updatedPatient.gender ?? AdministrativeGender.unknown;

    // Ensure we have an identifier
    final identifiers = updatedPatient.identifier ?? [];
    Identifier? navStemiIdentifier;

    // Look for our specific identifier
    final navStemiUri = Uri.parse('https://navstemi.org/patient');
    final hasNavStemiId = identifiers.any(
      (i) => i.system?.valueUri == navStemiUri,
    );

    if (!hasNavStemiId) {
      navStemiIdentifier = Identifier(
        system: FhirUri(navStemiUri),
        value: FhirString(const Uuid().v4()),
        use: IdentifierUse.official,
      );
    }

    // Apply all the required field fixes
    return updatedPatient.copyWith(
      active: isActive,
      name: needsDefaultName ? [tempName!] : updatedPatient.name,
      gender: gender,
      identifier: hasNavStemiId
          ? updatedPatient.identifier
          : [...(updatedPatient.identifier ?? []), navStemiIdentifier!],
    );
  }

  /// Converts from PatientInfoModel to FHIR Practitioner (cardiologist)
  /// Leverages the existing PractitionerX.asCardiologist extension
  Practitioner? toFhirCardiologist(
    PatientInfoModel model, {
    Practitioner? existingPractitioner,
  }) {
    if (model.cardiologist == null || model.cardiologist!.isEmpty) {
      return null;
    }

    // Create a new Practitioner or use an existing one
    final practitioner = existingPractitioner ?? const Practitioner();

    // Use the existing extension to set practitioner as a cardiologist
    return practitioner.asCardiologist(model.cardiologist!);
  }

  /// Helper method to extract sex at birth from FHIR Patient
  SexAtBirth? _extractSexAtBirthFromFhir(Patient patient) {
    final gender = patient.gender;

    if (gender == null) {
      return null;
    }

    if (gender == AdministrativeGender.male) {
      return SexAtBirth.male;
    } else if (gender == AdministrativeGender.female) {
      return SexAtBirth.female;
    } else if (gender == AdministrativeGender.other) {
      return SexAtBirth.other;
    } else {
      return SexAtBirth.unknown;
    }
  }

  /// Helper method to extract cardiologist name from FHIR Practitioner
  String? _extractCardiologistName(Practitioner? practitioner) {
    if (practitioner == null) {
      return null;
    }

    // Try to use the text property first, if available
    final name = practitioner.name?.firstOrNull;
    final nameText = name?.text;
    if (nameText != null) {
      return nameText.valueString;
    }

    // Otherwise, try to construct a name from family and given parts
    final family = name?.family?.valueString;
    final given = name?.given?.join(' ');

    if (family != null || given != null) {
      final parts = [given, family]
          .where((part) => part != null && part.isNotEmpty)
          .join(' ');
      return parts.isNotEmpty ? parts : null;
    }

    return null;
  }
}
