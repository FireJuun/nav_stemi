import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

// Mocks
class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockAuthClient extends Mock implements auth.AuthClient {}

class MockInMemoryStore extends Mock implements InMemoryStore<GoogleAppUser?> {}

// Fakes
class FakeGoogleSignInAccount extends Fake implements GoogleSignInAccount {}

void main() {
  late GoogleAuthRepository repository;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockAccount;
  late MockAuthClient mockAuthClient;

  setUpAll(() {
    registerFallbackValue(FakeGoogleSignInAccount());
  });

  setUp(() {
    mockGoogleSignIn = MockGoogleSignIn();
    mockAccount = MockGoogleSignInAccount();
    mockAuthClient = MockAuthClient();

    // Mock the static GoogleSignIn instance by creating repository with mocked dependencies
    // Note: In the actual implementation, GoogleSignIn is created as a static instance
    // For testing, we'll test the methods' behavior
    repository = GoogleAuthRepository();
  });

  group('GoogleAuthRepository', () {
    test('should return auth state stream', () {
      // Act
      final stream = repository.authStateChanges();

      // Assert
      expect(stream, isA<Stream<GoogleAppUser?>>());
    });

    test('should return current user', () {
      // Act
      final user = repository.currentUser;

      // Assert
      expect(user, isNull); // Initially null
    });

    test('init should set up user change listener', () async {
      // For integration testing, we'd need to mock the static GoogleSignIn instance
      // This test verifies the method exists and doesn't throw
      await expectLater(repository.init(), completes);
    });

    test('signIn method exists and handles exceptions', () async {
      // The signIn method catches and prints errors
      // We can verify it doesn't throw uncaught exceptions
      await expectLater(repository.signIn(), completes);
    });

    group('setAppUser', () {
      test('should not update if user is null', () async {
        // Act
        await repository.setAppUser(null);

        // Assert
        expect(repository.currentUser, isNull);
      });
    });

    group('signInSilently', () {
      test('should handle silent sign in', () async {
        // Verify the method exists and handles errors
        await expectLater(repository.signInSilently(), completes);
      });
    });
  });

  group('GoogleAppUser', () {
    test('should create with user and client', () {
      // Arrange & Act
      final appUser = GoogleAppUser(
        user: mockAccount,
        client: mockAuthClient,
      );

      // Assert
      expect(appUser.user, equals(mockAccount));
      expect(appUser.client, equals(mockAuthClient));
    });

    test('should be an AppUser', () {
      // Arrange & Act
      final appUser = GoogleAppUser(
        user: mockAccount,
        client: mockAuthClient,
      );

      // Assert
      expect(appUser, isA<AppUser>());
    });
  });
}
