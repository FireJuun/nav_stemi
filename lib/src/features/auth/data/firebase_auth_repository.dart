import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/src/features/auth/data/auth_repository.dart';
import 'package:nav_stemi/src/features/auth/domain/app_user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Service for handling Firebase authentication
/// This is separate from the AppUser domain which handles FHIR data access
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if current user is anonymous
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? false;

  /// Check if current user signed in with phone
  bool get isPhoneUser =>
      _auth.currentUser?.providerData
          .any((info) => info.providerId == 'phone') ??
      false;

  /// Get current user's UID (null if not authenticated)
  String? get uid => _auth.currentUser?.uid;

  /// Stream of Firebase auth state changes
  @override
  Stream<AppUser?> authStateChanges() => _auth.authStateChanges().map(
        (user) => user == null ? null : FirebaseAppUser(uid: user.uid),
      );

  /// Sign out the current user
  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  /// Check if the current user is an admin
  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // Check if the user's UID exists in the users-admin collection
      final adminDoc = await FirebaseFirestore.instance
          .collection('users-admin')
          .doc(user.uid)
          .get();

      return adminDoc.exists;
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      return false;
    }
  }

  @override
  AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;

    return FirebaseAppUser(uid: user.uid);
  }

  @override
  void init() {}

  @override
  Future<void> signIn() async {
    // firebase_ui_auth handles phone sign-in, so this can be empty
    // or redirect to the sign-in page
  }
}

@Riverpod(keepAlive: true)
FirebaseAuthRepository firebaseAuthRepository(Ref ref) {
  return FirebaseAuthRepository();
}
