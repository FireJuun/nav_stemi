import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

// Mocks
class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

// Fakes
class FakeUri extends Fake implements Uri {}

class FakeBaseRequest extends Fake implements http.BaseRequest {}

void main() {
  late TestAuthRepository repository;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(FakeUri());
    registerFallbackValue(FakeBaseRequest());
  });

  setUp(() {
    repository = TestAuthRepository();
    mockHttpClient = MockHttpClient();
  });

  group('TestAuthRepository', () {
    group('init', () {
      test('should complete without error when env vars are empty', () async {
        // Since Env values are compile-time constants, we can't mock them
        // Just test that init doesn't throw
        await expectLater(repository.init(), completes);
      });
    });

    group('signIn', () {
      test('should complete without error', () async {
        // The signIn method requires valid service account credentials
        // For testing, we just verify it doesn't throw when called
        // In real usage, it would need valid env vars
        await expectLater(repository.signIn(), completes);
      });
    });

    group('signOut', () {
      test('should complete without error', () async {
        await expectLater(repository.signOut(), completes);
      });

      test('should be idempotent', () async {
        // Calling signOut multiple times should not throw
        await repository.signOut();
        await repository.signOut();
        await repository.signOut();
      });
    });

    group('authStateChanges', () {
      test('should emit initial null state', () async {
        final stream = repository.authStateChanges();

        // Use first instead of expecting the stream itself
        final firstValue = await stream.first;
        expect(firstValue, isNull);
      });

      test('should return a stream', () {
        final stream = repository.authStateChanges();
        expect(stream, isA<Stream<AppUser?>>());
      });
    });

    group('currentUser', () {
      test('should return null initially', () {
        expect(repository.currentUser, isNull);
      });
    });
  });

  group('ServiceAccountClient', () {
    late ServiceAccountClient client;
    const testEmail = 'test@service.account';
    const testPrivateKeyPEM = '''
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC7W8bA
-----END PRIVATE KEY-----''';

    setUp(() {
      client = ServiceAccountClient(
        serviceAccountEmail: testEmail,
        privateKeyBase64: base64Encode(utf8.encode(testPrivateKeyPEM)),
      );
    });

    group('private key decoding', () {
      test('should decode base64 encoded PEM key', () {
        final base64Key = base64Encode(utf8.encode(testPrivateKeyPEM));
        final client = ServiceAccountClient(
          serviceAccountEmail: testEmail,
          privateKeyBase64: base64Key,
        );

        expect(client.privateKey, equals(testPrivateKeyPEM));
      });

      test('should handle PEM key passed directly', () {
        final client = ServiceAccountClient(
          serviceAccountEmail: testEmail,
          privateKeyBase64: testPrivateKeyPEM,
        );

        expect(client.privateKey, equals(testPrivateKeyPEM));
      });

      test('should handle invalid base64', () {
        const invalidBase64 = 'not-valid-base64!@#';
        final client = ServiceAccountClient(
          serviceAccountEmail: testEmail,
          privateKeyBase64: invalidBase64,
        );

        // Should return the original string when decoding fails
        expect(client.privateKey, equals(invalidBase64));
      });
    });

    test('should store service account email', () {
      expect(client.serviceAccountEmail, equals(testEmail));
    });

    tearDown(() {
      client.close();
    });
  });

  group('testAuthRepositoryProvider', () {
    test('should provide TestAuthRepository instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repository = container.read(testAuthRepositoryProvider);

      expect(repository, isA<TestAuthRepository>());
    });

    test('should return same instance on multiple reads', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repository1 = container.read(testAuthRepositoryProvider);
      final repository2 = container.read(testAuthRepositoryProvider);

      expect(identical(repository1, repository2), isTrue);
    });
  });
}
