import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:rxdart/rxdart.dart';

/// A fake authentication repository for the staging environment
/// that doesn't communicate with any real authentication services
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository();

  final _authState = BehaviorSubject<AppUser?>.seeded(null);
  bool _initialized = false;

  @override
  void init() {
    if (_initialized) return;
    _initialized = true;

    // Auto sign-in with a fake user on initialization
    // similar to anonymous auth but with a consistent fake email
    _authState.add(FakeAppUser(email: 'fake-user@navstemi.stage'));
    debugPrint('FakeAuthRepository initialized with fake user');
  }

  @override
  Stream<AppUser?> authStateChanges() => _authState.stream;

  @override
  AppUser? get currentUser => _authState.value;

  @override
  Future<void> signIn() async {
    // Always use the same fake user for sign-in
    _authState.add(FakeAppUser(email: 'fake-user@navstemi.stage'));
    debugPrint('Signed in with fake user');
  }

  @override
  Future<void> signOut() async {
    // Don't fully sign out in staging - just reset to a new fake user
    // This ensures we always have a user for testing
    _authState.add(FakeAppUser(email: 'fake-user@navstemi.stage'));
    debugPrint('Fake sign out (reset to fake user)');
  }
}

/// Provider for the fake authentication repository
final fakeAuthRepositoryProvider = Provider<AuthRepository>((ref) {
  return FakeAuthRepository()..init();
});
