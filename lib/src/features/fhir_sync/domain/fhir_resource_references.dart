import 'package:fhir_r4/fhir_r4.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fhir_resource_references.g.dart';

/// Holds references to FHIR resources for the active encounter
///
/// These references are critical to maintain proper relationships
/// between FHIR resources and avoid creating duplicate resources
class FhirResourceReferences {
  FhirResourceReferences({
    this.patientId,
    this.practitionerId,
    this.encounterId,
    this.stemiConditionId,
    this.aspirinAdministrationId,
    this.questionnaireResponseId,
  });

  /// ID of the Patient resource on the FHIR server
  final String? patientId;

  /// ID of the Practitioner (cardiologist) resource on the FHIR server
  final String? practitionerId;

  /// ID of the Encounter resource on the FHIR server
  final String? encounterId;

  /// ID of the STEMI Condition resource on the FHIR server
  final String? stemiConditionId;

  /// ID of the Aspirin MedicationAdministration resource on the FHIR server
  final String? aspirinAdministrationId;

  /// ID of the QuestionnaireResponse resource on the FHIR server
  final String? questionnaireResponseId;

  /// Creates a copy of this object with the specified fields replaced
  FhirResourceReferences copyWith({
    String? patientId,
    String? practitionerId,
    String? encounterId,
    String? stemiConditionId,
    String? aspirinAdministrationId,
    String? questionnaireResponseId,
  }) {
    return FhirResourceReferences(
      patientId: patientId ?? this.patientId,
      practitionerId: practitionerId ?? this.practitionerId,
      encounterId: encounterId ?? this.encounterId,
      stemiConditionId: stemiConditionId ?? this.stemiConditionId,
      aspirinAdministrationId:
          aspirinAdministrationId ?? this.aspirinAdministrationId,
      questionnaireResponseId:
          questionnaireResponseId ?? this.questionnaireResponseId,
    );
  }

  /// Checks if Patient reference exists
  bool get hasPatientReference => patientId != null && patientId!.isNotEmpty;

  /// Checks if Practitioner reference exists
  bool get hasPractitionerReference =>
      practitionerId != null && practitionerId!.isNotEmpty;

  /// Checks if Encounter reference exists
  bool get hasEncounterReference =>
      encounterId != null && encounterId!.isNotEmpty;

  /// Checks if STEMI Condition reference exists
  bool get hasStemiConditionReference =>
      stemiConditionId != null && stemiConditionId!.isNotEmpty;

  /// Checks if Aspirin Administration reference exists
  bool get hasAspirinAdministrationReference =>
      aspirinAdministrationId != null && aspirinAdministrationId!.isNotEmpty;

  /// Checks if QuestionnaireResponse reference exists
  bool get hasQuestionnaireResponseReference =>
      questionnaireResponseId != null && questionnaireResponseId!.isNotEmpty;

  /// Gets the Patient reference in FHIR format
  Reference? get patientReference => hasPatientReference
      ? Reference(reference: FhirString('Patient/$patientId'))
      : null;

  /// Gets the Practitioner reference in FHIR format
  Reference? get practitionerReference => hasPractitionerReference
      ? Reference(reference: FhirString('Practitioner/$practitionerId'))
      : null;

  /// Gets the Encounter reference in FHIR format
  Reference? get encounterReference => hasEncounterReference
      ? Reference(reference: FhirString('Encounter/$encounterId'))
      : null;

  /// Gets the STEMI Condition reference in FHIR format
  Reference? get stemiConditionReference => hasStemiConditionReference
      ? Reference(reference: FhirString('Condition/$stemiConditionId'))
      : null;

  /// Gets the Aspirin Administration reference in FHIR format
  Reference? get aspirinAdministrationReference =>
      hasAspirinAdministrationReference
          ? Reference(
              reference: FhirString(
                'MedicationAdministration/$aspirinAdministrationId',
              ),
            )
          : null;

  /// Gets the QuestionnaireResponse reference in FHIR format
  Reference? get questionnaireResponseReference =>
      hasQuestionnaireResponseReference
          ? Reference(
              reference:
                  FhirString('QuestionnaireResponse/$questionnaireResponseId'),
            )
          : null;
}

/// Provider for FHIR resource references
@Riverpod(keepAlive: true)
class FhirResourceReferencesNotifier extends _$FhirResourceReferencesNotifier {
  @override
  FhirResourceReferences build() {
    return FhirResourceReferences();
  }

  /// Updates the Patient resource ID
  void updatePatientId(String id) {
    state = state.copyWith(patientId: id);
  }

  /// Updates the Practitioner resource ID
  void updatePractitionerId(String id) {
    state = state.copyWith(practitionerId: id);
  }

  /// Updates the Encounter resource ID
  void updateEncounterId(String id) {
    state = state.copyWith(encounterId: id);
  }

  /// Updates the STEMI Condition resource ID
  void updateStemiConditionId(String id) {
    state = state.copyWith(stemiConditionId: id);
  }

  /// Updates the Aspirin Administration resource ID
  void updateAspirinAdministrationId(String id) {
    state = state.copyWith(aspirinAdministrationId: id);
  }

  /// Updates the QuestionnaireResponse resource ID
  void updateQuestionnaireResponseId(String id) {
    state = state.copyWith(questionnaireResponseId: id);
  }

  /// Updates all references from a response bundle
  void updateFromBundle(Bundle responseBundle) {
    if (responseBundle.entry == null) return;

    for (final entry in responseBundle.entry!) {
      final resource = entry.resource;
      final id = resource?.id?.value;

      if (id == null || id.isEmpty) continue;

      if (resource is Patient) {
        updatePatientId(id);
      } else if (resource is Practitioner) {
        updatePractitionerId(id);
      } else if (resource is Encounter) {
        updateEncounterId(id);
      } else if (resource is Condition) {
        // Check if this is the STEMI condition
        final coding = resource.code?.coding?.firstOrNull;
        final isStemiCondition = coding?.code?.value == '401303003' ||
            coding?.display?.value?.contains('STEMI') == true;
        if (isStemiCondition) {
          updateStemiConditionId(id);
        }
      } else if (resource is MedicationAdministration) {
        final medicationX = resource.medicationX;
        // Check if this is the aspirin administration
        final coding = medicationX is CodeableConcept
            ? medicationX.coding?.firstOrNull
            : null;
        final isAspirinAdmin = coding?.code?.value == '317300' ||
            coding?.display?.value?.contains('Aspirin') == true;
        if (isAspirinAdmin) {
          updateAspirinAdministrationId(id);
        }
      } else if (resource is QuestionnaireResponse) {
        updateQuestionnaireResponseId(id);
      }
    }
  }

  /// Resets all references (e.g., when starting a new encounter)
  void reset() {
    state = FhirResourceReferences();
  }
}
