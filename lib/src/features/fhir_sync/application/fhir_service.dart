import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fhir_service.g.dart';

/// Service class that manages FHIR operations with authentication
/// This service depends on Riverpod for state management
class FhirService {
  /// Constructor that takes a ref for dependency injection
  FhirService(this.ref);

  /// Reference for accessing providers
  final Ref ref;

  /// Base URI for the FHIR server from environment
  final Uri baseUri = Uri.parse(Env.fhirBaseUri);

  /// Get a repository with an authenticated client
  FhirRepository _getAuthenticatedRepository() {
    final currentUser = ref.read(authRepositoryProvider).currentUser;

    if (currentUser == null) {
      throw const FhirRequestException(
        'User not authenticated',
        401,
        'No authenticated user found',
      );
    }

    // Get the appropriate client based on user type
    final client = switch (currentUser) {
      GoogleAppUser() => currentUser.client,
      ServiceAccountUser() => currentUser.client,
    };

    // Create and return a repository with the authenticated client
    return FhirRepository(
      client: client,
      baseUri: baseUri,
    );
  }

  /// Sends a transaction bundle to the FHIR server
  Future<Bundle> postTransactionBundle(Bundle bundle) async {
    try {
      return await _getAuthenticatedRepository().postTransactionBundle(bundle);
    } catch (e) {
      // Log the error
      debugPrint('Error sending FHIR bundle: $e');
      rethrow;
    }
  }

  /// Read a FHIR resource by its type and ID
  Future<Resource> readResource({
    required String resourceType,
    required String id,
  }) async {
    try {
      return await _getAuthenticatedRepository().readResource(
        resourceType: resourceType,
        id: id,
      );
    } catch (e) {
      // Log the error
      debugPrint('Error reading $resourceType/$id: $e');
      rethrow;
    }
  }

  /// Create a new FHIR resource
  Future<Resource> createResource({
    required String resourceType,
    required Resource resource,
  }) async {
    try {
      return await _getAuthenticatedRepository().createResource(
        resourceType: resourceType,
        resource: resource,
      );
    } catch (e) {
      // Log the error
      debugPrint('Error creating $resourceType: $e');
      rethrow;
    }
  }

  /// Update an existing FHIR resource
  Future<Resource> updateResource({
    required String resourceType,
    required String id,
    required Resource resource,
  }) async {
    try {
      return await _getAuthenticatedRepository().updateResource(
        resourceType: resourceType,
        id: id,
        resource: resource,
      );
    } catch (e) {
      // Log the error
      debugPrint('Error updating $resourceType/$id: $e');
      rethrow;
    }
  }

  /// Search for resources by type with parameters
  Future<Bundle> searchResources({
    required String resourceType,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      return await _getAuthenticatedRepository().searchResources(
        resourceType: resourceType,
        parameters: parameters,
      );
    } catch (e) {
      // Log the error
      debugPrint('Error searching for $resourceType: $e');
      rethrow;
    }
  }

  /// Get the capability statement from the server
  Future<CapabilityStatement> getCapabilities() async {
    try {
      return await _getAuthenticatedRepository().getCapabilities();
    } catch (e) {
      // Log the error
      debugPrint('Error getting capabilities: $e');
      rethrow;
    }
  }

  /// Delete a FHIR resource by its type and ID
  Future<void> deleteResource({
    required String resourceType,
    required String id,
  }) async {
    try {
      await _getAuthenticatedRepository().deleteResource(
        resourceType: resourceType,
        id: id,
      );
    } catch (e) {
      // Log the error
      debugPrint('Error deleting $resourceType/$id: $e');
      rethrow;
    }
  }

  /// Check if we can connect to the FHIR server
  Future<bool> isConnected() async {
    try {
      // Try to get capabilities as a basic connectivity test
      await getCapabilities();
      return true;
    } catch (e) {
      debugPrint('FHIR connectivity check failed: $e');
      return false;
    }
  }

  /// Adds simulation capabilities for testing/development
  Future<Bundle> postTransactionBundleWithFallback(Bundle bundle) async {
    try {
      // First try with the real repository
      return await postTransactionBundle(bundle);
    } catch (e) {
      // Log the error
      debugPrint('Falling back to simulation mode: $e');

      // Fall back to simulation
      return _simulateServerResponse(bundle);
    }
  }

  /// Simulates a server response for testing/development
  Bundle _simulateServerResponse(Bundle bundle) {
    // Create a simulated response bundle
    final responseEntries = <BundleEntry>[];
    final bundleEntries = bundle.entry ?? <BundleEntry>[];

    for (final entry in bundleEntries) {
      final resource = entry.resource;
      if (resource == null) continue;

      // Simulate the server assigning an ID if it's a POST
      final isPost = entry.request?.method == HTTPVerb.POST;
      final existingId = resource.id?.value;
      final id = isPost
          ? 'generated-${DateTime.now().millisecondsSinceEpoch}-${resource.resourceType}'
          : existingId;

      // Add ID to the resource
      final resourceWithId = resource.copyWith(id: FhirString(id));

      // Add to response bundle
      responseEntries.add(
        BundleEntry(
          resource: resourceWithId,
          response: BundleResponse(
            status: FhirString('201 Created'),
            location: FhirUri(
              '${resource.resourceType}/$id)',
            ),
          ),
        ),
      );
    }

    // Create response bundle
    final responseBundle = Bundle(
      type: BundleType.transaction_response,
      entry: responseEntries,
    );

    debugPrint('Using simulated FHIR server response (demo mode)');

    return responseBundle;
  }
}

/// Provider for the FhirService
@riverpod
FhirService fhirService(Ref ref) {
  return FhirService(ref);
}
