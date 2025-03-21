import 'package:nav_stemi/nav_stemi.dart';

/// Original source: Andrea Bizzotto
/// https://github.com/bizz84/complete-flutter-course
///
class AuthRespository {
  AuthRespository();

  final _authState = InMemoryStore<AppUser?>(null);

  Stream<AppUser?> authStateChanges() => _authState.stream;

  AppUser? get currentUser => _authState.value;

  void dispose() => _authState.close();

  Future<void> signOut() async => _authState.value = null;

  Future<void> signIn() async {
    // TODO(FireJuun): Implement sign in
    // _authState.value = AppUser();
  }
}
