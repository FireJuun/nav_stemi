import 'dart:convert';

import 'package:fhir_r4/fhir_r4.dart';
import 'package:fhir_r4_at_rest/fhir_r4_at_rest.dart';
import 'package:http/http.dart' as http;

/// Repository for making FHIR API requests
/// This is a pure repository with no dependencies on Riverpod
class FhirRepository {
  /// Constructor requires a client and base URI
  FhirRepository({
    required this.client,
    required this.baseUri,
  });

  /// HTTP client for making requests
  final http.Client client;

  /// Base URI for the FHIR server
  final Uri baseUri;

  /// Sends a transaction bundle to the FHIR server
  Future<Bundle> postTransactionBundle(Bundle bundle) async {
    try {
      // Instead of using FhirTransactionRequest directly, we'll create a custom request
      // that doesn't include the problematic _format parameter
      final url = Uri.parse('$baseUri/');

      // Prepare headers and body
      final headers = <String, String>{
        'Content-Type': 'application/fhir+json',
        'Accept': 'application/fhir+json',
        'Prefer': 'return=representation',
      };

      final requestBody = jsonEncode(bundle.toJson());

      // Send the request
      final response = await client.post(
        url,
        headers: headers,
        body: requestBody,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Bundle.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw FhirRequestException(
          'Failed to post transaction bundle: ${response.statusCode}',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is FhirRequestException) {
        rethrow;
      }
      throw FhirRequestException(
        'Error sending transaction bundle: $e',
        500,
        e.toString(),
      );
    }
  }

  /// Read a FHIR resource by its type and ID
  Future<Resource> readResource({
    required String resourceType,
    required String id,
  }) async {
    try {
      // Create a custom request instead of using FhirReadRequest
      // to avoid the problematic _format parameter
      final url = Uri.parse('$baseUri/$resourceType/$id');

      // Prepare headers
      final headers = <String, String>{
        'Accept': 'application/fhir+json',
      };

      // Send the request
      final response = await client.get(url, headers: headers);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Resource.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw FhirRequestException(
          'Failed to read $resourceType/$id: ${response.statusCode}',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is FhirRequestException) {
        rethrow;
      }
      throw FhirRequestException(
        'Error reading resource: $e',
        500,
        e.toString(),
      );
    }
  }

  /// Create a new FHIR resource
  Future<Resource> createResource({
    required String resourceType,
    required Resource resource,
  }) async {
    try {
      final response = await FhirCreateRequest(
        base: baseUri,
        resourceType: resourceType,
        resource: resource.toJson(),
        client: client,
      ).sendRequest();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Resource.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw FhirRequestException(
          'Failed to create $resourceType: ${response.statusCode}',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is FhirRequestException) {
        rethrow;
      }
      throw FhirRequestException(
        'Error creating resource: $e',
        500,
        e.toString(),
      );
    }
  }

  /// Update an existing FHIR resource
  Future<Resource> updateResource({
    required String resourceType,
    required String id,
    required Resource resource,
  }) async {
    try {
      final response = await FhirUpdateRequest(
        base: baseUri,
        resourceType: resourceType,
        id: id,
        resource: resource.toJson(),
        client: client,
      ).sendRequest();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Resource.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw FhirRequestException(
          'Failed to update $resourceType/$id: ${response.statusCode}',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is FhirRequestException) {
        rethrow;
      }
      throw FhirRequestException(
        'Error updating resource: $e',
        500,
        e.toString(),
      );
    }
  }

  /// Search for resources by type with parameters
  Future<Bundle> searchResources({
    required String resourceType,
    Map<String, dynamic>? parameters,
  }) async {
    final search = SearchResource();

    if (parameters != null) {
      parameters.forEach((key, value) {
        search.add(key, value.toString());
      });
    }

    try {
      final response = await FhirSearchRequest(
        base: baseUri,
        resourceType: resourceType,
        search: search,
        client: client,
      ).sendRequest();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Bundle.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw FhirRequestException(
          'Failed to search $resourceType: ${response.statusCode}',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is FhirRequestException) {
        rethrow;
      }
      throw FhirRequestException(
        'Error searching resources: $e',
        500,
        e.toString(),
      );
    }
  }

  /// Get the capability statement from the server
  Future<CapabilityStatement> getCapabilities() async {
    try {
      // Create a custom request instead of using FhirCapabilitiesRequest
      // to avoid the problematic _format parameter
      final url = Uri.parse('$baseUri/metadata');

      // Prepare headers
      final headers = <String, String>{
        'Accept': 'application/fhir+json',
      };

      // Send the request
      final response = await client.get(url, headers: headers);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return CapabilityStatement.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw FhirRequestException(
          'Failed to get capabilities: ${response.statusCode}',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is FhirRequestException) {
        rethrow;
      }
      throw FhirRequestException(
        'Error getting capabilities: $e',
        500,
        e.toString(),
      );
    }
  }

  /// Delete a FHIR resource by its type and ID
  Future<void> deleteResource({
    required String resourceType,
    required String id,
  }) async {
    try {
      final response = await FhirDeleteRequest(
        base: baseUri,
        resourceType: resourceType,
        id: id,
        client: client,
      ).sendRequest();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw FhirRequestException(
          'Failed to delete $resourceType/$id: ${response.statusCode}',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is FhirRequestException) {
        rethrow;
      }
      throw FhirRequestException(
        'Error deleting resource: $e',
        500,
        e.toString(),
      );
    }
  }
}

/// Exception for FHIR request errors
class FhirRequestException implements Exception {
  const FhirRequestException(this.message, this.statusCode, this.responseBody);

  final String message;
  final int statusCode;
  final String responseBody;

  @override
  String toString() => 'FhirRequestException: $message (Status: $statusCode)';
}
