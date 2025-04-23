import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

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
    // First check again if we already have a patient reference
    // This prevents duplicate creation in race conditions
    final currentRefs = ref.read(fhirResourceReferencesNotifierProvider);
    if (currentRefs.hasPatientReference) {
      // Patient already exists, no need to create another one
      return;
    }

    // Create a Patient resource directly with the required fields
    final patient = Patient(
      identifier: [
        Identifier(
          system: FhirUri('https://navstemi.org/patient'),
          value: FhirString(const Uuid().v4()),
          use: IdentifierUse.official,
        ),
      ],
      active: FhirBoolean(false),
      name: [
        HumanName(
          family: FhirString('Temporary'),
          given: [FhirString('Patient')],
          use: NameUse.temp,
        ),
      ],
      gender: AdministrativeGender.unknown,
    );

    // Create a transaction bundle with the patient
    final bundle = Bundle(
      type: BundleType.transaction,
      entry: [
        BundleEntry(
          resource: patient,
          request: BundleRequest(
            method: HTTPVerb.pOST,
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
    // First check again if we already have an encounter reference
    // This prevents duplicate creation in race conditions
    final currentRefs = ref.read(fhirResourceReferencesNotifierProvider);
    if (currentRefs.hasEncounterReference) {
      // Encounter already exists, no need to create another one
      return;
    }

    // Ensure we have a patient reference before creating an encounter
    if (!currentRefs.hasPatientReference) {
      await _createBlankPatient();
      // Read the references again after patient creation
    }

    // Get the updated patient reference
    final updatedRefs = ref.read(fhirResourceReferencesNotifierProvider);
    final patient = updatedRefs.patientReference;

    if (patient == null) {
      throw Exception('Cannot create Encounter: Patient reference is null');
    }

    // Create an Encounter with required fields for US Core
    final encounter = Encounter(
      status: EncounterStatus.inProgress,
      class_: Coding(
        system: FhirUri('http://terminology.hl7.org/CodeSystem/v3-ActCode'),
        code: FhirCode('FLD'),
        display: FhirString('field'),
      ),
      // Add the required 'type' for US Core compliance
      type: [
        CodeableConcept(
          coding: [
            Coding(
              system:
                  FhirUri('http://terminology.hl7.org/CodeSystem/v3-ActCode'),
              code: FhirCode('AMB'),
              display: FhirString('ambulatory'),
            ),
          ],
          text: FhirString('Ambulatory encounter'),
        ),
      ],
      // Ensure subject is correctly set to the patient reference
      subject: patient,
      period: Period(
        start: FhirDateTime.fromDateTime(DateTime.now()),
      ),
    );

    // Create a transaction bundle with the encounter
    final bundle = Bundle(
      type: BundleType.transaction,
      entry: [
        BundleEntry(
          resource: encounter,
          request: BundleRequest(
            method: HTTPVerb.pOST,
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
