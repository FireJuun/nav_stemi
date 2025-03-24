import 'dart:io';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/healthcare/v1.dart';
import 'package:nav_stemi/nav_stemi.dart';

/// spec: https://github.com/flutter/packages/blob/main/packages/extension_google_sign_in_as_googleapis_auth/example/lib/main.dart
/// custom client id needed for iOS integration, per here:
/// https://pub.dev/packages/google_sign_in_ios#ios-integration
///
final _googleSignIn = GoogleSignIn(
  clientId: (Platform.isIOS) ? Env.iosGoogleClientId : null,
  scopes: <String>[CloudHealthcareApi.cloudHealthcareScope],
);

class GoogleAuthRepository implements AuthRepository {
  final _authState = InMemoryStore<AppUser?>(null);

  @override
  Stream<AppUser?> authStateChanges() => _authState.stream;

  @override
  AppUser? get currentUser => _authState.value;

  @override
  void init() {
    /// spec: https://pub.dev/packages/extension_google_sign_in_as_googleapis_auth/example
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      // TODO(FireJuun): Implement sign in with Google
      // _authState.value = GoogleAppUser(client: account);
    });
    // _googleSignIn.signInSilently();
  }

  @override
  void dispose() => _authState.close();

  @override

  /// spec: https://pub.dev/packages/googleapis_auth
  Future<void> signIn() async {
    try {
      final user = await _googleSignIn.signIn();
      if (user == null) {
        throw Exception('Failed to sign in with Google');
      }
      final client = await _googleSignIn.authenticatedClient();
      if (client == null) {
        throw Exception('Failed to get authenticated client');
      }

      _authState.value = GoogleAppUser(user: user, client: client);
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
    }
  }

  @override
  Future<void> signOut() async => _authState.value = null;
}
