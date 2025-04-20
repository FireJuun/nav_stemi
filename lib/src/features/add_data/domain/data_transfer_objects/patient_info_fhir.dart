import 'package:fhir_r4/fhir_r4.dart';
import 'package:nav_stemi/nav_stemi.dart';

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
    // Extract name components from FHIR Patient
    final humanName = patient.name?.firstOrNull;
    final lastName = humanName?.family;
    final firstName = humanName?.given?.firstOrNull;
    final middleNames = humanName?.given?.skip(1).join(' ');

    // Extract birthDate from FHIR Patient
    final birthDate = patient.birthDate != null
        ? DateTime.parse(patient.birthDate!.toString())
        : null;

    // Extract sex from FHIR Patient
    final sex = _extractSexAtBirthFromFhir(patient);

    // Extract cardiologist name from FHIR Practitioner
    final cardiologistName = _extractCardiologistName(cardiologist);

    // Create PatientInfoModel with dirty flag set to false
    return PatientInfoModel(
      lastName: lastName?.value,
      firstName: firstName?.value,
      middleName: middleNames,
      birthDate: birthDate,
      sexAtBirth: sex,
      cardiologist: cardiologistName,
      isDirty: false, // Data is synced with FHIR
    );
  }

  /// Converts from PatientInfoModel to FHIR Patient resource
  /// Leverages the existing PatientX.updatePatientInfo extension
  Patient toFhirPatient(PatientInfoModel model, {Patient? existingPatient}) {
    // Create a new Patient or use an existing one
    final patient = existingPatient ?? const Patient();

    // Use the existing extension to update patient information
    return patient.updatePatientInfo(model);
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
      return nameText.value;
    }

    // Otherwise, try to construct a name from family and given parts
    final family = name?.family?.value;
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
