import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/foundation.dart';
import 'package:nav_stemi/nav_stemi.dart';
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

    // Add debug logging to help troubleshoot
    debugPrint(
      'Processing response bundle with ${responseBundle.entry!.length} entries',
    );

    for (final entry in responseBundle.entry!) {
      // Extract resource type and ID from the location field
      // Location format is: BaseUri/ResourceType/id/_history/version
      String? resourceType;
      String? id;

      // Try to extract from response.location
      if (entry.response?.location != null) {
        final location = entry.response!.location.toString();
        debugPrint('Parsing location: $location');

        // Remove the base URI from the location
        final baseUri = Env.fhirBaseUri;
        var path = location;

        if (location.startsWith(baseUri)) {
          path = location.substring(baseUri.length);
          // Remove leading slash if present
          if (path.startsWith('/')) {
            path = path.substring(1);
          }
        }

        // Split the path to extract resource type and ID
        // Format should be: ResourceType/id/_history/version
        final pathParts = path.split('/');

        if (pathParts.length >= 2) {
          resourceType = pathParts[0];
          id = pathParts[1];
          debugPrint(
            'Extracted from location: resourceType=$resourceType, id=$id',
          );
        }
      }
      // Fallback to entry.resource if available
      else if (entry.resource != null && entry.resource!.id != null) {
        resourceType = entry.resource!.resourceType.toString();
        id = entry.resource!.id!.valueString;
        debugPrint(
          'Extracted from resource: resourceType=$resourceType, id=$id',
        );
      }

      if (id == null || id.isEmpty) {
        debugPrint('No ID found in bundle entry, skipping');
        continue;
      }

      if (resourceType == null) {
        debugPrint('No resource type found for ID: $id, skipping');
        continue;
      }

      debugPrint('Processing resource of type: $resourceType with ID: $id');

      // Update the appropriate reference based on resource type
      if (resourceType == 'Patient') {
        debugPrint('Updating Patient ID to: $id');
        updatePatientId(id);
      } else if (resourceType == 'Practitioner') {
        updatePractitionerId(id);
      } else if (resourceType == 'Encounter') {
        updateEncounterId(id);
      } else if (resourceType == 'Condition') {
        // For conditions we need to check if it's STEMI, but we may not have
        // the full resource available in the response
        // Store it for now, the actual validation can happen when we fetch the full resource
        updateStemiConditionId(id);
      } else if (resourceType == 'MedicationAdministration') {
        // For medication administration, similar to conditions
        updateAspirinAdministrationId(id);
      } else if (resourceType == 'QuestionnaireResponse') {
        updateQuestionnaireResponseId(id);
      }
    }

    // Print the final state for debugging
    debugPrint(
      'Updated references: Patient=${state.patientId}, Encounter=${state.encounterId}',
    );
  }

  /// Resets all references (e.g., when starting a new encounter)
  void reset() {
    state = FhirResourceReferences();
  }
}
