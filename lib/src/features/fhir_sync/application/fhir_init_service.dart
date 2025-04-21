import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fhir_init_service.g.dart';

/// Service to initialize blank FHIR resources when needed
///
/// This service ensures that basic FHIR resources (Patient, Encounter)
/// are created before they're needed by other parts of the application.
class FhirInitService {
  const FhirInitService(this.ref);

  final Ref ref;

  /// Initialize blank FHIR resources when navigating to key screens
  Future<void> initializeBlankResources() async {
    // Check if we already have patient and encounter references
    final refs = ref.read(fhirResourceReferencesNotifierProvider);

    // Create a blank Patient if needed
    if (!refs.hasPatientReference) {
      await _createBlankPatient();
    }

    // Create a blank Encounter if needed
    if (!refs.hasEncounterReference) {
      await _createBlankEncounter();
    }
  }

  /// Create a blank Patient resource and store its ID
  Future<void> _createBlankPatient() async {
    // Create a minimal Patient resource
    final patient = Patient.empty();

    // Create a transaction bundle with the patient
    final bundle = Bundle(
      type: BundleType.transaction,
      entry: [
        BundleEntry(
          resource: patient,
          request: BundleRequest(
            method: HTTPVerb.POST,
            url: FhirUri('Patient'),
          ),
        ),
      ],
    );

    // Send the bundle to the FHIR server
    final responseBundle =
        await ref.read(fhirSyncServiceProvider).sendFhirBundle(bundle);

    // Update our resource references with the server-assigned IDs
    ref
        .read(fhirResourceReferencesNotifierProvider.notifier)
        .updateFromBundle(responseBundle);
  }

  /// Create a blank Encounter resource and store its ID
  Future<void> _createBlankEncounter() async {
    // Get the patient reference
    final refs = ref.read(fhirResourceReferencesNotifierProvider);
    if (!refs.hasPatientReference) {
      // This shouldn't happen because we're checking before calling,
      // but just in case
      await _createBlankPatient();
    }

    // Create a minimal Encounter resource linked to the patient
    final encounter = Encounter.empty();
    final patientRef =
        ref.read(fhirResourceReferencesNotifierProvider).patientReference;
    final encounterWithPatient = encounter.copyWith(subject: patientRef);

    // Create a transaction bundle with the encounter
    final bundle = Bundle(
      type: BundleType.transaction,
      entry: [
        BundleEntry(
          resource: encounterWithPatient,
          request: BundleRequest(
            method: HTTPVerb.POST,
            url: FhirUri('Encounter'),
          ),
        ),
      ],
    );

    // Send the bundle to the FHIR server
    final responseBundle =
        await ref.read(fhirSyncServiceProvider).sendFhirBundle(bundle);

    // Update our resource references with the server-assigned IDs
    ref
        .read(fhirResourceReferencesNotifierProvider.notifier)
        .updateFromBundle(responseBundle);
  }
}

/// Provider for the FHIR initialization service
@riverpod
FhirInitService fhirInitService(Ref ref) {
  return FhirInitService(ref);
}
