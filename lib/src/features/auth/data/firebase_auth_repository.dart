import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_auth_repository.g.dart';

/// Service for handling Firebase authentication
/// This is separate from the AppUser domain which handles FHIR data access
class FirebaseAuthRepository {
  FirebaseAuthRepository() {
    _initializeAnonymousAuth();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if current user is anonymous
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? false;

  /// Get current user's UID (null if not authenticated)
  String? get uid => _auth.currentUser?.uid;

  /// Stream of Firebase auth state changes
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Initialize anonymous authentication when service is created
  void _initializeAnonymousAuth() {
    if (_auth.currentUser == null) {
      signInAnonymously();
    }
  }

  /// Sign in anonymously
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      debugPrint('Signed in anonymously: ${userCredential.user?.uid}');
      return userCredential.user;
    } catch (e) {
      debugPrint('Error signing in anonymously: $e');
      return null;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await signInAnonymously(); // Sign back in anonymously after sign out
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  /// Check if the current user is an admin
  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // Check if the user's UID exists in the admin-users collection
      final adminDoc = await FirebaseFirestore.instance
          .collection('admin-users')
          .doc(user.uid)
          .get();

      return adminDoc.exists;
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      return false;
    }
  }
}

@Riverpod(keepAlive: true)
FirebaseAuthRepository firebaseAuthRepository(Ref ref) {
  return FirebaseAuthRepository();
}
