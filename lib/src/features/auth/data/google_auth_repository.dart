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
  GoogleAuthRepository() {
    init();
  }

  final _authState = InMemoryStore<GoogleAppUser?>(null);

  @override
  Stream<GoogleAppUser?> authStateChanges() => _authState.stream;

  @override
  GoogleAppUser? get currentUser => _authState.value;

  /// spec: https://pub.dev/packages/extension_google_sign_in_as_googleapis_auth/example
  @override
  Future<void> init() async {
    _googleSignIn.onCurrentUserChanged.listen(
      (GoogleSignInAccount? newUser) async => setAppUser(newUser),
    );

    final user = await _googleSignIn.signInSilently();
    await setAppUser(user);
  }

  /// spec: https://pub.dev/packages/googleapis_auth
  @override
  Future<void> signIn() async {
    try {
      final user = await _googleSignIn.signIn();
      if (user == null) {
        throw Exception('Failed to sign in with Google');
      }
      await setAppUser(user);
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    // Clear the auth state when signing out
    _authState.value = null;
  }

  /// Use the current signed in Google Account to create an http client
  /// and update the auth state with the new user and client.
  Future<void> setAppUser(GoogleSignInAccount? user) async {
    if (user == null) return;
    if (user == _authState.value?.user) return;

    final client = await _googleSignIn.authenticatedClient();
    if (client == null) {
      throw Exception('Failed to get authenticated client');
    }

    _authState.value = GoogleAppUser(user: user, client: client);
  }
}
