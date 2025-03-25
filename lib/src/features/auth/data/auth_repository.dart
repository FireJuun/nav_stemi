import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

/// Original source: Andrea Bizzotto
/// https://github.com/bizz84/complete-flutter-course
///
abstract class AuthRepository {
  const AuthRepository();

  Stream<AppUser?> authStateChanges() => throw UnimplementedError();
  AppUser? get currentUser => throw UnimplementedError();

  void init() => throw UnimplementedError();

  Future<void> signIn() async => throw UnimplementedError();
  Future<void> signOut() async => throw UnimplementedError();
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  throw UnimplementedError();
}

@Riverpod(keepAlive: true)
Stream<AppUser?> authStateChanges(Ref ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges();
}
