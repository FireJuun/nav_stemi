import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:jose/jose.dart';
import 'package:nav_stemi/nav_stemi.dart';

/// A provider for the test authentication repository
final testAuthRepositoryProvider = Provider<AuthRepository>((ref) {
  return TestAuthRepository();
});

/// A simple HTTP client that uses service account credentials
/// for authenticating with Google Cloud APIs
class ServiceAccountClient extends http.BaseClient {
  ServiceAccountClient({
    required this.serviceAccountEmail,
    required String privateKeyBase64,
  }) : privateKey = _decodePrivateKey(privateKeyBase64);

  final String serviceAccountEmail;
  final String privateKey;
  final http.Client _inner = http.Client();
  String? _accessToken;
  DateTime? _tokenExpiry;

  /// Decodes a base64-encoded private key back to PEM format
  static String _decodePrivateKey(String base64Key) {
    // If the key is already in PEM format (starts with -----BEGIN PRIVATE KEY-----)
    // just return it as is
    if (base64Key.trim().startsWith('-----BEGIN PRIVATE KEY-----')) {
      return base64Key;
    }

    try {
      final bytes = base64.decode(base64Key);
      final pemKey = utf8.decode(bytes);
      return pemKey;
    } catch (e) {
      debugPrint('Error decoding private key: $e');
      // If decoding fails, return the original string
      // This handles cases where the key might be provided in raw PEM format
      return base64Key;
    }
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (_accessToken == null || _isTokenExpired()) {
      await _refreshAccessToken();
    }

    // Add the token to the request
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _inner.send(request);
  }

  bool _isTokenExpired() {
    if (_tokenExpiry == null) return true;
    // Return true if token expires in less than 5 minutes
    return _tokenExpiry!
        .isBefore(DateTime.now().add(const Duration(minutes: 5)));
  }

  Future<void> _refreshAccessToken() async {
    try {
      final jwt = _createJWT();

      final response = await _inner.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        body: {
          'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
          'assertion': jwt,
        },
      );

      if (response.statusCode == 200) {
        final tokenData = jsonDecode(response.body) as Map<String, dynamic>;
        _accessToken = tokenData['access_token'] as String;
        _tokenExpiry = DateTime.now().add(
          Duration(seconds: tokenData['expires_in'] as int),
        );
        debugPrint('Successfully retrieved access token');
      } else {
        throw Exception('Failed to refresh access token: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error refreshing access token: $e');
      rethrow;
    }
  }

  /// Creates a JWT for Google Cloud authentication
  /// For Healthcare API scope, see: https://cloud.google.com/healthcare/docs/reference/rest
  String _createJWT() {
    try {
      // Create the claims for the JWT
      final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
      final claims = {
        'iss': serviceAccountEmail,
        'sub': serviceAccountEmail,
        'aud': 'https://oauth2.googleapis.com/token',
        'iat': now, // Issued at time
        'exp': now + 3600, // Expires in 1 hour
        'scope': 'https://www.googleapis.com/auth/cloud-healthcare',
      };

      // Parse the private key (PEM format)
      final key = JsonWebKey.fromPem(privateKey, keyId: 'service-account-key');

      // Create and sign the JWT
      final builder = JsonWebSignatureBuilder()
        ..jsonContent = claims
        ..addRecipient(key, algorithm: 'RS256');

      return builder.build().toCompactSerialization();
    } catch (e) {
      debugPrint('Error creating JWT: $e');
      rethrow;
    }
  }
}

/// Test authentication repository that uses service account credentials
/// instead of Google Sign In for testing purposes
class TestAuthRepository implements AuthRepository {
  TestAuthRepository();

  final _authState = InMemoryStore<AppUser?>(null);
  ServiceAccountClient? _client;

  @override
  Stream<AppUser?> authStateChanges() => _authState.stream;

  @override
  AppUser? get currentUser => _authState.value;

  @override
  Future<void> init() async {
    // Check if we have environment variables for service account
    if (Env.serviceAccountEmail.isNotEmpty &&
        Env.serviceAccountPrivateKey.isNotEmpty) {
      await signIn();
    }
  }

  @override
  Future<void> signIn() async {
    try {
      if (Env.serviceAccountEmail.isEmpty ||
          Env.serviceAccountPrivateKey.isEmpty) {
        throw Exception('Service account credentials are missing');
      }

      _client = ServiceAccountClient(
        serviceAccountEmail: Env.serviceAccountEmail,
        privateKeyBase64: Env.serviceAccountPrivateKey,
      );

      // Create a test user with the service account client
      _authState.value = ServiceAccountUser(
        email: Env.serviceAccountEmail,
        client: _client!,
      );

      debugPrint(
        '''Successfully signed in with service account: ${Env.serviceAccountEmail}''',
      );
    } catch (e) {
      debugPrint('Error signing in with service account: $e');
      _authState.value = null;
    }
  }

  @override
  Future<void> signOut() async {
    _client = null;
    _authState.value = null;
    debugPrint('Signed out service account user');
  }
}
