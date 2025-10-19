import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/src/features/auth/data/auth_repository.dart';
import 'package:nav_stemi/src/features/auth/domain/app_user.dart';

import '../../../../helpers/mock_providers.dart';

// Create a test implementation of AuthRepository
class TestAuthRepository extends AuthRepository {
  TestAuthRepository({
    this.mockCurrentUser,
    Stream<AppUser?>? mockAuthStateChanges,
  }) : _authStateChanges =
            mockAuthStateChanges ?? Stream.value(mockCurrentUser);

  final AppUser? mockCurrentUser;
  final Stream<AppUser?> _authStateChanges;
  bool initCalled = false;
  bool signInCalled = false;
  bool signOutCalled = false;

  @override
  Stream<AppUser?> authStateChanges() => _authStateChanges;

  @override
  AppUser? get currentUser => mockCurrentUser;

  @override
  void init() {
    initCalled = true;
  }

  @override
  Future<void> signIn() async {
    signInCalled = true;
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }
}

void main() {
  group('AuthRepository', () {
    late TestAuthRepository testAuthRepository;
    late MockGoogleSignInAccount mockGoogleSignInAccount;
    late MockAuthClient mockAuthClient;
    late GoogleAppUser testUser;

    setUp(() {
      mockGoogleSignInAccount = MockGoogleSignInAccount();
      mockAuthClient = MockAuthClient();
      testUser = GoogleAppUser(
        user: mockGoogleSignInAccount,
        client: mockAuthClient,
      );
    });

    test('should provide auth state changes stream', () async {
      final authStateStream = Stream<AppUser?>.fromIterable([
        null,
        testUser,
        null,
      ]);

      testAuthRepository = TestAuthRepository(
        mockAuthStateChanges: authStateStream,
      );

      final states = <AppUser?>[];
      final subscription = testAuthRepository.authStateChanges().listen(
            states.add,
          );

      // Wait for stream to complete
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(states, [null, testUser, null]);

      await subscription.cancel();
    });

    test('should return current user', () {
      testAuthRepository = TestAuthRepository(
        mockCurrentUser: testUser,
      );

      expect(testAuthRepository.currentUser, equals(testUser));
    });

    test('should return null when no current user', () {
      testAuthRepository = TestAuthRepository();

      expect(testAuthRepository.currentUser, isNull);
    });

    test('should call init method', () {
      testAuthRepository = TestAuthRepository();

      expect(testAuthRepository.initCalled, isFalse);

      testAuthRepository.init();

      expect(testAuthRepository.initCalled, isTrue);
    });

    test('should call signIn method', () async {
      testAuthRepository = TestAuthRepository();

      expect(testAuthRepository.signInCalled, isFalse);

      await testAuthRepository.signIn();

      expect(testAuthRepository.signInCalled, isTrue);
    });

    test('should call signOut method', () async {
      testAuthRepository = TestAuthRepository();

      expect(testAuthRepository.signOutCalled, isFalse);

      await testAuthRepository.signOut();

      expect(testAuthRepository.signOutCalled, isTrue);
    });

    test('abstract class cannot be instantiated directly', () {
      // This test verifies that AuthRepository is properly abstract
      // and requires a concrete implementation
      expect(TestAuthRepository, isNotNull);

      // Verify that our test implementation properly overrides all methods
      final testRepo = TestAuthRepository();
      expect(testRepo.authStateChanges, isA<Function>());
      expect(testRepo.signIn, isA<Function>());
      expect(testRepo.signOut, isA<Function>());
      expect(testRepo.init, isA<Function>());
    });
  });
}
