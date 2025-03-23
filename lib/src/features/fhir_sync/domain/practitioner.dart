import 'package:fhir_r4/fhir_r4.dart';

extension PractitionerX on Practitioner {
  Practitioner updateName(HumanName name) {
    return copyWith(
      name: [
        HumanName(
          family: name.family,
          given: name.given,
          prefix: name.prefix,
          suffix: name.suffix,
        ),
      ],
    );
  }

  /// Cardiologists, who are referenced by patients
  /// It's also worth looking at these ValueSets, if including PractitionerRoles
  /// https://hl7.org/fhir/R4/practitionerrole.html
  /// https://hl7.org/fhir/R4/valueset-c80-practice-codes.html
  Practitioner asCardiologist(String cardiologist) {
    return copyWith(
      qualification: [
        PractitionerQualification(
          code: CodeableConcept(
            coding: [
              /// R4 Spec: https://hl7.org/fhir/R4/valueset-practitioner-role.html

              Coding(
                system: FhirUri(
                  'http://terminology.hl7.org/CodeSystem/v3-RoleCode',
                ),
                code: FhirCode('17561000'),
                display: FhirString('Cardiologist'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Paramedics, who are part of the care team
  Practitioner asParamedic() {
    return copyWith(
      qualification: [
        PractitionerQualification(
          code: CodeableConcept(
            coding: [
              /// R4 Spec: https://hl7.org/fhir/R4/valueset-practitioner-role.html
              Coding(
                system: FhirUri(
                  'http://terminology.hl7.org/CodeSystem/v3-RoleCode',
                ),
                code: FhirCode('397897005'),
                display: FhirString('Paramedic'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
