import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'fake_fhir_service.g.dart';

/// A fake implementation of the FhirService for staging/demo environments
///
/// This service simulates interactions with a FHIR server without actually
/// making network requests or requiring authentication.
class FakeFhirService implements FhirService {
  FakeFhirService(this.ref);

  @override
  final Ref ref;

  /// Resources stored in memory for the fake service
  final Map<String, Map<String, Resource>> _resources = {
    'Patient': {},
    'Practitioner': {},
    'Encounter': {},
    'Condition': {},
    'MedicationAdministration': {},
    'QuestionnaireResponse': {},
  };

  /// Base URI (not used in the fake implementation,
  /// but needed for interface compatibility)
  @override
  final Uri baseUri = Uri.parse('https://fake.fhir.server/staging');

  /// Simulates sending a transaction bundle to the FHIR server
  @override
  Future<Bundle> postTransactionBundle(Bundle bundle) async {
    debugPrint(
      '''FAKE: Processing transaction bundle with ${bundle.entry?.length ?? 0} entries''',
    );
    // Short delay to simulate network latency
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final responseEntries = <BundleEntry>[];
    final entries = bundle.entry ?? <BundleEntry>[];

    for (final entry in entries) {
      final resource = entry.resource;
      if (resource == null) continue;

      final resourceType = resource.resourceType.toString();
      final method = entry.request?.method;
      final id = resource.id?.valueString ?? const Uuid().v4();

      // Create a copy of the resource with an ID
      final resourceWithId = resource.copyWith(id: FhirString(id));

      // Store the resource in our in-memory database
      if (!_resources.containsKey(resourceType)) {
        _resources[resourceType] = {};
      }

      _resources[resourceType]![id] = resourceWithId;

      // Create a response entry
      responseEntries.add(
        BundleEntry(
          resource: resourceWithId,
          response: BundleResponse(
            status:
                FhirString(method == HTTPVerb.pOST ? '201 Created' : '200 OK'),
            location: FhirUri('$resourceType/$id'),
          ),
        ),
      );
    }

    return Bundle(
      type: BundleType.transactionResponse,
      entry: responseEntries,
    );
  }

  /// Simulates reading a FHIR resource
  @override
  Future<Resource> readResource({
    required String resourceType,
    required String id,
  }) async {
    debugPrint('FAKE: Reading $resourceType/$id');
    // Simulate network latency
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Check if the resource exists in our fake database
    if (_resources.containsKey(resourceType) &&
        _resources[resourceType]!.containsKey(id)) {
      return _resources[resourceType]![id]!;
    }

    // If not found, create a blank resource with the requested ID
    return _createBlankResource(resourceType, id);
  }

  /// Create a blank resource for the given type
  Resource _createBlankResource(String resourceType, String id) {
    switch (resourceType) {
      case 'Patient':
        return Patient(id: FhirString(id));
      case 'Practitioner':
        return Practitioner(id: FhirString(id));
      case 'Encounter':
        return defaultEmsEncounter.copyWith(id: FhirString(id));
      case 'MedicationAdministration':
        final subject = Reference(
          reference: FhirString('Patient/$id'),
        );
        return MedicationAdministration(
          subject: subject,
          effectiveX: FhirDateTime.fromDateTime(DateTime.now()),
          medicationX: CodeableConcept(
            coding: [
              /// R4 spec: https://build.fhir.org/ig/HL7/PDDI-CDS/ValueSet-valueset-aspirin.html
              Coding(
                system: FhirUri('http://www.nlm.nih.gov/research/umls/rxnorm'),
                code: FhirCode('317300'), // RxNorm code for Aspirin 325
                display: FhirString('Aspirin 325 mg'),
              ),
            ],
          ),
          id: FhirString(id),
          status: MedicationAdministrationStatusCodes.unknown,
        );
      case 'Condition':
        final subject = Reference(
          reference: FhirString('Patient/$id'),
        );
        return Condition(
          subject: subject,
          id: FhirString(id),
        );
      case 'QuestionnaireResponse':
        return QuestionnaireResponse(
          status: QuestionnaireResponseStatus.inProgress,
          id: FhirString(id),
        );
      default:
        throw Exception('Unsupported resource type: $resourceType');
    }
  }

  /// Simulates creating a new FHIR resource
  @override
  Future<Resource> createResource({
    required String resourceType,
    required Resource resource,
  }) async {
    debugPrint('FAKE: Creating $resourceType');
    // Simulate network latency
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final id = const Uuid().v4();
    final resourceWithId = resource.copyWith(id: FhirString(id));

    if (!_resources.containsKey(resourceType)) {
      _resources[resourceType] = {};
    }

    _resources[resourceType]![id] = resourceWithId;
    return resourceWithId;
  }

  /// Simulates updating an existing FHIR resource
  @override
  Future<Resource> updateResource({
    required String resourceType,
    required String id,
    required Resource resource,
  }) async {
    debugPrint('FAKE: Updating $resourceType/$id');
    // Simulate network latency
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final resourceWithId = resource.copyWith(id: FhirString(id));

    if (!_resources.containsKey(resourceType)) {
      _resources[resourceType] = {};
    }

    _resources[resourceType]![id] = resourceWithId;
    return resourceWithId;
  }

  /// Simulates searching for FHIR resources
  @override
  Future<Bundle> searchResources({
    required String resourceType,
    Map<String, dynamic>? parameters,
  }) async {
    debugPrint(
      'FAKE: Searching for $resourceType with parameters: $parameters',
    );
    // Simulate network latency
    await Future<void>.delayed(const Duration(milliseconds: 400));

    // Return empty bundle for simplicity
    return Bundle(
      type: BundleType.searchset,
      total: FhirUnsignedInt(0),
      entry: [],
    );
  }

  /// Simulates fetching FHIR server capabilities
  @override
  Future<CapabilityStatement> getCapabilities() async {
    debugPrint('FAKE: Getting capabilities');
    // Simulate network latency
    await Future<void>.delayed(const Duration(milliseconds: 200));

    return CapabilityStatement(
      status: PublicationStatus.active,
      date: FhirDateTime.fromDateTime(DateTime.now()),
      kind: CapabilityStatementKind.instance,
      fhirVersion: FHIRVersion.value401,
      format: [FhirCode('json')],
    );
  }

  /// Simulates deleting a FHIR resource
  @override
  Future<void> deleteResource({
    required String resourceType,
    required String id,
  }) async {
    debugPrint('FAKE: Deleting $resourceType/$id');
    // Simulate network latency
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (_resources.containsKey(resourceType)) {
      _resources[resourceType]!.remove(id);
    }
  }

  /// Always returns true for connectivity check in fake mode
  @override
  Future<bool> isConnected() async {
    debugPrint('FAKE: Checking connectivity (always true)');
    return true;
  }

  /// Wraps the transaction method since we don't need a fallback in fake mode
  @override
  Future<Bundle> postTransactionBundleWithFallback(Bundle bundle) {
    return postTransactionBundle(bundle);
  }
}

/// Provider for the fake FHIR service
@riverpod
FhirService fakeFhirService(Ref ref) {
  return FakeFhirService(ref);
}
